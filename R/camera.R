#' Access data from user's cameras: UI function
#'
#' A webcam view and snapshot function. Will send a 3d array (width, height,
#' colors+opacity) back to your computer of the frame when you click take photo.
#' Paired with the server function \code{\link{shinycamera}}.
#'
#' @seealso \code{\link{shinycamera}}
#' @param id the id you will use to keep track of this component in your app
#' @param height Must be a valid CSS unit (like \code{'100\%'}, \code{'400px'},
#'   \code{'auto'}) or a number, which will be coerced to a string and have
#'   \code{'px'} appended.
#'
#' @return A video overlay and a 'shutter' button.
#'
#' @examples
#' \dontrun{
#' shinycameraUI('myrecorder')
#' }
#'
#' @export
shinycamera_UI = function(id, height = '400px'){
  # Create a namespace function using the provided id
  ns = shiny::NS(id)

  #set up output
  r2d3::d3Output(ns("shinycamera"), height = height)
}


#' Access data from user's cameras: Server function
#'
#' Upon completion of line draw, returns a reactive variable that contains a
#' vector of the y coordinates of what the user has drawn. This also includes
#' the start point specified with `draw_start` This is the server component of
#' shinycamera. You never directly use this function but instead call it through
#' the shiny function `callModule()`. See the example for how to do this. Paired
#' with the UI function \code{\link{shinycamera_UI}}.
#'
#' @seealso \code{\link{shinycamera_UI}}
#' @param input,output,session you can ignore these as it is taken care of by
#'   \code{shiny::callModule()}
#' @param output_width How many pixels wide want your returned photos/the view
#'   of the webcam. Defaults to \code{300}.
#' @param output_height How many pixels tall want your returned photos/the view
#'   of the webcam. If left unspecified, defaults to a square image,
#'   \code{output_width} value.
#'
#'
#' @return A reactive function that will return a 3D array with dimensions
#'   \code{(height, width, channels (RGBA))} corresponding to the image taken by
#'   the webcam when shutter was pressed. The RGBA are all in the range of 0-1.
#'
#' @examples
#' \dontrun{
#' camera_snapshot = callModule( shinycamera, 'my_camera', output_width = 350)
#' }
#'
#' @export
shinycamera = function(input, output, session,
                      output_width = 300,
                      output_height = NULL ) {

  # If there's no input for height, make square
  if (is.null(output_height)) {
    output_height = output_width
  }

  # Setup unique message passing ids for shiny and js
  photo_send_loc = session$ns('viewr_message')
  photo_recieved_loc = session$ns('photo_recieved')

  output$shinycamera = r2d3::renderD3(
    r2d3::r2d3(
      system.file("r2d3/viewr/main.js", package = "shinycamera"),
      data = NULL,
      container = 'div',
      dependencies = 'd3-jetpack',
      options = list(
        shiny_message_loc = photo_send_loc,
        shiny_ready_loc = photo_recieved_loc,
        output_size = list(
          width = output_width,
          height = output_height
        )
      )
    )
  )

  shiny::reactive({
    shiny::req(input$viewr_message)

    raster_image = gsub('data:image/png;base64,', '', input$viewr_message, fixed = TRUE)
    raster_image = gsub(' ', '+', raster_image, fixed = TRUE)
    raster_image = jsonlite::base64_dec(raster_image)
    raster_image = png::readPNG(raster_image)
    raster_image = grDevices::as.raster(raster_image[ , , -4])

    # send message to javascript to let it know we got image
    session$sendCustomMessage(photo_recieved_loc, 'yay!');

    raster_image
  })
}