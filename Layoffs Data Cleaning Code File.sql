# SQL Project 1: Data Cleaning
# This project focuses on cleaning a dataset related to layoffs using SQL. The goal is to handle null values, remove duplicate records, and standardize data for further analysis. The project uses a temporary staging table for intermediate steps, followed by the creation of a cleaned table.

## Tasks Covered:
## 1. Handling Null Values
## 2. Removing Duplicate Rows
## 3. Standardizing Columns
## 4. Updating Inconsistent Data

# Creating a staging table from the data table.
# This step creates a temporary staging table that is a copy of the original table structure.

CREATE TABLE layoffs_staging
LIKE layoffs;

# Checking the structure of the staging table to ensure it's created correctly.

SELECT *
FROM layoffs_staging;

# Inserting all data from the original table into the staging table for cleaning purposes.

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

# Dealing with Null Values
# Replacing the text 'Null' or empty values in the 'industry' column with actual SQL NULL values.

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = 'Null' OR industry = '';

# Replacing 'Null' or empty values in the 'total_laid_off' column with SQL NULL values.

UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE industry = 'Null' OR industry = '';

# Replacing 0 or existing NULL values in the 'percentage_laid_off' column with SQL NULL values for consistency.

UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off IS NULL OR percentage_laid_off = 0;

# Replacing the text 'Null' or empty values in the 'stage' column with actual SQL NULL values.

UPDATE layoffs_staging
SET stage = NULL
WHERE stage = 'Null' OR stage = '';

# Replacing 0 or existing NULL values in the 'funds_raised_millions' column with SQL NULL values for consistency.

UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions IS NULL OR funds_raised_millions = 0;

# Adding row numbers to each row to identify duplicates and identifying duplicate entries.
# Using ROW_NUMBER() to assign a unique number to each row within partitions based on key columns.
# Rows with row_num > 1 are considered duplicates.

WITH layoffs_rows AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM layoffs_rows
WHERE row_num > 1;

# Create a new table to store cleaned data and delete duplicate rows.
# Dropping the existing clean table if it exists.

DROP TABLE IF EXISTS layoffs_clean;

# Creating a new table to store cleaned data, including the row number column for identifying duplicates.

CREATE TABLE `layoffs_clean` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Inserting data from the staging table into the clean table with row numbers assigned to each row.

INSERT INTO layoffs_clean
WITH layoffs_rows AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY company, location, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM layoffs_rows;

# Checking for duplicate rows in the clean table.

SELECT *
FROM layoffs_clean
WHERE row_num > 1;

# Example query to check for a specific company to ensure the data is correctly cleaned.

SELECT *
FROM layoffs_clean
WHERE company LIKE 'Ball%';

# Deleting duplicate rows from the clean table by removing rows with row_num > 1.

DELETE 
FROM layoffs_clean
WHERE row_num > 1;

# Updating Null Values
# Checking the cleaned table to ensure null values have been handled properly.

SELECT *
FROM layoffs_clean;

# Checking distinct values in the 'industry' column to identify inconsistencies.

SELECT DISTINCT industry
FROM layoffs_clean;

# Cleaning the 'industry' column by standardizing inconsistent values.

UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry = 'CryptoCurrency'
    OR industry = 'Crypto Currency';

# Cleaning the 'total_laid_off' and 'percentage_laid_off' columns by removing rows where both are NULL.

DELETE
FROM layoffs_clean
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

# Checking company and industry data for inconsistencies.

SELECT company, industry
FROM layoffs_clean;

# Updating the 'industry' column for rows where it is NULL based on matching rows with the same company and location.

UPDATE layoffs_clean AS t1
    JOIN layoffs_clean AS t2
    ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

# Verifying data for a specific company to ensure accuracy.

SELECT *
FROM layoffs_clean
WHERE company = 'Airbnb';

# Cleaning the 'stage' column (no cleaning needed as values are already consistent).

SELECT DISTINCT stage
FROM layoffs_clean;

# Cleaning the 'country' column by standardizing inconsistent values.

SELECT DISTINCT country
FROM layoffs_clean;

# Updating the 'country' column to fix inconsistent values.

UPDATE layoffs_clean
SET country = 'United States'
WHERE country = 'United States.';

# Dropping the 'row_num' column from the clean table as it is no longer needed.

ALTER TABLE layoffs_clean
DROP COLUMN row_num;

# Checking the final cleaned table to ensure all cleaning steps have been applied correctly.

SELECT *
FROM layoffs_clean;
