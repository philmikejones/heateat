# Manage shapefile directories
setup_dirs <- function(directory) {
  if (!dir.exists(directory)) {
    dir.create(directory)
    message("Created ", directory)
  } else {
    message(directory, " exists")
  }
}
