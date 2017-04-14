---
title: "boston Products: Course Project 1: R Markdown and Leaflet"
author: "Yogesh Saletore"
date: "April 14, 2017"
output: html_document
keep_md: true
---
# Bars in Boston Area

```r
library(leaflet)
library(jsonlite)

boston <- fromJSON('https://data.cityofboston.gov/resource/fdxy-gydq.json', flatten = TRUE)
```
April 14, 2017


```r
boston$lat = sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), ",")[1]) })
boston$lng = sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), " ")[2]) })
boston = boston[boston$lat != 0 | boston$lng != 0,]
boston$label = paste(boston$businessname, boston$address, boston$city, boston$dayphn, sep = "<br>")

leaflet(boston) %>% addTiles() %>% addMarkers(popup = data$label)
```

```
## Assuming 'lng' and 'lat' are longitude and latitude, respectively
```

```
## Error in loadNamespace(name): there is no package called 'webshot'
```
