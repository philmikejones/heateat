# Libraries ====
require("rgeos")
require("maptools")
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



# Map background ====
# LAD layer for context
elad <- readOGR(dsn = "../../Boundary Data/LADs/englandLADs", 
                "england_lad_2011Polygon")
proj4string(elad) <- CRS("+init=epsg:27700")
eladf <- fortify(elad, region = "code")
eladf <- merge(eladf, elad@data, by.x = "id", by.y = "code")
rm(elad)
llad <- geom_polygon(data = eladf, aes(long, lat, group = group), 
                     fill = "transparent", colour = "light grey")



# Region layer for context ====
reg <- readOGR(dsn = "../../Boundary Data/Regions/EngWales Regions 2011",
               "England_gor_2011")
proj4string(reg) <- CRS("+init=epsg:27700")
regf <- fortify(reg, region = "CODE")
regf <- merge(regf, reg@data, by.x = "id", by.y = "CODE")
rm(reg)
lreg <- geom_polygon(data = regf, aes(long, lat, group = group), 
                     fill = "transparent", colour = "light grey")



# East Midlands region ====
em <- readOGR(dsn = "../../Boundary Data/Regions/east-midlands",
               "england_gor_2011Polygon")
proj4string(em) <- CRS("+init=epsg:27700")
emf <- fortify(em, region = "code")
emf <- merge(emf, em@data, by.x = "id", by.y = "code")
rm(em)
lem <- geom_polygon(data = emf, aes(long, lat, group = group), 
                     fill = "transparent", colour = "dark grey")
ggplot() + lem + map + coord_equal()



# East of England region ====
ee <- readOGR(dsn = "../../Boundary Data/Regions/east-of-england",
              "england_gor_2011Polygon")
