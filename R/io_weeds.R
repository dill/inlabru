#' Weeds survey data
#' 
#' See Melville and Welsh (2001) - Line transect sampling in small regions, Biometrics
#' and Johnson et al. (2010) - A Model-Based Approach for Making Ecological Inference from Distance Sampling Data, Biometrics
#' 
#' @examples \\donttest{ data(weeds) ; plot(weeds)}
#' @name weeds
NULL


# INTERNAL DATA STORAGE
io_weeds.getDataDir = function() {
  return(system.file("data",package="iDistance"))
  # return("/home/fbachl/git/essmod_backup/development/fb/weeds/weeds_report")
  }


#' Regenerate \link{weeds} data and store it to \code{weeds.RData}
#' 
#' @aliases io_weeds.pkgdata.save
#' @export
#' @return NULL
#' @examples \\dontrun{io_weeds.pkgdata.save();}
#' @author Fabian E. Bachl <\email{f.e.bachl@@bath.ac.uk}>
#'

io_weeds.pkgdata.save = function(){
  ## save the data we will include in the R package
  weeds = io_weeds.pkgdata.load()
  save(weeds, file=paste0(io_weeds.getDataDir(),"/weeds.RData"))
}



#' Load \link{weeds} survey data from raw data sets
#'
#' @aliases io_weeds.pkgdata.load
#' @export
#' @return \code{weeds} the \link{weeds} data set
#' @examples \\dontrun{weeds = io_weeds.pkgdata.load();}
#' @author Fabian E. Bachl <\email{f.e.bachl@@bath.ac.uk}>
#'

io_weeds.pkgdata.load = function(){
  #
  # Load and inspect weeds data.
  #
  load(file= paste(io_weeds.getDataDir(), "weeds.all.rda",sep=.Platform$file.sep))
  load(file= paste(io_weeds.getDataDir(), "weeds.lines.rda",sep=.Platform$file.sep))
  
  
  
  #
  # Convert weeds data into iDistance format
  #
  
  #
  # 1) Format weeds effort data
  # 
  effort = data.frame(strat = 1, 
                      trans = paste0("1.",weeds.lines$label),
                      seg = paste0("1.",weeds.lines$label,".1"),
                      det = NA,
                      start.x = weeds.lines$x0, start.y = weeds.lines$y0,
                      end.x = weeds.lines$x1, end.y = weeds.lines$y1,
                      x = NA, y = NA,
                      distance = NA,
                      seen = NA)
  
  #
  # 2) Format detection data. These have to go into the effort data.frame as well.
  #
  
  det = numeric(length(weeds.all$label))
  for (k in 1:length(weeds.all$label)) { det[weeds.all$label == k] = 1:sum(weeds.all$label == k) }
  
  detections = data.frame(strat = 1,
                          trans = paste0("1.",weeds.all$label),
                          seg = paste0("1.",weeds.all$label,".1"),
                          det = paste0("1.",weeds.all$label,".1",det),
                          start.x = weeds.lines[weeds.all$label,"x0"], start.y = weeds.lines[weeds.all$label,"y0"], 
                          end.x = weeds.lines[weeds.all$label,"x1"], end.y = weeds.lines[weeds.all$label,"y1"],
                          weeds.all[,c("x","y")],
                          distance = weeds.all$distance,
                          seen = weeds.all$Seen)
  
  
  
  #
  # 3) Merge effort and detections into one data.frame and assign class "effort"
  #
  weffort = rbind(effort, detections)
  weffort = weffort[order(weffort$seg),] # The ordering is IMPORTANT!
  class(weffort) = c("effort","data.frame")
  
  #
  # Finally, make the dsdata object
  #
  
  dset = make.dsdata(effort = weffort)
  
  return(dset)
}


#' Generate a shapefile describing the weed data transects by polygons
#' 
#' @aliases io_weeds.transect.save
#' @export
#' @return NULL
#' @examples \\dontrun{io_weeds.transect.save();}
#' @author Fabian E. Bachl <\email{f.e.bachl@@bath.ac.uk}>
#'

io_weeds.transect.save = function(){
  
  xx = numeric()
  yy = numeric()
  id = numeric()
  
  for ( k in 1:8 ){
    xx = c(xx, 150*c((k-1), k, k, (k-1)))
    yy = c(yy, 0, 0, 1200, 1200)
    id = c(id,rep(k, 4))
  }
  dd = data.frame(Id = id, x = xx, y = yy)
  
  ddTable <- data.frame(Id = 1:8, Name = paste0("trans_",1:8))
  ddShapefile <- convert.to.shapefile(dd, ddTable, "Id", 5)
  
  write.shapefile(ddShapefile, paste0(io_weeds.getDataDir(),"/weeds.transect"), arcgis = T)
}


#' Generate a shapefile describing the weed data sheeps presence by two polygons
#' 
#' @aliases io_weeds.sheep.save
#' @export
#' @return NULL
#' @examples \\dontrun{io_weeds.sheep.save();}
#' @author Fabian E. Bachl <\email{f.e.bachl@@bath.ac.uk}>
#'

io_weeds.sheep.save = function(){

  dd = data.frame(Id = c(1,1,1,1,2,2,2,2), 
                  x = c(0,600,600,0, 600, 1200, 1200, 600), 
                  y = c(0,0,1200,1200, 0,0,1200,1200))
  
  ddTable <- data.frame(Id = 1:2, Name = paste0("sheep_",1:2))
  ddShapefile <- convert.to.shapefile(dd, ddTable, "Id", 5)
  
  write.shapefile(ddShapefile, paste0(io_weeds.getDataDir(),"/weeds.sheep"), arcgis = T)
}

