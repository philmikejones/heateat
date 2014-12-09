# Libraries ====
require("maptools")
require("rgeos")
require("rgdal")
require("scales")
require("deldir")  # for voronoi polygons
require("ggplot2")



# Map background layers ====
# Regions
ereg <- readOGR(dsn = "shapes/ewregions/",
               "England_gor_2011")
proj4string(ereg) <- CRS("+init=epsg:27700")

# LADs
elad <- readOGR(dsn = "shapes/englandLADs/", 
                "england_lad_2011Polygon")
proj4string(elad) <- CRS("+init=epsg:27700")
row.names(elad) <- as.character(1:length(elad))



# Clip regions ====
regCodes <- as.character(ereg$CODE)
reg      <- list()
for(i in 1:length(regCodes)){
  tmp <- gIntersection(elad, ereg[ereg$CODE == regCodes[i], ],
                       byid = T, drop_not_poly = T)
  row.names(tmp) <- as.character(gsub(paste0(" ", i-1), "", row.names(tmp)))
  tmp <- SpatialPolygonsDataFrame(tmp, elad@data[row.names(tmp), ])
  reg[[i]] <- tmp
}
rm(tmp, i)

regf <- list()
for(i in 1:length(reg)){
  tmp <- fortify(reg[[i]], region = "code")
  tmp <- merge(tmp, reg[[i]], by.x = "id", by.y = "code")
  regf[[i]] <- tmp
}
rm(tmp, i)



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

# Regions
# East of England
eerf <- fortify(eer, region = "CODE")
eerf <- merge(eerf, eer, by.x = "id", by.y = "CODE")

# London
lorf <- fortify(lor, region = "CODE")
lorf <- merge(lorf, lor, by.x = "id", by.y = "CODE")

# North West
nwrf <- fortify(nwr, region = "CODE")
nwrf <- merge(nwrf, nwr, by.x = "id", by.y = "CODE")

# North East
nerf <- fortify(ner, region = "CODE")
nerf <- merge(nerf, ner, by.x = "id", by.y = "CODE")

# East Midlands
emrf <- fortify(emr, region = "CODE")
emrf <- merge(emrf, emr, by.x = "id", by.y = "CODE")

# Yorkshire and The Humber
yhrf <- fortify(yhr, region = "CODE")
yhrf <- merge(yhrf, yhr, by.x = "id", by.y = "CODE")
soaclip <- elsoa[yhr, ]
soaclipf <- fortify(soaclip, region = "code")
soaclipf <- merge(soaclipf, soaclip, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = soaclipf, aes(long, lat, group = group),
               fill = "#c7e9c0", colour = "dark grey") +
  geom_polygon(data = soaclipf, aes(long, lat, group = group),
               fill = "#00441b", colour = "dark grey") +
  geom_polygon(data = yhlf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = yhrf, aes(long, lat, group = group),
               fill = "transparent", colour = "black") +
  map + coord_equal()

# South West
swrf <- fortify(swr, region = "CODE")
swrf <- merge(swrf, swr, by.x = "id", by.y = "CODE")

# West Midlands
wmrf <- fortify(wmr, region = "CODE")
wmrf <- merge(wmrf, wmr, by.x = "id", by.y = "CODE")

# South East
serf <- fortify(ser, region = "CODE")
serf <- merge(serf, ser, by.x = "id", by.y = "CODE")
