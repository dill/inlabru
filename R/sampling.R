#' Sample from a log Gaussian Cox process (LGCP)
#' 
#'
#' @aliases sample.lgcp
#' @export
#'
#' @param mesh An \link{inla.mesh} object
#' @param loglambda A vector of log intensities at the mesh vertices (for higher order basis functions, e.g. for \code{inla.mesh.1d} meshes, \code{loglambda} should be given as \code{mesh$m} basis function weights rather than the values at the \code{mesh$n} vertices)
#' @param strategy Only applicable to 2D meshes. Use "rectangle" for flat 2D meshes and "spherical" for "sliced-spherical" for spherical meshes. 
#' @param R Only for spherical meshes. This sets the radius of the sphere approximated by the mesh.
#' @param samplers A SpatialPolygonsDataFrame. Simulated points that fall outside these polygons are discarded.
#'
#' @return point samples on the mesh
#' 
#' @examples
#' library(inlabru)
#' vertices = seq(0, 3, by = 0.1)
#' mesh = inla.mesh.1d(vertices)
#' loglambda = 5-0.5*vertices)
#' pts = sample.lgcp(mesh, loglambda)
#' pts$y = 0
#' plot(vertices, exp(loglambda), type = "l", ylim = c(0,150))
#' points(pts, pch = "|" )
#'
#' @examples 
#' data("gorillanests")
#' pts = sample.lgcp(gnestmesh, rep(-10, gnestmesh$n))
#' ggplot() + gg(gnestmesh) + gg(pts)

sample.lgcp = function(mesh, loglambda, strategy = "rectangle", R = 6371, samplers = NULL) {
  
if (class(mesh) == "inla.mesh.1d") {
  xmin = mesh$interval[1]
  xmax = mesh$interval[2]
  area = xmax - xmin
  wmax = max(loglambda)
  Npoints = rpois(1, lambda = area * exp(wmax))
  points = runif(n = sum(Npoints), min=xmin, max=xmax)
  A = inla.mesh.project(mesh,points)$A
  ploglambda = exp( loglambda - wmax)
  pointValues = as.vector(A %*% ploglambda)
  keep = which(runif(Npoints) < pointValues)
  ret = data.frame(points[keep])
  colnames(ret) = "x"
  return(ret)
  
} else {
  
  if ( strategy == "rectangle") {
      
      ###########################################################################
      ## Code for simulating LGCPs on triangulated domains (planar or spherical)
      ## used throughout Simpson et al. (2011)
      ## Author: Daniel Simpson
      ## This code comes with no warranty or guarantee of any kind.
      ###########################################################################
      
      ###########################################################################
      ## Code was adapted to accommodate sampling from multiple fields in
      ## one go. The fields have to be provided as rows in the loglambda arguments
      ## Author: Fabian E. Bachl
      ###########################################################################
      
    
      # Construct bounding rectangle
      loc <- mesh$loc
      xmin = min(loc[,1])
      xmax = max(loc[,1])
      ymin = min(loc[,2])
      ymax = max(loc[,2])
      area =(xmax- xmin)*(ymax- ymin)
      
      # If loglambda is a vector, turn it into a matrix
      if ( !is.matrix(loglambda) ){ loglambda = matrix(loglambda, nrow = 1) }
      
      # Simulate number of points
      n.fields = dim(loglambda)[1]
      lambda_max <- apply(loglambda, MARGIN = 1, max)
      Npoints <- sapply(1:n.fields, function(x) {rpois(1, lambda = area * exp(lambda_max[x]))})
      
      # Simulate uniform points on the bounding rectangle
      x <- runif(n = sum(Npoints), min=xmin, max=xmax)
      y <- runif(n = sum(Npoints), min=ymin, max=ymax)
      s <- rep(1:n.fields, Npoints) # Which field are these intended for
      points <-cbind(x,y)
      
      # Do some thinning
      A <- inla.mesh.project(mesh,points)$A
      ploglambda = exp( loglambda - lambda_max)
      pointValues = A %*% t(ploglambda)
      # Extract value for each point depending on which field the point was created for
      pointValues = pointValues[cbind(seq_along(s), s)]
      keep = which(runif(sum(Npoints)) < pointValues)
      ret = points[keep,]
      attr(ret, "field") = s[keep]
      
      # What to return
      ret = ret
  
  } else if ( strategy == "spherical" ) {
    # Simulate number of points
    area =   4*pi*R^2
    lambda_max <- max(loglambda)
    Npoints <- rpois(n=1,lambda=area*exp(lambda_max))
    if (Npoints > 5000000) { stop(paste0("Too many points!: ",Npoints)) }
  
    # Choose z uniformly distributed in [-1,1].
    z <- runif(n=Npoints, min=-1, max=1)
    # Choose t uniformly distributed on [0, 2*pi).
    t <- runif(n=Npoints, min=0, max=2*pi)
    r = sqrt(1-z^2)
    x = r * cos(t)
    y = r * sin(t)
    
    loc = euc.to.geo(data.frame(x=x,y=y,z=z), R = 1)
    points = as.matrix(loc[,c("lon","lat")])
    A = inla.mesh.project(mesh,points)$A
    loglambda = exp(loglambda - lambda_max)
    pointValues = as.vector(A%*%loglambda)
    points = points[runif(Npoints) < pointValues,]
    
    # What to return
    ret = points
    
  
  } else if ( strategy == "sliced-spherical" ) {
    
    # Simulate number of points
    lon.range = range(mesh$loc[,1])
    lon.rel = abs((lon.range[2]-lon.range[1])/360)
    area = (4*pi*R^2)*lon.rel
    
    lambda_max <- max(loglambda)
    loglambda = exp(loglambda - lambda_max)
    Npoints <- rpois(n=1,lambda=area*exp(lambda_max))
    # cat(Npoints)
    sampled.points = list()
    nblocks = max(1,Npoints/1000000)
    sp = ceiling(seq(1,Npoints+1, length.out = max(2,nblocks)))
    n.sampled = 0
    
    for (k in 1:(length(sp)-1)) {
      n.points = sp[k+1] - sp[k]
      
      # Choose z uniformly distributed in [-1,1].
      z <- runif(n = n.points, min=-1, max=1) # transforms into longitude
      # Choose t uniformly distributed on [0, 2*pi).
      t <- runif(n = n.points, min = 2*pi*(lon.range[1]+180)/360, max = 2*pi*(lon.range[2]+180)/360)
      r = sqrt(1-z^2)
      x = r * cos(t)
      y = r * sin(t)
      
      loc = euc.to.geo(data.frame(x=x,y=y,z=z), R = 1)
      loc[,2] = loc[,2] - 180
      
      points = as.matrix(loc[,c("lon","lat")])
      A <- inla.mesh.project(mesh,points)$A
      pointValues = as.vector(A%*%loglambda)
      keep = runif(n.points) < pointValues
      sampled.points[[k]] = points[keep,]
      n.sampled = n.sampled + sum(pointValues == 0)
    }
  #   cat(paste0("sp:",sp))
  #   cat(paste0("n.sampled:",n.sampled))
  #   print(paste0("Fraction of points kept: ", n.sampled/Npoints) )
    
    # What to return
    ret = do.call(rbind,sampled.points)
  }

}

  if ( !is.null(mesh$crs) ) {
    ret = as.data.frame(ret)
    coordinates(ret) = c("x","y")
    proj4string(ret) = mesh$crs
  }
  
  # Only retain points within the samplers
  if( !is.null(samplers) ){
    ret = ret[!is.na(over(ret, samplers)), ]
  }
  
  ret
}
