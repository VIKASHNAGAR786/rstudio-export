server <- function(input, output) {

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
      ExampleLevels = c(
        paste(sex_factor_levels, collapse = ", "),
        paste(pclass_levels, collapse = ", "),
        paste(head(sex_character_levels, 2), collapse = ", ")
      ),
      Note = c("Ordered factor for grouping", "Ordered factor with class priority", "Character values have no level order"),
      row.names = NULL
    )
  })

  output$frequencyTable <- renderTable({
    q4_frequency
  })

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
      paste0(scales::percent(titanic_stats$SurvivalRate, accuracy = 0.1), " (", titanic_stats$SurvivedCount, ")"),
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
