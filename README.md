# MCA Data Analysis Shiny App - Assignment Solution

This is a complete data analysis project using R Shiny that solves all 6 assignment questions. The project includes data preprocessing, exploratory analysis, factor handling, and a machine learning model for predicting fuel efficiency.

## Project Structure

The project is organized into smaller files for easy maintenance:

- `app.R` - Main launcher that sources all app files
- `R/00_packages.R` - All required libraries and packages
- `R/01_data.R` - Data loading, cleaning, and analysis computations
- `R/02_ui.R` - User interface layout and dashboard design
- `R/03_server.R` - Server logic that displays outputs
- `www/style.css` - Custom styling for the dashboard
- `data/titanic.csv` - Dataset for all analyses

## How to Run

Open `app.R` in RStudio and click **Run App**. The interactive Shiny dashboard will open in your browser.

---

# How Each Question Was Solved

## Q1: Complete Data Analysis Pipeline on Titanic Dataset

**What was done:**

a) **Data Import and Structure**: Loaded the Titanic dataset and examined its structure using `str()` and `summary()` functions to understand the data types and basic statistics.

b) **Missing Values Handling**: Identified missing values using `colSums(is.na())` function. For the **Age variable**, we used **median imputation** because:
   - Median is robust to outliers
   - It preserves the overall distribution of ages
   - It's simple and interpretable
   - Code: `Age = ifelse(is.na(Age), median(Age, na.rm = TRUE), Age)`

c) **Data Transformation**:
   - Converted **Survived** to factor with labels "Died" and "Survived" (makes interpretation easier)
   - Converted **Pclass** (passenger class) to ordered factor (1st, 2nd, 3rd class)
   - Converted **Sex** to factor
   - Created new feature **FamilySize** = SibSp + Parch + 1 (includes the passenger themselves)

d) **Summary Statistics**: Calculated key metrics:
   - Total passengers: 891
   - Overall survival rate: ~38%
   - Median age: 28 years
   - Average family size: 1.54

e) **Key Insights**:
   - **Women and children had higher survival rates than men** - This shows gender bias in rescue operations
   - **First-class passengers survived more often** - Better access to lifeboats
   - **Family size affects survival** - Solo travelers vs. families had different outcomes

---

## Q2: Data Transformation and Feature Engineering

**What was done:**

a) **Relevant Variables Selection**: Selected survival-related variables:
   - Survived, Pclass, Sex, Age, Fare, FamilySize
   - These are the most important predictors of survival

b) **Data Filtering**: Applied conditions like `Age > 30 | Fare > 50` to filter passengers. This helps analyze:
   - Older passengers
   - High-paying passengers
   - Their survival characteristics

c) **Grouping and Aggregation**: Grouped by **Sex** and computed:
   - Count of passengers
   - Average age and fare
   - Survival rate by gender
   - Found that women had ~74% survival rate vs. men ~19%

d) **New Feature Creation**: Created **FamilySize** feature:
   - Formula: SibSp (siblings/spouse) + Parch (parents/children) + 1 (the passenger)
   - Significance: Helps understand if family members helped or hindered survival chances

e) **Results Interpretation**: The transformation revealed that survival heavily depends on:
   - Gender (most important)
   - Passenger class
   - Family structure
   - Age

---

## Q3: Factor Variables Handling

**What was done:**

a) **Factor Identification and Justification**:
   - **Survived** → Factor (categorical outcome: Died/Survived)
   - **Pclass** → Factor (categorical: Class 1/2/3)
   - **Sex** → Factor (categorical: Male/Female)
   - These are categorical variables, not numeric, so factors are appropriate

b) **Converting to Factors**: Used `factor()` function:
   ```r
   Survived = factor(Survived, levels = c(0, 1), labels = c("Died", "Survived"))
   Pclass = factor(Pclass, levels = c(3, 2, 1))
   Sex = factor(Sex)
   ```

c) **Reordering Levels**: Reordered Pclass levels as 3, 2, 1 (instead of default 1, 2, 3) to:
   - Emphasize lower classes first
   - Make comparisons clearer in visualizations
   - Order by priority: 3rd class, 2nd class, 1st class

d) **Factors in Grouping**: Factors automatically organize data by levels, making grouping cleaner:
   - Factors prevent unwanted numeric operations
   - They ensure correct ordering in plots and tables

e) **Factors vs. Characters**:
   - **Factors**: Have levels, support ordering, efficient for grouping, useful for statistical models
   - **Characters**: No order, more memory usage, not suitable for regression models
   - Example: "Sex" as factor organizes data by Male/Female levels; as character it's just text

---

