
library(tidyverse)
library(fs)
library(shinyjs)
library(httr)
library(shiny)
library(shinydashboard)
library(memoise)
library(shinyWidgets)
library(jsonlite)
library(reactable)
library(glue)
library(shinydashboardPlus)
library(shinyalert)

# custom functions and styles 
map(dir_ls("./utils/"), ~source(.x))

# source modules
map(dir_ls("./modules/"), ~source(.x))

# source front end components
map(dir_ls("./ui/"), ~source(.x))


# runtime options
options(
  shiny.launch.browser = TRUE
)

# change to false to run in dev mode
in_production <- TRUE

app_color_palette <- c("#5bcefa", "#00ffff", "#ffffff", "#2d677d", "#000000")
