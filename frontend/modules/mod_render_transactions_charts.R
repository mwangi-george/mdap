render_transactions_chart_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plain_box_template(600, 6, title_text = " ", apexchartOutput(ns("top_10_transaction_types"))),
    plain_box_template(600, 6, title_text = " ", apexchartOutput(ns("top_10_counterparties")))
  )
}


render_transactions_chart_server <- function(id, transactions, active_user) {
  moduleServer(id, function(input, output, session) {
    ## charts ---------------------
    output$top_10_transaction_types <- renderApexchart({
      create_bar_or_column_chart_apex(
        data_with_transactions = transactions,
        chart_type = "column",
        column_to_count = "transaction_type",
        title_text = "Most Recurring Transaction Types",
        subtitle_text = active_user,
        x_axis_text = "Transaction Types",
        y_axis_text = "No. of transactions"
      )
    })
    
    output$top_10_counterparties <- renderApexchart({
      create_bar_or_column_chart_apex(
        data_with_transactions = transactions,
        chart_type = "bar",
        column_to_count = "counterparty",
        title_text = "Most Recurring Counterparties",
        subtitle_text = active_user,
        x_axis_text = "No. of transactions",
        y_axis_text = "Counterparty"
      )
    })
  })
}
