library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggsci)

# Define UI
ui <- fluidPage(
  titlePanel("Effort vs. Revenue & Cost"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("e_look", "Select e_look:", min = 0, max = 5, value = 1, step = 0.1)
    ),
    
    mainPanel(
      plotOutput("plot")
    )
  )
)

# Define Server
server <- function(input, output) {
  output$plot <- renderPlot({
    # Parameters
    p <- 5
    c <- 2
    q <- 0.5  # Example value
    r <- 1    # Example value
    K <- 50   # Example value
    e_look <- input$e_look  # Use user input
    
    # Define growth from effort
    Croissance = function(Effort){
      y = q*Effort * (1 - q/r*Effort)*K
      return(y)
    }
    
    # Define monetary functions with negative return for optimization
    profit = function(Effort, p_ = p , c_ = c){
      y = p_*Croissance(Effort) - c_*Effort
      return(-y)
    }
    
    marginal_revenue= function(Effort, p_ = p, c_ = c){
      y = p*q*K*(1-2*Effort*q/r)
      return(y)
    }
    
    
    # Compute data
    data_fin <- data.frame(Effort = seq(0, 5, 0.01)) %>%
      mutate(Croissance = q * Effort * (1 - q / r * Effort) * K) %>%
      mutate(Revenue = p * Croissance, 
             Cost = c * Effort) %>%
      mutate("Marginal Revenue" = p*q*K*(1-2*e_look*q/r)*(Effort-e_look)+p*q*K*e_look*(1-e_look*q/r)) %>%
      select(-Croissance)
    
    # Pivot data for ggplot
    data_long <- data_fin %>%
      pivot_longer(-Effort, values_to = "values", names_to = "names")
    
    # Plot
    ggplot(data_long, aes(x = Effort, y = values, color = names)) +
      geom_line(linewidth = 1) +
      geom_segment(aes(
        x = e_look, xend = e_look,
        yend = c * e_look, y = p * q * e_look * (1 - q / r * e_look) * K
      ), linewidth = 0.7, linetype = "dashed", color= "black") +
      geom_segment(aes(
        x = e_look, xend = e_look,
        yend = c * e_look, y = 0
      ), linewidth = 0.7, linetype = "dashed", color="black") +
      scale_color_aaas() +
      theme_minimal(base_size = 18) +
      ylim(0, 30) +
      labs(x = "Effort", y = "Values", color = "")
  })
}

# Run the app
shinyApp(ui, server)


