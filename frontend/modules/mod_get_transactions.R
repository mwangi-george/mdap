source("./dependencies_load.R")

# UI
get_transactions_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      actionBttn(ns("fetch_all_transactions"), label = "Fetch Transactions"),
      actionBttn(ns("trigger_transaction_register_button"), label = "Post Transaction"),
      actionBttn(ns("trigger_transaction_delete_button"), label = "Delete a Transaction")
    ),
    br(),
    fluidRow(
      plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("total_transactions"), width = 12)),
      plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("transaction_amount"), width = 12)),
      plain_box_template(120, 4, title_text = " ", infoBoxOutput(ns("transaction_cost"), width = 12)),
      plain_box_template(600, 6, title_text = " ", highchartOutput(ns("top_10_transaction_types"))),
      plain_box_template(600, 6, title_text = " ", highchartOutput(ns("top_10_counterparties")))
    ),
    fluidRow(
      plain_box_template(850, 12, title_text = "Transaction history", reactableOutput(ns("all_transactions_table")))
    )
  )
}

# Logic
get_transactions_server <- function(id, auth_token, active_user){
  moduleServer(id, function(input,output, session) {
    # namespace to access ui elements created in the server side
    ns <- session$ns
    
    # Fetch existing transaction for current user ---------------------------
    transactions_4_current_user <- eventReactive(input$fetch_all_transactions, {
      
      get_req_endpoint <- str_c(generate_base_url(in_production), "transactions/retrieve/all")
      query_output <- get_all_transactions(get_req_endpoint, auth_token)
      
      if (class(query_output) == "data.frame") {
        output$all_transactions_table <- renderReactable({
          req(input$fetch_all_transactions)
          render_reactables_func(query_output)
        })
      } else if (class(query_output) == "list"){
        output$all_transactions_table <- renderReactable({
          req(input$fetch_all_transactions)
          shinyalert("Oops!", "You have not posted any transactions", type = "error", closeOnClickOutside = TRUE)
          render_reactables_func(transactions_output_model())
        })
      } else {
        req(input$fetch_all_transactions)
        shinyalert("Oops!", query_output, type = "error", closeOnClickOutside = TRUE)
        render_reactables_func(transactions_output_model())
      }
      
      return(query_output)
    })
    
    ## Value boxes ------------
    observe({
      req(transactions_4_current_user())
      
      transactions_data_4_valuebox <- transactions_data_4_valuebox_func(transactions_4_current_user())
      
      output$total_transactions <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Transactions",
          value = prettyNum(transactions_data_4_valuebox$total_transactions, big.mark = ", "),
          color = "teal",
          icon = icon("laptop-code")
        )
      })
      
      output$transaction_amount <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Amount Transacted",
          value = prettyNum(transactions_data_4_valuebox$transaction_amount, big.mark = ", "),
          color = "teal",
          icon = icon("laptop-code")
        )
      })
      
      output$transaction_cost <- renderInfoBox({
        infoBox(
          width = 12,
          title = "",
          subtitle = "Total Transaction Costs",
          value = prettyNum(transactions_data_4_valuebox$transaction_cost, big.mark = ", "),
          color = "teal",
          icon = icon("laptop-code")
        )
      })
      
      ## charts ---------------------
      output$top_10_counterparties <- renderHighchart({
        
        create_bar_or_column_chart_func(
          data_with_transactions = transactions_4_current_user(), 
          chart_type = "column", 
          column_to_count = "counterparty",
          title_text = "Most Recurring Counterparties",
          subtitle_text = active_user, 
          x_axis_text = "Counterparty", 
          y_axis_text = "No. of transactions"
        )
      })
      
      output$top_10_transaction_types <- renderHighchart({
        
        create_bar_or_column_chart_func(
          data_with_transactions = transactions_4_current_user(), 
          chart_type = "bar", 
          column_to_count = "transaction_type",
          title_text = "Most Recurring Transaction Types",
          subtitle_text = active_user, 
          x_axis_text = "Transaction Types", 
          y_axis_text = "No. of transactions"
        )
      })
      
    })
    
    ### Registering a transaction --------------
    observeEvent(input$trigger_transaction_register_button, {
      showModal(modalDialog(
        title = "Register a transaction",
        textAreaInput(
          inputId = ns("user_transaction_message"), label = "", 
          placeholder = "Paste your Mpesa Message here...",
          width = "100%", height = "150px"
        ),
        actionButton(ns("perform_transaction_registration_button"), "Register", class = "btn-primary"),
        easyClose = TRUE,
        size = "m",
        footer = modalButton("Close", icon = icon("arrow-right-to-bracket"))
      ))
    })
    
    
    # Registering a new transaction
    observeEvent(input$perform_transaction_registration_button, {
      req(input$user_transaction_message)
      req(input$perform_transaction_registration_button)
      
      post_req_endpoint <- str_c(generate_base_url(in_production), "transactions/new")
      res <- post_a_transaction(post_req_endpoint, auth_token, input$user_transaction_message)
      
      # when we expect a connection error
      if (class(res) == "character") {
        
        shinyalert("Oops!", res, type = "error", closeOnClickOutside = TRUE)
      } else {
        
        # status code $ api response message
        s_code <- res %>% status_code()
        message <- res %>% content()
        
        if (s_code == 201L) {
          shinyalert("Post Successful!", message[[1]], type = "success", closeOnClickOutside = TRUE)
        } else if (s_code == 406L) {
          shinyalert("Oops!", message[[1]], type = "error", closeOnClickOutside = TRUE)
        }
      }
    })
    
    ### Deleting a transaction -------------------------------
    
    # Trigger to transaction deletion modal
    observeEvent(input$trigger_transaction_delete_button, {
      showModal(modalDialog(
        title = "Delete a transaction",
        textAreaInput(ns("transaction_code_to_delete"), "Transaction Code", placeholder = "Enter transaction code here...", width = "100%"),
        actionButton(ns("perform_transaction_deletion_button"), "Delete", class = "btn-primary"),
        easyClose = TRUE,
        size = "m",
        footer = modalButton("Close", icon = icon("arrow-right-to-bracket"))
      ))
    })
    
    # delete the transaction
    observeEvent(input$perform_transaction_deletion_button, {
      req(input$transaction_code_to_delete)
      req(input$perform_transaction_deletion_button)
      
      delete_req_endpoint <- str_c(generate_base_url(in_production), "transactions/delete")
      deletion_response <- delete_a_transaction_func(delete_req_endpoint, input$transaction_code_to_delete, auth_token)
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
    # End of module
  })
}


