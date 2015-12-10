library(shiny)
library(ggplot2)
library(RMySQL)

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
    full_table = dbGetQuery(mydb, "select * from PrevHIV")
    
    dbDisconnect(mydb)
    
    #Generate plot
    output$dataPlot <- renderPlot({
      
      #Get min and max year based on input
      minval <- input$slider[1]
      maxval <- input$slider[2]
      
      #Get values based on user input
      chosencountry <- input$dropdownmenu
      chosengender <- input$dropdownmenuGender
      
      #Create a subset of data
      df_subset <- subset(full_table,Country==chosencountry &(Year>=minval)&(Year<=maxval)) #& Gender==chosengender)

      #Plots the prevalence rate for each gender over 10 years
      p <- ggplot(data = df_subset, aes(x=Year, y=Prevalence, group = interaction(Gender, Country), colour = interaction(Gender, Country))) + 
        geom_line(aes(linetype=Gender),size = 1)+
        geom_point(size = 3, fill = "white") +
        xlab("Year") + 
        ylab("Prevalence Rate %") +
        ggtitle("HIV Prevalence Rate")
      
      #Prints the line graph
      print(p)
    }, height = 500, width = 750)
  }
)
