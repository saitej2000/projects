# Walmart Sales Anlayis

create database if not exists WalmartSales_Analysis;

CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(30) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100),
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- Feature Engineering ----------------------------------------------------------------------------------

-- --- time_of_day
select time,
(Case 
    when time between "00:00:00" and "12:00:00" then "Morning"
    when time between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening" end) as time_of_day 
 from sales;

-- ---------creating column and inserting the values by using update.....

ALTER TABLE sales add column time_of_day varchar(20);

set sql_safe_updates = 0;
update sales 
set time_of_day = (Case 
    when time between "00:00:00" and "12:00:00" then "Morning"
    when time between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening" end);
set sql_safe_updates = 1;

-- --- day_name
select date, dayname(date) from sales;

alter table sales add column day_name varchar(10);

set sql_safe_updates = 0;
update sales 
set day_name = dayname(date);
set sql_safe_updates = 1;

-- --- month_name
select date, monthname(date) from sales;

alter table sales add column month_name varchar(10);
set sql_safe_updates = 0;
update sales 
set month_name = monthname(date);
set sql_safe_updates = 1;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- Generic questions ------------------------------------------------------------------------------------ 

-- --1. How many unique cities does the data have?

select count(distinct city) from sales;

-- --2. in which city is each branch?

select count(distinct branch) from sales;
select distinct city, branch from sales;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- product questions ------------------------------------------------------------------------------------ 

-- --1. How many unique product lines does the data have?
select count(distinct product_line) from sales;

-- --2. what is the most common payment method?
select payment_method, count(payment_method) cnt from sales group by payment_method order by cnt desc;

-- --3. what is the most selling product_line?
select product_line, count(product_line) cnt from sales group by product_line order by cnt desc limit 3;

-- --4.what is the total revenue by month?
select month_name, sum(total) total from sales group by month_name order by total desc;

-- --5. what month had largest COGS?
select month_name, sum(cogs) sum from sales group by month_name order by sum desc limit 1;

-- --6. what product line has the largest revenue?
select product_line, sum(total) sum from sales group by product_line order by sum desc limit 1;

-- --7 what is the city with largest revenue?
select city, sum(total) sum from sales group by city order by sum desc limit 1;

-- --8. what product line has the largest VAT?
select product_line, avg(VAT) avg_VAT from sales group by product_line order by avg_VAT desc limit 1;

-- --9. fetch each product line and add a column to those product line showing "Good", "Bad". [Good if it is greater than avg sales]   ####not solved#####
select sum(total)/count(distinct product_line) from sales;     -- avg condition(53481)  <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

SELECT  
    product_line, sum(total) total_revenue,
    CASE
        WHEN SUM(total) > (select sum(total)/count(distinct product_line) from sales) THEN 'Good'
        ELSE 'Bad'
    END AS sales_raniking
FROM
    sales
GROUP BY product_line;


-- --10 which branch sold more products than avergare product sold?                                                           
select branch, sum(quantity) qty from sales group by branch having sum(quantity) > (select avg(quantity) from sales);

-- --11. what is the most common product line by gender?                         <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
select gender,product_line, count(gender) total_cnt from sales 
group by gender, product_line order by total_cnt desc;

select * from (select gender,product_line, count(gender) total_cnt, rank() over(partition by gender order by count(gender) desc) rnk from sales 
group by gender, product_line) a where rnk=1;

-- --12. what is the average rating of each product line?                         <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
select product_line, round(avg(rating),2) avg_rating from sales group by product_line order by avg_rating desc;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- Sales questions ------------------------------------------------------------------------------------ 

-- 1. Number of sales made in each time of the the day per week?
select time_of_day, count(*) from sales group by time_of_day;

-- 2. which of the customer types brings the most revenue
select customer_type, sum(total) total_revenue from sales group by customer_type order by total_revenue desc limit 1;

-- 3. which city has the largest tax percent/VAT (Value added tax)?
select city, avg(VAT) avg_VAT from sales group by city order by avg_VAT desc limit 1;

select avg(VAT) from sales;

-- 4. which customer type pays the most in VAT?
select customer_type, avg(VAT) avg_VAT from sales group by customer_type order by avg_VAT desc;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- Customer questions ------------------------------------------------------------------------------------ 

-- 1. How many unique customer types does the data have?
select count(distinct customer_type) from sales;

-- 2. How many unique payment methods does the data have?
select distinct payment_method from sales;

-- 3. what is the most common customer type?
select customer_type, count(customer_type) cnt from sales group by customer_type order by cnt desc;

-- 4. which cutomer type buys the most?
select customer_type, count(*) cnt from sales group by customer_type order by cnt desc;

-- 5. what is the gender of most of the customers?
select gender, count(*) cnt from sales group by gender order by cnt desc;

-- 6. what is the gender distribution per branch?
select branch, gender, count(gender) from sales group by branch, gender order by branch;

-- 7. which time of the day do customers give more ratings?
select time_of_day, avg(rating) avg_rating from sales group by time_of_day order by avg_rating desc;

-- 8. which time of the day do customers give more ratings per branch?
select branch, time_of_day, avg(rating) avg_rating from sales group by time_of_day, branch order by branch, avg_rating desc;

-- 9. which day of the week has the best avg rating?
select day_name, avg(rating) avg_rating from sales group by day_name order by avg_rating desc;

-- 10. which day of the week has the best avg rating?                        <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
SELECT * FROM
(SELECT 
    branch, day_name,
    AVG(rating) AS avg_rating,
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS branch_rank
FROM 
    sales 
GROUP BY 
    branch, day_name)a where branch_rank = 1;


