conds <- all(grepl("Doncaster", lsoa@data$name))
if (!conds) {
  warning("LSOA not joined correctly (LSOA not from Doncaster present)")
  stop()
}
rm(conds)

if (!(nrow(fp) == nrow(lsoa_data))) {
  warning("LSOA row numbers do not match")
  stop()
}
rm(lsoa_data)
