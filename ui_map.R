library(shiny)
library(RMySQL)
library(RODBC)

# Define UI
shinyUI(fluidPage(
  # Application title
  titlePanel(title="Interactive HIV Prevalance Rates Worldwide"),
  sidebarLayout(
    #Sidebar with a slider for year
    sidebarPanel(
      #Select country
      sliderInput("slider", label = h3("Year"), min = 1990, max = 2014, value = 1990, sep = "")
      ), mainPanel(
      plotOutput("dataPlot")
      )
)
))
