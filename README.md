# Retail Sales Analysis (SQL + Tableau Visuals)
View [`Tableau Visualization`](https://public.tableau.com/app/profile/carissa.mason/viz/RetailAnalyticsSQLTableau_17476785683750/Dashboard) here

This project uses SQL to analyze 2023 retail sales. Using advanced SQL techniques, including CTEs, aggregations, and window functions, the data was cleaned and transformed to power a Tableau dashboard. The dashboard serves as a visual layer to communicate the business insights extracted through SQL.

> **Note**: Due to incomplete data, January 2024 data was excluded.

---

## SQL Analysis

The SQL workflow handles the core logic and calculations, including:

### 1. Rolling 3-Month Sales Average

```sql
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
```

### 2. Monthly Product Category Ranking

```sql
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
```
These prepared datasets were exported and connected to Tableau for visualization.

---
The queries below showcase further SQL capabilities applied during the project:

### 3. Customer Lifetime Value Ranking
Ranks the top 10 customers based on their total spent.

```sql
SELECT 
    customer_id,
    SUM(total_amount) AS customer_lifetime_value,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS customer_rank
FROM retail_sales
GROUP BY customer_id
LIMIT 10;
```
### 4. Age Group Bucketing with CASE
Buckets customers into age groups for demographic insights.

```sql
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
```
### Additional SQL Queries Used
- **Product Category Revenue Totals**
- **Sales by Gender with Avg Order Value**

*Full SQL file available in [`retail_sales_analysis.sql`](retail_sales_analysis.sql)*

## Tableau Visual Layer 

Tableau was used as a presentation layer to build:

- **KPI Cards**: Total Sales, MoM Growth %, Top Selling Category
- **Charts**:
  - Sales by Age Group
  - Top 10 Customers by Lifetime Value
  - Monthly Rank of Category Sales
  - Total Sales by Product Category Trend
  - Rolling 3-Month Avg Trend
  - MoM Growth % Chart

- **Interactivity**: Month parameter and hover tooltips

---

## Business Insights

- **Electronics** led as the highest-revenue category.
- **Age group 26-35** had the highest total sales.
- **MoM tracking** enabled clear visualization of fluctuations in revenue.
- **December slight decline** may point to seasonality or incomplete data.

---

## Actionable Suggestions

- Focus campaigns on high-performing age groups (26–35).
- Improve Beauty sales through promotions or product bundles.
- Monitor dips in rolling averages to improve inventory strategies.

---

## Data Source
This project utilizes the [Retail Sales Dataset](https://www.kaggle.com/datasets/mohammadtalib786/retail-sales-dataset?resource=download)
 from Kaggle. 
- File: `retail_sales_export.csv` from
- Fields: Customer ID, Age, Gender, Category, Month, Quantity, Unit Price, Total Amount
- January 2024 excluded from analysis due to partial data

---

## Tools & Skills

| Tool/Language | Purpose |
|---------------|---------|
| **SQL**       | Data exploration, aggregations, CTEs, window functions |
| **Tableau**   | Dashboard building and visualization |

---

## Project Scope

- SQL was used for all meaningful business logic
- Tableau was used for a user-friendly visual presentation
- Dashboard design guided by pre-aggregated SQL outputs
