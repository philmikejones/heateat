#' Polygons for the Doncaster LAD outline
#'
#' A fortified dataset containing the outline of the Doncaster LAD
#'
#' @format A dataframe with 7348 rows and 10 variables:
#' \describe{
#'  \item{long}{Longitude (east-west) coordinate of node}
#'  \item{lat}{Latitude (north-south) coordinate of node}
#'  \item{order}{plot order of node in group}
#'  \item{hole}{Logical: is the polygon empty (TRUE) or filled (FALSE)?}
#'  \item{piece}{}
#'  \item{id}{Identifier for polygon}
#'  \item{group}{Identifies which group the node belongs to}
#'  \item{code}{Unique code for Doncaster LAD}
#'  \item{name}{LAD name}
#'  \item{altname}{English name if primary name is in Welsh}
#' }
#' @source See data-raw/
"lads_f"
