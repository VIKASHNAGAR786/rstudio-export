# Titanic data preparation and analysis objects

titanic <- read.csv("data/titanic.csv")

titanic_clean <- titanic %>%
  rename_with(~ "SibSp", contains("Siblings")) %>%
  rename_with(~ "Parch", contains("Parents")) %>%
  mutate(
    Age = ifelse(is.na(Age), median(Age, na.rm = TRUE), Age),
    Survived = factor(Survived, levels = c(0, 1), labels = c("Died", "Survived")),
    Pclass = factor(Pclass, levels = c(3, 2, 1)),
    Sex = factor(Sex),
    FamilySize = SibSp + Parch + 1
  )

titanic_stats <- titanic_clean %>%
  summarise(
    Total = n(),
    Survived = sum(Survived == "Survived", na.rm = TRUE),
    SurvivalRate = mean(Survived == "Survived"),
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

sex_factor_levels <- levels(titanic_clean$Sex)
pclass_levels <- levels(titanic_clean$Pclass)
sex_character_levels <- unique(as.character(titanic$Sex))

q4_frequency <- titanic_clean %>%
  count(Sex, Survived) %>%
  rename(Frequency = n)

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

# mtcars machine learning pipeline
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
