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
showListGender = dbGetQuery(mydb, "select distinct gender from PrevHIV")

dbDisconnect(mydb)

# Define UI
shinyUI(fluidPage(
  # Application title
  titlePanel(title="Interactive HIV Prevalance Rates by Countries"),
  sidebarLayout(
    #Sidebar with a drop down menu of countries
    sidebarPanel(
      #Select country
      selectizeInput("dropdownmenu", label = h3("Country"), choices = showList, selected = 'Botswana', multiple = TRUE)
      , sliderInput("slider", label = h3("Year"), min = 1990, max = 2014, value = c(1990,2014), sep = "")
      #, selectizeInput("dropdownmenuGender", label = h3("Gender"), choices = showListGender, selected = "Male", multiple = TRUE))
      ), mainPanel(
      plotOutput("dataPlot")
      )
)
))
