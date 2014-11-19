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
# # LAD layer
# elad <- readOGR(dsn = "../../Boundary Data/LADs/englandLADs", 
#                 "england_lad_2011Polygon")
# proj4string(elad) <- CRS("+init=epsg:27700")
# eladf <- fortify(elad, region = "code")
# eladf <- merge(eladf, elad@data, by.x = "id", by.y = "code")
# rm(elad)
# llad <- geom_polygon(data = eladf, aes(long, lat, group = group), 
#                      fill = "transparent", colour = "light grey")

# # Region layer
# reg <- readOGR(dsn = "../../Boundary Data/Regions/EngWales Regions 2011",
#                "England_gor_2011")
# proj4string(reg) <- CRS("+init=epsg:27700")
# regf <- fortify(reg, region = "CODE")
# regf <- merge(regf, reg@data, by.x = "id", by.y = "CODE")
# rm(reg)
# lreg <- geom_polygon(data = regf, aes(long, lat, group = group), 
#                      fill = "transparent", colour = "light grey")



# Individual Regions ====
# East Midlands
em <- readOGR(dsn = "../../Boundary Data/Regions/east-midlands",
               "england_gor_2011Polygon")
proj4string(em) <- CRS("+init=epsg:27700")
emf <- fortify(em, region = "code")
emf <- merge(emf, em@data, by.x = "id", by.y = "code")
lem <- geom_polygon(data = emf, aes(long, lat, group = group), 
                     fill = "transparent", colour = "dark grey")



# East of England
ee <- readOGR(dsn = "../../Boundary Data/Regions/east-of-england",
              "england_gor_2011Polygon")