proj4string(ee) <- CRS("+init=epsg:27700")
eef <- fortify(ee, region = "code")
eef <- merge(eef, ee@data, by.x = "id", by.y = "code")
rm(ee)
lee <- geom_polygon(data = eef, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lee + map + coord_equal()



# London region ====
lon <- readOGR(dsn = "../../Boundary Data/Regions/london/",
              "england_gor_2011Polygon")
proj4string(lon) <- CRS("+init=epsg:27700")
lonf <- fortify(lon, region = "code")
lonf <- merge(lonf, lon@data, by.x = "id", by.y = "code")
rm(lon)
llon <- geom_polygon(data = lonf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + llon + map + coord_equal()



# North East region ====
ne <- readOGR(dsn = "../../Boundary Data/Regions/north-east/",
               "england_gor_2011Polygon")
proj4string(ne) <- CRS("+init=epsg:27700")
nef <- fortify(ne, region = "code")
nef <- merge(nef, ne@data, by.x = "id", by.y = "code")
rm(ne)
lne <- geom_polygon(data = nef, aes(long, lat, group = group), 
                     fill = "transparent", colour = "dark grey")
ggplot() + lne + map + coord_equal()



# North West region ====
nw <- readOGR(dsn = "../../Boundary Data/Regions/north-west/",
              "england_gor_2011Polygon")
proj4string(nw) <- CRS("+init=epsg:27700")
nwf <- fortify(nw, region = "code")
nwf <- merge(nwf, nw@data, by.x = "id", by.y = "code")
rm(nw)
lnw <- geom_polygon(data = nwf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lnw + map + coord_equal()



# South East region ====
se <- readOGR(dsn = "../../Boundary Data/Regions/south-east/",
              "england_gor_2011Polygon")
proj4string(se) <- CRS("+init=epsg:27700")
sef <- fortify(se, region = "code")
sef <- merge(sef, se@data, by.x = "id", by.y = "code")
rm(se)
lse <- geom_polygon(data = sef, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lse + map + coord_equal()



# South West region ====
sw <- readOGR(dsn = "../../Boundary Data/Regions/south-west/",
              "england_gor_2011Polygon")
proj4string(sw) <- CRS("+init=epsg:27700")
swf <- fortify(sw, region = "code")
swf <- merge(swf, sw@data, by.x = "id", by.y = "code")
rm(sw)
lsw <- geom_polygon(data = swf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lsw + map + coord_equal()



# West Midlands region ====
wm <- readOGR(dsn = "../../Boundary Data/Regions/west-midlands/",
              "england_gor_2011Polygon")
proj4string(wm) <- CRS("+init=epsg:27700")
wmf <- fortify(wm, region = "code")
wmf <- merge(wmf, wm@data, by.x = "id", by.y = "code")
rm(wm)
lwm <- geom_polygon(data = wmf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lwm + map + coord_equal()



# Yorkshire and the Humber region ====
yh <- readOGR(dsn = "../../Boundary Data/Regions/yorks-humber/",
              "england_gor_2011Polygon")
proj4string(yh) <- CRS("+init=epsg:27700")
yhf <- fortify(yh, region = "code")
yhf <- merge(yhf, yh@data, by.x = "id", by.y = "code")
rm(yh)
lyh <- geom_polygon(data = yhf, aes(long, lat, group = group), 
                    fill = "transparent", colour = "dark grey")
ggplot() + lyh + map + coord_equal()



# Food bank layer ====
fbt <- read.csv("data/foodbanks.csv")
fbm <- read.csv("data/foodbanks-matched.csv")
fb  <- merge(fbt, fbm, by = "match")
rm(fbt, fbm)
fb <- fb[fb$URINDEW10nov != 9, ]  # 9 is Scotland/NI/Channel Is/IoM, see docs

# Simplify urban/rural classification
fb$ru <- NA
fb$ru[fb$URINDEW10nov == 1] <- "urban"
fb$ru[fb$URINDEW10nov == 2] <- "urban"
fb$ru[fb$URINDEW10nov == 3] <- "urban"
fb$ru[fb$URINDEW10nov == 5] <- "urban"
fb$ru[fb$URINDEW10nov == 6] <- "urban"
fb$ru[fb$URINDEW10nov == 7] <- "urban"

fb$ru[fb$URINDEW10nov == 4] <- "rural"
fb$ru[fb$URINDEW10nov == 8] <- "rural"

fbl <- geom_point(data = fb, aes(OSEAST1M10nov, OSNRTH1M10nov, group = match, 
                                 size = Total, colour = ru))



# # Voronoi polygon layer ====
# vp  <- deldir(fb$OSEAST1M10nov, fb$OSNRTH1M10nov)
# vpm <- geom_segment(data = vp$dirsgs, aes(x = x1, y = y1, xend = x2, yend = y2),
#                     colour = "dark grey")



# Fuel poverty layer ====
# MSOA quintile ====
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



# Priority LSOAs ====
# commented out because it takes bloody ages
lsoa <- readOGR(dsn = "../../Boundary Data/LSOAs/eng-lsoa-2011", 
                "england_lsoa_2011Polygon")
proj4string(lsoa) <- CRS("+init=epsg:27700")

fpp           <- read.csv("data/fp-priority-lsoa.csv")
lsoa$code     <- as.character(lsoa$code)
fpp$LSOA.CODE <- as.character(fpp$LSOA.CODE)
lsoa$priority <- lsoa$code %in% fpp$LSOA.CODE
lsoaf         <- fortify(lsoa, region = "code")
lsoaf         <- merge(lsoaf, lsoa@data, by.x = "id", by.y = "code")
lsoaf <- lsoaf[lsoaf$priority == T, ]

plsoa <- geom_polygon(data = lsoaf, aes(long, lat, group = group, 
                                        fill = priority))



# Final map ====
ggplot() + llad + fbl + plsoa + 
  scale_colour_manual(values = c("black", "light grey")) +
  coord_equal() + mapl
# + vpm
# + qmsoa

ggsave("maps/fb-fp-lsoa.pdf", width = 21/2.54, height = 29.7/2.54)
