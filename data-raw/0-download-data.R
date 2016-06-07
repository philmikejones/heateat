# LADs ====
download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011.zip",
              destfile = "extdata/lads.zip", mode = "wb", method = "wget")
dir.create("extdata/lads", showWarnings = FALSE, recursive = TRUE)
unzip("extdata/lads.zip", exdir = "extdata/lads/")

# LSOA ====
download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011.zip",
              destfile = "extdata/lsoa.zip", mode = "wb", method = "wget")
dir.create("extdata/lsoa", showWarnings = FALSE, recursive = TRUE)
unzip("extdata/lsoa.zip", exdir = "extdata/lsoa/")

# Fuel poverty ====
download.file("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/485161/2013_Sub-regional_tables.xlsx",
              destfile = "extdata/fuel-poverty.xlsx")
