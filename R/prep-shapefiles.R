# Load packages
require("rgdal")
require("rgeos")


# Set up the directories necessary for download.file()
setup_dir("data/")
setup_dir("data/shapes/")
setup_dir("data/shapes/regions/")
setup_dir("data/shapes/lads/")
setup_dir("data/shapes/lsoas/")


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

# Set CRS
proj4string(regs) <- CRS("+init=epsg:27700")
proj4string(lads) <- CRS("+init=epsg:27700")
proj4string(lsoa) <- CRS("+init=epsg:27700")


# # Separate regions and clip
# ## Clip regions
# reg_codes <- as.character(regs@data$code)
# reg      <- list()
# for(i in 1:length(reg_codes)){
#   tmp <- gIntersection(lads, regs[regs@data$code == reg_codes[i], ],
#                        byid = TRUE, drop_lower_td = TRUE)
#   row.names(tmp) <- as.character(gsub(paste0(" ", i-1), "", row.names(tmp)))
#   tmp <- SpatialPolygonsDataFrame(tmp, lads@data[row.names(tmp), ])
#   reg[[i]] <- tmp
# }
# rm(tmp, i)
#
# reg_f <- list()
# for (i in 1:length(reg)) {
#   tmp <- fortify(reg[[i]], region = "code")
#   tmp <- merge(tmp, reg[[i]], by.x = "id", by.y = "code")
#   reg_f[[i]] <- tmp
# }
# rm(tmp, i)
# rm(reg_codes, regs, lads)
#
# # Obtain eligible rural area data
# # Eligible rural areas lookup (table 4)
# eral <- read.csv("data/csco-eligible-rural-area-lsoa.csv",
#                  skip = 7, header = TRUE)
# eral <- eral[, c(4:5)]
# names(eral) <- c("name", "code")
#
# elsoa$CODE <- as.character(elsoa$CODE)
# eral$code  <- as.character(eral$code)
# era        <- elsoa[elsoa$CODE %in% eral$code == TRUE, ]
# rm(eral)
#
# # Most deprived quartile rural areas lookup (table 5)
# dral <- read.csv("data/eligible-deprived-rural-areas-25.csv",
#                  skip = 7, header = TRUE)
# dral <- dral[, 4:5]
# names(dral) <- c("name", "code")
#
# dral$code  <- as.character(dral$code)
# dra        <- elsoa[elsoa$CODE %in% dral$code == TRUE, ]
# rm(dral)
#
# # Eligible areas of low income lookup (table 1)
# alil <- read.csv("data/eligible-areas-low-income-eng.csv",
#                  skip = 7, header = TRUE)
# alil <- alil[, 4:5]
# names(alil) <- c("name", "code")
#
# alil$code <- as.character(alil$code)
# ali       <- elsoa[elsoa$CODE %in% alil$code == TRUE, ]
# rm(alil)
# rm(elsoa)
#
# # Food bank layer ====
# fbt <- read.csv("data/foodbanks.csv")
# fbm <- read.csv("data/foodbanks-matched.csv")
# fb <- merge(fbt, fbm, by = "match")
# rm(fbt, fbm)
# fb <- fb[fb$URINDEW10nov != 9, ] # 9 is Scotland/NI/Channel Is/IoM, see docs
# fb$Total[fb$Total == -99] <- NA
# # create projection for clipping
# coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
# proj4string(fb) <- CRS("+init=epsg:27700")
# fb <- spTransform(fb, CRSobj = CRS(proj4string(reg[[1]])))
