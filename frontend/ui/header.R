header <- dashboardHeader(
  title = "MPESA Data Analyzer",
  leftUi = tagList(
    br(),
    uiOutput("current_userOutput"),
    tags$li(
      class = "dropdown", # Ensures it's aligned properly in the header
      tags$div(
        tags$style(HTML(logout_button_hover_style)),
        tags$button(
          a(icon("right-from-bracket"),
            "Logout",
            href = "javascript:window.location.reload(true)",
            style = "text-decoration: none; color: inherit;" # Ensures the link doesn't change styles
          ),
          style = logout_button_style
        ),
        style = "float: right; margin-right: -12px;" # Ensures the button is on the far right
      )
    )
  )
)
