render_transactions_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plain_box_template(850, 12, title_text = "Transaction history", reactableOutput(ns("all_transactions_table")))
  )
}


render_transactions_table_server <- function(id, transactions_df) {
  moduleServer(id, function(input, output, session) {
    
    observe({
      transactions_df
      
      if (class(transactions_df) == "data.frame") {
        
        output$all_transactions_table <- renderReactable({
          render_reactables_func(transactions_df)
        })
        
      } else if (class(transactions_df) == "list"){
        
        shinyalert("Oops!", "You have not posted any transactions", type = "error", closeOnClickOutside = TRUE)
        output$all_transactions_table <- renderReactable({
          render_reactables_func(transactions_output_model())
        })
        
      } else {
        
        shinyalert("Oops!", transactions_df, type = "error", closeOnClickOutside = TRUE)
        output$all_transactions_table <- renderReactable({
          render_reactables_func(transactions_output_model())
        })
        
      }
    })
  })
}