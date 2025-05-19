-- Create the retail_sales table.
CREATE TABLE retail_sales (
    transaction_id SERIAL PRIMARY KEY,
    date DATE,
    customer_id VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    product_category VARCHAR(100),
    quantity INT,
    price_per_unit NUMERIC(10,2),
    total_amount NUMERIC(10,0)
);
-- ============================================
-- Data Exploration
-- ============================================
-- View the first 10 rows of data.
SELECT * FROM retail_sales LIMIT 10;

-- View the total sales by month.
SELECT 
    DATE_TRUNC('month', date) AS sales_month,
    SUM(total_amount) AS total_monthly_sales
FROM retail_sales
GROUP BY sales_month
ORDER BY sales_month;

-- View sales by gender.
SELECT 
    gender,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_sales,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM retail_sales
GROUP BY gender;

-- View top performing products categories.
SELECT 
    product_category,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_amount) AS total_revenue
FROM retail_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- View top 10 customers by lifetime value.
SELECT 
    customer_id,
    SUM(total_amount) AS customer_lifetime_value,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS customer_rank
FROM retail_sales
GROUP BY customer_id
ORDER BY customer_lifetime_value DESC
LIMIT 10;

-- View age group breakdown
SELECT
    CASE
        WHEN age >= 18 AND age <= 25 THEN '18-25'
        WHEN age <= 35 THEN '26-35'
        WHEN age <= 45 THEN '36-45'
        WHEN age <= 55 THEN '46-55'
        WHEN age <= 65 THEN '56-65'
        ELSE '66+'
    END AS age_group,
    COUNT(*) AS total_transactions,
    SUM(total_amount) AS total_sales
FROM retail_sales
GROUP BY age_group
ORDER BY total_sales DESC;

-- View monthly sales and a 3-month rolling average.
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', date) AS sales_month,
        SUM(total_amount) AS total_sales
    FROM retail_sales
    GROUP BY DATE_TRUNC('month', date)
),
rolling_avg AS (
    SELECT 
        sales_month,
        total_sales,
        ROUND(
            AVG(total_sales) OVER (
                ORDER BY sales_month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS rolling_3_month_avg,
        TO_CHAR(sales_month, 'Mon YYYY') AS sales_month_label
    FROM monthly_sales
)
SELECT * 
FROM rolling_avg;

-- View rank of product performance by month. 
WITH monthly_category_sales AS (
    SELECT 
        DATE_TRUNC('month', date) AS sales_month,
        product_category,
        SUM(total_amount) AS category_sales
    FROM retail_sales
    GROUP BY DATE_TRUNC('month', date), product_category
),
category_ranked AS (
    SELECT 
        sales_month,
        product_category,
        category_sales,
        RANK() OVER (
            PARTITION BY sales_month 
            ORDER BY category_sales DESC
        ) AS category_rank,
        TO_CHAR(sales_month, 'Mon YYYY') AS sales_month_label
    FROM monthly_category_sales
)
SELECT * 
FROM category_ranked
WHERE category_rank <= 3;