# LADs ====
download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lad_2011.zip",
              destfile = "inst/extdata/lads.zip", mode = "wb", method = "wget")
dir.create("inst/extdata/lads", showWarnings = FALSE, recursive = TRUE)
unzip("inst/extdata/lads.zip", exdir = "inst/extdata/lads/")

# LSOA ====
download.file("https://census.edina.ac.uk/ukborders/easy_download/prebuilt/shape/England_lsoa_2011.zip",
              destfile = "inst/extdata/lsoa.zip", mode = "wb", method = "wget")
dir.create("inst/extdata/lsoa", showWarnings = FALSE, recursive = TRUE)
unzip("inst/extdata/lsoa.zip", exdir = "inst/extdata/lsoa/")

# Fuel poverty ====
download.file("https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/485161/2013_Sub-regional_tables.xlsx",
              destfile = "data/raw/fuel-poverty.xlsx")
