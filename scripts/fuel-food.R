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
lor <- ereg[ereg$CODE == "E12000007", ]
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

eerf <- fortify(eer, region = "CODE")
eerf <- merge(eerf, eer, by.x = "id", by.y = "CODE")
lorf <- fortify(lor, region = "CODE")
lorf <- merge(lorf, lor, by.x = "id", by.y = "CODE")
nwrf <- fortify(nwr, region = "CODE")
nwrf <- merge(nwrf, nwr, by.x = "id", by.y = "CODE")
nerf <- fortify(ner, region = "CODE")
nerf <- merge(nerf, ner, by.x = "id", by.y = "CODE")
emrf <- fortify(emr, region = "CODE")
emrf <- merge(emrf, emr, by.x = "id", by.y = "CODE")
yhrf <- fortify(yhr, region = "CODE")
yhrf <- merge(yhrf, yhr, by.x = "id", by.y = "CODE")
swrf <- fortify(swr, region = "CODE")
swrf <- merge(swrf, swr, by.x = "id", by.y = "CODE")
wmrf <- fortify(wmr, region = "CODE")
wmrf <- merge(wmrf, wmr, by.x = "id", by.y = "CODE")
serf <- fortify(ser, region = "CODE")
serf <- merge(serf, ser, by.x = "id", by.y = "CODE")



# LADs
elad <- readOGR(dsn = "shapes/englandLADs/", 
                "england_lad_2011Polygon")
proj4string(elad) <- CRS("+init=epsg:27700")
row.names(elad) <- as.character(1:length(elad))

# LADs by region
# gIntersection/gIntersects method
# 0 E12000006          East of England
eel <- gIntersection(elad, eer, byid = T, drop_not_poly = T)
row.names(eel) <- as.character(gsub(" 0", "", row.names(eel)))
eel <- SpatialPolygonsDataFrame(eel, elad@data[row.names(eel), ])
eelf <- fortify(eel, region = "code")
eelf <- merge(eelf, eel, by.x = "id", by.y = "code")

# 1 E12000007                   London
lol <- gIntersection(elad, lor, byid = T, drop_not_poly = T)
row.names(lol) <- as.character(gsub(" 1", "", row.names(lol)))
lol <- SpatialPolygonsDataFrame(lol, elad@data[row.names(lol), ])
lolf <- fortify(lol, region = "code")
lolf <- merge(lolf, lol, by.x = "id", by.y = "code")

# 2 E12000002               North West
nwl <- gIntersection(elad, nwr, byid = T, drop_not_poly = T)
row.names(nwl) <- as.character(gsub(" 2", "", row.names(nwl)))
nwl <- SpatialPolygonsDataFrame(nwl, elad@data[row.names(nwl), ])
nwlf <- fortify(nwl, region = "code")
nwlf <- merge(nwlf, nwl, by.x = "id", by.y = "code")

# 3 E12000001               North East
nel <- gIntersection(elad, ner, byid = T, drop_not_poly = T)
row.names(nel) <- as.character(gsub(" 3", "", row.names(nel)))
nel <- SpatialPolygonsDataFrame(nel, elad@data[row.names(nel), ])
nelf <- fortify(nel, region = "code")
nelf <- merge(nelf, nel, by.x = "id", by.y = "code")

# 4 E12000004            East Midlands
eml <- gIntersection(elad, emr, byid = T, drop_not_poly = T)
row.names(eml) <- as.character(gsub(" 4", "", row.names(eml)))
eml <- SpatialPolygonsDataFrame(eml, elad@data[row.names(eml), ])
emlf <- fortify(eml, region = "code")
emlf <- merge(emlf, eml, by.x = "id", by.y = "code")

# 5 E12000003 Yorkshire and The Humber
yhl <- gIntersection(elad, yhr, byid = T, drop_not_poly = T)
row.names(yhl) <- as.character(gsub(" 5", "", row.names(yhl)))
yhl <- SpatialPolygonsDataFrame(yhl, elad@data[row.names(yhl), ])
yhlf <- fortify(yhl, region = "code")
yhlf <- merge(yhlf, yhl, by.x = "id", by.y = "code")

# 6 E12000009               South West
swl <- gIntersection(elad, swr, byid = T, drop_not_poly = T)
row.names(swl) <- as.character(gsub(" 6", "", row.names(swl)))
swl <- SpatialPolygonsDataFrame(swl, elad@data[row.names(swl), ])
swlf <- fortify(swl, region = "code")
swlf <- merge(swlf, swl, by.x = "id", by.y = "code")

# 7 E12000005            West Midlands
wml <- gIntersection(elad, wmr, byid = T, drop_not_poly = T)
row.names(wml) <- as.character(gsub(" 7", "", row.names(wml)))
wml <- SpatialPolygonsDataFrame(wml, elad@data[row.names(wml), ])
wmlf <- fortify(wml, region = "code")
wmlf <- merge(wmlf, wml, by.x = "id", by.y = "code")

# 8 E12000008               South East
swl <- gIntersection(elad, swr, byid = T, drop_not_poly = T)
row.names(swl) <- as.character(gsub(" 8", "", row.names(swl)))
swl <- SpatialPolygonsDataFrame(swl, elad@data[row.names(swl), ])
swlf <- fortify(swl, region = "code")
swlf <- merge(swlf, swl, by.x = "id", by.y = "code")



# Fuel poverty layer ====
# LSOAs
elsoa <- readOGR(dsn = "shapes/englsoa/", 
                "england_lsoa_2011Polygon")
proj4string(elsoa) <- CRS("+init=epsg:27700")

eral <- read.csv("data/csco-eligible-rural-area-lsoa.csv", skip = 7, header = T)
eral <- eral[4:5]
names(eral) <- c("name", "code")

elsoa$code <- as.character(elsoa$code)
eral$code  <- as.character(eral$code)
elsoa$era  <- elsoa$code %in% eral$code
elsoa      <- elsoa[elsoa$era == T, ]

edra <- read.csv("data/eligible-deprived-rural-areas-25.csv", 
                 skip = 7, header = T)
edra <- edra[, 4:5]
names(edra) <- c("name", "code")

elsoa$code <- as.character(elsoa$code)
edra$code  <- as.character(edra$code)
elsoa$edra <- elsoa$code %in% edra$code
elsoa      <- elsoa[elsoa$edra == T, ]



# # Final maps ====
# Yorkshire and The Humber
soaclip <- elsoa[yhr, ]
soaclipf <- fortify(soaclip, region = "code")
soaclipf <- merge(soaclipf, soaclip, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = soaclipf, aes(long, lat, group = group),
               fill = "orange", colour = "dark grey") +
  geom_polygon(data = yhlf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = yhrf, aes(long, lat, group = group),
               fill = "transparent", colour = "black") +
  map + coord_equal()
