# Exploratory Data Analysis on Layoffs Data  
# This SQL project explores layoffs data, focusing on identifying trends, patterns, and insights.

# 1. Preview the cleaned dataset to understand its structure.
SELECT *
FROM layoffs_clean;

# 2. Identify the maximum number of employees laid off on a single day.
SELECT MAX(total_laid_off) AS max_layoffs_in_one_day
FROM layoffs_clean;

# 3. Find companies that had 100% of their employees laid off (i.e., completely shut down).
SELECT company, percentage_laid_off
FROM layoffs_clean
WHERE percentage_laid_off = 1;

# 4. List the distinct stages of companies in the dataset.
SELECT DISTINCT stage
FROM layoffs_clean;

# 5. Identify the companies that laid off the most employees in a single event.
SELECT company, MAX(total_laid_off) AS max_layoffs
FROM layoffs_clean
GROUP BY company
ORDER BY max_layoffs DESC;

# 6. Analyze companies with large amounts of funding that experienced significant layoffs.
SELECT company, SUM(total_laid_off) AS total_layoffs, SUM(funds_raised_millions) AS total_funding
FROM layoffs_clean
GROUP BY company
ORDER BY total_layoffs DESC, total_funding DESC;

# 7. Identify companies that laid off more than 1,000 employees.
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
GROUP BY company
HAVING SUM(total_laid_off) > 1000;

# 8. Determine the date range of layoffs in the dataset.
SELECT MIN(`date`) AS start_date, MAX(`date`) AS end_date
FROM layoffs_clean;

# 9. Find the total number of layoffs by year to see which year had the most layoffs.
SELECT YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
GROUP BY `year`;

# 10. Identify which sectors (industries) were hit the hardest by layoffs.
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
GROUP BY industry
ORDER BY total_layoffs DESC;

# 11. Find countries that had more than 100,000 layoffs and rank them by total layoffs.
SELECT country, SUM(total_laid_off) AS layoffs
FROM layoffs_clean
GROUP BY country
ORDER BY layoffs DESC;

# 12. Calculate the cumulative total of layoffs per month using a rolling sum.
WITH rolling_layoffs AS (
  SELECT SUBSTRING(date, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
  FROM layoffs_clean
  WHERE SUBSTRING(date, 1, 7) IS NOT NULL
  GROUP BY `month`
  ORDER BY `month`
)
SELECT `month`, SUM(total_off) OVER (ORDER BY `month`) AS cumulative_layoffs
FROM rolling_layoffs
ORDER BY `month`;

# 13. Analyze which stages of companies experienced the most layoffs.
SELECT stage, SUM(total_laid_off) AS layoffs
FROM layoffs_clean
GROUP BY stage
ORDER BY layoffs DESC;

# 14. Break down layoffs by company and year to see trends over time.
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

# 15. Identify the top 5 companies with the largest layoffs each year using a DENSE_RANK window function.
WITH layoffs AS (
  SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS laid
  FROM layoffs_clean
  GROUP BY company, YEAR(`date`)
  HAVING SUM(total_laid_off) IS NOT NULL
  ORDER BY `year` ASC, laid DESC
),
company_ranking AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY `year` ORDER BY laid DESC) AS ranking
  FROM layoffs
  WHERE `year` IS NOT NULL
)
SELECT *
FROM company_ranking
WHERE ranking < 6
ORDER BY `year`;