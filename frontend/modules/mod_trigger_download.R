# source("./dependencies_load.R")
# 
# # Download Button UI
# trigger_download_ui <- function(id) {
#   ns <- NS(id)
#   actionBttn(ns("fetch_all_transactions"), label = "Fetch Transactions")
# }
# 
# 
# # Download Back end process
# trigger_download_server <- function(id, auth_token){
#   moduleServer(id, function(input,output, session) {
#     ns <- session$ns
#     
#     return_data <- reactiveVal()
#     
#     # Fetch existing transaction for current user ---------------------------
#     transactions_4_current_user <- eventReactive(input$fetch_all_transactions, {
#       
#       get_req_endpoint <- str_c(generate_base_url(in_production), "transactions/retrieve/all")
#       query_output <- get_all_transactions(get_req_endpoint, auth_token)
#       
#       if (class(query_output) == "data.frame") {
#         output$all_transactions_table <- renderReactable({
#           req(input$fetch_all_transactions)
#           render_reactables_func(query_output)
#         })
#       } else if (class(query_output) == "list"){
#         output$all_transactions_table <- renderReactable({
#           req(input$fetch_all_transactions)
#           shinyalert("Oops!", "You have not posted any transactions", type = "error", closeOnClickOutside = TRUE)
#           render_reactables_func(transactions_output_model())
#         })
#       } else {
#         req(input$fetch_all_transactions)
#         shinyalert("Oops!", query_output, type = "error", closeOnClickOutside = TRUE)
#         render_reactables_func(transactions_output_model())
#       }
#       
#       return(query_output)
#     })
#     return_data(transactions_4_current_user())
#     return(return_data())
#   })
# }