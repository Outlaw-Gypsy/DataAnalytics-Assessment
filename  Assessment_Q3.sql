-- 3) Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).
-- This query was derived by analyzing two tables:
-- 1. plans_plan – which defines the type of each financial plan (savings or investment)
-- 2. savings_savingsaccount – which stores transaction dates, plan IDs, owner IDs, and account activity status
-- The goal is to find all active accounts with no transactions in the past 365 days.

-- Get latest transaction date per account
WITH last_txn_per_account AS (
  SELECT 
    plan_id,
    owner_id,
    MAX(transaction_date) AS last_transaction_date -- Get the most recent transaction date
  FROM savings_savingsaccount
  GROUP BY plan_id, owner_id
)
-- Join with plans and document the number of days of inactivity
SELECT
  sa.plan_id,
  sa.owner_id,
  CASE
    WHEN p.is_regular_savings = 1 THEN 'Savings' -- Determine the plan type by using the provided flag
    WHEN p.is_a_fund = 1 THEN 'Investment'
    ELSE 'Unknown'
  END AS type, -- Type of plan: either Savings or Investment
  lta.last_transaction_date, -- The date the customer last made a transaction
  DATEDIFF(CURDATE(), lta.last_transaction_date) AS inactivity_days -- How long (in days) the account has been inactive
FROM (
  SELECT DISTINCT plan_id, owner_id
  FROM savings_savingsaccount
) sa
LEFT JOIN last_txn_per_account AS lta -- LEFT JOIN is used so that accounts with no transactions at all (i.e. new or dormant accounts) are still included (NULL values)
  ON sa.plan_id = lta.plan_id AND sa.owner_id = lta.owner_id
JOIN plans_plan p 
  ON sa.plan_id = p.id
-- Filter for accounts that have had no transactions in over a year
WHERE 
  lta.last_transaction_date IS NULL -- No transaction has ever occurred
  OR lta.last_transaction_date < CURDATE() - INTERVAL 365 DAY; -- Last transaction was more than 365 days ago
  