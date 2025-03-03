library(tidyverse)
library(leaflet)
library(readxl)
library(leaflet.providers)
library(raster)
library(sf)



IND_2 <- getData("GADM", country = "IND", level = 3)
pal <- colorFactor(
  palette = "Paired",
  domain = IND_2@data$NAME_1
)
IND_2 %>%
  leaflet() %>%
  addProviderTiles(providers$Esri.WorldShadedRelief) %>%
  addPolygons(
    weight = 1,
    stroke = TRUE,
    color = "white",
    fillColor = ~ pal(NAME_1),
    fillOpacity = 0.7,
    dashArray = "3",
    label = ~NAME_3,
    popup = ~ paste(
      "Zila:", NAME_3,
      "<br/>",
      "District:", NAME_2,
      "<br/>",
      "State:", NAME_1,
      "<br/>",
      "Country:", NAME_0
    ),
    highlight = highlightOptions(
      weight = 2,
      dashArray = "",
      color = "red",
      bringToFront = TRUE
    )
  )