hero_banner <- tags$div(
  class = "hero-banner",
  tags$div(
    class = "hero-copy",
    tags$span(class = "hero-kicker", "Assignment Dashboard"),
    tags$h1("Titanic + Fuel Efficiency Analysis"),
    tags$p("A polished, assignment-ready dashboard with tabbed navigation, compact summaries, and a machine learning pipeline.")
  ),
  tags$img(src = "hero-illustration.svg", class = "hero-art", alt = "Dashboard illustration")
)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "MCA Data Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Titanic Analysis", tabName = "titanic", icon = icon("ship")),
      menuItem("Fuel Efficiency ML", tabName = "mtcars", icon = icon("car"))
    )
  ),
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    hero_banner,
    tabItems(
      tabItem(
        tabName = "overview",
        fluidRow(
          valueBoxOutput("totalBox", width = 3),
          valueBoxOutput("survivalBox", width = 3),
          valueBoxOutput("medianAgeBox", width = 3),
          valueBoxOutput("familyBox", width = 3)
        ),
        fluidRow(
          box(title = "Project Snapshot", width = 12, status = "primary", solidHeader = TRUE,
              p("Use the sidebar to switch between the Titanic analysis and the mtcars machine learning model."),
              p("Each main section is further divided into tabs so the dashboard stays readable and presentation friendly."),
              tags$div(class = "overview-grid",
                       tags$div(class = "overview-chip", "Clean structure"),
                       tags$div(class = "overview-chip", "Tabbed navigation"),
                       tags$div(class = "overview-chip", "Readable code"),
                       tags$div(class = "overview-chip", "Professional styling")))
        )
      ),
      tabItem(
        tabName = "titanic",
        fluidRow(
          box(title = "Titanic Explorer", width = 12, status = "primary", solidHeader = TRUE,
              tabsetPanel(
                tabPanel(
                  "Structure",
                  fluidRow(
                    box(width = 12, title = "Structure & Summary (Q1a)", status = "info", solidHeader = TRUE,
                        verbatimTextOutput("structure"))
                  )
                ),
                tabPanel(
                  "Cleaning",
                  fluidRow(
                    box(width = 4, title = "Missing Values & Insights (Q1b, Q1e)", status = "warning", solidHeader = TRUE,
                        tableOutput("missingTable"),
                        tags$ul(
                          tags$li(q1_insights[1]),
                          tags$li(q1_insights[2]),
                          tags$li(q1_insights[3])
                        )),
                    box(width = 8, title = "Transformation & Filtered Data (Q2)", status = "warning", solidHeader = TRUE,
                        tableOutput("relevantTable"),
                        tableOutput("filteredTable"))
                  )
                ),
                tabPanel(
                  "Factors",
                  fluidRow(
                    box(width = 6, title = "Grouping & Factor Levels (Q2, Q3)", status = "success", solidHeader = TRUE,
                        tableOutput("groupedTable"),
                        tableOutput("factorLevelsTable")),
                    box(width = 6, title = "Survival Analysis (Q4)", status = "success", solidHeader = TRUE,
                        selectInput("factorVar", "Select Variable (Q4a):",
                                    choices = c("Sex", "Pclass", "Embarked"), selected = "Sex"),
                        plotOutput("factorPlot"),
                        tableOutput("frequencyTable"))
                  )
                ),
                tabPanel(
                  "Workflow",
                  fluidRow(
                    box(width = 12, title = "Workflow Summary (Q5)", status = "primary", solidHeader = TRUE,
                        tags$ol(
                          tags$li(q5_workflow[1]),
                          tags$li(q5_workflow[2]),
                          tags$li(q5_workflow[3]),
                          tags$li(q5_workflow[4]),
                          tags$li(q5_workflow[5])
                        ))
                  )
                )
              ))
        )
      ),
      tabItem(
        tabName = "mtcars",
        fluidRow(
          box(width = 12, title = "Fuel Efficiency Model", status = "primary", solidHeader = TRUE,
              tabsetPanel(
                tabPanel(
                  "Data",
                  fluidRow(
                    box(width = 6, title = "Correlation & Data Snapshot (Q6a, Q6d)", status = "info", solidHeader = TRUE,
                        tableOutput("correlationTable")),
                    box(width = 6, title = "Linear Regression Model (Q6f)", status = "info", solidHeader = TRUE,
                        verbatimTextOutput("mlSummary"))
                  )
                ),
                tabPanel(
                  "Performance",
                  fluidRow(
                    box(width = 4, title = "Model Performance (Q6g)", status = "success", solidHeader = TRUE,
                        tableOutput("metricsTable")),
                    box(width = 4, title = "Regression Coefficients (Q6h)", status = "success", solidHeader = TRUE,
                        tableOutput("coeffTable")),
                    box(width = 4, title = "Model Notes (Q6i, Q6j)", status = "success", solidHeader = TRUE,
                        p("The model is evaluated on a held-out test set. If the test error stays low and R-squared is strong, the model is reasonably fit; otherwise it may need more features or a non-linear model."))
                  )
                ),
                tabPanel(
                  "Prediction",
                  fluidRow(
                    box(width = 12, title = "Prediction Plot", status = "warning", solidHeader = TRUE,
                        plotOutput("regPlot"))
                  )
                )
              ))
        )
      )
    ),
    tags$div(class = "app-footer",
             "developed by vikash nagar ; mca 2 sem ; kid 27416")
  )
)
