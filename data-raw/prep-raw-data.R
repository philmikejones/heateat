# Set up the directories necessary for download.file()
dir.create("data/shapes/lads/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/shapes/lsoa/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/raw/",         recursive = TRUE, showWarnings = FALSE)


# Download necessary shapefiles from census.ukdataservice.ac.uk
if (!file.exists("data-raw/lads.zip")) {
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011.zip",
    mode = "wb", method = "wget", destfile = "data-raw/lads.zip"
  )
}

if (!file.exists("data-raw/lsoas.zip")) {
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011.zip",
    destfile = "data-raw/lsoas.zip", method = "wget", mode = "wb"
  )
}


# Unzip
unzip("data-raw/lads.zip", exdir = "data-raw/lads/")
unzip("data-raw/lsoas.zip",   exdir = "data-raw/lsoa/")


# Load shapefiles
lads <- rgdal::readOGR(dsn = "data/shapes/lads", "england_lad_2011")
lads@data$label <- as.character(lads@data$label)

# Filter South Yorkshire
lads <- lads[lads@data$name == "Barnsley"  |
               lads@data$name == "Doncaster" |
               lads@data$name == "Rotherham" |
               lads@data$name == "Sheffield", ]

lsoa <- rgdal::readOGR(dsn = "data/shapes/lsoa", "england_lsoa_2011")
lsoa@data$code <- as.character(lsoa@data$code)
lsoa_data <- lsoa@data

lsoa <- lsoa[lads, ]
lsoa <- rgeos::gIntersection(lads, lsoa, byid = TRUE, drop_lower_td = TRUE)

row.names(lsoa) <- gsub("9 ",   "", row.names(lsoa))
row.names(lsoa) <- gsub("214 ", "", row.names(lsoa))
row.names(lsoa) <- gsub("297 ", "", row.names(lsoa))
row.names(lsoa) <- gsub("320 ", "", row.names(lsoa))

lsoa <- sp::SpatialPolygonsDataFrame(lsoa,
                                     lsoa_data[row.names(lsoa_data) %in% row.names(lsoa), ])
lsoa@data$name <- as.character(lsoa@data$name)

conds <- all(grepl("Barnsley",  lsoa@data$name) |
             grepl("Doncaster", lsoa@data$name) |
             grepl("Rotherham", lsoa@data$name) |
             grepl("Sheffield", lsoa@data$name))

if (!conds) {
  warning("LSOA not joined correctly (LSOA not in South Yorkshire present)")
  stop()
}


# Load fuel poverty data
if (!file.exists("data/raw/fuel-poverty.xlsx")) {
  message("Obtaining fuel poverty data...")
  download.file("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/485161/2013_Sub-regional_tables.xlsx",
                destfile = "data/raw/fuel-poverty.xlsx")
}

fp <- readxl::read_excel("data/raw/fuel-poverty.xlsx",
                         sheet = "Table 3", skip = 1, col_names = TRUE)
fp <- dplyr::select(fp, 1, 6, 7, 8)
fp <- na.omit(fp)
colnames(fp) <- c("code", "num_hh", "num_fph", "per_fph")

if (!(nrow(fp) == nrow(lsoa_data))) {
  warning("LSOA row numbers do not match")
  stop()
}
rm(lsoa_data)


# Join
lsoa@data <- dplyr::inner_join(lsoa@data, fp, by = "code")


# Fortify shapefiles
lads_f <- fortify(lads, region = "label")
lads_f <- dplyr::inner_join(lads_f, lads@data, by = c("id" = "label"))

lsoa_f <- fortify(lsoa, region = "code")
lsoa_f <- dplyr::inner_join(lsoa_f, lsoa@data, by = c("id" = "code"))

# Export .RData files
save(lads_f, file = "data/lads.RData")
save(lsoa_f, file = "data/lsoa.RData")
