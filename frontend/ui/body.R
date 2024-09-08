transactions_tab <- tabItem(
  tabName = "user_transactions",
  get_transactions_ui("transactions_mod")
)

body <- dashboardBody(
  
  tabItems(
    transactions_tab
  )
)