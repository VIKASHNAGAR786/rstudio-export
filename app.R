library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(caret) # For Q6: ML Data Splitting
library(scales)

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

# --- SUMMARY STATS FOR UI ---
titanic_stats <- titanic_clean %>%
  summarise(
    Total = n(),
    Survived = sum(as.numeric(Survived) - 1 == 1, na.rm = TRUE),
    SurvivalRate = mean(Survived == "Survived") ,
    MedianAge = median(Age, na.rm = TRUE),
    AvgFamily = round(mean(FamilySize, na.rm = TRUE), 2)
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
    # include custom styles
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
    tabItems(
      # Titanic Tab
      tabItem(tabName = "titanic",
              fluidRow(
                valueBoxOutput("totalBox", width = 3),
                valueBoxOutput("survivalBox", width = 3),
                valueBoxOutput("medianAgeBox", width = 3),
                valueBoxOutput("familyBox", width = 3)
              ),
              fluidRow(
                box(title = "Structure & Summary (Q1a)", width = 12, collapsible = TRUE,
                    verbatimTextOutput("structure"))
              ),
              fluidRow(
                box(title = "Survival Analysis (Q4)", width = 8,
                    plotOutput("factorPlot")),
                box(title = "Controls", width = 4,
                    selectInput("factorVar", "Select Variable (Q4a):", 
                                choices = c("Sex", "Pclass", "Embarked"), selected = "Sex"),
                    p("This plot shows how factor levels influence survival. Use the controls to switch variables.")
                )
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
    ,
    tags$div(class = "app-footer",
             "developed by vikash nagar ; mca 2 sem ; kid 27416")
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
      geom_bar(position = "fill") +
      scale_y_continuous(labels = percent_format()) +
      scale_fill_brewer(palette = "Set2") +
      theme_minimal(base_size = 14) +
      labs(title = paste("Survival rate by", input$factorVar), y = "Proportion", fill = "Outcome")
  })

  # Value boxes for summary stats
  output$totalBox <- renderValueBox({
    valueBox(
      formatC(titanic_stats$Total, format = "d", big.mark = ","),
      "Total Passengers",
      icon = icon("users"),
      color = "aqua"
    )
  })

  output$survivalBox <- renderValueBox({
    valueBox(
      paste0(round(100 * titanic_stats$SurvivalRate, 1), "%"),
      "Overall Survival Rate",
      icon = icon("heartbeat"),
      color = "green"
    )
  })

  output$medianAgeBox <- renderValueBox({
    valueBox(
      titanic_stats$MedianAge,
      "Median Age",
      icon = icon("child"),
      color = "yellow"
    )
  })

  output$familyBox <- renderValueBox({
    valueBox(
      titanic_stats$AvgFamily,
      "Avg Family Size",
      icon = icon("users"),
      color = "purple"
    )
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