source("./dependencies_load.R")

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
          url = str_c(base_url_path, "users/login"),
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

transactions_output_model <- function() {
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
  function(endpoint, auth_token, user = "George") {
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

        if (response %>% status_code() == 200L) {
          print(glue("{user} fetched all their transactions at {Sys.time()}"))
        }
        # data frame is in index 1
        return(response_df[[1]])
      },
      error = function(e) {
        return(e$message)
      }
    )
  },
  cache = cachem::cache_mem(max_age = 10)
)



post_a_transaction <- function(endpoint, auth_token, transaction_message, user = "George") {
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

      if (response %>% status_code() == 201L) {
        print(glue("{user} posted a transaction at {Sys.time()}"))
      }

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
  tryCatch(
    expr = {
      response <- POST(
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
      if (response %>% status_code() == 201L) {
        print(glue("A new user has been registered with username: {username}"))
      }

      return(response)
    },
    error = function(e) {
      return(e$message)
    }
  )
}


# DELETE a transaction
delete_a_transaction_func <- function(endpoint, transaction_code, auth_code, user = "George") {
  tryCatch(
    expr = {
      response <- DELETE(
        endpoint,
        query = list(transaction_code = transaction_code),
        add_headers(
          accept = "application/json",
          Authorization = str_c("Bearer ", auth_code)
        )
      )
      if (response %>% status_code() == 200L) {
        print(glue("{user} deleted a transaction with code: {transaction_code}"))
      }
      return(response)
    },
    error = function(e) {
      return(e$message)
    }
  )
}



summarize_fetched_transactions <- function(data_with_transactions) {
  # This function processes a dataset of transaction data to calculate the total transaction amount,
  # total transaction cost, and the total number of transactions.
  # It converts transaction amounts and costs to numeric values, handles any potential errors or warnings,
  # and returns a summary of these key metrics.
  # The function is memoised to cache results for improved performance.

  default_table_if_error_occurs <- tibble(transaction_amount = 0, transaction_cost = 0, total_transactions = 0)

  tryCatch(
    expr = {
      results <- suppressWarnings(
        expr = {
          data_with_transactions %>%
            mutate(
              transaction_amount = str_remove_all(transaction_amount, ","),
              transaction_amount = as.numeric(transaction_amount),
              transaction_cost = str_remove_all(transaction_cost, ","),
              transaction_cost = as.numeric(transaction_cost)
            ) %>%
            summarise(
              transaction_amount = sum(transaction_amount, na.rm = TRUE),
              transaction_cost = sum(transaction_cost, na.rm = TRUE),
              total_transactions = n()
            )
        }
      )
      return(results)
    },
    error = function(e) {
      print(e$message)
      return(default_table_if_error_occurs)
    }
  )
}

# Function Template to create a box template for shiny app
plain_box_template <- function(height = 600, width = 6, title_text = NULL, ...) {
  box(
    height = height,
    width = width,
    title = title_text,
    collapsible = TRUE,
    collapsed = FALSE,
    status = "maroon",
    solidHeader = TRUE,
    ...
  )
}

# This function creates a bar or column chart from a dataset containing transaction data.
# The chart displays the top 10 most frequent values in a specified column and includes customizable titles and axis labels.
create_bar_or_column_chart_func <- function(
    data_with_transactions, chart_type, column_to_count, title_text, subtitle_text, x_axis_text, y_axis_text) {
  tryCatch(
    expr = {
      data_with_transactions %>%
        count(!!rlang::sym(column_to_count), name = "count") %>%
        arrange(desc(count)) %>%
        head(10) %>%
        hchart(
          type = chart_type,
          hcaes(!!rlang::sym(column_to_count), count),
          showInLegend = FALSE,
          maxSize = "15%",
          dataLabels = list(enabled = TRUE)
        ) %>%
        hc_colors(colors = c(
          "#9e0142", "#d53e4f", "#f46d43", "#fdae61", "#fee08b",
          "#e6f598", "#abdda4", "#66c2a5", "#3288bd", "#5e4fa2"
        )) %>%
        hc_exporting(enabled = TRUE) %>%
        hc_tooltip(crosshairs = TRUE, backgroundColor = "white", shared = F, borderWidth = 4) %>%
        hc_title(
          text = title_text,
          align = "left",
          style = list(fontweight = "bold", fontsize = "15px")
        ) %>%
        hc_subtitle(
          text = paste("Showing data for ", subtitle_text),
          align = "left",
          style = list(fontweight = "bold", fontsize = "13px")
        ) %>%
        hc_add_theme(hc_theme_elementary()) %>%
        hc_chart(zoomType = "x") %>%
        hc_xAxis(title = list(text = x_axis_text)) %>%
        hc_yAxis(title = list(text = y_axis_text), labels = list(enabled = FALSE)) %>%
        hc_plotOptions(series = list(states = list(hover = list(enabled = TRUE, color = "red"))))
    },
    error = function(e) {
      return(e)
    }
  )
}


create_bar_or_column_chart_apex <- function(
    data_with_transactions, column_to_count, chart_type, title_text, subtitle_text, x_axis_text = NULL, y_axis_text = NULL
    ) {
  #
  tryCatch(
    expr = {
      plotting_df <- data_with_transactions %>%
        count(!!sym(column_to_count), name = "value") %>%
        arrange(desc(value)) %>%
        head(10) %>%
        mutate(!!column_to_count := fct_reorder(!!sym(column_to_count), value))

      plotting_df %>%
        apex(aes(!!sym(column_to_count), value), type = chart_type, height = "250px") %>%
        ax_legend(show = FALSE) %>% 
        ax_labs(
          title = title_text, subtitle = str_c("Showing data for ", subtitle_text), x = x_axis_text, y = y_axis_text
        ) %>% 
        set_input_click(
          inputId = "click",
          multiple = TRUE,
          effect_value = 20
        ) %>%
          set_input_zoom("zoom")
    }, 
    error = function(e){
      return(e)
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
      transaction_amount = colDef(name = "amount"),
      transaction_code = colDef(name = "code"),
      transaction_cost = colDef(name = "cost"),
      transaction_type = colDef(name = "type")
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
