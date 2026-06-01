# Nova_Cart_Analysis

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis Query Highlight](#data-analysis-query-highlight)


## Project Overview
This is an end-to-end Analysis into the sales nd operation performance of the e-commerc "Nova_Cart". By looking into varoius aspect of the company data, we seek to identify trends, sales drive, brand limitation, Retention Metrics, Customer drop_off rate, drop_off drivers and overall performance of the business.

## Data Sources
Nova_Cart_Date: The primary dataset used for this analysis is the "Nova_Cart_data.csv" file, containing detailed information about the sales made by the company. 

## Tools
- Excel - Data Cleaning 
   - [Download Here](https://microsoft.com)
- PostgreSQl - Data Analysis
   - [Download Here](https://www.postgresql.org/download/)
- PowerBI - Creating Report
   - [Download Here](https://www.microsoft.com/en-us/download/details.aspx?id=58494&msockid=2fafce07f9f165923597d8d4f8e36471)

## Data Cleaning
- Data loading and Inspection
- Gender, Sales Channel and Payment_method, columns standardisation
- Handling Null values
-  Date Format transfromation ("yyy-MM-dd)
-  Handling null values in customer rating
-  Columns Formatting
-  Data Grain_level Identification 

## Exploratory Data Analysis
- What is the overall sales trend?
- Which products are the top sellers?
- What are the peak sales period?
- Which brand distrbuted the most orders?
- Brand Retention Analysis

## Data Analysis Query Highlight
```sql
-- Profit Margin
WITH margin_calc AS (
	SELECT 					
		 SUM(total_amount) AS revenue,				-- 13% Profit margin
		 SUM(profit) AS total_profit
	FROM public."Nova_data"
)
SELECT 											
	ROUND(
		((total_profit * 100.0)/ NULLIF(revenue,0)),0) AS profit_margin
FROM margin_calc;
```
```sql
-- customer_retention
WITH monthly_orders AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date) AS order_month
    FROM public."Nova_data"
),
retention AS (
    SELECT							
        customer_id,
        order_month,
        LEAD(order_month) OVER(
            PARTITION BY customer_id
            ORDER BY order_month
        ) AS next_order_month							
    FROM monthly_orders
)
SELECT
    order_month,
    COUNT(customer_id) AS customers,
    COUNT(
        CASE
            WHEN next_order_month = order_month + INTERVAL '1 month'
            THEN customer_id
        END
    ) AS retained_customers,
	ROUND(
        COUNT(
            CASE
                WHEN next_order_month = order_month + INTERVAL '1 month'
                THEN customer_id
            END
        ) * 1.0 / COUNT(customer_id),2) AS retention_rate
FROM retention
GROUP BY order_month
ORDER BY order_month;
```
```sql
-- Brand funnel Analysis
WITH brand_funnel_metrics AS(
	SELECT
		brand,
		SUM(product_views) AS product_views_,
		SUM(add_to_cart_count) AS add_to_cart
	FROM public."Nova_data"
	GROUP BY brand
),	
brand_funnel_analysis AS(
	SELECT 
		brand, 
		product_views_,
		add_to_cart,
		(add_to_cart * 100.0/product_views_)  AS conversion_rate,
		((product_views_ - add_to_cart) * 100 / product_views_) AS drop_off_rate
	FROM brand_funnel_metrics
)
SELECT
	brand,						
	product_views_,			
	add_to_cart,							
	ROUND(conversion_rate,2) AS conversion_rate,
	ROUND(drop_off_rate,2) AS drop_off_rate
FROM brand_funnel_analysis
ORDER BY conversion_rate DESC;
```

## Result/Findings
- The Company has a 13% proft Margin
- The Company is having a hige proble with customer retention
- Zentrix Laptop is the product that generated the most Revenue, a total of ₦ 2,836,219.92 
- Omnicore Brand contributed most to the revenue with a total revenue of  ₦ 17,895,583.03
- New customers contributed most to the comany with a revenue of  ₦ 43,371,472.96 and a profit of ₦ 5,549,083.61
[Access the full Report Here]

## Limitations
There were 800 null names so I had to make use of the unique cusomer Id for quality control.

## References
[Stack Overflow](https://stackoverflow.com/)

No file chosen
Attach files by dragging & dropping, selecting or pasting them.
