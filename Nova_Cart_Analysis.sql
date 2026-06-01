
SELECT * 
FROM public."Nova_data"

---- REVENUE AND PROFITABILITY
-- Total Revenue
SELECT
	ROUND(
	 	SUM(total_amount),2) AS revenue
FROM public."Nova_data";

-- Total profit
SELECT
	SUM(profit) AS total_profit
FROM public."Nova_data";

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

-- Sold product
SELECT
	SUM(quantity) AS total_sold
FROM public."Nova_data"


-- sales channel profit and revenue
SELECT
	sales_channel,
	SUM(profit) AS total_profit,
	ROUND(
	 	SUM(total_amount),2) AS revenue
FROM public."Nova_data"
GROUP BY sales_channel;

-- Supplier and the revenue generated
SELECT
	supplier_name,
	ROUND(
	 	SUM(total_amount),2) AS revenue
FROM public."Nova_data"
GROUP BY supplier_name
ORDER BY supplier_name DESC;

-- Products and the revenue generated from them
SELECT 
	product_name,
	SUM(total_amount) AS revenue   -- Zentrix Laptop tops the list
FROM public."Nova_data"
GROUP BY product_name
ORDER BY revenue DESC;

-- Brand and the revenue generated from them
SELECT 
	brand, 
	SUM(total_amount) as revenue
FROM public."Nova_data"      				-- Onmicore contributed most to the revenue
GROUP BY brand
ORDER BY revenue DESC;

-- Customer segment and the amount generated 
SELECT
	customer_segment,
	SUM(total_amount) AS revenue,
	SUM(profit) AS total_profit
FROM public."Nova_data"  			--NEW customers top the list of the most revenue and profit
GROUP BY  customer_segment
ORDER BY revenue DESC, total_profit DESC;

-- Products relationship with revenue and profit
WITH revenue_profit AS (
	SELECT 
		product_name,
		SUM(total_amount) AS total_revenue,
		SUM(profit) AS total_profit
	FROM public."Nova_data"
	GROUP BY  product_name
	ORDER BY total_revenue DESC
)
SELECT *
from revenue_profit;

-- Discount relationship  with profit
SELECT 
	
FROM public."Nova_data";


-- Average order value
SELECT
	ROUND(
		AVG(profit),2) AS Avg_order_value
FROM public."Nova_data";

-- Average profit per product category
SELECT 
	product_category,
	ROUND(
		AVG(profit),2) AS avg_profit_per_categ
FROM public."Nova_data"
GROUP BY product_category;

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


---- PRODUCT PERFORMANCE
-- 5 Most Sold Product
SELECT
	product_name,
	SUM(quantity) AS sold
FROM public."Nova_data"		--HyperGrid Cleaning topped
GROUP BY product_name
ORDER BY sold DESC
LIMIT 5;

SELECT
	product_name,
	COUNT(
		CASE
			WHEN order_status = 'Returned' THEN order_id
		END) AS returned_product				-- OmniCore cooling is the most returned product
FROM public."Nova_data"
GROUP BY product_name
ORDER BY returned_product DESC;




---- CUSTOMER EXPERIENCE
-- Top 5 customers with the most orders and revenue generated from them
SELECT
	customer_id,
	COUNT(order_id) AS total_orders,
	SUM(total_amount) AS revenue
FROM public."Nova_data"
GROUP BY customer_id
ORDER BY  revenue DESC, total_orders DESC
LIMIT 5;

-- order status
SELECT
	order_status,
	COUNT(order_status) AS order_count
FROM public."Nova_data"
GROUP BY order_status
ORDER BY order_count DESC;

-- Top 5 most returned products
SELECT 
	product_name,
	COUNT(order_status) AS order_count
FROM public."Nova_data"					-- Omnicore Cooling was the most returned product
WHERE order_status = 'Returned' 
GROUP BY product_name
ORDER BY order_count DESC
LIMIT 5;

-- Is Returned orders affected by rating
SELECT 
	"Customer_rating",
	COUNT(order_status) AS order_count
FROM public."Nova_data"
WHERE order_status = 'Returned'  -- There is no direct relationship between both 
GROUP BY "Customer_rating"
ORDER BY order_count DESC;

--  Relationship between brand and returned orders
SELECT
	brand,
	COUNT(order_status) AS order_count
