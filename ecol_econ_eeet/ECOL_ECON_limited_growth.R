library(shiny)
library(shinythemes)
library(ggplot2)
library(dplyr)
library(tidyr)

library(rsconnect)


# Simulation function: returns a long data frame of the model's dynamics.
simulate_model <- function(Time, r0, control_rate_1, control_rate_2, c_min, g) {
  # Fixed parameters (aside from those passed in)
  alpha_r <- 0.6
  alpha <- (1 - alpha_r) / 2
  rho <- 0.1
  delta <- 0.1
  beta <- 0.5
  
  # Initial conditions
  R0 <- 1000   # Resource stock
  A0 <- 1      # Productivity
  K0 <- 10     # Capital
  N0 <- 5      # Population
  
  # Pre-allocate vectors (length Time+1 for state variables, Time for flows)
  R <- numeric(Time + 1)
  A <- numeric(Time + 1)
  K <- numeric(Time + 1)
  N <- numeric(Time + 1)
  
  Y <- numeric(Time)
  r_vec <- numeric(Time)
  
  # Set initial conditions
  R[1] <- R0
  A[1] <- A0
  K[1] <- K0
  N[1] <- N0
  
  # Create a control rate vector: first half and second half can differ.
  half_time <- floor(Time / 2)
  control_rate_vector <- c(rep(control_rate_1, half_time), rep(control_rate_2, Time - half_time))
  
  # Simulation loop
  for (t in 1:Time) {
    # Determine resource extraction: extract r0 if resource stock allows it.
    r_vec[t] <- ifelse((R[t] - r0) > 0, r0, 0)
    
    # Production function (CES with components: resource, labor, and capital)
    Y[t] <- A[t] * ( alpha_r * (r_vec[t])^rho +
                       alpha   * (N[t])^rho +
                       alpha   * (K[t])^rho )^(1/rho)
    
    # Update resource dynamics: subtract extraction (ensuring non-negative stock).
    R[t + 1] <- max(R[t] - r_vec[t], 0)
    
    # Productivity dynamics: constant growth.
    A[t + 1] <- (1 + g) * A[t]
    
    # Capital dynamics: depreciated capital plus new investment.
    K[t + 1] <- (1 - delta) * K[t] + (1 - beta) * Y[t]
    
    # Population dynamics: adjust based on production vs. minimum consumption.
    N[t + 1] <- max((N[t] + (beta * Y[t] - c_min * N[t])) * (1 - control_rate_vector[t]), 0)
  }
  
  # Create a data frame (Time 0 to Time) and include flows (Production starts at t = 1)
  f <- data.frame(
    Time = 0:Time,
    Resource = R,
    Production = c(0, Y),
    Capital = K,
    Population = N
  )
  
  # Reshape to long format for plotting.
  f_long <- f %>%
    pivot_longer(-Time, names_to = "Variable", values_to = "Value")
  
  return(f_long)
}

# Define the UI with a professional theme and custom CSS
ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  # Custom CSS styling for a report-like look
  tags$head(
    tags$style(HTML("
      .navbar { margin-bottom: 20px; }
      .well { background-color: #f7f7f7; border: none; }
      h2 { font-weight: 300; color: #2c3e50; }
      .form-group { margin-bottom: 15px; }
    "))
  ),
  
  # Title
  titlePanel("Dynamics of Resource Extraction Model"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Simulation Settings"),
      sliderInput("r0", 
                  "Extraction Rate (r0):", 
                  min = 0, max = 10, value = 3, step = 0.1),
      sliderInput("control_rate1", 
                  "Control Rate (Period 1):", 
                  min = 0, max = 1, value = 0.2, step = 0.01),
      sliderInput("control_rate2", 
                  "Control Rate (Period 2):", 
                  min = 0, max = 1, value = 0.2, step = 0.01),
      sliderInput("c_min", 
                  "Minimum Consumption (c_min):", 
                  min = 0, max = 5, value = 0.5, step = 0.1),
      sliderInput("g", 
                  "Technology Growth Rate (g):", 
                  min = 0, max = 0.05, value = 0.002, step = 0.0005),
      width = 3
    ),
    
    mainPanel(
      h2("Model Dynamics Comparison"),
      p("This report compares a baseline scenario with fixed parameters against a new scenario with user-adjustable parameters."),
      plotOutput("modelPlot", height = "600px")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Baseline scenario: fixed parameters (extraction rate = 3, control rates = 0.2, etc.)
  baseline <- reactive({
    simulate_model(Time = 500, 
                   r0 = 3, 
                   control_rate_1 = 0.2, 
                   control_rate_2 = 0.2, 
                   c_min = 0.5, 
                   g = 0.002) %>%
      mutate(scenario = "Baseline")
  })
  
  # New scenario: parameters chosen by the user
  newScenario <- reactive({
    simulate_model(Time = 500, 
                   r0 = input$r0, 
                   control_rate_1 = input$control_rate1, 
                   control_rate_2 = input$control_rate2, 
                   c_min = input$c_min, 
                   g = input$g) %>%
      mutate(scenario = "New Scenario")
  })
  
  # Combine the two scenarios
  combinedData <- reactive({
    bind_rows(baseline(), newScenario())
  })
  
  # Create the plot comparing both scenarios.
  output$modelPlot <- renderPlot({
    ggplot(combinedData(), aes(x = Time, y = Value, color = scenario)) +
      geom_line(size = 1) +
      facet_wrap(~ Variable, scales = "free_y", ncol = 2) +
      theme_bw(base_size = 14) +
      scale_color_manual(values = c('dodgerblue', 'firebrick'))+
      theme(
        strip.background = element_rect(fill = "#ecf0f1", color = NA),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
        legend.title = element_text(face = "bold")
      ) +
      labs(title = "Dynamics of the System: Baseline vs. New Scenario",
           x = "Time",
           y = "Value",
           color = "Scenario")
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

rsconect::deployApp()
