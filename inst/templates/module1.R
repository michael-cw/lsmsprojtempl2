#' UI element
#'
#'
#' @keywords internal
#' @noRd


moduleUI1 <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns('file1'), 'Upload zip files', accept = '.zip'),
    shiny::selectizeInput(ns("event1"), "Event 1", choices = NULL)
  )
}

#' @keywords internal
#' @noRd

moduleUI2 <- function(id) {
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("selectedEvents"))
  )
}

#' Server logic
#'
#'
#' @keywords internal
#' @noRd

moduleSRV <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Your server logic goes here ...

    # Display selected events
    output$selectedEvents <- renderDT({
      filteredData <- data.frame(
        Event = c("Event 1", "Event 2", "Event 3"),
        Date = c("2020-01-01", "2020-01-02", "2020-01-03"),
        stringsAsFactors = FALSE
      )
      datatable(filteredData, options = list(order = list(list(1, 'asc'))), rownames = FALSE)
    })

  })
}
