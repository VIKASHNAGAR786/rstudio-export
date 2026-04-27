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

titanic_missing <- colSums(is.na(titanic))
titanic_relevant <- titanic_clean %>% select(Survived, Pclass, Sex, Age, Fare, FamilySize)
titanic_filtered <- titanic_clean %>% filter(Age > 30 | Fare > 50)
titanic_grouped <- titanic_clean %>%
  group_by(Sex) %>%
  summarise(
    Count = n(),
    AvgAge = round(mean(Age, na.rm = TRUE), 1),
    AvgFare = round(mean(Fare, na.rm = TRUE), 2),
    SurvivalRate = round(mean(Survived == "Survived"), 3),
    .groups = "drop"
  )

sex_character <- titanic %>% mutate(Sex_char = as.character(Sex))
sex_factor_levels <- levels(titanic_clean$Sex)
pclass_levels <- levels(titanic_clean$Pclass)

q4_frequency <- titanic_clean %>%
  count(Sex, Survived) %>%
  rename(Frequency = n)

q6_predictors <- c("mpg", "wt", "hp", "cyl", "disp", "drat", "qsec")
q6_correlations <- round(cor(mtcars[, q6_predictors]), 3)

set.seed(123)
q6_index <- createDataPartition(mtcars$mpg, p = 0.8, list = FALSE)
q6_train <- mtcars[q6_index, ]
q6_test <- mtcars[-q6_index, ]
q6_model <- lm(mpg ~ wt + hp + cyl, data = q6_train)
q6_predictions <- predict(q6_model, newdata = q6_test)
q6_mse <- mean((q6_test$mpg - q6_predictions)^2)
q6_r2 <- 1 - sum((q6_test$mpg - q6_predictions)^2) / sum((q6_test$mpg - mean(q6_test$mpg))^2)
q6_coefficients <- data.frame(
  Term = names(coef(q6_model)),
  Estimate = round(unname(coef(q6_model)), 4),
  row.names = NULL
)

q1_insights <- c(
  "Women and children generally show higher survival rates than men.",
  "First-class passengers tend to survive more often than lower classes.",
  "Larger family sizes are linked to different survival patterns than solo travelers."
)

q5_workflow <- c(
  "Load data and inspect structure.",
  "Handle missing values and convert categorical variables to factors.",
  "Create derived features such as FamilySize.",
  "Summarize, visualize, and interpret key patterns.",
  "Train and evaluate the regression model on mtcars."
)

# --- UI SECTION ---
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "MCA Data Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Titanic Analysis", tabName = "titanic", icon = icon("ship")),
      menuItem("Fuel Efficiency ML", tabName = "mtcars", icon = icon("car"))
    )
  ),
  dashboardBody(
    # include custom styles
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    tags$div(
      class = "hero-banner",
      tags$div(
        class = "hero-copy",
        tags$h1("Titanic + Fuel Efficiency Analysis"),
        tags$p("A polished, assignment-ready dashboard with data exploration, factor analysis, and a machine learning pipeline.")
      )
    ),
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
                box(title = "Missing Values & Insights (Q1b, Q1e)", width = 4,
                    tableOutput("missingTable"),
                    tags$ul(
                      tags$li(q1_insights[1]),
                      tags$li(q1_insights[2]),
                      tags$li(q1_insights[3])
                    )),
                box(title = "Transformation & Filtered Data (Q2)", width = 8,
                    tableOutput("relevantTable"),
                    tableOutput("filteredTable"))
              ),
              fluidRow(
                box(title = "Grouping & Factor Levels (Q2, Q3)", width = 6,
                    tableOutput("groupedTable"),
                    tableOutput("factorLevelsTable")),
                box(title = "Survival Analysis (Q4)", width = 6,
                    plotOutput("factorPlot"),
                    tableOutput("frequencyTable"))
              ),
              fluidRow(
                box(title = "Workflow Summary (Q5)", width = 12,
                    tags$ol(
                      tags$li(q5_workflow[1]),
                      tags$li(q5_workflow[2]),
                      tags$li(q5_workflow[3]),
                      tags$li(q5_workflow[4]),
                      tags$li(q5_workflow[5])
                    ))
              ),
              fluidRow(
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
                box(title = "Correlation & Data Snapshot (Q6a, Q6d)", width = 6,
                    tableOutput("correlationTable")),
                box(title = "Linear Regression Model (Q6f)", width = 6,
                    verbatimTextOutput("mlSummary")),
              ),
              fluidRow(
                box(title = "Model Performance (Q6g)", width = 4,
                    tableOutput("metricsTable")),
                box(title = "Regression Coefficients (Q6h)", width = 4,
                    tableOutput("coeffTable")),
                box(title = "Model Notes (Q6i, Q6j)", width = 4,
                    p("The model is evaluated on a held-out test set. If the test error stays low and R-squared is strong, the model is reasonably fit; otherwise it may need more features or a non-linear model."))
              ),
              fluidRow(
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
    list(
      Structure = capture.output(str(titanic_clean)),
      Summary = summary(titanic_clean)
    )
  })

  output$missingTable <- renderTable({
    data.frame(
      Variable = names(titanic_missing),
      MissingValues = as.integer(titanic_missing),
      row.names = NULL
    )
  })

  output$relevantTable <- renderTable({
    head(titanic_relevant, 10)
  })

  output$filteredTable <- renderTable({
    head(titanic_filtered, 10)
  })

  output$groupedTable <- renderTable({
    titanic_grouped
  })

  output$factorLevelsTable <- renderTable({
    data.frame(
      Variable = c("Sex", "Pclass", "Sex as character"),
      ExampleLevels = c(paste(sex_factor_levels, collapse = ", "), paste(pclass_levels, collapse = ", "), "No levels; treated as plain text"),
      row.names = NULL
    )
  })

  output$frequencyTable <- renderTable({
    q4_frequency
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

  output$correlationTable <- renderTable({
    as.data.frame(q6_correlations)
  }, rownames = TRUE)

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
    summary(q6_model)
  })
  
  output$metricsTable <- renderTable({
    data.frame(
      Metric = c("Test MSE", "Test R-Squared", "Training Rows", "Test Rows"),
      Value = c(round(q6_mse, 4), round(q6_r2, 4), nrow(q6_train), nrow(q6_test)),
      row.names = NULL
    )
  })

  output$coeffTable <- renderTable({
    q6_coefficients
  })
  
  output$regPlot <- renderPlot({
    prediction_frame <- data.frame(
      Actual = q6_test$mpg,
      Predicted = q6_predictions
    )

    ggplot(prediction_frame, aes(x = Actual, y = Predicted)) +
      geom_point(color = "steelblue", size = 2.5) +
      geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
      theme_minimal(base_size = 14) +
      labs(title = "Actual vs Predicted MPG on Test Data", x = "Actual MPG", y = "Predicted MPG")
  })
}

shinyApp(ui, server)