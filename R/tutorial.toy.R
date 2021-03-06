toy.completesample = function(lambda = function(loc) { 1000 * dnorm(coordinates(loc)[,1], sd = 2) * dnorm(coordinates(loc)[,2], sd = 2)}, seed = 1) {
  set.seed(seed)
  bnd = inla.mesh.segment(loc = rbind(c(-5,-5), c(5,-5), c(5,5), c(-5,5)))
  mesh = inla.mesh.2d(interior = bnd, max.edge = 1)
  sp = SpatialPoints(sample.lgcp(mesh, log(lambda(SpatialPoints(mesh$loc)))))
  return(list(points = sp, mesh = mesh))
}


toy.pointsample = function(lambda = function(loc) { 1000 * dnorm(coordinates(loc)[,1], sd = 2) * dnorm(coordinates(loc)[,2], sd = 2)}, area = 0.1^2, n = 500, seed = 1) {
  
  set.seed(seed)
  
  bnd = inla.mesh.segment(loc = rbind(c(-5,-5), c(5,-5), c(5,5), c(-5,5)))
  mesh = inla.mesh.2d(interior = bnd, max.edge = 1)
  
  # Sample sampling locations
  x = runif(n, min = -5, max = 5)
  y = runif(n, min = -5, max = 5)
  sp = SpatialPoints(cbind(x,y))
  
  # Sample number of detections at each sampling location
  sp.data = data.frame(n = rpois(n,  area * lambda(sp)), area = area)
  sp = SpatialPointsDataFrame(sp, data = sp.data)
  samplers = SpatialPointsDataFrame(sp, data = data.frame(weight = sp$area, n = sp.data$n))
  coordnames(samplers) = c("x","y")
  
  # Create spatial points corresponding to detections
  n.det = sum(sp.data$n)
  idx.det = rep(1:length(x), sp.data$n)
  coords.det = coordinates(sp)[idx.det,]
  coords.det[,1] = coords.det[,1] + (2*runif(n.det)-1)*sqrt(area)/2
  coords.det[,2] = coords.det[,2] + (2*runif(n.det)-1)*sqrt(area)/2
  detections = SpatialPoints(coords.det)
  coordnames(detections) = c("x","y")
  
  return(list(points = detections, samplers = samplers, mesh = mesh))
}


toy.linesample = function(lambda, n = 1, nseg = 1000, width = 0.1, seed = 1, ID = "my.line") {
  
  spRbindRecurse = function(x) { 
    if (length(x)>1) {spRbind(x[[1]], spRbindRecurse(x[2:length(x)]))} 
    else {x[[1]]} 
  }
  
  set.seed(seed)

if (n == 1) {

    x1 = runif(1, min = -5, max = 5)
    y1 = runif(1, min = -5, max = 5)
    x2 = runif(1, min = -5, max = 5)
    y2 = runif(1, min = -5, max = 5)
    x3 = runif(1, min = -5, max = 5)
    y3 = runif(1, min = -5, max = 5)
    
    
    l1 = cbind(x1 + seq(0,1,length.out = nseg+1) * (x2 - x1),
               y1 + seq(0,1,length.out = nseg+1) * (y2 - y1))
    
    l2 = cbind(x2 + seq(0,1,length.out = nseg+1) * (x3 - x2),
               y2 + seq(0,1,length.out = nseg+1) * (y3 - y2))
    
    
    segs = rbind(l1, l2)
    lil = lapply(1:(nrow(segs)-1), function(n) Lines(list(Line(rbind(segs[n,],segs[n+1,]))), ID = n))
    sli = SpatialLines(lil)
    
    # Sample number of detections per segment
    mp = getSpatialLinesMidPoints(sli)
    len = SpatialLinesLengths(sli)
    area = len * width
    n.det = rpois(length(area),  area * lambda(SpatialPoints(mp)))
    
    if (sum(n.det > 0)) {
    # Turn segments into list of detections
    idx.det = rep(1:length(area), n.det)
    coords.det = coordinates(mp)[idx.det,]
    data.det = data.frame(distance = runif(sum(n.det), min = 0, max = 0.5 * width))
    points = SpatialPointsDataFrame(coords.det, data = data.det)
    # plot(sli)
    # plot(detections, add = TRUE)
    } else {
      points = NULL
    }
    
    # Integrated line
    li = Line(cbind(c(x1,x2,x3),c(y1,y2,y3)))
    lil = Lines(list(li), ID = ID)
    sli = SpatialLines(list(lil))
    sli.data = data.frame(n = sum(n.det), weight = width)
    rownames(sli.data) = ID
    sldf = SpatialLinesDataFrame(sli, data = sli.data)
    samplers = SpatialLinesDataFrame(sli, data = sli.data[,"weight", drop=FALSE])
    
    return(list(line = sldf, points = points, samplers = samplers))
    
} else {
  
  bnd = inla.mesh.segment(loc = rbind(c(-5,-5), c(5,-5), c(5,5), c(-5,5)))
  mesh = inla.mesh.2d(interior = bnd, max.edge = 1)
  
  lst = lapply(1:n, function(x) toy.linesample(lambda = lambda, n = 1, ID = x, nseg = nseg, width = width, seed = seed+x) )
  ret = list(mesh = mesh,
             lines = spRbindRecurse(lapply(lst, function(x) x$line)),
             points = do.call(rbind, lapply(lst, function(x) x$points)),
             samplers = spRbindRecurse(lapply(lst, function(x) x$samplers)))
  
  return(ret)
}
}

