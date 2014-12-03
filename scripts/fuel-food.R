# Libraries ====
require("maptools")
require("rgeos")
require("rgdal")
require("scales")
require("deldir")  # for voronoi polygons
require("ggplot2")



# Themes ====
map <- theme(line = element_blank(), 
             text = element_blank(), 
             title = element_blank(),
             panel.background = element_rect(fill = "transparent"),
             legend.position = "none")
mapl <- theme(line = element_blank(),
              axis.text = element_blank(),
              axis.title = element_blank(),
              panel.background = element_rect(fill = "transparent"))



# Paper sizes ====
port <- c(29.7/2.54, 42/2.54)
land <- c(42/2.54, 29.7/2.54)



# Map background layers ====
# Regions
ereg <- readOGR(dsn = "shapes/ewregions/",
               "England_gor_2011")
proj4string(ereg) <- CRS("+init=epsg:27700")
#   CODE                          NAME
# 0 E12000006          East of England
# 1 E12000007                   London
# 2 E12000002               North West
# 3 E12000001               North East
# 4 E12000004            East Midlands
# 5 E12000003 Yorkshire and The Humber
# 6 E12000009               South West
# 7 E12000005            West Midlands
# 8 E12000008               South East

# LADs
elad <- readOGR(dsn = "shapes/englandLADs/", 
                "england_lad_2011Polygon")
proj4string(elad) <- CRS("+init=epsg:27700")

# region/LAD lookup from https://geoportal.statistics.gov.uk/geoportal/catalog/search/resource/details.page?uuid={B6A77A55-DB44-4C3C-901F-82742CB6A54B}
unzip(zipfile = "data/Countries_(2012)_to_government_office_regions_(2010)_to_counties_(2012)_to_local_authority_districts_(2012)_to_wards_(2012)_UK_lookup.zip",
      files = "CTRY12_GOR10_CTY12_LAD12_WD12_UK_LU.csv", exdir = "data/")
rllook <- read.csv("data/CTRY12_GOR10_CTY12_LAD12_WD12_UK_LU.csv")



# Fuel poverty layer ====
# LSOAs
elsoa <- readOGR(dsn = "shapes/englsoa/", 
                "england_lsoa_2011Polygon")
proj4string(elsoa) <- CRS("+init=epsg:27700")



# # Food bank layer ====
# fbt <- read.csv("data/foodbanks.csv")
# fbm <- read.csv("data/foodbanks-matched.csv")
# fb  <- merge(fbt, fbm, by = "match")
# rm(fbt, fbm)
# fb <- fb[fb$URINDEW10nov != 9, ]  # 9 is Scotland/NI/Channel Is/IoM, see docs
# fb$Total[fb$Total == -99] <- NA
# # create projection for clipping
# coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
# proj4string(fb) <- CRS("+init=epsg:27700")
# fb <- spTransform(fb, CRSobj = CRS(proj4string(reg)))



# # Final maps ====
yhr  <- ereg[ereg$CODE == "E12000003", ]
yhrf <- fortify(yhr, region = "CODE")
yhrf <- merge(yhrf, yhr, by.x = "id", by.y = "CODE")
yhl  <- gIntersection(yhr, yhl, byid = T, drop_not_poly = T)
yhl  <- SpatialPolygonsDataFrame(yhl, elad)
yhlf <- fortify(yhl, region = "")
head(elad@data)

ggplot() +
  geom_polygon(data = yhlf, aes(x = long, y = lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_polygon(data = yhrf, aes(x = long, y = lat, group = group),
               fill = "transparent", colour = "light grey") +
  map + coord_equal()
