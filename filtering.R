
library(maps)
library(sf)
library(leaflet)
library(dplyr)
library(shiny)
library(bigrquery)
library(fontawesome)

con <- dbConnect(
    bigrquery::bigquery(),
    project = "tides-saas-309509",
    dataset = "917302307943",
    billing = "tides-saas-309509"
)
sql <- "SELECT *  FROM `tides-saas-309509.917302307943.mapping`"
ds <- bq_dataset("tides-saas-309509", "mapping")
tb <- bq_dataset_query(ds,
    query = sql,
    billing = "tides-saas-309509"
)
bqdata <- bq_table_download(tb)

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%; height:100%} "),
    leafletOutput("mymap", height = "100%"),
    absolutePanel(
        style = "background: #dddddd; padding: 10px",
        top = 10, right = 10, draggable = TRUE,
        radioButtons("flow_name", h3("Select the Flow Name"),
            choices = list(
                "All" = "", "Tree" = "Tree", "Pothole" = "Pothole"
            )
        )
    )
)

logos <- awesomeIconList(
    "Pothole" = makeAwesomeIcon(
        icon = "fire",
        markerColor = "blue",
        library = "fa"
    ),
    "Tree" = makeAwesomeIcon(
        icon = "tree",
        markerColor = "green",
        library = "fa"
    )
)

server <- function(input, output, session) {
    output$mymap <- renderLeaflet({
        filtered_data <- bqdata %>%
            dplyr::filter(if (input$flow_name == "") {
                flow_name != ""
            } else {
                flow_name == input$flow_name
            })
        leaflet(filtered_data) %>%
            addTiles() %>%
            addAwesomeMarkers(
                lat = ~lat, lng = ~long,
                icon = ~ logos[flow_name],
                popup = paste0(
                    "<h4>", filtered_data$flow_name, "</h4>",
                    "<img src = ", filtered_data$image,
                    ' width="100%"  height="100"', ">",
                    "<p> Shared by ",
                    filtered_data$name, " on ",
                    filtered_data$inserted_at,
                    "</p>"
                ),
                clusterOptions = markerClusterOptions()
            )
    })
}


shinyApp(ui, server)
