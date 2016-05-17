# Packages ====
require("rgeos")
require("rgdal")
require("ggplot2")
require("maptools")


# Download boundary data ====
# create dirs for download.file()
if (dir.exists("shapes/") == FALSE) {
  dir.create("shapes/")
}

# # Regions
# download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_gor_2011.zip",
#          destfile = "shapes/regions.zip", method = "curl")
# unzip("shapes/regions.zip", exdir = "shapes/regions", overwrite = TRUE)
# 
# # LADs
# download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011.zip",
#               destfile = "shapes/lads.zip", method = "curl")
# unzip("shapes/lads.zip", exdir = "shapes/lads", overwrite = TRUE)
# 
# # LSOAs
# download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011.zip",
#               destfile = "shapes/lsoas.zip", method = "curl")
# unzip("shapes/lsoas.zip", exdir = "shapes/lsoas/", overwrite = TRUE)


# Map background layers ====
# Regions
ereg <- readOGR(dsn = "shapes/regions", "england_gor_2011")
proj4string(ereg) <- CRS("+init=epsg:27700")

# LADs
elad <- readOGR(dsn = "shapes/lads/", "england_lad_2011")
proj4string(elad) <- CRS("+init=epsg:27700")
row.names(elad) <- as.character(row.names(elad))

# Clip regions
reg_codes <- as.character(ereg@data$code)
reg      <- list()
for(i in 1:length(reg_codes)){
  tmp <- gIntersection(elad, ereg[ereg@data$code == reg_codes[i], ],
                       byid = TRUE, drop_lower_td = TRUE)
  row.names(tmp) <- as.character(gsub(paste0(" ", i-1), "", row.names(tmp)))
  tmp <- SpatialPolygonsDataFrame(tmp, elad@data[row.names(tmp), ])
  reg[[i]] <- tmp
}
rm(tmp, i)

reg_f <- list()
for (i in 1:length(reg)) {
  tmp <- fortify(reg[[i]], region = "code")
  tmp <- merge(tmp, reg[[i]], by.x = "id", by.y = "code")
  reg_f[[i]] <- tmp
}
rm(tmp, i)
rm(reg_codes, ereg, elad)


# Fuel poverty layers ====
# LSOAs
elsoa <- readOGR(dsn = "shapes/lsoas", "england_lsoa_2011")
proj4string(elsoa) <- CRS("+init=epsg:27700")

# Eligible rural areas lookup (table 4)
eral <- read.csv("data/csco-eligible-rural-area-lsoa.csv",
                 skip = 7, header = TRUE)
eral <- eral[, c(4:5)]
names(eral) <- c("name", "code")

elsoa$CODE <- as.character(elsoa$CODE)
eral$code  <- as.character(eral$code)
era        <- elsoa[elsoa$CODE %in% eral$code == TRUE, ]
rm(eral)

# Most deprived quartile rural areas lookup (table 5)
dral <- read.csv("data/eligible-deprived-rural-areas-25.csv", 
                 skip = 7, header = TRUE)
dral <- dral[, 4:5]
names(dral) <- c("name", "code")

dral$code  <- as.character(dral$code)
dra        <- elsoa[elsoa$CODE %in% dral$code == TRUE, ]
rm(dral)

# Eligible areas of low income lookup (table 1)
alil <- read.csv("data/eligible-areas-low-income-eng.csv",
                 skip = 7, header = TRUE)
alil <- alil[, 4:5]
names(alil) <- c("name", "code")

alil$code <- as.character(alil$code)
ali       <- elsoa[elsoa$CODE %in% alil$code == TRUE, ]
rm(alil)
rm(elsoa)


# Food bank layer ====
fbt <- read.csv("data/foodbanks.csv")
fbm <- read.csv("data/foodbanks-matched.csv")
fb <- merge(fbt, fbm, by = "match")
rm(fbt, fbm)
fb <- fb[fb$URINDEW10nov != 9, ] # 9 is Scotland/NI/Channel Is/IoM, see docs
fb$Total[fb$Total == -99] <- NA
# create projection for clipping
coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
proj4string(fb) <- CRS("+init=epsg:27700")
fb <- spTransform(fb, CRSobj = CRS(proj4string(reg[[1]])))


# # Final maps ====
# Themes
map <- theme(line = element_blank(), 
             text = element_blank(), 
             title = element_blank(),
             panel.background = element_rect(fill = "transparent"),
             legend.position = "none")
mapl <- theme(line = element_blank(),
              axis.text = element_blank(),
              axis.title = element_blank(),
              panel.background = element_rect(fill = "transparent"))

# Paper sizes
port <- c(29.7/2.54, 42/2.54)
land <- c(42/2.54, 29.7/2.54)

for(i in 1:length(regf)){
  erac <- era[reg[[i]], ]
  eraf <- fortify(erac, region = "CODE")
  eraf <- merge(eraf, erac, by.x = "id", by.y = "CODE")
  
  alic <- ali[reg[[i]], ]
  alif <- fortify(alic, region = "CODE")
  alif <- merge(alif, alic, by.x = "id", by.y = "CODE")
  
  drac <- dra[reg[[i]], ]
  draf <- fortify(drac, region = "CODE")
  draf <- merge(draf, drac, by.x = "id", by.y = "CODE")
  
  fbc <- fb[reg[[i]], ]
  fbc@data <- merge(fbc@data, fbc, by = "match")
  
  ggplot() +
    geom_polygon(data = eraf, aes(long, lat, group = group,
                                  fill = "CSCO eligible rural area"), 
                 colour = "dark grey") +
    geom_polygon(data = draf, aes(long, lat, group = group,
                                  fill = "Deprived rural area"),
                 colour = "light grey") +
    geom_polygon(data = alif, aes(long, lat, group = group, 
                                  fill = "Eligible low-income area")
                 , colour = "light grey") +
    geom_polygon(data = regf[[i]], aes(long, lat, group = group),
                 fill = "transparent", colour = "black") +
    geom_point(data = fbc@data, aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                               colour = Total.x, size = 4)) +
    scale_size(guide = FALSE) +  # remove size legend
    scale_fill_manual(values = c("CSCO eligible rural area" = "#c7e9c0",
                                 "Deprived rural area"      = "#238b45",
                                 "Eligible low-income area" = "#6baed6")) +
    guides(fill = guide_legend(title = NULL)) +  # remove fill legends title
    scale_colour_gradient(low = "#fdae6b", high = "#a63603", na.value = "grey",
                        name = "Total Clients") +
    annotation_raster(ccn, ymin = (min(regf[[i]]$long)),
                           ymax = (max(regf[[i]]$long)),
                           xmin = (min(regf[[i]]$lat)),
                           xmax = (min(regf[[i]]$lat))) +
    mapl + coord_equal()
  
  ggsave(filename = paste0("region", i, ".pdf"), path = "maps/",
                           width = land[1], height = land[2])
}
