source("./dependencies_load.R")

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
in_production <- FALSE 

# color palette for the application
app_color_palette <- c("#5bcefa", "#00ffff", "#ffffff", "#2d677d", "#000000")
