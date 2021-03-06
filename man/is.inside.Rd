% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mesh.R
\name{is.inside}
\alias{is.inside}
\title{Query if a point is inside the mesh boundary}
\usage{
is.inside(mesh, loc, mesh.coords = NULL)
}
\arguments{
\item{mesh}{an inla.mesh object}

\item{mesh.coords}{Coordinate names of the mesh. Use only if loc is a data.frame with respective column names.}

\item{points}{points to query}
}
\value{
inside Boolean, TRUE if inside
}
\description{
Query if a point is inside the mesh boundary
}
\author{
Fabian E. Bachl <\email{f.e.bachl@bath.ac.uk}>
}