toy.polysample = function(lambda, n = 1, seed = 1) {
  
  spRbindRecurse = function(x) { 
    if (length(x)>1) {spRbind(x[[1]], spRbindRecurse(x[2:length(x)]))} 
    else {x[[1]]} 
  }
  
  set.seed(seed)
  
  require(maptools) # for spRbind
  
  bnd = inla.mesh.segment(loc = rbind(c(-5,-5), c(5,-5), c(5,5), c(-5,5)))
  mesh = inla.mesh.2d(interior = bnd, max.edge = 1)
  
  spdfs = list()
  smpls = list()
  
  detections = list()
  for (k in 1:n) {
    
    # Sample from SpatialPolygons

    x1 = runif(1, min = -5, max = 3)
    y1 = runif(1, min = -5, max = 3)
    xoff = runif(1, min = 0.5, max = 2)
    yoff = runif(1, min = 0.5, max = 2)
         
    loc = rbind(c(x1,y1), c(x1,y1+yoff), c(x1+xoff,y1+yoff), c(x1+xoff,y1))
    
    po = Polygon(loc)
    pss = Polygons(list(po), ID = k)
    spos = SpatialPolygons(list(pss))
    # plot(mesh)
    # plot(spos, add = TRUE, lwd = 3)
    
    # Evaluate lambda at mesh vertices
    lambda.mesh = lambda(SpatialPoints(mesh$loc))
    lambda.max = max(lambda.mesh)
    n.smp = rpois(1, xoff*yoff * lambda.max)
    sx = x1 + xoff*runif(n.smp)
    sy = y1 + yoff*runif(n.smp)
    
    # Filter
    A = inla.spde.make.A(mesh = mesh, loc = cbind(sx,sy))
    prob = as.vector((A %*% lambda.mesh)/lambda.max)
    keep = runif(n.smp) < prob
    nkeep = sum(keep)
    
    # plot(mesh)
    # points(sx,sy, col = 1+keep)
    
    if (nkeep >0) det = SpatialPointsDataFrame(data.frame(sx,sy)[keep,], data = data.frame(sampler = rep(k, nkeep)))
    
    df = data.frame(n = sum(keep), n.true = n.smp)
    rownames(df) = k
    spdfs = c(spdfs, list(SpatialPolygonsDataFrame(spos, data = df)))
    if (nkeep >0) detections = c(detections, list(det))
    smpls = c(smpls, list(spos))
  }
  

  spdfs = spRbindRecurse(spdfs)
  smpls = spRbindRecurse(smpls)
  detections = do.call(rbind, detections)

  return(list(samplers = spdfs, points = detections, something = smpls, mesh = mesh))
}





