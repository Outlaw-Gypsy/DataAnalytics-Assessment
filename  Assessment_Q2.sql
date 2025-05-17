-- 2) Calculate the average number of transactions per customer per month and categorize them:
-- This query utilizes the following tables:
-- 1. users_customuser: Contains customer demographic and contact information
-- 2. savings_savingsaccount: Contains records of deposit transactions
-- The goal is to calculate average monthly transaction frequency per customer
-- and categorize customers as High, Medium, or Low Frequency users.

-- Compute the number of transactions per customer per month
WITH monthly_transactions AS (
  SELECT 
    ss.owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month, -- Extract year and month only
    COUNT(*) AS monthly_count -- Count number of transactions that month
  FROM savings_savingsaccount AS ss
	LEFT JOIN users_customuser AS uc
		ON ss.owner_id = uc.id
  GROUP BY ss.owner_id, txn_month
),
-- Calculate average monthly transactions per customer
avg_transactions_per_customer AS (
  SELECT 
    owner_id,
    AVG(monthly_count) AS avg_transactions_per_month -- Average monthly activity for each customer
  FROM monthly_transactions
  GROUP BY owner_id
),
-- Categorize each customer based on their average monthly transactions
categorized_customers AS (
  SELECT
    owner_id,
    avg_transactions_per_month,
    CASE 
      WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
      WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM avg_transactions_per_customer
)
-- Aggregate the categorized data for final output
SELECT
  frequency_category, -- Category (High/Medium/Low)
  COUNT(*) AS customer_count, -- Total customers in this category
  ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month -- Average of averages
FROM categorized_customers
GROUP BY frequency_category
ORDER BY 
  FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
  