# Require maptools for fortify()
require("maptools")

# Set up the directories necessary for download.file()
dir.create("data/shapes/regs/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/shapes/lads/", recursive = TRUE, showWarnings = FALSE)
dir.create("data/shapes/lsoa/", recursive = TRUE, showWarnings = FALSE)

# Download necessary shapefiles from census.ukdataservice.ac.uk
# Regions
if (!file.exists("data/shapes/regions.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    url = "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_gor_2011_gen.zip",
    destfile = "data/shapes/regions.zip", mode = "wb", method = "wget"
  )
}

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
if (!file.exists("data/shapes/regs/england_gor_2011_gen.shp")) {
  unzip("data/shapes/regions.zip", exdir = "data/shapes/regs/")
}

if (!file.exists("data/shapes/lads/england_lad_2011_gen.shp")) {
  unzip("data/shapes/lads.zip",    exdir = "data/shapes/lads/")
}

if (!file.exists("data/shapes/lsoas/england_lsoa_2011_gen.shp")) {
  unzip("data/shapes/lsoas.zip",   exdir = "data/shapes/lsoa/")
}


# Load regions
regs   <- rgdal::readOGR(dsn = "data/shapes/regs", "england_gor_2011_gen")

# Load LADs
lads <- rgdal::readOGR(dsn = "data/shapes/lads", "england_lad_2011_gen")

# LSOAs
lsoa <- rgdal::readOGR(dsn = "data/shapes/lsoa", "england_lsoa_2011_gen")


# Load fuel poverty data
dir.create("data/raw/")
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

# Join to shapefile
lsoa@data$code <- as.character(lsoa@data$code)
lsoa@data <- dplyr::inner_join(lsoa@data, fp, by = "code")









# #
# # # Food bank layer ====
# # fbt <- read.csv("data/foodbanks.csv")
# # fbm <- read.csv("data/foodbanks-matched.csv")
# # fb <- merge(fbt, fbm, by = "match")
# # rm(fbt, fbm)
# # fb <- fb[fb$URINDEW10nov != 9, ] # 9 is Scotland/NI/Channel Is/IoM, see docs
# # fb$Total[fb$Total == -99] <- NA
# # # create projection for clipping
# # coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
# # proj4string(fb) <- CRS("+init=epsg:27700")
# # fb <- spTransform(fb, CRSobj = CRS(proj4string(reg[[1]])))
