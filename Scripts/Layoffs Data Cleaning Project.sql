# SQL Project 1: Data Cleaning
#This project focuses on cleaning a dataset related to layoffs using SQL. The goal is to handle null values, remove duplicate records, and standardize data for further analysis. The project uses a temporary staging table for intermediate steps, followed by the creation of a cleaned table.

## Tasks Covered:
##1. Handling Null Values
##2. Removing Duplicate Rows
##3. Standardizing Columns
##4. Updating Inconsistent Data

#Creating a staging table from data table. 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT*
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

#Dealing with Null Values

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = 'Null' or industry = '';

UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE industry = 'Null' or industry = '';

UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off IS NULL OR percentage_laid_off = 0;

UPDATE layoffs_staging
SET stage = NULL
WHERE stage = 'Null' or stage = '';

UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions IS NULL OR funds_raised_millions = 0;



#Adding row numbers to each row to indentify duplicates and identifying duplicate entries

WITH layoffs_rows AS (
SELECT *, 
ROW_NUMBER() OVER 
	(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging 
)
SELECT *
	FROM layoffs_rows
    WHERE row_num > 1;
    
#Create new table with row numbers to delete duplicate rows

DROP TABLE IF EXISTS layoffs_clean; 

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


INSERT INTO layoffs_clean
WITH layoffs_rows AS (
SELECT *, 
ROW_NUMBER() OVER 
	(PARTITION BY company, location, `date`, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging 
)
SELECT *
FROM layoffs_rows;

SELECT *
FROM layoffs_clean
WHERE row_num > 1;


SELECT *
FROM layoffs_clean
WHERE company LIKE 'Ball%';

#Deleting duplicate rows 
DELETE 
FROM layoffs_clean
WHERE row_num > 1;

#Updating Null Values
#
SELECT *
FROM layoffs_clean;

SELECT DISTINCT industry
FROM layoffs_clean;

#Cleaning Column: industry 
UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry = 'CryptoCurrency'
	OR industry = 'Crypto Currency';
    
#Cleaning Column: total and % laid off
DELETE
FROM layoffs_clean
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

#Cleaning Column: COMPANY AND INDUSTRY
SELECT company, industry
FROM layoffs_clean;

#Updating industries if exists and NULL

UPDATE layoffs_clean as t1
		JOIN layoffs_clean AS t2
		ON t1.company = t2.company
		AND t1.location = t2.location
SET t1.industry = t2.industry 
	WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
    
SELECT *
FROM layoffs_clean
WHERE company = 'Airbnb';

#Cleaning Column: Stage (no cleaning needed)
SELECT DISTINCT stage
FROM layoffs_clean;

#Cleaning Column: Country
SELECT DISTINCT country
FROM layoffs_clean;

UPDATE layoffs_clean
SET country = 'United States'
WHERE country = 'United States.';

ALTER TABLE layoffs_clean
DROP COLUMN row_num;

SELECT *
FROM layoffs_clean;

