# Set up cores
cores <- parallel::detectCores()


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
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_gor_2011_gen.zip",
    method = "wget", destfile = "data/shapes/regions.zip"
  )
}

# LADs
if (!file.exists("data/shapes/lads.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011_gen.zip",
    method = "wget", destfile = "data/shapes/lads.zip"
  )
}

# LSOAs
if (!file.exists("data/shapes/lsoas.zip")) {
  message("Fetching shapefile(s)...")
  download.file(
    "https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011_gen.zip",
    method = "wget", destfile = "data/shapes/lsoas.zip"
  )
}

# Finally unzip the files...
if (!file.exists("data/shapes/regions/england_gor_2011_gen.shp")) {
  unzip("data/shapes/regions.zip", exdir = "data/shapes/regions/")
}

if (!file.exists("data/shapes/lads/england_lad_2011_gen.shp")) {
  unzip("data/shapes/lads.zip",    exdir = "data/shapes/lads/")
}

if (!file.exists("data/shapes/lsoas/england_lsoa_2011_gen.shp")) {
  unzip("data/shapes/lsoas.zip",   exdir = "data/shapes/lsoas/")
}


# Load regions
regions <- rgdal::readOGR(dsn = "data/shapes/regions", "england_gor_2011_gen")

# Filter each region
regions_list <- list()
for (i in 1:nrow(regions@data)) {
  regions_list[[i]] <- regions[i, ]
}


# Clip LADs
lads <- rgdal::readOGR(dsn = "data/shapes/lads", "england_lad_2011_gen")
lads_list <- list()

# Subset first; it's more resource-efficient than gIntersection()
lad_east_e <- lads[reg_east_e, ]
lad_london <- lads[reg_london, ]
lad_n_west <- lads[reg_n_west, ]
lad_n_east <- lads[reg_n_east, ]
lad_east_m <- lads[reg_east_m, ]
lad_york_h <- lads[reg_york_h, ]
lad_s_west <- lads[reg_s_west, ]
lad_west_m <- lads[reg_west_m, ]
lad_s_east <- lads[reg_s_east, ]

lad_east_e <- rgeos::gIntersection(lad_east_e, reg_east_e, byid = TRUE)
lad_london <- rgeos::gIntersection(lad_london, reg_london, byid = TRUE)
lad_n_west <- rgeos::gIntersection(lad_n_west, reg_n_west, byid = TRUE)
lad_n_east <- rgeos::gIntersection(lad_n_east, reg_n_east, byid = TRUE)
lad_east_m <- rgeos::gIntersection(lad_east_m, reg_east_m, byid = TRUE)
lad_york_h <- rgeos::gIntersection(lad_york_h, reg_york_h, byid = TRUE)
lad_s_west <- rgeos::gIntersection(lad_s_west, reg_s_west, byid = TRUE)
lad_west_m <- rgeos::gIntersection(lad_west_m, reg_west_m, byid = TRUE)
lad_s_east <- rgeos::gIntersection(lad_s_east, reg_s_east, byid = TRUE)



regions_lads <- parallel::mclapply(regions_lads, function(x)
  rgeos::gIntersection(x, spgeom2 = regs, byid = TRUE)
)


# LSOAs
lsoa <- rgdal::readOGR(dsn = "data/shapes/lsoas", "england_lsoa_2011_gen")

# Split LSOAs into regions
# Subset first because it's efficient
regions_lsoa <- list(
  easte_lsoa = lsoa[regions[["easte"]], ],
  lond_lsoa  = lsoa[regions[["lond"]], ],
  nortw_lsoa = lsoa[regions[["nortw"]], ],
  norte_lsoa = lsoa[regions[["norte"]], ],
  eastm_lsoa = lsoa[regions[["eastm"]], ],
  yorks_lsoa = lsoa[regions[["yorks"]], ],
  soutw_lsoa = lsoa[regions[["soutw"]], ],
  westm_lsoa = lsoa[regions[["westm"]], ],
  soute_lsoa = lsoa[regions[["soute"]], ]
)
regions_lsoa <- parallel::mclapply(regions_lsoa, function(x)
  rgeos::gIntersection(x, spgeom2 = regs, byid = TRUE)
)



# Load fuel poverty data
setup_dir("data/raw/")
if (!file.exists("data/raw/fuel-poverty.xlsx")) {
  message("Obtaining fuel poverty data...")
  download.file("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/485161/2013_Sub-regional_tables.xlsx",
                destfile = "data/raw/fuel-poverty.xlsx")
}
fp <- readxl::read_excel("data/raw/fuel-poverty.xlsx",
                         sheet = "Table 3", skip = 1, col_names = TRUE)
fp <- dplyr::select(fp, 1, 6, 7, 8)
colnames(fp) <- c("code", "num_hh", "num_fph", "per_fph")
fp <- na.omit(fp)

# Join to shapefile
lsoa@data$code <- as.character(lsoa@data$code)
lsoa@data <- dplyr::inner_join(lsoa@data, fp, by = "code")


# proj4string(regs) <- CRS("+init=epsg:27700")
# proj4string(lads) <- CRS("+init=epsg:27700")
# proj4string(lsoa) <- CRS("+init=epsg:27700")
#
# regions_lsoa <- lapply(regions, gIntersection, spgeom2 = lsoa, byid = TRUE)
#
#
#
# # reg_f <- list()
# # for (i in 1:length(reg)) {
# #   tmp <- fortify(reg[[i]], region = "code")
# #   tmp <- merge(tmp, reg[[i]], by.x = "id", by.y = "code")
# #   reg_f[[i]] <- tmp
# # }
# # rm(tmp, i)
# # rm(reg_codes, regs, lads)
# #
# # # Obtain eligible rural area data
# # # Eligible rural areas lookup (table 4)
# # eral <- read.csv("data/csco-eligible-rural-area-lsoa.csv",
# #                  skip = 7, header = TRUE)
# # eral <- eral[, c(4:5)]
# # names(eral) <- c("name", "code")
# #
# # elsoa$CODE <- as.character(elsoa$CODE)
# # eral$code  <- as.character(eral$code)
# # era        <- elsoa[elsoa$CODE %in% eral$code == TRUE, ]
# # rm(eral)
# #
# # # Most deprived quartile rural areas lookup (table 5)
# # dral <- read.csv("data/eligible-deprived-rural-areas-25.csv",
# #                  skip = 7, header = TRUE)
# # dral <- dral[, 4:5]
# # names(dral) <- c("name", "code")
# #
# # dral$code  <- as.character(dral$code)
# # dra        <- elsoa[elsoa$CODE %in% dral$code == TRUE, ]
# # rm(dral)
# #
# # # Eligible areas of low income lookup (table 1)
# # alil <- read.csv("data/eligible-areas-low-income-eng.csv",
# #                  skip = 7, header = TRUE)
# # alil <- alil[, 4:5]
# # names(alil) <- c("name", "code")
# #
# # alil$code <- as.character(alil$code)
# # ali       <- elsoa[elsoa$CODE %in% alil$code == TRUE, ]
# # rm(alil)
# # rm(elsoa)
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
