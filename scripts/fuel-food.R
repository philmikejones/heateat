# Libraries ====
require("rgeos")
require("maptools")
require("rgdal")
require("scales")
require("deldir")  # for voronoi polygons
require("ggplot2")



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



# Food bank layer ====
fb    <- read.csv("data/foodbanks-matched.csv")
fbloc <- geom_point(data = fb, aes(OSEAST1M10nov, OSNRTH1M10nov))

# Voronoi polygon layer ====
vp  <- deldir(fb$OSEAST1M10nov, fb$OSNRTH1M10nov)
vpm <- geom_segment(data = vp$dirsgs, aes(x = x1, y = y1, xend = x2, yend = y2))



# Fuel poverty layer ====
lihc <- read.csv("data/fplihc.csv", skip = 2, header = T)
lihc$Estimated.number.of.households <- 
  as.numeric(lihc$Estimated.number.of.households)
lihc$Estimated.number.of.Fuel.Poor.Households <- 
  as.numeric(lihc$Estimated.number.of.Fuel.Poor.Households)

lmlu <- read.csv("data/OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv", header = T)
lmlu <- subset(lmlu, select = c("LSOA11CD", "MSOA11CD"))
lmlu <- unique(lmlu)

lihc <- merge(lihc, lmlu, by.x = "LSOA.Code", by.y = "LSOA11CD")
rm(lmlu)

msoas <- unique(lihc$MSOA11CD)
lihc$Estimated.number.of.Fuel.Poor.Households <- 
  as.numeric(lihc$Estimated.number.of.Fuel.Poor.Households)
lihc$fphh <- NA
for(i in 1:NROW(msoas)){
  lihc$fphh[lihc$MSOA11CD == msoas[i]] <-
    sum(lihc$Estimated.number.of.Fuel.Poor.Households[lihc$MSOA11CD == msoas[i]])
}
lihc <- subset(lihc, select = c("MSOA11CD", "fphh"))
lihc <- unique(lihc)
rm(i, msoas)

msoahh <- read.csv("data/eng-msoa-households.csv")
msoahh <- subset(msoahh, select = c("geography.code", 
                                    "Tenure..All.households..measures..Value"))
lihc   <- merge(lihc, msoahh, by.x = "MSOA11CD", by.y = "geography.code")
lihc$pfphh <- NA
lihc$pfphh <- (lihc$fphh / lihc$Tenure..All.households..measures..Value) * 100

urmsoa <- read.csv("data/RUC11_MSOA11_EW.csv", header = T)
lihc   <- merge(lihc, urmsoa, by = "MSOA11CD")
rm(urmsoa, msoahh)

lihc <- subset(lihc, pfphh >= quantile(pfphh, 0.75))

# MSOA layer
emsoa <- readOGR(dsn = "../../Boundary Data/MSOAs/England", "England_msoa_2011")
emsoa@data <- merge(emsoa@data, lihc, by.x = "CODE", by.y = "MSOA11CD")
emsoaf <- fortify(emsoa, region = "CODE")
emsoaf <- merge(emsoaf, emsoa@data, by.x = "id", by.y = "CODE")



# Final map ====
ggplot() + llad + fbloc + vpm + coord_equal()



# # Fuel poverty priority LSOAs ====
# lsoa <- readOGR(dsn = "../../Boundary Data/LSOAs/eng-lsoa-2011", 
#                 "england_lsoa_2011Polygon")
# proj4string(lsoa) <- CRS("+init=epsg:27700")
# 
# fpp           <- read.csv("data/fp-priority-lsoa.csv")
# lsoa$code     <- as.character(lsoa$code)
# fpp$LSOA.CODE <- as.character(fpp$LSOA.CODE)
# lsoa$priority <- lsoa$code %in% fpp$LSOA.CODE
# lsoaf         <- fortify(lsoa, region = "code")
# lsoaf         <- merge(lsoaf, lsoa@data, by.x = "id", by.y = "code")
# 
# f <- ggplot(lsoaf, aes(long, lat, group = group, fill = priority))
# f + geom_polygon() + coord_equal()
