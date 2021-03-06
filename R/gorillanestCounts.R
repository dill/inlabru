#' @name gorillanestCounts
#' @title Gorilla Nesting Site counts in selected plots.
#' @docType data
#' @description This a subset of the \code{gorillas} dataset from the package \code{spatstat}, reformatted
#' as point process data for use with \code{inlabru}. The data have also been thinned by keeping
#' only nests within a set of 15 plots (see below).
#' 
#' @usage data(gorillanestCounts)
#' 
#' @format The data contain these objects:
#'  \describe{
#'    \item{\code{gplotcounts}:}{ A \code{SpatialPointsDataFrame} object containing the locations of 
#'    the COUNTS only of \emph{detected} gorilla nests in each plot.}
#'  }
#' @source 
#' Library \code{spatstat}.
#' 
#' @references 
#' Funwi-Gabga, N. (2008) A pastoralist survey and fire impact assessment in the Kagwene Gorilla 
#' Sanctuary, Cameroon. M.Sc. thesis, Geology and Environmental Science, University of Buea, 
#' Cameroon.
#' 
#' Funwi-Gabga, N. and Mateu, J. (2012) Understanding the nesting spatial behaviour of gorillas 
#' in the Kagwene Sanctuary, Cameroon. Stochastic Environmental Research and Risk Assessment 
#' 26 (6), 793-811.
#' 
#' @examples
#'  data(gorillanests) # need this for gnestboundary and plots
#'  data(gorillanestCounts)
#'  x=coordinates(gplotcounts)[,1]
#'  y=coordinates(gplotcounts)[,2]
#'  count=gplotcounts@data$n
#'  ggplot() +gg(gnestboundary) +gg(plots) +  geom_text(aes(label=count, x=x, y=y))
#'  
NULL
