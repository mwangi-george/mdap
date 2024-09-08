
library(dplyr)
library(purrr)
library(tidyr)
library(tibble)
library(lubridate)
library(fs)
library(shinyjs)
library(httr)
library(shiny)
library(shinydashboard)
library(memoise)
library(shinyWidgets)
library(jsonlite)
library(reactable)
library(glue)
library(shinydashboardPlus)
library(shinyalert)

get_transactions_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        width = 12,
        height = 850,
        title = "Your Transactions",
        collapsible = TRUE,
        collapsed = FALSE,
        status = "maroon",
        solidHeader = TRUE,
        actionBttn(ns("fetch_all_transactions"), label = "Fetch Transactions"),
        reactableOutput(ns("all_transactions_table"))
      ),
      box(
        width = 12,
        height = 250,
        title = "Expand to post a new transaction",
        collapsible = TRUE,
        collapsed = TRUE,
        status = "maroon",
        solidHeader = TRUE,
        textAreaInput(
          ns("user_transaction_message"), label = "", placeholder = "Paste your Mpesa Message here...",
          width = "100%", height = "150px"
        ),
        actionBttn(ns("register_a_transaction"), label = "Post Transaction")
      )
    )
  )
}

get_transactions_server <- function(id, auth_token){
  moduleServer(id, function(input,output, session) {
    
    # Fetch existing transaction for current user
    observeEvent(input$fetch_all_transactions, {
      
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
    })
    
    # Registering a new transaction -----------
    observeEvent(input$register_a_transaction, {
      req(input$user_transaction_message)
      req(input$register_a_transaction)
      
      post_req_endpoint <- str_c(generate_base_url(in_production), "transactions/new")
      res <- post_a_transaction(post_req_endpoint, auth_token, input$user_transaction_message)
      
      # when we expect a connection error
      if (class(res) == "character") {
        shinyalert(
          "Oops!", res, type = "error", closeOnClickOutside = TRUE
        )
      } else {
        # status code
        s_code <- res %>% status_code()
        
        # output message
        message <- res %>% content()
        
        if (s_code == 201L) {
          shinyalert(
            "Post Successful!", message[[1]], type = "success", closeOnClickOutside = TRUE
          )
        } else if (s_code == 406L) {
          shinyalert(
            "Oops!", message[[1]], type = "error", closeOnClickOutside = TRUE
          )
        }
      }
    })
  })
}


