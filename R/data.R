#' Polygons for the Doncaster LAD outline
#'
#' A fortified dataset containing the outline of the Doncaster LAD
#'
#' @format A dataframe with 7348 rows and 9 variables:
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
#' }
#' @source See data-raw/
"lads_f"

#' Polygons for Doncaster LSOAs
#'
#' A fortified dataset containing the outline of the Doncaster Lower-layer Super Output Areas
#'
#' @format A dataframe with 165872 rows and 12 variables:
#' \describe{
#'  \item{long}{Longitude (east-west) coordinate of node}
#'  \item{lat}{Latitude (north-south) coordinate of node}
#'  \item{order}{plot order of node in group}
#'  \item{hole}{Logical: is the polygon empty (TRUE) or filled (FALSE)?}
#'  \item{piece}{}
#'  \item{id}{Identifier for polygon}
#'  \item{group}{Identifies which group the node belongs to}
#'  \item{name}{LSOA name}
#'  \item{label}{LSOA label}
#'  \item{num_hh}{Number of households in the LSOA}
#'  \item{num_fph}{Number of households in fuel poverty. See \url{https://www.gov.uk/government/statistics/2013-sub-regional-fuel-poverty-data-low-income-high-costs-indicator}}
#'  \item{per_fph}{Percent of households in fuel poverty (num_fph / num_hh)}
#' }
#' @source See data-raw/
"lsoa_f"
