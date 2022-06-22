
library(ggplot2)
library(ggmap)
library(RColorBrewer)
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
sql <- "SELECT CAST(latitude AS FLOAT64) as lat, CAST(longitude AS FLOAT64) as long FROM `tides-saas-309509.917302307943.messages` where longitude is not null"
ds <- bq_dataset("tides-saas-309509", "contacts")
tb <- bq_dataset_query(ds,
    query = sql,
    billing = "tides-saas-309509"
)
bqdata <- bq_table_download(tb)

coords.data <- bqdata
# Active Region Glific bounds
# map_bounds <- c(left = 75, bottom = 25, right = 85, top = 35)
# India bounds
map_bounds <- c(left = 68, bottom = 8, right = 98, top = 38)
coords.map <- get_stamenmap(map_bounds, zoom = 7, maptype = "toner-lite")
coords.map <- ggmap(coords.map, extent = "device", legend = "none")
# heat map layer: Polygons with fill color based on relative frequency of coordinates
coords.map <- coords.map + stat_density2d(data = coords.data, aes(x = long, y = lat, fill = ..level.., alpha = ..level..), geom = "polygon")
# fill the density contours
coords.map <- coords.map + scale_fill_gradientn(colours = rev(brewer.pal(7, "Spectral")))
# Add the coords,color red and define shape
coords.map <- coords.map + geom_point(data = coords.data, aes(x = long, y = lat), fill = "red", shape = 23, alpha = 0.8)

coords.map <- coords.map + theme_bw()
ggsave(filename = "./coords.png")
