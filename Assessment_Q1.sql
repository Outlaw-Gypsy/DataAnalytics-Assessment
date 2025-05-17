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






