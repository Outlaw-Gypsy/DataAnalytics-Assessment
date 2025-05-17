SHOW TABLES;

SELECT *
FROM plans_plan;

SELECT *
FROM savings_savingsaccount;

SELECT *
FROM users_customuser;

SELECT *
FROM withdrawals_withdrawal;

DESCRIBE plans_plan;

DESCRIBE savings_savingsaccount;

DESCRIBE users_customuser;

DESCRIBE withdrawals_withdrawal;

-- 1) Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
-- users_customuser
-- savings_savingsaccount
-- plans_plan

SELECT 
  ss.owner_id,
  CONCAT(uc.first_name, ' ', uc.last_name) AS name,
  SUM(CASE WHEN pp.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count, -- Count only funded savings plans
  SUM(CASE WHEN pp.is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count, -- Count only funded investment plans
  SUM(ss.confirmed_amount) AS total_deposits -- Total amount deposited by the user
FROM savings_savingsaccount ss
LEFT JOIN plans_plan pp 
	ON ss.plan_id = pp.id
LEFT JOIN users_customuser uc 
	ON ss.owner_id = uc.id
GROUP BY ss.owner_id, name
HAVING savings_count >= 1 AND investment_count >= 1 -- Only keep customers who have at least one of each type
ORDER BY total_deposits DESC;



-- 4) For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup)
-- Total transactions
-- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
-- Order by estimated CLV from highest to lowest

-- Calculate estimated CLV for each customer based on their transaction activity
SELECT 
  uc.id AS customer_id,                                    
  CONCAT(uc.first_name, ' ', uc.last_name) AS name,          -- Full name
  TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE()) AS tenure_months, -- Months since signup
  COUNT(ss.id) AS total_transactions,                       -- Total number of transactions
  ROUND(
    CASE 
    -- If the user joined this month (0-month tenure), we can't divide by zero,
	-- so we assign a CLV of 0 to avoid errors.
      WHEN TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE()) = 0 THEN 0 
	-- Otherwise, apply the CLV formula
    -- (total_transactions / tenure_in_months) * 12 * average_profit_per_transaction
      ELSE (
        (COUNT(ss.id) / TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE())) * 12 * 
        (AVG(ss.confirmed_amount * 0.001) / 100)  -- 0.1% of transaction value (Formula provided)
      )
    END, 2 -- Round thevalue to 2 decimal places (as it is done for currency-based values)
  ) AS estimated_clv                                        -- Estimated Customer Lifetime Value in Naira
FROM users_customuser AS uc
LEFT JOIN savings_savingsaccount AS ss 
  ON uc.id = ss.owner_id
GROUP BY uc.id, uc.date_joined, uc.first_name, uc.last_name
ORDER BY estimated_clv DESC;

 





