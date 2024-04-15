-- CREATE DATABASE

CREATE DATABASE IF NOT EXISTS salesdatawalmart;

-- CREATE TABLE
salesCREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer VARCHAR (30) NOT NULL,
    gender VARCHAR (10) NOT NULL,
    product_line VARCHAR (100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4),
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
)

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

SELECT * FROM salesdatawalmart.sales;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

-- FEATURE ENGINEERING (generate new columns)
/*
Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. 
This will help answer the question on which part of the day most sales are made.
*/

SELECT 
	time,
    (CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:00:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:00:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END
);

/*
Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
This will help answer the question on which week of the day each branch is busiest.
*/

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

/*
Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
Help determine which month of the year has the most sales and profit. 
*/

SELECT
	date,
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------


-- GENERIC QUESTIONS
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

-- BUSINESS QUESTIONS: PRODUCT 

-- How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line) AS number_unique_pl
FROM sales;

-- What is the most common payment method?
SELECT 
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?
SELECT 
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month?
SELECT 
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT
    month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	city,
    branch,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT
    product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT
	AVG(total) 
FROM sales;

SELECT 
	product_line,
	ROUND(AVG(total),2) AS avg_sales,
	(CASE
		WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN "Good"
        ELSE "Bad"
	END) AS Criteria
FROM sales
GROUP BY product_line
ORDER BY avg_sales;

-- Which branch sold more products than average product sold?
SELECT AVG(quantity)
FROM sales;

SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

-- BUSINESS QUESTIONS: SALES

-- Number of sales made in each time of the day per weekday
SELECT
    time_of_day,
    COUNT(*) AS total_sales
FROM sales
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT 
	customer AS customer_type,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	city,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY city
ORDER BY avg_VAT DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer AS customer_type,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------

-- BUSINESS QUESTIONS: CUSTOMER
-- How many unique customer types does the data have?
SELECT 
	DISTINCT customer
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT
	customer AS customer_type,
	COUNT(customer) AS cnt
FROM sales
GROUP BY customer
ORDER BY cnt DESC;

-- Which customer type buys the most?
SELECT
	customer AS customer_type,
    SUM(total) AS total_sales
FROM sales
GROUP BY customer_type
ORDER BY total_sales DESC;

SELECT
	customer AS customer_type,
    SUM(quantity) AS total_qty
FROM sales
GROUP BY customer_type
ORDER BY total_qty DESC;

-- What is the gender of most of the customers?
SELECT 
	gender,
    COUNT(*) AS cnt
FROM sales
GROUP BY gender
ORDER BY cnt DESC;

-- What is the gender distribution per branch?
SELECT
	DISTINCT branch,
    gender,
    COUNT(*) AS cnt
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;

-- Which time of the day do customers give most ratings?
SELECT
    time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;


-- Which time of the day do customers give most ratings per branch?
SELECT
    branch,
    time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT
    day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;


-- Which day of the week has the best average ratings per branch?
SELECT
    branch,
    day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------
