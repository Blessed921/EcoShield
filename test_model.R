# Load necessary libraries
library(ggplot2)
library(caret)  # for confusionMatrix and other metrics
library(readxl) # for reading Excel files
library(dplyr)  # for data manipulation

# Load the EcoShield.xlsx data
file_path <- "C:/Users/Blessed/Documents/Techwiz2/EcoShield/EcoShield/SP_dataset2.xlsx"
data  <- read_excel(file_path)

# Check the structure of the dataset
str(data)
any(is.na(data))
# Select relevant columns for the analysis (Total Production and predictor columns)
# Here, we use columns like production averages and yield change
data <- data %>%
  select(Total_Production,
         wheat production average 2000 to 2006 in t (FAO),
         rice production average 2000 to 2006 in t (FAO),
         maize production average 2000 to 2006 in t (FAO),
         wheat yield change (%) from baseline under the SRES A1FI 2020 scenario,
         rice yield change (%) from baseline under the SRES A1FI 2020 scenario) %>%
                            filter(complete.cases(.))  # Remove rows with missing values
                            
                            # Rename columns for easier access
                            colnames(data) <- c("Total_Production", "Wheat_Production", "Rice_Production", "Maize_Production", "Wheat_Yield_Change", "Rice_Yield_Change")
                            
                            
                            # Split the dataset into training and testing sets (70% training, 30% testing)
                            set.seed(123)  # For reproducibility
                            train_indices <- sample(1:nrow(data), 0.7 * nrow(data))  # 70% for training
                            train_data <- data[train_indices, ]
                            test_data <- data[-train_indices, ]
                            
                            # Print train and test data summary
                            cat("Training Data Summary:\n")
                            print(summary(train_data))
                            cat("\nTesting Data Summary:\n")
                            print(summary(test_data))
                            
                            # Clean and convert to numeric
                            train_data$Wheat_Production <- as.numeric(gsub("[^0-9.-]", "", train_data$Wheat_Production))
                            train_data$Rice_Production <- as.numeric(gsub("[^0-9.-]", "", train_data$Rice_Production))
                            train_data$Maize_Production <- as.numeric(gsub("[^0-9.-]", "", train_data$Maize_Production))
                            train_data$Wheat_Yield_Change <- as.numeric(gsub("[^0-9.-]", "", train_data$Wheat_Yield_Change))
                            train_data$Rice_Yield_Change <- as.numeric(gsub("[^0-9.-]", "", train_data$Rice_Yield_Change))
                            train_data$Total_Production <- as.numeric(gsub("[^0-9.-]", "", train_data$Total_Production))
                            
                            test_data$Wheat_Production <- as.numeric(gsub("[^0-9.-]", "", test_data$Wheat_Production))
                            test_data$Rice_Production <- as.numeric(gsub("[^0-9.-]", "", test_data$Rice_Production))
                            test_data$Maize_Production <- as.numeric(gsub("[^0-9.-]", "", test_data$Maize_Production))
                            test_data$Wheat_Yield_Change <- as.numeric(gsub("[^0-9.-]", "", test_data$Wheat_Yield_Change))
                            test_data$Rice_Yield_Change <- as.numeric(gsub("[^0-9.-]", "", test_data$Rice_Yield_Change))
                            test_data$Total_Production <- as.numeric(gsub("[^0-9.-]", "", test_data$Total_Production))
                            
                            
                            # Fit a linear model (predicting Total Production using other columns)
                            model <- lm(Total_Production ~ Wheat_Production + Rice_Production + Maize_Production + Wheat_Yield_Change + Rice_Yield_Change, data = train_data)
                            
                            # Make predictions on the test data
                            predictions <- predict(model, newdata = test_data)
                            
                            # Calculate metrics (MAE, MSE, RMSE, R-squared)
                            mae <- mean(abs(test_data$Total_Production - predictions))
                            mse <- mean((test_data$Total_Production - predictions)^2)
                            rmse <- sqrt(mse)
                            r_squared <- 1 - (sum((test_data$Total_Production - predictions)^2) / sum((test_data$Total_Production - mean(test_data$Total_Production))^2))
                            
                            # Print metrics
                            cat("Mean Absolute Error (MAE):", mae, "\n")
                            cat("Mean Squared Error (MSE):", mse, "\n")
                            cat("Root Mean Squared Error (RMSE):", rmse, "\n")
                            cat("R-squared (R²):", r_squared, "\n")
                            
                            # Combine actual and predicted values for plotting
                            results <- data.frame(Actual = test_data$Total_Production, Predicted = predictions)
                            
                            # Plotting the results with enhancements
                            ggplot(results, aes(x = Actual, y = Predicted)) +
                              geom_point(color = 'blue', size = 3, alpha = 0.7) +  # Enhanced visualization
                              geom_abline(intercept = 0, slope = 1, color = 'red', linetype = "dashed", size = 1) +
                              labs(title = "Actual vs Predicted Total Production",
                                   x = "Actual Total Production",
                                   y = "Predicted Total Production") +
                              theme_minimal() +
                              theme(plot.title = element_text(hjust = 0.5))  # Center the title
                            
                            # Conducting significance tests for the model (F-statistic and p-values)
                            cat("\nModel Summary:\n")
                            summary(model)
                            