% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/camera.R
\name{shinycamera_UI}
\alias{shinycamera_UI}
\title{Access data from user's cameras: UI function}
\usage{
shinycamera_UI(id, height = "400px")
}
\arguments{
\item{id}{the id you will use to keep track of this component in your app}

\item{height}{Must be a valid CSS unit (like \code{'100\%'}, \code{'400px'},
\code{'auto'}) or a number, which will be coerced to a string and have
\code{'px'} appended.}
}
\value{
A video overlay and a 'shutter' button.
}
\description{
A webcam view and snapshot function. Will send a 3d array (width, height,
colors+opacity) back to your computer of the frame when you click take photo.
Paired with the server function \code{\link{shinycamera}}.
}
\examples{
\dontrun{
shinycameraUI('myrecorder')
}

}
\seealso{
\code{\link{shinycamera}}
}