proj4string(ee) <- CRS("+init=epsg:27700")
eef <- fortify(ee, region = "code")
eef <- merge(eef, ee@data, by.x = "id", by.y = "code")
lee <- geom_polygon(data = eef, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# London
lon <- readOGR(dsn = "../../Boundary Data/Regions/london/",
              "england_gor_2011Polygon")
proj4string(lon) <- CRS("+init=epsg:27700")
lonf <- fortify(lon, region = "code")
lonf <- merge(lonf, lon@data, by.x = "id", by.y = "code")
llon <- geom_polygon(data = lonf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# North East
ne <- readOGR(dsn = "../../Boundary Data/Regions/north-east/",
               "england_gor_2011Polygon")
proj4string(ne) <- CRS("+init=epsg:27700")
nef <- fortify(ne, region = "code")
nef <- merge(nef, ne@data, by.x = "id", by.y = "code")
lne <- geom_polygon(data = nef, aes(long, lat, group = group), 
                     fill = "transparent", colour = "dark grey")



# North West
nw <- readOGR(dsn = "../../Boundary Data/Regions/north-west/",
              "england_gor_2011Polygon")
proj4string(nw) <- CRS("+init=epsg:27700")
nwf <- fortify(nw, region = "code")
nwf <- merge(nwf, nw@data, by.x = "id", by.y = "code")
lnw <- geom_polygon(data = nwf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# South East
se <- readOGR(dsn = "../../Boundary Data/Regions/south-east/",
              "england_gor_2011Polygon")
proj4string(se) <- CRS("+init=epsg:27700")
sef <- fortify(se, region = "code")
sef <- merge(sef, se@data, by.x = "id", by.y = "code")
lse <- geom_polygon(data = sef, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# South West
sw <- readOGR(dsn = "../../Boundary Data/Regions/south-west/",
              "england_gor_2011Polygon")
proj4string(sw) <- CRS("+init=epsg:27700")
swf <- fortify(sw, region = "code")
swf <- merge(swf, sw@data, by.x = "id", by.y = "code")
lsw <- geom_polygon(data = swf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# West Midlands
wm <- readOGR(dsn = "../../Boundary Data/Regions/west-midlands/",
              "england_gor_2011Polygon")
proj4string(wm) <- CRS("+init=epsg:27700")
wmf <- fortify(wm, region = "code")
wmf <- merge(wmf, wm@data, by.x = "id", by.y = "code")
lwm <- geom_polygon(data = wmf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# Yorkshire and the Humber
yh <- readOGR(dsn = "../../Boundary Data/Regions/yorks-humber/",
              "england_gor_2011Polygon")
proj4string(yh) <- CRS("+init=epsg:27700")
yhf <- fortify(yh, region = "code")
yhf <- merge(yhf, yh@data, by.x = "id", by.y = "code")
lyh <- geom_polygon(data = yhf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")



# Food bank layer ====
fbt <- read.csv("data/foodbanks.csv")
fbm <- read.csv("data/foodbanks-matched.csv")
fb  <- merge(fbt, fbm, by = "match")
rm(fbt, fbm)
fb <- fb[fb$URINDEW10nov != 9, ]  # 9 is Scotland/NI/Channel Is/IoM, see docs

# # Simplify urban/rural classification
# fb$ru <- NA
# fb$ru[fb$URINDEW10nov == 1] <- "urban"
# fb$ru[fb$URINDEW10nov == 2] <- "urban"
# fb$ru[fb$URINDEW10nov == 3] <- "urban"
# fb$ru[fb$URINDEW10nov == 5] <- "urban"
# fb$ru[fb$URINDEW10nov == 6] <- "urban"
# fb$ru[fb$URINDEW10nov == 7] <- "urban"
# 
# fb$ru[fb$URINDEW10nov == 4] <- "rural"
# fb$ru[fb$URINDEW10nov == 8] <- "rural"

# create projection for clipping
coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
proj4string(fb) <- CRS("+init=epsg:27700")
fb <- spTransform(fb, CRSobj = CRS(proj4string(yh)))



# # Voronoi polygon layer ====
# vp  <- deldir(fb$OSEAST1M10nov, fb$OSNRTH1M10nov)
# vpm <- geom_segment(data = vp$dirsgs, aes(x = x1, y = y1, xend = x2, yend = y2),
#                     colour = "dark grey")



# Fuel poverty layer ====
# MSOA quintile
# lihc <- read.csv("data/fplihc.csv", skip = 2, header = T)
# lihc$Estimated.number.of.households <- 
#   as.numeric(lihc$Estimated.number.of.households)
# lihc$Estimated.number.of.Fuel.Poor.Households <- 
#   as.numeric(lihc$Estimated.number.of.Fuel.Poor.Households)
# 
# lmlu <- read.csv("data/OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv", header = T)
# lmlu <- subset(lmlu, select = c("LSOA11CD", "MSOA11CD"))
# lmlu <- unique(lmlu)
# 
# lihc <- merge(lihc, lmlu, by.x = "LSOA.Code", by.y = "LSOA11CD")
# rm(lmlu)
# 
# msoas <- unique(lihc$MSOA11CD)
# lihc$Estimated.number.of.Fuel.Poor.Households <- 
#   as.numeric(lihc$Estimated.number.of.Fuel.Poor.Households)
# lihc$fphh <- NA
# for(i in 1:NROW(msoas)){
#   lihc$fphh[lihc$MSOA11CD == msoas[i]] <-
#     sum(lihc$Estimated.number.of.Fuel.Poor.Households[lihc$MSOA11CD == msoas[i]])
# }
# lihc <- subset(lihc, select = c("MSOA11CD", "fphh"))
# lihc <- unique(lihc)
# rm(i, msoas)
# 
# msoahh <- read.csv("data/eng-msoa-households.csv")
# msoahh <- subset(msoahh, select = c("geography.code", 
#                                     "Tenure..All.households..measures..Value"))
# lihc   <- merge(lihc, msoahh, by.x = "MSOA11CD", by.y = "geography.code")
# lihc$pfphh <- NA
# lihc$pfphh <- (lihc$fphh / lihc$Tenure..All.households..measures..Value) * 100
# 
# urmsoa <- read.csv("data/RUC11_MSOA11_EW.csv", header = T)
# lihc   <- merge(lihc, urmsoa, by = "MSOA11CD")
# rm(urmsoa, msoahh)
# 
# lihc <- subset(lihc, pfphh >= quantile(pfphh, 0.8))
# 
# emsoa <- readOGR(dsn = "../../Boundary Data/MSOAs/England", "England_msoa_2011")
# emsoaf <- fortify(emsoa, region = "CODE")
# emsoaf <- merge(emsoaf, emsoa@data, by.x = "id", by.y = "CODE")
# emsoaf <- merge(emsoaf, lihc, by.x = "id", by.y = "MSOA11CD")
# rm(emsoa, lihc)
# qmsoa <- geom_polygon(data = emsoaf, aes(long, lat, group = group), 
#                                       fill = "red")



# Priority LSOAs
lsoa <- readOGR(dsn = "../../Boundary Data/LSOAs/eng-lsoa-2011", 
                "england_lsoa_2011Polygon")
proj4string(lsoa) <- CRS("+init=epsg:27700")

fpp           <- read.csv("data/fp-priority-lsoa.csv")
lsoa$code     <- as.character(lsoa$code)
fpp$LSOA.CODE <- as.character(fpp$LSOA.CODE)
lsoa$priority <- lsoa$code %in% fpp$LSOA.CODE
lsoa          <- lsoa[lsoa$priority == T, ]

lru <- read.csv("data/RUC11_LSOA11_EW.csv", header = T)
# Specify rural/urban dichotomy
# E1 and E2 == rural
lru$ru <- NA
lru$ru[lru$RUC11CD == "A1"] <- "Urban"
lru$ru[lru$RUC11CD == "B1"] <- "Urban"
lru$ru[lru$RUC11CD == "C1"] <- "Urban"
lru$ru[lru$RUC11CD == "C2"] <- "Urban"
lru$ru[lru$RUC11CD == "D1"] <- "Urban"
lru$ru[lru$RUC11CD == "D2"] <- "Urban"

lru$ru[lru$RUC11CD == "E1"] <- "Rural"
lru$ru[lru$RUC11CD == "E2"] <- "Rural"

lsoa@data <- merge(lsoa@data, lru, by.x = "code", by.y = "LSOA11CD")
lsoa  <- spTransform(lsoa, CRSobj = CRS(proj4string(yh)))



# # Final maps ====
# East of England
cfb <- fb[ee, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[ee, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = eef, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "east-england.pdf", path = "maps/", 
       width = land[1], height = land[2])

# East Midlands
cfb <- fb[em, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[em, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = emf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "east-midlands.pdf", path = "maps/", 
       width = land[1], height = land[2])

# London
cfb <- fb[lon, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[lon, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = lonf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "london.pdf", path = "maps/", 
       width = land[1], height = land[2])

# North East
cfb <- fb[ne, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[ne, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = nef, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "north-east.pdf", path = "maps/", 
       width = port[1], height = port[2])

# North West
cfb <- fb[nw, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[nw, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = nwf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "north-west.pdf", path = "maps/", 
       width = port[1], height = port[2])

# South East
cfb <- fb[se, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[se, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = sef, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "south-east.pdf", path = "maps/", 
       width = land[1], height = land[2])

# South West
cfb <- fb[sw, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[sw, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = swf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "south-west.pdf", path = "maps/", 
       width = land[1], height = land[2])

# West Midlands
cfb <- fb[wm, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[wm, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = wmf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "west-midlands.pdf", path = "maps/", 
       width = land[1], height = land[2])

# Yorkshire and the Humber
cfb <- fb[yh, ]
cfb@data <- merge(cfb@data, cfb, by = "match")
clsoa  <- lsoa
clsoa  <- clsoa[yh, ]
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, lsoa@data, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = yhf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  scale_colour_gradient(low = "pink", high = "red", name = "Total Clients") +
  scale_fill_brewer(type = "qual", palette = "Dark2", 
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl
  
ggsave(filename = "yorks-humber.pdf", path = "maps/", 
       width = land[1], height = land[2])
