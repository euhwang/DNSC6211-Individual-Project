library(shiny)
library(ggplot2)
library(RMySQL)
library(rgdal)
library(plyr)
library(dplyr)
library(scales)
library(RColorBrewer)

#****Need to set working directory in line 45****

shinyServer(
  function(input, output, session) {

    #MySQL Database Connection
    mysql_host <- "localhost"
    mysql_port <- 3306
    mysql_user <- "root"
    mysql_pass <- "root"
    mysql_dbname <- "HIV"
    
    mydb = dbConnect(MySQL(), 
                     user=mysql_user, 
                     password=mysql_pass, 
                     dbname=mysql_dbname, 
                     host=mysql_host,
                     port=mysql_port)
    
    #Read the whole table
    full_table = dbGetQuery(mydb, "select * from PrevHIV where Gender = 'Total'")
    colnames(full_table)[1]<-"name"
    
    dbDisconnect(mydb)
    
    #Generate plot
    output$dataPlot <- renderPlot({
      
      #Get min and max year based on input
      minval <- input$slider[1]

      #Create a subset of data
      df_subset <- subset(full_table,Year==minval) 
      
      #Be sure to change to desired working directory on your computer
      #Set working directory, download necessary map files, and unzip them
      setwd("/home/vagrant/.spyder/Final Individual Assignment/Option 2")
      download.file("http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip", destfile="ne_110m_admin_0_countries.zip")
      unzip("ne_110m_admin_0_countries.zip")
      
      #Build a blank theme for ggplot
      theme_opts <- list(theme(panel.grid.minor = element_blank(),
                               panel.grid.major = element_blank(),
                               panel.background = element_blank(),
                               plot.background = element_rect(fill="white"),
                               panel.border = element_blank(),
                               axis.line = element_blank(),
                               axis.text.x = element_blank(),
                               axis.text.y = element_blank(),
                               axis.ticks = element_blank(),
                               axis.title.x = element_blank(),
                               axis.title.y = element_blank(),
                               plot.title = element_text(size=22)))
      
      #load a map with the polygons of the countries
      wmap_countries <- readOGR(dsn=".", layer="ne_110m_admin_0_countries")
      #Project the map onto Robinson coordinates
      wmap_countries_robin <- spTransform(wmap_countries, CRS("+proj=robin"))
      #Turn the map into a dataframe that we can draw
      wmap_countries_robin_df <- fortify(wmap_countries_robin)
      
      wmap_countries_robin@data$id <- rownames(wmap_countries_robin@data)
      wmap_countries_robin_df_final <- join(wmap_countries_robin_df, wmap_countries_robin@data, by="id")
      
      #Join world map countries to world bank data
      final <- left_join(wmap_countries_robin_df_final, df_subset, by="name")
      
      #Sets indicator scale
      final$Prevalence<- cut(final$Prevalence, breaks=c(0,0.1,0.5,1,2,4,10,20,30), ordered_result=TRUE)
      
      #Plots the world map with a range of orange coloring based on the scale value for each country
      p <- ggplot(subset(final, !continent == "Antarctica")) + 
        geom_path(aes(long, lat, group = group), color = "white") +
        geom_polygon(aes(long, lat, group = group, fill = Prevalence)) + 
        scale_fill_brewer("8 Indicator Scale", type="seq", palette="Green", na.value = "grey") + 
        theme_opts + coord_equal(xlim=c(-13000000,16000000), ylim=c(-6000000,8343004)) +
        ggtitle("HIV Prevalence Rates Worldwide")
      
      #prints the map
      print(p)

    }, height = 500, width = 750)
  }
)
