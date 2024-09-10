source("./dependencies_load.R")

# Download Button UI
fetch_transactions_ui <- function(id) {
  ns <- NS(id)
  actionBttn(ns("fetch_transactions_button"), label = "Fetch Transactions")
}


# Download Back end process
fetch_transactions_server <- function(id, auth_token, active_user){
  moduleServer(id, function(input,output, session) {

    # Fetch existing transaction for current user ---------------------------
    mod_return_value <- eventReactive(input$fetch_transactions_button, {

      get_req_endpoint <- str_c(generate_base_url(in_production), "transactions/retrieve/all")
      query_output <- get_all_transactions(get_req_endpoint, auth_token, active_user)

      return(query_output)
    })
    
    return(mod_return_value())
  })
}