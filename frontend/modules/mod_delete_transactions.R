source("./dependencies_load.R")


delete_transaction_ui <- function(id){
  ns <- NS(id)
  tagList(
    actionBttn(ns("transaction_delete_button"), label = "Delete a Transaction"),
  )
}


delete_transaction_server <- function(id, auth_token, active_user) {
  moduleServer(id, function(input, output, session) {
    # get namespace
    ns <- session$ns
    
    # Trigger to transaction deletion modal
    observeEvent(input$transaction_delete_button, {
      showModal(modalDialog(
        title = "Delete a transaction",
        textAreaInput(ns("transaction_code"), "Transaction Code", placeholder = "Enter transaction code here...", width = "100%"),
        actionButton(ns("perform_transaction_deletion_button"), "Delete", class = "btn-primary"),
        easyClose = TRUE,
        size = "m",
        footer = modalButton("Close", icon = icon("arrow-right-to-bracket"))
      ))
    })
    
    # delete the transaction
    observeEvent(input$perform_transaction_deletion_button, {
      req(input$transaction_code)
      
      delete_req_endpoint <- str_c(generate_base_url(in_production), "transactions/delete")
      deletion_response <- delete_a_transaction_func(delete_req_endpoint, input$transaction_code, auth_token, active_user)
      s_code <- deletion_response %>% status_code()
      message <- deletion_response %>% content()
      
      if (s_code == 200L) {
        shinyalert("Deletion Successful!", message[[1]], type = "success", closeOnClickOutside = TRUE)
      } else if (s_code == 404) {
        shinyalert("Oops!", message[[1]], type = "error", closeOnClickOutside = TRUE)
      } else if (s_code == 500L) {
        shinyalert("Oops!", message[[1]], type = "error", closeOnClickOutside = TRUE)
      } 
    })
  })
}