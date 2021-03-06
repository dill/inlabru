#' @name gorillas
#' @title Gorilla Nesting Sites.
#' @docType data
#' @description This the \code{gorillas} dataset from the package \code{spatstat}, reformatted
#' as point process data for use with \code{inlabru}. 
#' 
#' @usage data(gorillas)
#' 
#' @format The data are a list that contains these elements:
#'  \describe{
#'    \item{\code{nests}:}{ A \code{SpatialPointsDataFrame} object containing the locations of 
#'    the gorilla nests.}
#'    \item{\code{boundary}:}{ An \code{SpatialPolygonsDataFrame} object defining the boundary
#'    of the region that was searched for the nests.}
#'    \item{\code{mesh}:}{ An \code{inla.mesh} object containing a mesh that can be used
#'    with function \code{lgcp} to fit a LGCP to the nest data.}
#'    \item{\code{gcov}:}{ A list of raster objects, one for each of these spatial covariates:
#'     \describe{
#'       \item{\code{aspect}}{ Compass direction of the terrain slope. Categorical, with levels 
#'       N, NE, E, SE, S, SW, W and NW, which are coded as integers 1 to 8.}
#'       \item{\code{elevation}}{ Digital elevation of terrain, in metres.}
#'       \item{\code{heat}}{ Heat Load Index at each point on the surface (Beer's aspect), 
#'       discretised. Categorical with values Warmest (Beer's aspect between 0 and 0.999), 
#'       Moderate (Beer's aspect between 1 and 1.999), Coolest (Beer's aspect equals 2). These are
#'       coded as integers 1, 2 and 3, in that order.}
#'       \item{\code{slopangle}}{ Terrain slope, in degrees.}
#'       \item{\code{slopetype}}{ Type of slope. Categorical, with values Valley, Toe (toe slope), 
#'       Flat, Midslope, Upper and Ridge. These are coded as integers 1 to 6.}
#'       \item{\code{vegetation}}{ Vegetation type: a categorical variable with 6 levels coded as
#'       integers 1 to 6 (in order of increasing expected habitat suitability)}
#'       \item{\code{waterdist}}{ Euclidean distance from nearest water body, in metres.}
#'     }
#'    }
#'    \item{\code{plotsample}}{Plot sample of gorilla nests, sampling 9x9 over the region, with 60\% coverage. Components:
#'    \describe{
#'      \item{\code{counts}}{ A data frame with elements \code{x}, \code{y}, \code{count}, 
#'      \code{exposure}, being the x- and y-coordinates of the centre of each plot, the count in each 
#'      plot and the area of each plot.}
#'      \item{\code{plots}}{ A \code{SpatialPolygonsDataFrame} defining the individual plot boundaries.}
#'      \item{\code{nests}}{ A \code{SpatialPointsDataFrame} giving the locations of each detected nest.}
#'    }
#'    }
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
#'  data(gorillas) # get the data
#'  # extract all the objects, for convenience:
#'  nests = gorillas$nests
#'  mesh = gorillas$mesh
#'  boundary = gorillas$boundary
#'  gcov = gorillas$gcov
#'  gnestsamples = gorillas$plotsample
#'  
#'  # plot all the nests, mesh and boundary
#'  ggplot() + gg(mesh,lwd=0.1) + gg(boundary) + gg(gnests, pch="+",cex=2)
#'  
#'  # Plot the elevation covariate
#'  plot(gcov$elevation) 
#'  
#'  # Plot the plot sample
#'  ggplot() + gg(gnestsamples$nests) + gg(gnestsamples$plots)
#'  

NULL
