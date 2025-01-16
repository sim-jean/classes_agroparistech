
library(shiny)
library(ggplot2)

# Define UI
ui <- fluidPage(
  titlePanel("Fisheries Management Models"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("model", "Choose a Model:", 
                  choices = c("Open Access", "Maximum Sustainable Yield", "Maximum Economic Yield")),
      
      sliderInput("initial_stock", "Initial Stock Size:", 
                  min = 100, max = 1000, value = 500),
      sliderInput("growth_rate", "Growth Rate:", 
                  min = 0.01, max = 0.1, value = 0.05),
      sliderInput("harvest_rate", "Harvest Rate (as % of stock):", 
                  min = 0, max = 1, value = 0.1),
      actionButton("solve", "Solve Model")
    ),
    
    mainPanel(
      plotOutput("stockPlot"),
      textOutput("modelSolution")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  observeEvent(input$solve, {
    
    # Parameters for the models
    initial_stock <- input$initial_stock
    growth_rate <- input$growth_rate
    harvest_rate <- input$harvest_rate
    
    # Define the models
    if (input$model == "Open Access") {
      # Open Access Model: No regulation, constant harvest rate
      time_steps <- 1:50
      stock_levels <- initial_stock * exp(growth_rate * time_steps) - harvest_rate * time_steps
      
    } else if (input$model == "Maximum Sustainable Yield") {
      # MSY Model: Optimal harvest at MSY
      # Assuming logistic growth model and that MSY occurs at half the carrying capacity
      time_steps <- 1:50
      carrying_capacity <- 1000
      msy_harvest_rate <- 0.2  # 20% of carrying capacity for MSY
      stock_levels <- carrying_capacity * exp(growth_rate * time_steps) / (1 + exp(growth_rate * time_steps / carrying_capacity))
      
    } else if (input$model == "Maximum Economic Yield") {
      # MEY Model: Harvest rate that maximizes profit
      # MEY occurs when harvesting at 1/2 of the carrying capacity (like MSY)
      time_steps <- 1:50
      carrying_capacity <- 1000
      mey_harvest_rate <- 0.1  # Assumed rate for MEY
      stock_levels <- carrying_capacity * exp(growth_rate * time_steps) / (1 + exp(growth_rate * time_steps / carrying_capacity))
    }
    
    # Plotting the stock levels over time
    output$stockPlot <- renderPlot({
      ggplot(data.frame(Time = time_steps, Stock = stock_levels), aes(x = Time, y = Stock)) +
        geom_line() +
        labs(title = paste(input$model, "Model: Stock Levels Over Time"),
             x = "Time", y = "Stock Size")
    })
    
    # Display the model solution (optional)
    output$modelSolution <- renderText({
      paste("Final stock size at time step", max(time_steps), ":", round(stock_levels[length(stock_levels)], 2))
    })
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)