FROM public."Nova_data"
WHERE order_status = 'Returned'
GROUP BY brand 						-- Auralis got the Most order returned
ORDER BY order_count DESC;

-- product with the best rating
SELECT
	product_name,
	ROUND(
		AVG("Customer_rating"),1) AS avg_rating
FROM public."Nova_data"
GROUP BY product_name					-- NovaTech Shoes has the best rating
ORDER BY avg_rating DESC
LIMIT 1;
	
-- brand with the best rating
SELECT
	brand,
	ROUND(
		AVG("Customer_rating"),1) AS avg_rating
FROM public."Nova_data"
GROUP BY brand 							-- bad customer reputation although Zentrix topped 
ORDER BY avg_rating DESC;

-- rating relationship with delivery_speed
SELECT 	
	"Customer_rating",
	ROUND(
		AVG(delivery_time_days),2) AS avg_del_days 
FROM  public."Nova_data"        	-- Customer rating is influenced by delivery days
GROUP BY "Customer_rating"
ORDER BY avg_del_days ASC;


---- LOGISTICS
-- Average delivery days
SELECT 
	ROUND(
		AVG(delivery_time_days),2) AS avg_del_days 
FROM public."Nova_data";

--  Shipping_provider and the avg del days
SELECT
	shipping_provider,
	ROUND(
		AVG(delivery_time_days),2) AS avg_del_days 
FROM public."Nova_data"       				-- FedEx delivers the Fastest 
GROUP BY shipping_provider
ORDER BY avg_del_days ASC;

-- Which country experience the most delay in delivery
SELECT
	country,
	ROUND(
		AVG(delivery_time_days),2) AS avg_del_days 
FROM public."Nova_data" 
GROUP BY country 						-- Kenya get late deliveries the most
ORDER BY avg_del_days DESC
LIMIT 1;

-- Warehouse and the number of orders shipped out and how many were returned

WITH total_orders AS (
	SELECT
		COUNT(order_status) AS total_orders	
	FROM public."Nova_data" 	
)
SELECT 
	w.warehouse_location,
	COUNT(w.order_status) AS warehouse_orders,   			-- Lagos contributed 60% to the total_orders
	ROUND( 													--More than the other location combined
		(COUNT(w.order_status) * 100.0) / t.total_orders, 2) AS order_contribution_pct
FROM public."Nova_data" w
CROSS JOIN total_orders t
GROUP BY w.warehouse_location, t.total_orders;

-- warehouse and the number of returned orders
SELECT
	warehouse_location,
	COUNT(order_status) AS Returned_orders
FROM public."Nova_data" 					
WHERE order_status = 'Returned'   			-- Lagos had the most returned orders
GROUP BY warehouse_location
ORDER BY Returned_orders DESC;

-- Shipping provider and their average delivery cost
SELECT
	shipping_provider,
	ROUND(
	AVG(shipping_cost),2) AS avg_shipping_cost  --- UPS is the Most expensive shipping_provider
FROM public."Nova_data"
GROUP BY shipping_provider
ORDER BY shipping_provider DESC;

-- Shipping provider and the total number of orders delivered
SELECT
	shipping_provider,
	COUNT(order_id) AS prod_delivered
FROM public."Nova_data"          		--DHL handled the most orders
GROUP BY shipping_provider
ORDER BY prod_delivered DESC;


---- CUSTOMER BEHAVIOUR
-- Most used payment method
SELECT
	payment_method,
	COUNT(payment_method) AS payment_method_usage
FROM public."Nova_data"    
GROUP BY payment_method
ORDER BY payment_method_usage DESC;

