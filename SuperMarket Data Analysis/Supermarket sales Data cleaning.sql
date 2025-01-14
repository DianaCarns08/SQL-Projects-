DESCRIBE supermarket;

#Updating column types
ALTER TABLE supermarket
MODIFY COLUMN `Invoice ID` VARCHAR(20);

ALTER TABLE supermarket
MODIFY COLUMN `Unit price` DECIMAL(10,2);

ALTER TABLE supermarket
MODIFY COLUMN `Quantity` INT;

ALTER TABLE supermarket
MODIFY COLUMN `Date` DATE;

ALTER TABLE supermarket
DROP COLUMN `Date Backup`;

ALTER TABLE supermarket
ADD COLUMN `Date Backup` VARCHAR(20);

UPDATE  supermarket
SET `Date Backup` = `Date`;

UPDATE supermarket
SET `Date`= STR_TO_DATE(`Date`, '%m/%d/%Y');

ALTER TABLE supermarket
MODIFY COLUMN `Date` DATE;

ALTER TABLE supermarket
MODIFY COLUMN `Time` TIME;

ALTER TABLE supermarket
MODIFY COLUMN `cogs` DECIMAL(10,2);


ALTER TABLE supermarket
MODIFY COLUMN `gross margin percentage` DECIMAL(10,6);

ALTER TABLE supermarket
MODIFY COLUMN `gross income` DECIMAL(10,6);

ALTER TABLE supermarket
MODIFY COLUMN `rating` DECIMAL(10,6);

SELECT *
FROM supermarket;

#What is the most popular payment method used by customers?
SELECT DISTINCT payment,COUNT(payment)
FROM supermarket
GROUP BY payment;

#Which branch is the most profitable?
SELECT DISTINCT branch, AVG(`gross income`) AS Avg_income
FROM supermarket
GROUP BY branch
ORDER BY Avg_income DESC;

-- Which product category generates the highest revenue?
SELECT `Product Line`, ROUND(SUM(Total),2) AS Total_Revenue
FROM supermarket
GROUP BY `Product Line`
ORDER BY Total_Revenue DESC;

-- How many products are purchased by customers?
SELECT `Invoice ID`,SUM(Quantity) AS Products
FROM supermarket
GROUP BY `Invoice ID`
ORDER BY 1;

-- In which city branch should expansion be considered, and which products should be emphasized
SELECT City, SUM(`gross income`)AS income, SUM(Quantity)AS products, (SUM(`gross income`)/SUM(Quantity)) AS Profit_per_product
FROM supermarket
GROUP BY City
ORDER BY 2 DESC;

-- Demographics in City
SELECT City, Gender, COUNT(*) AS Total_persons
FROM supermarket
GROUP BY city, gender;

#Average Profit by city, gender
SELECT City, Gender,COUNT(*)AS Total_persons,SUM(`gross income`) AS Avg_income, SUM(QUantity) AS Products_sold, ROUND((SUM(`gross income`)/SUM(QUantity)),2) AS Income_per_product
FROM supermarket
GROUP BY City,Gender
ORDER BY City, 3 DESC;

#Profit by Month
SELECT SUBSTRING(`Date`,6,2) AS Months, Avg(`gross income`) as Avg_Profit
FROM supermarket
GROUP BY SUBSTRING(`Date`,6,2)
ORDER BY 2 DESC;

-- Avg Profit per product line per month
SELECT `Product Line`, SUBSTRING(`Date`,6,2) AS Months,Avg(`gross income`) as Avg_Profit
FROM supermarket
GROUP BY `Product Line`,SUBSTRING(`Date`,6,2)
ORDER BY 1;

-- Product Line purchases by Gender
SELECT Gender, `Product Line`, COUNT(*) AS Purchases
FROM supermarket
GROUP BY `Product Line`,Gender
ORDER BY 2;

SELECT `Product Line`, 
	SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female_count,
	SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male_count,
    COUNT(*) AS Total
FROM supermarket
GROUP BY `Product Line`;

-- Gender and payment type
SELECT Gender, Payment, COUNT(*) AS Payment_type
FROM supermarket
GROUP BY Gender, Payment
ORDER BY 2;

