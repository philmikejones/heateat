require("rgdal")
require("rgeos")

# Set up the directories necessary for download.file()
heateat::setup_dirs("data/")
heateat::setup_dirs("data/shapes/")
heateat::setup_dirs("data/shapes/regions/")
heateat::setup_dirs("data/shapes/lads/")
heateat::setup_dirs("data/shapes/lsoas/")

# Download necessary shapefiles from census.ukdataservice.ac.uk
# Regions
if (!file.exists("data/shapes/regions.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_gor_2011.zip",
    destfile = "data/shapes/regions.zip"
  )
}

# LADs
if (!file.exists("data/shapes/lads.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011.zip",
    destfile = "data/shapes/lads.zip"
  )
}

# LSOAs
if (!file.exists("data/shapes/lsoas.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011.zip",
    destfile = "data/shapes/lsoas/"
  )
}

# Finally unzip the files...
if (!file.exists("data/shapes/regions/england_gor_2011.shp")) {
  unzip("data/shapes/regions.zip", exdir = "data/shapes/regions/")
}

if (!file.exists("data/shapes/lads/england_lad_2011.shp")) {
  unzip("data/shapes/lads.zip",    exdir = "data/shapes/lads/")
}

if (!file.exists("data/shapes/lsoas/england_lsoa_2011.shp")) {
  unzip("data/shapes/lsoas.zip",   exdir = "data/shapes/lsoas/")
}

# Load the shapefiles
regs <- readOGR(dsn = "data/shapes/regions", "england_gor_2011")
lads <- readOGR(dsn = "data/shapes/lads",    "england_lad_2011")
lsoa <- readOGR(dsn = "data/shapes/lsoas",   "england_lsoa_2011")
