library(maps)
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
sql = "SELECT contact_name as name, contact_phone, id as pop, CAST(latitude AS FLOAT64) as lat, CAST(longitude AS FLOAT64) as long, '0' as capital  FROM `tides-saas-309509.917302307943.messages` where longitude is not null"
ds <- bq_dataset("tides-saas-309509", "contacts")
tb <- bq_dataset_query(ds,
                       query = sql,
                       billing = "tides-saas-309509"
)
bark = bq_table_download(tb)

ui <- fluidPage(
  titlePanel("My first R shiny app"),
  leafletOutput("mymap")
)

server <- function(input, output, session) {
  output$mymap <- renderLeaflet({
    leaflet(bark %>%
              dplyr::filter(
              )) %>%
    addTiles() %>%
   addMarkers(lat = ~lat, lng= ~long)
  })
}


shinyApp(ui, server)

