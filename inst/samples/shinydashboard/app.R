## app.R ##
library(shiny)
library(shinydashboard)
library(shinyevents)

ui <- dashboardPage(
  dashboardHeader(title = "shinyevents sample"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(
        title = "Inputs", status = "info",
        textInput("text", "Text"),
        selectInput("dropdown", "Dropdown", c("one", "two", "three")),
        sliderInput("slider", "Slider", 1, 10, 5),
        actionButton("button", "Button")
      ),
      box(
        title = "Plot", status = "info",
        plotOutput("plot")
      )
    ),
    fluidRow(
      box(
        title = "Last 25 events", status = "success",
        tableOutput("events"), width = 12
      )
    )
  )
)

server <- function(input, output, session) {

  # shinyevents tracking main section -----------------------------
  ## Initialized a new shinyevents variable, we'll call it `tracker`
  tracker <- shiny_events_to_csv()
  ## A simple entry that logs when the app is initially started
  tracker$event("app_initiated")
  ## Changes to inputs can be tracked using shiny::observeEvent()
  observeEvent(input$text, tracker$event("text_change", input$text), ignoreInit = TRUE)
  observeEvent(input$button, tracker$event("button_clicked"), ignoreInit = TRUE)
  observeEvent(input$dropdown, tracker$event("dropdown_changed", input$dropdown), ignoreInit = TRUE)
  observeEvent(input$slider, tracker$event("slider_changed", input$slider), ignoreInit = TRUE)
  ## session$onSessionEnded allows to track when the session was ended
  session$onSessionEnded(function() tracker$event("close_app"))

  output$plot <- renderPlot({
    input$button
    rnorm_size <- 1000000 * isolate(input$slider)
    ## Tracks when the output's code was started
    tracker$event("plot_start", rnorm_size)
    d <- rnorm(rnorm_size)
    hist(d, main = paste("Histogram of rnorm() size", rnorm_size))
    ## Tracks when the code was completed
    tracker$event("plot_complete")
  })

  event_data <- reactiveFileReader(1000, session, "shiny-events.csv", read.csv,
    stringsAsFactors = FALSE,
    col.names = c("guid", "app", "activity", "value", "datetime")
  )

  output$events <- renderTable({
    ce <- event_data()
    ce$guid <- paste0(substr(ce$guid, 1, 9), "...")
    ce$time <- substr(ce$datetime, 12, 19)
    ce$date <- substr(ce$datetime, 1, 10)
    ce <- ce[nrow(ce):1, ]
    ce <- ce[, c("time", "date", "guid", "activity", "value", "app")]
    head(ce, 25)
  })
}

shinyApp(ui, server)
