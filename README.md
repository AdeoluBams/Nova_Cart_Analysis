# Nova_Cart_Analysis

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- 


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
- Gender, Sales Channel and Payment_method columns standardisation
-  Date Format transfromation ("yyy-MM-dd)
-  Handling null values in customer rating
-  Columns Formatting
-  Data Grain_level Identification 

## Exploratory Data Analysis/ Analysis Highlight
- What is the overall sales trend?
- Which products are the top sellers?
- What are the peak sales period?
- Which brand distrbuted the most orders?
- Brand Retention Analysis

## Data Analysis (Query) Highlight
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
```sql
-- month over month growth
WITH month_month AS (
	SELECT
		EXTRACT(Year FROM order_date) AS year_,
		SUM(total_amount) AS revenue
	FROM public."Nova_data"
	GROUP BY year_
),
revenue_diff AS(
 	SELECT
	 	year_,
		revenue,
		LAG(revenue) OVER(ORDER BY year_) AS prev_revenue
	FROM month_month
),
growth_calc AS(
	SELECT 
		year_,
		revenue,
		prev_revenue,
		(prev_revenue - revenue)/ NULLIF (prev_revenue,0) AS perc_change
	FROM revenue_diff
)
SELECT *
FROM growth_calc;
```
```sql
-- Seasonal sales analysis
WITH seasonal_rev AS(
	SELECT
		EXTRACT(YEAR FROM order_date)	AS year_,
		EXTRACT(MONTH FROM order_date)	AS month_,
		COUNT(order_id) AS orders
FROM public."Nova_data" 
GROUP BY EXTRACT(MONTH FROM order_date), EXTRACT(YEAR FROM order_date)
),
month_classif AS (                                                         -- Customers tend to purchaae more during rainy season
	SELECT *,
		CASE 
			WHEN month_ IN (11,12,1,2,3) THEN 'Dry Season'
			ELSE 'Rainy Season'
		END AS season
	FROM seasonal_rev
)
SELECT 
	year_,
	season,
	SUM(orders)  AS total_orders	
FROM month_classif
GROUP BY year_, season
ORDER BY year_ ASC, total_orders DESC;
```

## Result/Findings

## Recommendations

## Limitations

## References

No file chosen
Attach files by dragging & dropping, selecting or pasting them.
