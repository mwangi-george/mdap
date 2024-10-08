
source("./dependencies_load.R")

## UI building ----------------------------------------------
data_page <- dashboardPage(
  options = list(sidebarExpandOnHover = TRUE),
  header, sidebar, body, controlbar, footer,
  skin = app_color_palette[1]
)

ui <- fluidPage(
  useShinyjs(),
  tags$style(
    # accessed from styles.R
    login_page_style
  ),
  div(
    id = "login-page",
    style = "width: 500px;",
    h3("Welcome", class = "login-header", style = heading_style),
    textInput("api_user", label = "Username", placeholder = "Enter your username", value = "", width = "100%"),
    passwordInput("api_pass", "Password", placeholder = "Enter your password", value = "", width = "100%"),
    actionButton("login", "Login", class = "btn-primary", style = "width: 100%;"),
    br(), br(),
    tags$h4("Or", align = "center"),
    actionButton("register", "Register", class = "btn-secondary", style = "width: 100%;") # Registration button
  ),
  div(
    id = "data-page", hidden = TRUE,
    fluidRow(data_page)
  )
)
