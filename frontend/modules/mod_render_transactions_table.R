render_transactions_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plain_box_template(850, 12, title_text = "Transaction history", reactableOutput(ns("all_transactions_table"))),
    downloadBttn(ns("download_transactions"), "Download")
  )
}


render_transactions_table_server <- function(id, transactions_df, active_user) {
  moduleServer(id, function(input, output, session) {
    
    observe({
      transactions_df
      
      if (class(transactions_df) == "data.frame") {
        
        output$all_transactions_table <- renderReactable({
          # allow current user to download a csv of the feteched data
          output$download_transactions <- downloadHandler(
            filename = function() {
              glue("data_for_{active_user}_on_{today()}.csv")
            },
            content = function(file) {
              write.csv(transactions_df, file, row.names = FALSE)
            }
          )
          
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