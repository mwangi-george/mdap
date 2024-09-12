transactions_tab <- tabItem(
  tabName = "user_transactions",
  fluidRow(
    actionBttn("fetch_transactions_button", label = "Fetch Transactions"),
    post_transaction_ui("post_transaction"),
    delete_transaction_ui("delete_transaction")
  ),
  br(),
  fluidRow(render_transactions_infobox_ui("infoboxes")),
  fluidRow(render_transactions_chart_ui("highcharts"))
)

transactions_history_tab <- tabItem(
  tabName = "transaction_history",
  fluidRow(
    render_transactions_table_ui("historical_transactions")
  )
)

body <- dashboardBody(
  tabItems(
    transactions_tab, transactions_history_tab
  )
)