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

eer <- ereg[ereg$CODE == "E12000006", ]
lr  <- ereg[ereg$CODE == "E12000007", ]
nwr <- ereg[ereg$CODE == "E12000002", ]
ner <- ereg[ereg$CODE == "E12000001", ]
emr <- ereg[ereg$CODE == "E12000004", ]
yhr <- ereg[ereg$CODE == "E12000003", ]
swr <- ereg[ereg$CODE == "E12000009", ]
wmr <- ereg[ereg$CODE == "E12000005", ]
ser <- ereg[ereg$CODE == "E12000008", ]

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
row.names(elad) <- as.character(1:length(elad))

# LADs by region
# subset method
eel <- elad[eer, ]
plot(eer); plot(eel, add = T)

# gIntersection/gIntersects method
eel <- gIntersection(elad, eer, byid = T, drop_not_poly = T)
row.names(eel) <- as.character(gsub(" 0", "", row.names(eel)))
eel <- SpatialPolygonsDataFrame(eel, elad@data[row.names(eel), ])

eelf <- fortify(eel, region = "code")
eelf <- merge(eelf, eel, by.x = "id", by.y = "code")
ggplot() + 
  geom_polygon(data = eelf, aes(long, lat, group = group),
               fill = "transparent", colour = "black") +
  coord_equal()



# extracts IDs clipped as vector
IDs.SpatialPolygonsDataFrame <- function(x,...) {
  vapply(slot(x, "polygons"), function(x) slot(x, "ID"), "")
}
# Function courtesy of gsk3 (https://github.com/gsk3)
# Source: https://github.com/gsk3/taRifx.geo/blob/2fc3fdd35713a028bef8eefa4bef9fdc446b1b4c/R/R-GIS.R#L518

eeu <- gIntersection(elad, eer, byid = T, drop_not_poly = T)
ids <- as.numeric(gsub(" 0", "", 
                       as.character(IDs.SpatialPolygonsDataFrame(eeu))))
SpatialPolygonsDataFrame(eeu, elad@data[ids])




# Fuel poverty layer ====
# LSOAs
elsoa <- readOGR(dsn = "shapes/englsoa/", 
                "england_lsoa_2011Polygon")
proj4string(elsoa) <- CRS("+init=epsg:27700")



# # Final maps ====
