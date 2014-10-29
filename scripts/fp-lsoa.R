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

ggplot() + llad + coord_equal()



# Food bank layer ====
fb <- read.csv("data/foodbanks-matched.csv")

eladf <- fortify(elad, region = "code")
eladf <- merge(eladf, elad@data, by.x = "id", by.y = "code")
wladf <- fortify(wlad, region = "code")
wladf <- merge(wladf, wlad@data, by.x = "id", by.y = "code")
sladf <- fortify(slad, region = "code")
sladf <- merge(sladf, slad@data, by.x = "id", by.y = "code")

vp  <- deldir(fb$OSEAST1M10nov, fb$OSNRTH1M10nov)

ggplot() + 
  geom_polygon(data = eladf, aes(long, lat, group = group), 
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = wladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = sladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_point(data = fb, aes(OSEAST1M10nov, OSNRTH1M10nov, group = input_row)) +
  geom_segment(data = vp$dirsgs, aes(x = x1, y = y1, xend = x2, yend = y2)) + 
  coord_equal()

rm(elad, slad, wlad, eladf, sladf, wladf, vp, e, fb)



# Fuel poverty layer ====
# MSOA layer
emsoa <- readOGR(dsn = "../../Boundary Data/MSOAs/England", "England_msoa_2011")
emsoa@data <- merge(emsoa@data, fuel10, by.x = "CODE", by.y = "MSOA11CD")
emsoaf <- fortify(emsoa, region = "CODE")
emsoaf <- merge(emsoaf, emsoa@data, by.x = "id", by.y = "CODE")

# Fuel poverty and food bank location maps
# fuel10 ====
fuellihc <- read.csv("data/fplihc.csv", skip = 2, header = T)
write.table(fuellihc[fuellihc$Estimated.number.of.households < fuellihc$Estimated.number.of.Fuel.Poor.Households, ],
            "fplihchh-incorrect.csv", sep="\t")
fuellihc$Estimated.number.of.households <- as.numeric(fuellihc$Estimated.number.of.households)
fuellihc$Estimated.number.of.Fuel.Poor.Households <- as.numeric(fuellihc$Estimated.number.of.Fuel.Poor.Households)

fuel10 <- read.csv("data/fp10.csv", skip = 2, header = T)
write.table(fuel10[fuel10$Estimated.number.of.households < fuel10$Estimated.number.of.Fuel.Poor.Households, ],
            "fphh-incorrect.csv", sep="\t")
lmlu   <- read.csv("data/OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv", header = T)
lmlu   <- subset(lmlu, select = c("LSOA11CD", "MSOA11CD"))
lmlu   <- unique(lmlu)
# 32,844 fuel10; 34,753 lmlu LSOAs - includes Wales?
fuel10 <- merge(fuel10, lmlu, by.x = "LSOA.Code", by.y = "LSOA11CD")
rm(lmlu)

fuel10$Estimated.number.of.households <- 
  as.numeric(fuel10$Estimated.number.of.households)
msoas <- unique(fuel10$MSOA11CD)
fuel10$households <- NA
for(i in 1:NROW(msoas)){
  fuel10$households[fuel10$MSOA11CD == msoas[i]] <-
    sum(fuel10$Estimated.number.of.households[fuel10$MSOA11CD == msoas[i]])
}

fuel10$Estimated.number.of.Fuel.Poor.Households <- 
  as.numeric(fuel10$Estimated.number.of.Fuel.Poor.Households)
fuel10$fphh <- NA
for(i in 1:NROW(msoas)){
  fuel10$fphh[fuel10$MSOA11CD == msoas[i]] <-
    sum(fuel10$Estimated.number.of.Fuel.Poor.Households[fuel10$MSOA11CD == msoas[i]])
}

View(fuel10[fuel10$fphh > fuel10$households, ])

fuel10u <- subset(fuel10, select = c("MSOA11CD", "households", "fphh"))
fuel10u <- unique(fuel10u)
rm(i, msoas)

urmsoa <- read.csv("data/RUC11_MSOA11_EW.csv", header = T)
fuel10 <- merge(fuel10, urmsoa, by = "MSOA11CD")
rm(urmsoa)
fuel10$pfphh <- (fuel10$fphh / fuel10$households) * 100
fuel10 <- subset(fuel10, select = -households)
View(fuel10[which(fuel10$pfphh > 100), ])
fuel10[which(fuel10$households < 50), ]






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



# Prepare FP/RU data ====
# Two different fuel poverty definitions, 10% and 'Low Income High Cost'
# Treat each separately
fp10   <- read.csv("data/fp10.csv", skip = 2, header = T)
fplihc <- read.csv("data/fplihc.csv", skip = 2, header = T)

# # merge in rural classification
# ru <- read.csv("data/RUC11_LSOA11_EW.csv", header = T)
# 
# fp10 <- merge(fp10, ru, by.x = "LSOA.Code", by.y = "LSOA11CD")
# fp10 <- subset(fp10, select = c("LSOA.Code", "Estimated.number.of.households",
#                                 "Estimated.number.of.Fuel.Poor.Households",
#                                 "RUC11CD", "RUC11"))
# 
# fplihc <- merge(fplihc, ru, by.x = "LSOA.Code", by.y = "LSOA11CD")
# fplihc <- subset(fplihc, select = c("LSOA.Code", 
#                                     "Estimated.number.of.households", 
#                                     "Estimated.number.of.Fuel.Poor.Households",
#                                     "RUC11CD",  "RUC11"))

# Remove urban areas?
# fp10 <- subset(fp10, RUC11CD == "D1" | RUC11CD == "D2" | 
#                  RUC11CD == "E1" | RUC11CD == "E2")
# fplihc <- subset(fplihc, RUC11CD == "D1" | RUC11CD == "D2" | 
#                    RUC11CD == "E1" | RUC11CD == "E2")
# rm(ru)







# Fuel poverty priority LSOAs ====
lsoa <- readOGR(dsn = "../../Boundary Data/LSOAs/eng-lsoa-2011", 
                "england_lsoa_2011Polygon")
proj4string(lsoa) <- CRS("+init=epsg:27700")

fpp           <- read.csv("data/fp-priority-lsoa.csv")
lsoa$code     <- as.character(lsoa$code)
fpp$LSOA.CODE <- as.character(fpp$LSOA.CODE)
lsoa$priority <- lsoa$code %in% fpp$LSOA.CODE
lsoaf         <- fortify(lsoa, region = "code")
lsoaf         <- merge(lsoaf, lsoa@data, by.x = "id", by.y = "code")

f <- ggplot(lsoaf, aes(long, lat, group = group, fill = priority))
f + geom_polygon() + coord_equal()


lsoa@data <- merge(lsoa@data, fp10, by.x = "code", by.y = "LSOA.Code")
lsoaf <- fortify(lsoa, region = "code")
lsoaf <- merge(lsoaf, lsoa@data, by.x = "id", by.y = "code")
m <- ggplot(lsoaf, aes(long, lat, group = group, 
                       fill = Estimated.number.of.Fuel.Poor.Households))
m + geom_polygon() + coord_equal() + scale_fill_grey()
