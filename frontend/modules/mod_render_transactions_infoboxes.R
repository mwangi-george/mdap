render_transactions_infobox_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("total_transactions"), width = 12)),
    plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("transaction_amount"), width = 12)),
    plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("transaction_cost"), width = 12)),
  )
}

render_transactions_infobox_server <- function(id, fetched_transactions) {
  moduleServer(id, function(input, output, session) {
    
    observe({
      fetched_transactions
      
      transformed_data <- summarize_fetched_transactions(fetched_transactions)
      
      output$total_transactions <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Transactions",
          value = prettyNum(transformed_data$total_transactions, big.mark = ", "),
          color = "teal",
          icon = icon("hashtag")
        )
      })
      
      output$transaction_amount <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Amount Transacted",
          value = prettyNum(transformed_data$transaction_amount, big.mark = ", "),
          color = "teal",
          icon = icon("hand-holding-dollar")
        )
      })
      
      output$transaction_cost <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Transaction Costs",
          value = prettyNum(transformed_data$transaction_cost, big.mark = ", "),
          color = "teal",
          icon = icon("money-check-dollar")
        )
      })
    })
    
  })
}