header <- dashboardHeader(
  title = "MPESA Data Analyzer",
  leftUi = tagList(
    br(),
    uiOutput("current_userOutput")
  )
)