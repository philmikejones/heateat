# Prepare FP/RU data ====
# Two different fuel poverty definitions, 10% and 'Low Income High Cost'
# Treat each separately
fp10   <- read.csv("data/fp10.csv", skip = 2, header = T)
fplihc <- read.csv("data/fplihc.csv", skip = 2, header = T)

# Add in rural classification; remove urban
ru <- read.csv("data/RUC11_LSOA11_EW.csv", header = T)

fp10 <- merge(fp10, ru, by.x = "LSOA.Code", by.y = "LSOA11CD")
fp10 <- subset(fp10, select = c("LSOA.Code", "Estimated.number.of.households",
                                "Estimated.number.of.Fuel.Poor.Households",
                                "RUC11CD", "RUC11"))
# fp10 <- subset(fp10, RUC11CD == "D1" | RUC11CD == "D2" | 
#                  RUC11CD == "E1" | RUC11CD == "E2")

fplihc <- merge(fplihc, ru, by.x = "LSOA.Code", by.y = "LSOA11CD")
fplihc <- subset(fplihc, select = c("LSOA.Code", 
                                    "Estimated.number.of.households", 
                                    "Estimated.number.of.Fuel.Poor.Households",
                                    "RUC11CD",  "RUC11"))
# fplihc <- subset(fplihc, RUC11CD == "D1" | RUC11CD == "D2" | 
#                    RUC11CD == "E1" | RUC11CD == "E2")
rm(ru)

# Libraries ====
require("maptools")
require("rgeos")
require("rgdal")
require("scales")
require("ggplot2")

# Map ====
lsoa <- readOGR(dsn = "../../Boundary Data/LSOAs/eng-lsoa-2011", 
                "england_lsoa_2011Polygon")
proj4string(lsoa) <- CRS("+init=epsg:27700")
lsoa@data <- merge(lsoa@data, fp10, by.x = "code", by.y = "LSOA.Code")
lsoaf <- fortify(lsoa, region = "code")
lsoaf <- merge(lsoaf, lsoa@data, by.x = "id", by.y = "code")
m <- ggplot(lsoaf, aes(long, lat, group = group, 
                       fill = Estimated.number.of.Fuel.Poor.Households))
m + geom_polygon() + coord_equal()
