library(shiny)
library(leaflet)
library(jsonlite)
library(DT)
library(dplyr)
library(RCurl)

# read in the data set live using JSON and then filter it down to what we need
boston <- fromJSON(getURL('http://data.cityofboston.gov/resource/fdxy-gydq.json'), flatten = TRUE)
boston = boston[boston$licstatus == "Active",]
boston = boston[,c("address", "businessname", "city", "dayphn", "location.coordinates", "descript",
	"licensecat", "licstatus", "property_id", "state", "zip")]

# split out the lat/lng for leaflet
boston$lng = sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), ",")[1]) })
boston$lat = sapply(boston$location.coordinates, function(X) { as.numeric(strsplit(as.character(X), " ")[2]) })
boston = boston[boston$lat != 0 | boston$lng != 0,]

# create a label field to display more info
boston$label = paste(boston$businessname, boston$address, boston$city, boston$dayphn, sep = "<br>")

server <- function(input, output, session) {
	
	# reactive to filter the data live based on UI changes
	filtered_data <- reactive({
		filt_data <- boston
		
		if(!is.null(input$address) && input$address != "") {
			filt_data <- filt_data %>% filter(grepl(input$address, filt_data$address, ignore.case = TRUE))
		}
		
		if(!is.null(input$businessname) && input$businessname != "") {
			filt_data <- filt_data %>% filter(grepl(input$businessname, filt_data$businessname, ignore.case = TRUE))
		}
		
		if(!is.null(input$city) && input$city != "") {
			filt_data <- filt_data %>% filter_(paste0("city == '", input$city, "'"))
		}
		
		if(!is.null(input$descript) && input$descript != "") {
			filt_data <- filt_data %>% filter_(paste0("descript == '", input$descript, "'"))
		}
		
		if(!is.null(input$licensecat) && input$licensecat != "") {
			filt_data <- filt_data %>% filter_(paste0("licensecat == '", input$licensecat, "'"))
		}
		
		filt_data
	})
	
	# this will generate the simple leaflet plot utilizing the filtered_data() reactive
	output$mymap <- renderLeaflet({
		leaflet(filtered_data()) %>% 
			addTiles() %>% 
			addMarkers(popup = boston$label)
	})
	
	# a data table using the filtered_data() reactive
	output$data_table <- DT::renderDataTable(DT::datatable({
		filtered_data()
	}, rownames = FALSE, options = list(scrollX = TRUE)))
}

ui <- fluidPage(
	headerPanel("Interactive Map of Places to Eat in Boston"),
	fluidRow(
		# UI elements for filtering
		column(width = 2,
			p("Use these inputs to filter the data at right. The text inputs perform case-insensitive search, while the select fields filter based on a single value."),
			textInput("address", label = "Address"),
			textInput("businessname", label = "Business Name"),
			selectInput("city", label = "City", choices = c(Choose = "", unique(boston$city))),
			selectInput("descript", label = "Description", choices = c(Choose = "", unique(boston$descript))),
			selectInput("licensecat", label = "License Category", 
				choices = c(Choose = "", unique(boston$licensecat)))
		),
		# data table view
		column(width = 4, div(dataTableOutput("data_table"), style = "font-size:80%")),
		# leaflet view
		column(width = 6, leafletOutput("mymap"))
	)
)

shinyApp(ui = ui, server = server)