library(shiny)
library(RMySQL)
library(RODBC)

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

#Gets distinct countries for the dropdownmenu
showList = dbGetQuery(mydb, "select distinct country from PrevHIV")

dbDisconnect(mydb)

# Define UI
shinyUI(fluidPage(
  # Application title
  titlePanel(title="Interactive HIV Prevalance Rates by Countries"),
  sidebarLayout(
    #Sidebar with a drop down menu of countries
    sidebarPanel(
      #Select country
      selectInput("dropdownmenu", label = h3("Country"), choices = showList, selected = 'Botswana', multiple = FALSE)),
                mainPanel(
      plotOutput("dataPlot")
    )
  )
))
