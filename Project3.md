Eating out in Boston
========================================================
author: Yogesh Saletore
date: April 30, 2017
autosize: true

The First Iteration
========================================================
<small>
The first project focused on using leaflet to create a map. I utilized a JSON library to load information from a Boston database and displayed an interactive map. While the application was successful, some of the feedback was that there was too much information there. 

GitHub: <https://github.com/ysaletore/Data-Products>


```r
library(leaflet)
library(jsonlite)
library(plotly)

boston <- fromJSON('https://data.cityofboston.gov/resource/fdxy-gydq.json', flatten = TRUE)
boston <- boston[boston$licstatus == "Active",]
boston <- boston[,c("address", "businessname", "city", "dayphn", "location.coordinates")]

boston$lng <- sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), ",")[1]) })
boston$lat <- sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), " ")[2]) })
boston <- boston[boston$lat != 0 | boston$lng != 0,]
boston$label <- paste(boston$businessname, boston$address, boston$city, boston$dayphn, sep = "<br>")

widget <- leaflet(boston) %>% addTiles() %>% addMarkers(popup = boston$label)
htmlwidgets::saveWidget(as.widget(widget), file = "widget.html")
```
</small>
Demo of First Iteration
========================================================
<iframe src="https://ysaletore.github.io/Data-Products/" style="position:absolute;height:100%;width:100%"></iframe>

As a Shiny app
========================================================
<small>
A Shiny app enabled me to create specific UI elements, text boxes and select inputs, that could enable the user to either search for a specific business or address, or filter by the type of place or location that they were interested in. The leaflet map can then automatically update to allow the user to find locations much faster. 

While the first iteration was a simple R script, the app is structured into individual server and UI components. 
- The data is initially loaded using JSON. 
- The UI uses the data to limit the choices for the select applications. 
- The server uses a reactive to filter the data to the relevant rows
- The leaflet component uses that reactive to render the same leaflet map as before, this time filtered on the input fields.
</small>

The Shiny App
========================================================

ShinyApps.IO: <https://ysaletore.shinyapps.io/data_products_shiny_project2/>

GitHub: <https://github.com/ysaletore/Data-Products>
