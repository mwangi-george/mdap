sidebar <- dashboardSidebar(
  # minified = TRUE, collapsed = TRUE,
  sidebarMenu(
    menuItem("Transactions",  tabName = "user_transactions", icon = icon("angles-down"))
  )
)
