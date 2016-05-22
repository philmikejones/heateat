#' Directory setup helper functions
#'
#' @param directory Specify a directory to test and create if it doesn't already exist
#'
#' @return Creates a directory
#' @export
#'
#' @examples
#' # creates the data directory in the project's root directory
#' setup_dirs("data"/)
setup_dir <- function(directory) {
  if (!dir.exists(directory)) {
    dir.create(directory)
    message("Created ", directory)
  } else {
    message(directory, " exists")
  }
}
