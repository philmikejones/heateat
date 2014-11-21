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
reg <- readOGR(dsn = "shapes/ewregions/",
               "England_gor_2011")
proj4string(reg) <- CRS("+init=epsg:27700")
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



# Food bank layer ====
fbt <- read.csv("data/foodbanks.csv")
fbm <- read.csv("data/foodbanks-matched.csv")
fb  <- merge(fbt, fbm, by = "match")
rm(fbt, fbm)
fb <- fb[fb$URINDEW10nov != 9, ]  # 9 is Scotland/NI/Channel Is/IoM, see docs
fb$Total[fb$Total == -99] <- NA

# create projection for clipping
coordinates(fb) <- c("OSEAST1M10nov", "OSNRTH1M10nov")
proj4string(fb) <- CRS("+init=epsg:27700")
fb <- spTransform(fb, CRSobj = CRS(proj4string(reg)))

# # Voronoi polygon layer ====
# vp  <- deldir(fb$OSEAST1M10nov, fb$OSNRTH1M10nov)
# vpm <- geom_segment(data = vp$dirsgs,
#                     aes(x = x1, y = y1, xend = x2, yend = y2),
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
lsoa <- readOGR(dsn = "shapes/englsoa/", 
                "england_lsoa_2011Polygon")
proj4string(lsoa) <- CRS("+init=epsg:27700")

fpp           <- read.csv("data/fp-priority-lsoa.csv")
lsoa$code     <- as.character(lsoa$code)
fpp$LSOA.CODE <- as.character(fpp$LSOA.CODE)
lsoa$priority <- lsoa$code %in% fpp$LSOA.CODE
lsoa          <- lsoa[lsoa$priority == T, ]

lru <- read.csv("data/RUC11_LSOA11_EW.csv", header = T)
# Specify rural/urban dichotomy
lru$ru <- NA
lru$ru[lru$RUC11CD == "A1"] <- "Urban"  # Urban major conurbation
lru$ru[lru$RUC11CD == "B1"] <- "Urban"  # Urban minor conurbation
lru$ru[lru$RUC11CD == "C1"] <- "Urban"  # Urban city and town
lru$ru[lru$RUC11CD == "C2"] <- "Urban"  # Urban city and town sparse

lru$ru[lru$RUC11CD == "D1"] <- "Rural"  # Rural town and fringe
lru$ru[lru$RUC11CD == "D2"] <- "Rural"  # Rural town and fringe sparse
lru$ru[lru$RUC11CD == "E1"] <- "Rural"  # Rural village and dispersed
lru$ru[lru$RUC11CD == "E2"] <- "Rural"  # Rural village and dis. sparse

lsoa@data <- merge(lsoa@data, lru, by.x = "code", by.y = "LSOA11CD")
lsoa  <- spTransform(lsoa, CRSobj = CRS(proj4string(reg)))



# # Final maps ====
# East of England
creg  <- reg[reg$CODE == "E12000006", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "east-england.pdf", path = "maps/", 
       width = land[1], height = land[2])

# East Midlands
creg  <- reg[reg$CODE == "E12000004", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "east-midlands.pdf", path = "maps/", 
       width = land[1], height = land[2])

# London
creg  <- reg[reg$CODE == "E12000007", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "london.pdf", path = "maps/", 
       width = land[1], height = land[2])

# North East
creg  <- reg[reg$CODE == "E12000001", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "north-east.pdf", path = "maps/", 
       width = port[1], height = port[2])

# North West
creg  <- reg[reg$CODE == "E12000002", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "north-west.pdf", path = "maps/", 
       width = port[1], height = port[2])

# South East
creg  <- reg[reg$CODE == "E12000008", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "south-east.pdf", path = "maps/", 
       width = land[1], height = land[2])

# South West
creg  <- reg[reg$CODE == "E12000009", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "south-west.pdf", path = "maps/", 
       width = land[1], height = land[2])

# West Midlands
creg  <- reg[reg$CODE == "E12000005", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl

ggsave(filename = "west-midlands.pdf", path = "maps/", 
       width = land[1], height = land[2])

# Yorkshire and the Humber
creg  <- reg[reg$CODE == "E12000003", ]
clsoa <- lsoa[creg, ]
clad  <- elad[clsoa, ]
cfb   <- fb[creg, ]
cfb@data <- merge(cfb@data, cfb, by = "match")

cregf <- fortify(creg, region = "CODE")
cregf <- merge(cregf, creg, by.x = "id", by.y = "CODE")
cladf <- fortify(clad, region = "code")
cladf <- merge(cladf, clad, by.x = "id", by.y = "code")
clsoaf <- fortify(clsoa, region = "code")
clsoaf <- merge(clsoaf, clsoa, by.x = "id", by.y = "code")

ggplot() +
  geom_polygon(data = cladf, aes(long, lat, group = group),
               fill = "transparent", colour = "light grey") +
  geom_polygon(data = clsoaf, aes(long, lat, group = group,
                                  fill = ru)) +
  geom_polygon(data = cregf, aes(long, lat, group = group),
               fill = "transparent", colour = "dark grey") +
  geom_point(data = cfb@data, 
             aes(OSEAST1M10nov, OSNRTH1M10nov, group = match,
                 colour = Total.x)) +
  scale_colour_gradient(low = "light blue", high = "dark blue", 
                        na.value = "grey", 
                        name = "Total Clients") +
  scale_fill_manual(values = c("Rural" = "#1b9e77", "Urban" = "#d95f02"),
                    name = "Fuel Priority LSOA") +
  coord_equal() + mapl
  
ggsave(filename = "yorks-humber.pdf", path = "maps/", 
       width = land[1], height = land[2])
