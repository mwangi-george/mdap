source("./dependencies_load.R")

server <- function(input, output, session) {
  access_token <- reactiveVal()
  
  
  # Authentication --------------
  observeEvent(input$login, {
    
    username <- input$api_user
    password <- input$api_pass
    base_url <- generate_base_url(in_production)
    
    req(username)
    req(password)
    
    # call function to handle login
    login_response <- login_func(base_url, username, password)
    
    # when we expect a connection error
    if (class(login_response) == "character") {
      shinyalert("Oops!", login_response, type = "error", closeOnClickOutside = TRUE)
    } else {
      # Check the HTTP status code for success
      if (status_code(login_response) == 200L) {
        print(glue("{username} has logged in successfully 🎉🎉🎉🎉"))
        
        # Show dashboard if login is successful
        shinyjs::toggle("login-page", condition = FALSE)
        shinyjs::toggle("data-page", condition = TRUE)
        
        # Saving token globally for debugging
        token <<- content(login_response)$access_token
        access_token(token)
        
      } else {
        error_msg <- login_response %>% content()
        # Show an error message if login failed
        shinyalert("Oops!", error_msg[[1]], type = "error", closeOnClickOutside = TRUE)
        print(glue("{username} is trying to login but fails! 💔"))
      }
    }
  })
  
  # Trigger to show registration modal
  observeEvent(input$register, {
    showModal(
      modalDialog(
        title = div(tags$h3("User Registration", style = "color: #2d677d; font-weight: bold; text-align: center;")),
        tags$div(
          style = "display: flex; flex-direction: column; align-items: center;",
          textInput("reg_name", "Full Name", placeholder = "Enter your full name", width = "100%", value = ""),
          textInput("reg_email", "Email", placeholder = "Enter your email address", width = "100%", value = ""),
          textInput("reg_mpesa_no", "Mpesa Number", placeholder = "Enter your Mpesa Number", width = "100%", value = ""),
          passwordInput("reg_pass", "Password", placeholder = "Create a strong password", width = "100%", value = ""),
          textInput("reg_username", "Username", placeholder = "Create a unique username", width = "100%", value = "")
        ),
        actionButton("submit_registration", "Register", class = "btn btn-primary btn-lg", style = "width: 100%;"),
        easyClose = FALSE,
        size = "m",
        footer = tagList(
          # actionButton("submit_registration", "Register", class = "btn btn-success"),
          modalButton("Close", icon = icon("arrow-right-to-bracket"))
        )
      )
    )
  })
  
  # Handle registration logic
  observeEvent(input$submit_registration, {
    req(input$reg_name)
    req(input$reg_email)
    req(input$reg_mpesa_no)
    req(input$reg_pass)
    req(input$reg_username)
    
    registration_req_endpoint <- str_c(generate_base_url(in_production), "users/register")
    
    registration_response <- regiser_user_func(
      endpoint = registration_req_endpoint, 
      name = input$reg_name, 
      email = input$reg_email,
      mpesa_number = input$reg_mpesa_no,
      password = input$reg_pass,
      username = input$reg_username
    )
    
    if (class(registration_response) == "character"){
      shinyalert("Oops!", registration_response, type = "error", closeOnClickOutside = TRUE)
    } else {
      success__or_failure_msg <- registration_response %>% content()
      if (registration_response %>% status_code() == 201L) {
        shinyalert("Success!", success__or_failure_msg[[1]], type = "success", closeOnClickOutside = TRUE)
      } else {
        shinyalert("Oops!", success__or_failure_msg[[1]], type = "error", closeOnClickOutside = TRUE)
      }
    }
  })
  
  output$current_userOutput <- renderUI({
    tags$li(
      h4(str_c("Hi 👋 ", input$api_user), align = "center")
    )
  })
  
  
  # Fetch existing transaction for current user ---------------------------
  transactions_data_updated <- eventReactive(input$fetch_transactions_button, {
    
    get_req_endpoint <- str_c(generate_base_url(in_production), "transactions/retrieve/all")
    query_output <- get_all_transactions(get_req_endpoint, access_token(), input$api_user)
    
    return(query_output)
  })
  
  observe({
    req(input$login)
    req(transactions_data_updated())
    transactions_data_updated()
    
    render_transactions_infobox_server("infoboxes", transactions_data_updated())
  })
  
  observe({
    req(input$login)
    req(transactions_data_updated())
    transactions_data_updated()
    
    render_transactions_chart_server("highcharts", transactions_data_updated(), input$api_user)
  })
  
  
  observe({
    req(input$login)
    req(transactions_data_updated())
    transactions_data_updated()
    
    render_transactions_table_server("historical_transactions", transactions_data_updated())
  })
  
  observe({
    post_transaction_server("post_transaction", access_token(), input$api_user)
  })
  
  observe({
    delete_transaction_server("delete_transaction", access_token(), input$api_user)
  })
  # end
}