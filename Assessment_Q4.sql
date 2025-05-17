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
