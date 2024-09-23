# Install the packages
install.packages("readxl")
library(readxl)
# Load your dataset

data2 <- read_excel("C:/Users/Blessed/Documents/Techwiz2/EcoShield/EcoShield/SP_dataset2.xlsx")
print(data2)
# View first few rows of the dataset
head(data2)

# Handle missing values (optional)
data2[is.na(data2)]<- 0

# Convert categorical variables to factors
data2$CategoryColumn <- as.factor(data2$Total_Production)

# Split data into training and testing sets (70% train, 30% test)
# creating a test set with 30% of the data
set.seed(123)
test_size <- floor(0.3 * nrow(data2))
test_indices <- sample(1:nrow(data2), test_size)
testData <- data2[test_indices, ]
trainData <- data2[-test_indices, ]
print(testData)
print(trainData)

dim(testData)

# Random Forest
install.packages("randomForest")
library(randomForest)

# Replace spaces with underscores and remove special characters for all column names
colnames(trainData) <- gsub(" ", "_", colnames(trainData))
colnames(trainData) <- gsub("[^a-zA-Z0-9_]", "", colnames(trainData))

colnames(testData) <- gsub(" ", "_", colnames(testData))
colnames(testData) <- gsub("[^a-zA-Z0-9_]", "", colnames(testData))

trainData$Total_Production <- as.numeric(gsub("[^0-9.-]", "", trainData$Total_Production))
testData$Total_Production <- as.numeric(gsub("[^0-9.-]", "", testData$Total_Production))

trainData[is.na(trainData)] <- 0  # Replace NA with 0


# Train a Random Forest regression model
rf_model <- randomForest(Total_Production ~ country_name1, data = trainData)
print(rf_model)
# Predict on the test data
rf_predictions <- predict(rf_model, testData)
print(rf_predictions)



# Evaluate the model using RMSE
rmse <- sqrt(mean((rf_predictions - testData$Total_Production)^2))
print(paste("RMSE:", rmse))

# Support Vector Machine
# load the package
install.packages("e1071")  # Install the package if you don't have it
library(e1071)             # Load the library
install.packages("caret")  # Install the package if you haven't
library(caret)             # Load the package into the session

# Train SVM model
svm_model <- svm(Total_Production ~ country_name1, data = trainData, kernel = "linear")
print(svm_model)

# Predict on the test data
# Ensure consistent factor levels between train and test sets
testData$country_name1 <- factor(testData$country_name1, levels = levels(trainData$country_name1))

# Remove rows in the test set that have NA values for country_name1 (due to unseen levels)
testData <- testData[!is.na(testData$country_name1), ]

# Now make predictions
svm_predictions <- predict(svm_model, testData)
print(svm_predictions)


# Train Naive Bayes model
install.packages("naivebayes")
library(naivebayes)
nb_model <- naiveBayes(Total_Production ~ country_name1, data = trainData)
print(nb_model)
# Predict on the test data
nb_predictions <- predict(nb_model, testData)
print(nb_predictions)
