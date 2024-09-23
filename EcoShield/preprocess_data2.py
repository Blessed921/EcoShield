import pandas as pd

# Load the Excel file to check the structure and content of the dataset
file_path = 'C:/Users/Blessed/Downloads/crops-yield-changes-hadcm3-sres.xlsx'

# Load the Excel file to inspect sheet names first
xls = pd.ExcelFile(file_path)
sheet_names = xls.sheet_names

# Load both sheets to see their content
dictionary_df = pd.read_excel(xls, sheet_name='dictionary')
data_df = pd.read_excel(xls, sheet_name='data')
co2_yield_sheet = pd.read_excel(file_path, sheet_name='CO2 level and avg yield change')

# Preview both sheets
dictionary_preview = dictionary_df.head()
data_preview = data_df.head()
print(dictionary_preview, data_preview, co2_yield_sheet.head())

# Preview the columns of the dictionary and data sheets
# print(dictionary_df.columns, data_df.columns)

# Create a dictionary to map column names from the 'data' sheet to their descriptions in the 'dictionary' sheet
column_mapping = dict(zip(dictionary_df['Data filenames'], dictionary_df['Description']))

# Rename columns in the 'data' dataframe using the dictionary
renamed_data_df = data_df.rename(columns=column_mapping)

# Handle missing values by filling NaNs with 0
renamed_data_df.fillna(0, inplace=True)

# Reduce: Sum the production values of wheat, rice, and maize for each country
renamed_data_df['Total_Production'] = renamed_data_df[['wheat production average 2000 to 2006 in t (FAO)',
                                                       'rice production average 2000 to 2006 in t (FAO)',
                                                       'maize production average 2000 to 2006 in t (FAO)']].sum(axis=1)

# Set display options to show all rows and columns
pd.set_option('display.max_rows', None)  # Display all rows
pd.set_option('display.max_columns', None)  # Display all columns

# Show the first few rows of the renamed dataframe to verify
print(renamed_data_df.head())

# Step 1: Handling missing values by checking their extent
missing_values = data_df.isnull().sum()

# Percentage of missing values per column to decide which columns to drop
missing_percentage = (missing_values / len(data_df)) * 100

# Let's examine columns with more than 50% missing data
high_missing_cols = missing_percentage[missing_percentage > 50]

# Remove columns with more than 50% missing data and preview the reduced data
reduced_data_df = data_df.drop(columns=high_missing_cols.index)
reduced_data_preview = reduced_data_df.head()

print(missing_percentage, high_missing_cols, reduced_data_preview)

# Impute missing values for production columns using the mean of each column
imputed_data_df = reduced_data_df.copy()

# Columns selected for imputation
columns_to_impute = ['WH_2000', 'RI_2000', 'MZ_2000']


# Convert columns to numeric and impute missing values without chaining operations
for column in columns_to_impute:
# Convert the column to numeric, forcing non-numeric values to NaN
    imputed_data_df[column] = pd.to_numeric(imputed_data_df[column], errors='coerce')

    # Impute missing values with the mean, assigning the result back to the column
    imputed_data_df[column] = imputed_data_df[column].fillna(imputed_data_df[column].mean())

    # Now the imputation is done without chaining, and there's no warning

# Preview the data after imputation
imputed_data_preview = imputed_data_df[columns_to_impute].head()

# print(imputed_data_preview)

# Save the manipulated data to a new Excel file
renamed_data_df.to_excel('SP_dataset2.xlsx', index=False)
