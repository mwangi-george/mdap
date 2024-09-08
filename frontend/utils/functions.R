
library(tidyverse)
library(fs)
library(httr)
library(memoise)
library(jsonlite)
library(reactable)
library(glue)


generate_base_url <- function(production = FALSE) {
  if (production == TRUE) {
    # service name in docker compose
    url <- "http://backend:8000/" # - production url
    return(url)
  } else {
    # local port for testing
    url <- "http://127.0.0.1:8000/"
    return(url)
  }
}

login_func <- memoise(
  function(base_url_path, user, password) {
    tryCatch(
      expr = {
        response <- POST(
          url = str_c(base_url_path, "users/login/"),
          add_headers(
            accept = "application/json",
            `Content-Type` = "application/x-www-form-urlencoded"
          ),
          body = list(
            grant_type = "password",
            username = user,
            password = password,
            scope = "",
            client_id = "string",
            client_secret = "string"
          ),
          encode = "form"
        )
        return(response)
      },
      error = function(e) {
        return(e$message)
      }
    )
  },
  cache = cachem::cache_mem(max_age = 15)
)



# Implement modals for notifications
notification_modal <- function(notification_title, notification_text) {
  showModal(modalDialog(
    title = notification_title,
    notification_text,
    footer = modalButton("Close", icon = icon("circle-xmark")),
    easyClose = T,
    class = "custom-modal",
    tags$style(global_modal_style)
  ))
}

transactions_output_model <- function(){
  output_model <- tibble(
    id = integer(),
    transaction_code = character(),
    transaction_amount = character(),
    counterparty = character(),
    date = character(),
    time = character(),
    new_balance = character(),
    transaction_cost = character(),
    transaction_type = character(),
    user_id = integer()
  )
  return(output_model)
}


# Get all transactions -- cached
get_all_transactions <- memoise(
  function(endpoint, auth_token) {
    tryCatch(
      expr = {
        # make api call
        response <- GET(
          endpoint,
          add_headers(
            accept = "application/json",
            Authorization = str_c("Bearer ", auth_token)
          )
        )

        # convert response to data frame
        response_df <- response %>%
          content() %>%
          toJSON(auto_unbox = TRUE) %>%
          fromJSON()

        # this print helps know whether caching is working
        print(glue("An api call was made at {Sys.time()}"))

        # data frame is in index 1
        return(response_df[[1]])
      },
      error = function(e) {
        return(e$message)
      }
    )
  },
  # Make the memoized result automatically time out after 15 seconds.
  cache = cachem::cache_mem(max_age = 15)
)


post_a_transaction <- function(endpoint, auth_token, transaction_message) {
  print(glue("A post request was made at {Sys.time()}"))
  tryCatch(
    expr = {
      response <- POST(
        endpoint,
        add_headers(
          accept = "application/json",
          Authorization = str_c("Bearer ", auth_token),
          `Content-Type` = "application/json"
        ),
        body = list(
          mpesa_message = transaction_message
        ),
        encode = "json"
      )
      return(response)
    },
    error = function(e) {
      return(e$message)
    }
  )
}


regiser_user_func <- function(
    endpoint,
    name = "John Doe",
    email = "john_doe@gmail.com",
    mpesa_number = "+254700111222",
    username = "john_doe",
    password = "0987") {
  print(glue("A user registeration post request was made at {Sys.time()}"))
  tryCatch(
    expr = {
      res <- POST(
        endpoint,
        add_headers(
          accept = "application/json",
          `Content-Type` = "application/json"
        ),
        body = list(
          email = email,
          mpesa_number = mpesa_number,
          name = name,
          password = password,
          username = username
        ),
        encode = "json"
      )
      return(res)
    },
    error = function(e) {
      return(e$message)
    }
  )
}



# Base template function for rendering reactables
render_reactables_func <- function(input_data) {
  reactable(
    input_data,
    defaultPageSize = 10,
    striped = TRUE,
    bordered = TRUE,
    highlight = TRUE,
    fullWidth = TRUE,
    resizable = TRUE,
    paginationType = "simple",
    defaultColDef = colDef(
      align = "center",
      minWidth = 150,
      headerStyle = list(
        backgroundColor = "#f7f7f7",
        fontWeight = "bold",
        color = "#333",
        borderBottom = "1px solid #ddd",
        textAlign = "center"
      ),
      style = function(value) {
        if (is.numeric(value)) {
          list(color = ifelse(value < 0, "red", "green"), fontWeight = "bold")
        }
      }
    ),
    columns = list(
      # Customize specific columns if needed
      # e.g., "column_name" = colDef(name = "Custom Name")
    ),
    theme = reactableTheme(
      color = "#333",
      backgroundColor = "#ffffff",
      borderColor = "#cccccc",
      stripedColor = "#f9f9f9",
      highlightColor = "#f0f0f0",
      cellPadding = "8px 12px",
      tableStyle = list(
        fontFamily = "Arial, sans-serif",
        fontSize = "14px"
      ),
      headerStyle = list(
        fontSize = "16px"
      )
    ),
    showSortable = TRUE,
    showPageInfo = TRUE,
    showPageSizeOptions = TRUE,
    pageSizeOptions = c(5, 10, 25, 50, 100)
  )
}
