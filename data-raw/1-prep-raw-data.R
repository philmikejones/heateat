# Load LADs
lads <- rgdal::readOGR(dsn = "extdata/lads", "england_lad_2011")
lads@data$label <- as.character(lads@data$label)

# Load LSOA
lsoa <- rgdal::readOGR(dsn = "extdata/lsoa", "england_lsoa_2011")
lsoa@data$code <- as.character(lsoa@data$code)
lsoa_data <- lsoa@data

# Subset/clip on Doncaster
lads <- lads[lads@data$name == "Doncaster", ]

lsoa <- lsoa[lads, ]
lsoa <- rgeos::gIntersection(lads, lsoa, byid = TRUE, drop_lower_td = TRUE)

# Recreate data frame
row.names(lsoa) <- gsub("9 ",   "", row.names(lsoa))
lsoa <- sp::SpatialPolygonsDataFrame(lsoa,
  lsoa_data[row.names(lsoa_data) %in% row.names(lsoa), ])
lsoa@data$name <- as.character(lsoa@data$name)


# Load fuel poverty data
fp <- readxl::read_excel("extdata/fuel-poverty.xlsx", sheet = "Table 3",
                         skip = 1, col_names = TRUE)
fp <- dplyr::select(fp, 1, 6, 7, 8)
fp <- na.omit(fp)
colnames(fp) <- c("code", "num_hh", "num_fph", "per_fph")


# Join
lsoa@data <- dplyr::inner_join(lsoa@data, fp, by = "code")


# Fortify shapefiles
lads_f <- broom::tidy(lads, region = "label")
lads_f <- dplyr::inner_join(lads_f, lads@data, by = c("id" = "label"))
lads_f[, 8:9] <- apply(lads_f[, 8:9], 2, as.character)
lads_f$altname <- NULL

lsoa_f <- broom::tidy(lsoa, region = "code")
lsoa_f <- dplyr::inner_join(lsoa_f, lsoa@data, by = c("id" = "code"))
lsoa_f$label <- as.character(lsoa_f$label)


# Export .RData files
save(lads_f, file = "data/lads.RData")
save(lsoa_f, file = "data/lsoa.RData")

# Clean up
rm(list = ls())
