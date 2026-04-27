library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(caret) # For Q6: ML Data Splitting

# --- DATA PREPARATION (Global) ---
titanic <- read.csv("data/titanic.csv")

# Q1b & Q3: Cleaning & Factors
titanic_clean <- titanic %>%
  # Rename columns ONLY if they exist in the long format
  rename_with(~ "SibSp", contains("Siblings")) %>%
  rename_with(~ "Parch", contains("Parents")) %>%
  mutate(
    # Handling missing values (Q1b)
    Age = ifelse(is.na(Age), median(Age, na.rm = TRUE), Age),
    # Factor Conversion (Q3)
    Survived = factor(Survived, levels = c(0, 1), labels = c("Died", "Survived")),
    Pclass = factor(Pclass, levels = c(3, 2, 1)),
    Sex = factor(Sex),
    # This will now work regardless of the source file
    FamilySize = SibSp + Parch + 1
  )

# --- UI SECTION ---
ui <- dashboardPage(
  dashboardHeader(title = "MCA Data Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Titanic Analysis", tabName = "titanic", icon = icon("ship")),
      menuItem("Fuel Efficiency ML", tabName = "mtcars", icon = icon("car"))
    )
  ),
  dashboardBody(
    tabItems(
      # Titanic Tab
      tabItem(tabName = "titanic",
              fluidRow(
                box(title = "Structure & Summary (Q1a)", width = 12, collapsible = TRUE,
                    verbatimTextOutput("structure")),
                box(title = "Survival Analysis (Q4)", width = 8,
                    plotOutput("factorPlot")),
                box(title = "Controls", width = 4,
                    selectInput("factorVar", "Select Variable (Q4a):", 
                                choices = c("Sex", "Pclass", "Embarked")),
                    helpText("This plot shows how factor levels influence survival."))
              )
      ),
      # mtcars Tab
      tabItem(tabName = "mtcars",
              fluidRow(
                box(title = "Linear Regression Model (Q6f)", width = 6,
                    verbatimTextOutput("mlSummary")),
                box(title = "Model Performance (Q6g)", width = 6,
                    tableOutput("metricsTable")),
                box(title = "Prediction Plot", width = 12,
                    plotOutput("regPlot"))
              )
      )
    )
  )
)

# --- SERVER SECTION ---
server <- function(input, output) {
  
  # Q1a: Output Structure
  output$structure <- renderPrint({ 
    list(Structure = str(titanic_clean), Summary = summary(titanic_clean))
  })
  
  # Q4: Factor Distribution Plot
  output$factorPlot <- renderPlot({
    ggplot(titanic_clean, aes_string(x = input$factorVar, fill = "Survived")) +
      geom_bar(position = "dodge") +
      theme_minimal() +
      labs(title = paste("Distribution of", input$factorVar), y = "Passenger Count")
  })
  
  # Q6: Machine Learning Pipeline
  output$mlSummary <- renderPrint({
    # Splitting Data (Q6e)
    set.seed(123)
    index <- createDataPartition(mtcars$mpg, p = 0.8, list = FALSE)
    train_set <- mtcars[index, ]
    
    # Linear Model (Q6f)
    model <- lm(mpg ~ wt + hp + cyl, data = train_set)
    summary(model)
  })
  
  output$metricsTable <- renderTable({
    model <- lm(mpg ~ wt + hp + cyl, data = mtcars)
    # Simple evaluation (Q6g)
    r2 <- summary(model)$r.squared
    data.frame(Metric = "R-Squared", Value = round(r2, 4))
  })
  
  output$regPlot <- renderPlot({
    ggplot(mtcars, aes(x = wt, y = mpg)) +
      geom_point() +
      geom_smooth(method = "lm", color = "red") +
      labs(title = "Weight vs Fuel Efficiency", x = "Weight", y = "MPG")
  })
}

shinyApp(ui, server)