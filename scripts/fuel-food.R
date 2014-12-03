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
eregf <- fortify(ereg, region = "CODE")
eregf <- merge(eregf, ereg, by.x = "id", by.y = "CODE")
eladf <- fortify(elad, region = "code")
eladf <- merge(eladf, elad, by.x = "id", by.y = "code")
ggplot() +
  geom_polygon(data = eladf, aes(x = long, y = lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = eregf, aes(x = long, y = lat, group = group),
               fill = "transparent", colour = "dark grey") +
  map + coord_equal()
