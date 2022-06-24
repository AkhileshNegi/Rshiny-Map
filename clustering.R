
library(maps)
library(sf)
library(leaflet)
library(dplyr)
library(shiny)
library(bigrquery)

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

ui <- fillPage(
    titlePanel("Glific Mapping"),
    tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
    leafletOutput("mymap", width = "100%", height = "100%")
)

logos <- awesomeIconList(
    "Pothole" = makeAwesomeIcon(
        icon = "fire",
        markerColor = "blue",
        library = "fa"
    ),
    "Tree Cover" = makeAwesomeIcon(
        icon = "tree",
        markerColor = "green",
        library = "fa"
    )
)


server <- function(input, output, session) {
    output$mymap <- renderLeaflet({
        leaflet(bqdata %>%
            dplyr::filter()) %>%
            addTiles() %>%
            addAwesomeMarkers(
                lat = ~lat, lng = ~long,
                icon = ~ logos[flow_name],
                popup = paste0(
                    "<h6>", bqdata$flow_name,
                    "</h6>", "<img src = ",
                    bqdata$image, ' width="95"', ">"
                ),
                clusterOptions = markerClusterOptions()
            )
    })
}


shinyApp(ui, server)
