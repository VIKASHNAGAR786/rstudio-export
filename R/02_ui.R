hero_banner <- tags$div(
  class = "hero-banner",
  tags$div(
    class = "hero-copy",
    tags$span(class = "hero-kicker", "Assignment Dashboard"),
    tags$h1("Titanic + Fuel Efficiency Analysis"),
    tags$p("A polished, assignment-ready dashboard with data exploration, factor analysis, and a machine learning pipeline.")
  ),
  tags$img(src = "hero-illustration.svg", class = "hero-art", alt = "Dashboard illustration")
)

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
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    hero_banner,
    tabItems(
      tabItem(
        tabName = "titanic",
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
              p("This plot shows how factor levels influence survival. Use the controls to switch variables."))
        )
      ),
      tabItem(
        tabName = "mtcars",
        fluidRow(
          box(title = "Correlation & Data Snapshot (Q6a, Q6d)", width = 6,
              tableOutput("correlationTable")),
          box(title = "Linear Regression Model (Q6f)", width = 6,
              verbatimTextOutput("mlSummary"))
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
    ),
    tags$div(class = "app-footer",
             "developed by vikash nagar ; mca 2 sem ; kid 27416")
  )
)
