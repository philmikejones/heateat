# DEPENDS on maptools and rgeos being loaded into namespace for fortify()
# Import pipe
#' @importFrom magrittr %>%

# Set up the directories necessary for download.file()
dir.create("data/shapes/lads/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/shapes/lsoa/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/raw/",         recursive = TRUE, showWarnings = FALSE)

# Download necessary shapefiles from census.ukdataservice.ac.uk
# LADs
if (!file.exists("data/shapes/lads.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen.zip",
    mode = "wb", method = "wget", destfile = "data/shapes/lads.zip"
  )
}

# LSOAs
if (!file.exists("data/shapes/lsoas.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011_gen.zip",
    destfile = "data/shapes/lsoas.zip", method = "wget", mode = "wb"
  )
}

# Finally unzip the files...
if (!file.exists("data/shapes/lads/england_lad_2011_gen.shp")) {
  unzip("data/shapes/lads.zip",    exdir = "data/shapes/lads/")
}

if (!file.exists("data/shapes/lsoas/england_lsoa_2011_gen.shp")) {
  unzip("data/shapes/lsoas.zip",   exdir = "data/shapes/lsoa/")
}


# Load LADs
lads <- rgdal::readOGR(dsn = "data/shapes/lads", "england_lad_2011_gen")
lads@data$label <- as.character(lads@data$label)

# Filter South Yorkshire
lads <- lads[lads@data$name == "Barnsley"  |
             lads@data$name == "Doncaster" |
             lads@data$name == "Rotherham" |
             lads@data$name == "Sheffield", ]

# LSOAs
lsoa <- rgdal::readOGR(dsn = "data/shapes/lsoa", "england_lsoa_2011_gen")
lsoa@data$code <- as.character(lsoa@data$code)

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

if (!(nrow(fp) == nrow(lsoa@data))) {
  warning("LSOA row numbers do not match")
  stop()
}

# # Join to shapefile
# lsoa@data <- dplyr::inner_join(lsoa@data, fp, by = "code")
#
# # Fortify shapefiles
# regs_f <- ggplot2::fortify(regs, region = "label")
# regs_f <- dplyr::inner_join(regs_f, regs@data, by = c("id" = "label"))
# save(regs_f, file = "data/regions.RData")
#
# lads_f <- ggplot2::fortify(lads, region = "label")
# lads_f <- dplyr::inner_join(lads_f, lads@data, by = c("id" = "label"))
# save(lads_f, file = "data/lads.RData")
#
# lsoa_f <- ggplot2::fortify(lsoa, region = "code")
# lsoa_f <- dplyr::inner_join(lsoa_f, lsoa@data, by = c("id" = "code"))
# save(lsoa_f, file = "data/lsoa.RData")
