source("./dependencies_load.R")

post_transaction_ui <- function(id){
  ns <- NS(id)
  tagList(
    actionBttn(ns("transaction_post_button"), label = "Post Transaction"),
  )
}

post_transaction_server <- function(id, auth_token, active_user) {
  moduleServer(id, function(input, output, session) {
    # get namespace
    ns <- session$ns
    
    # observe trigger button
    observeEvent(input$transaction_post_button, {
      showModal(modalDialog(
        title = "Register a transaction",
        textAreaInput(
          inputId = ns("transaction_message"), label = "", 
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
      req(input$transaction_message)
      
      post_req_endpoint <- str_c(generate_base_url(in_production), "transactions/new")
      res <- post_a_transaction(post_req_endpoint, auth_token, input$transaction_message, active_user)
      
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
    
  })
}