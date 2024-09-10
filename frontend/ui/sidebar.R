sidebar <- dashboardSidebar(
  # minified = TRUE, collapsed = TRUE,
  sidebarMenu(
    menuItem("Transactions",  tabName = "user_transactions", icon = icon("angles-down")),
    menuItem("History", tabName = "transaction_history", icon = icon("list-check"))
  )
)