-- Seasonal sales analysis
WITH seasonal_rev AS(
	SELECT
		EXTRACT(YEAR FROM order_date)	AS year_,
		EXTRACT(MONTH FROM order_date)	AS month_,
		COUNT(order_id) AS orders
FROM public."Nova_data" 
GROUP BY EXTRACT(MONTH FROM order_date), EXTRACT(YEAR FROM order_date)
),
month_classif AS (
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
	SUM(orders)  AS total_orders	-- Customers tend to purchsae more during rainy season
FROM month_classif
GROUP BY year_, season
ORDER BY year_ ASC, total_orders DESC;

-- Customer (age) segment and their revenue
WITH age_rev AS(
	SELECT
		age,
		SUM(total_amount) AS revenue
	FROM public."Nova_data" 
	GROUP BY age
	ORDER BY age ASC
),
age_class AS(
	SELECT *,
		CASE
			WHEN age IN (19,20,21,22,23,24,25, 26,27,28,29) THEN 'Young Adults'
			WHEN age IN (30,31,32,33,34,35,36,37,38,39,40,42,43,44) THEN 'Adults'
			WHEN age IN (45,46,47,48,49,50,51,52,53,54,55,56,57,58,59) THEN 'Mddle_Aged Adults'
			ELSE 'Older_adults'
		END AS age_classification
	FROM age_rev
)
SELECT 
	age_classification,
	SUM(revenue) AS total_revenue   ----  Middle aged adult spent the most
FROM age_class
GROUP BY age_classification
ORDER BY total_revenue DESC;

-- Percentage of customers that returns
WITH rep_behav as(
SELECT
	COUNT(repeat_purchase_flag) AS return_behaviour
FROM public."Nova_data" 
),
repeatability_calc AS(
	SELECT
		p.repeat_purchase_flag,
		COUNT(p.repeat_purchase_flag) AS repeat_purchase,
		ROUND(
			(COUNT(p.repeat_purchase_flag) *100.0) /r.return_behaviour,2) AS repeat_purchase_pct
	FROM public."Nova_data" p
	CROSS JOIN rep_behav r
	GROUP BY p.repeat_purchase_flag, r.return_behaviour
	ORDER BY repeat_purchase DESC
)
SELECT 									-- 75% did not return for another purchase
	repeat_purchase_flag,
	repeat_purchase,
	repeat_purchase_pct
FROM repeatability_calc;

-- how late deliveries affect repeat purchase 
SELECT
	repeat_purchase_flag,
	COUNT(								-- late deliveries affect repeat purchase
	CASE
		WHEN delivery_time_days > 7 THEN order_id
	END) AS late_deliveries
FROM public."Nova_data"
GROUP BY repeat_purchase_flag;

-- Churn
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

---- REGIONAL & GEOGRAPHIC QUESTIONS

-- Product orders by country
SELECT
	country,
	COUNT(order_id) AS total_orders			-- There is a balance of orders even though 
FROM public."Nova_data"						-- Nigeria topped
GROUP BY country
ORDER BY total_orders DESC;

-- countries and the categories of product that dominated them
WITH country_product AS(
	SELECT
		country,
		product_category,
		COUNT(order_id) AS total_orders
	FROM public."Nova_data"	
	GROUP BY country, product_category
	ORDER BY country ASC, total_orders DESC
),
product_rank AS(
	SELECT
		country,
		product_category,
		total_orders,
		ROW_NUMBER() OVER(ORDER BY country ASC, total_orders DESC) AS rank_
	FROM country_product
)
SELECT
	country,					-- Gaming products dominated 3 out of the 4 countries
	product_category,
	total_orders
FROM product_rank
WHERE rank_ IN (1,5,9,13);

-- Are delivery delays location specific
SELECT
	country,
	COUNT(order_id)AS total_order,
	COUNT(
		CASE
			WHEN delivery_time_days > 7 THEN order_id
		END 
		) AS delayed_deliveries,
	ROUND(
		COUNT(
			CASE
				WHEN delivery_time_days > 7 THEN order_id
			END
		) * 100.0/COUNT(order_id),2) AS delay_percentage
FROM public."Nova_data"
GROUP BY country
ORDER BY delay_percentAge DESC;

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

--  Product Funnel Analysis
WITH product_funnel_metrics AS(
	SELECT
		product_name,
		SUM(product_views) AS product_views_,
		SUM(add_to_cart_count) AS add_to_cart
	FROM public."Nova_data"
	GROUP BY product_name
),	
product_funnel_analysis AS(
	SELECT 
		product_name, 
		product_views_,
		add_to_cart,
		(add_to_cart * 100.0/product_views_)  AS conversion_rate,
		((product_views_ - add_to_cart) * 100 / product_views_) AS drop_off_rate
	FROM product_funnel_metrics
)
SELECT
	product_name,						
	product_views_,			
	add_to_cart,							
	ROUND(conversion_rate,2) AS conversion_rate,
	ROUND(drop_off_rate,2) AS drop_off_rate
FROM product_funnel_analysis
ORDER BY conversion_rate DESC;


	