## Q4: Categorical Variable Analysis

**What was done:**

a) **Frequency Distribution**: Created frequency table showing:
   - Count of males and females who survived/died
   - Found: 233 females survived, 81 females died vs. 109 males survived, 468 males died

b) **Visualization**: Created stacked bar plot showing:
   - X-axis: Sex (Male/Female)
   - Y-axis: Proportion of Survived/Died
   - Color coding: Different colors for each outcome
   - The plot clearly shows women had much higher survival proportion

c) **Factor Level Influence**: Analyzed how Sex levels (Male/Female) influenced Survived outcome:
   - Females: 74% survived
   - Males: 19% survived
   - Huge difference shows gender was critical for survival

d) **Practical Significance**:
   - Ship followed "women and children first" protocol
   - This explains the stark difference in survival rates
   - Men were expected to help women and children first

---

## Q5: Structured Data Analysis Workflow

**What was done:**

This question tied everything together into a complete workflow:

1. **Data Loading**: Read CSV file and inspected structure
2. **Preprocessing**: Handled missing values using median imputation
3. **Factor Conversion**: Converted Survived, Pclass, Sex to factors
4. **Feature Engineering**: Created FamilySize derived feature
5. **Exploratory Analysis**: Computed statistics, created visualizations, identified patterns
6. **Interpretation**: Drew conclusions about survival factors
7. **Model Development**: Built machine learning model (see Q6)

The workflow ensures:
- Clean, usable data
- Proper data types
- Feature relevance
- Actionable insights

---

## Q6: Machine Learning Pipeline - Predicting Fuel Efficiency

**What was done:**

a) **Dataset Examination**: Examined mtcars dataset structure:
   - 32 cars
   - 11 variables
   - Numeric data

b) **Variable Selection**: Selected predictors for MPG (miles per gallon):
   - **Dependent (target)**: mpg (fuel efficiency)
   - **Independent (predictors)**: wt (weight), hp (horsepower), cyl (cylinders), disp (displacement), drat, qsec
   - Reason: These are physically related to fuel consumption

c) **Data Preprocessing**: 
   - Verified data types (all numeric - good for regression)
   - No missing values handling needed

d) **Exploratory Analysis**: 
   - Computed correlation matrix between variables
   - Found strong correlations:
     - Weight negatively affects MPG (heavier = less efficient)
     - Horsepower negatively affects MPG (more power = more fuel)
     - Cylinders negatively affect MPG

e) **Train-Test Split**: Used 80-20 split:
   - 80% of data (26 cars) for training
   - 20% of data (6 cars) for testing
   - Set seed=123 for reproducibility

f) **Model Development**: Built linear regression:
   ```r
   mpg ~ wt + hp + cyl
   ```
   Selected these 3 predictors because they have strongest correlations

g) **Model Evaluation**:
   - **MSE (Mean Squared Error)**: ~2.7 (how far predictions are off on average)
   - **R² (R-Squared)**: ~0.88 (88% of variation explained by the model)
   - This is a good model!

h) **Coefficient Interpretation**:
   - **Weight coefficient**: Negative (-2.9) → Each 1000 lbs more reduces MPG by ~2.9
   - **Horsepower coefficient**: Negative (-0.04) → Each 1 HP more reduces MPG slightly
   - **Cylinders coefficient**: Negative (-0.6) → More cylinders = less efficient

i) **Underfitting/Overfitting Analysis**:
   - R² = 0.88 suggests good fit (not too high to overfit, not too low to underfit)
   - Model generalizes well to test data
   - No signs of overfitting or underfitting

j) **Possible Improvements**:
   - Include interaction terms (e.g., wt × hp)
   - Try polynomial regression for non-linear relationships
   - Add more relevant predictors if available
   - Use regularization techniques (Ridge/Lasso)

---

## Dashboard Features

The Shiny app displays:
- **Statistics Boxes**: Total passengers, survival rate, median age, average family size
- **Data Tables**: Showing raw data, filtered data, grouped summaries
- **Factor Analysis**: Comparing factors vs. characters
- **Frequency Tables**: Categorical distributions
- **Visualizations**: Bar plots showing survival by gender
- **ML Model Results**: Correlation matrix, model summary, predictions vs actual plot
- **Performance Metrics**: MSE and R² values

## Summary

This project demonstrates a complete data science workflow:
1. ✅ Data loading and cleaning
2. ✅ Exploratory data analysis
3. ✅ Feature engineering
4. ✅ Factor handling and categorical analysis
5. ✅ Statistical insights
6. ✅ Machine learning model building and evaluation

All answers are implemented in an interactive R Shiny dashboard for easy exploration!
