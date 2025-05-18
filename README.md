# DataAnalytics-Assessment

This repository contains SQL queries written to support business analysis and decision-making based on customer behavior, transaction activity, and account data. The analysis is based on the following tables:

* `users_customuser` – customer demographic and contact information
* `savings_savingsaccount` – records of deposit transactions
* `plans_plan` – records of plans created by customers

---

## 1. ✨ High-Value Customers with Multiple Products

**Scenario:** The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).

**Task:** Write a query to find customers with at least one funded savings plan **AND** one funded investment plan, sorted by total deposits.

**Tables Used:**

* `users_customuser`
* `savings_savingsaccount`
* `plans_plan`

**Approach:**

* Joined the savings_savingsaccount and users_customuser table to the plans_plan table to determine whether each plan is a savings or investment product.
* Grouped data by `owner_id` to count the number of savings and investment plans per customer.
* Used `SUM(CASE WHEN ...)` logic to count each type of plan accurately.
* Filtered for customers having at least one of each product.
* Sorted the result by total deposit value to highlight high-value customers.

**Output:**

* `owner_id`, `name`, `savings_count`, `investment_count`, `total_deposits`

---

## 2. 📊 Transaction Frequency Analysis

**Scenario:** The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).

**Task:** Calculate the average number of transactions per customer per month and categorize them:

* **High Frequency**: ≥10 transactions/month
* **Medium Frequency**: 3–9 transactions/month
* **Low Frequency**: ≤2 transactions/month

**Tables Used:**

* `users_customuser`
* `savings_savingsaccount`

**Approach:**

* Grouped transactions by customer and transaction month.
* Calculated the average monthly transaction count per customer.
* Used a `CASE` expression to categorize customers into frequency bands.
* Aggregated to count customers in each category and compute average monthly activity.

**Output:**

* `frequency_category`, `customer_count`, `avg_transactions_per_month`

---

## 3. ⚡️ Account Inactivity Alert

**Scenario:** The ops team wants to flag accounts with no inflow transactions for over one year.

**Task:** Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).

**Tables Used:**

* `plans_plan`
* `savings_savingsaccount`

**Approach:**

* Used a CTE to compute the most recent transaction (`MAX(transaction_date)`) per account.
* Joined with `plans_plan` to identify plan type (Savings or Investment).
* Calculated inactivity days using `DATEDIFF(CURDATE(), last_transaction_date)`.
* Returned accounts with either no transactions or last transaction beyond 365 days.

**Output:**

* `plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

---

## 4. 💰 Customer Lifetime Value (CLV) Estimation

**Scenario:** Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).

**Task:** For each customer, assuming the `profit_per_transaction` is **0.1%** of the transaction value, calculate:

* Account tenure (months since signup)
* Total transactions
* Estimated CLV using:

  ```
  CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
  ```
* Order by estimated CLV from highest to lowest

**Tables Used:**

* `users_customuser`
* `savings_savingsaccount`

**Approach:**

* Calculated tenure in months using `TIMESTAMPDIFF` between signup date and current date.
* Counted transactions per user.
* Averaged transaction value to derive profit per transaction.
* Applied formula to compute CLV.
* Used `CASE` to avoid divide-by-zero errors for new users.
* Rounded CLV to 2 decimal places.

**Output:**

* `customer_id`, `name`, `tenure_months`, `total_transactions`, `estimated_clv`

---

## ⚠️ Challenges & Resolutions

### 1. No `last_transaction_date` column

**Problem:** The system didn't store the latest transaction date.

**Fix:** Determined the most recent transaction by grouping each account and using MAX(transaction_date).

### 2. Divide-by-zero edge case for CLV

**Problem:** Some users had zero months of tenure.

**Fix:** Handled with `CASE` to return `0` if tenure was `0`.

### 3. Identifying plan types

**Problem:** Plan type was not named directly.

**Fix:** Used boolean flags in `plans_plan` (`is_regular_savings`, `is_a_fund`) to infer type.

---

## 📁 Tables Overview

| Table                    | Purpose                                                     |
| ------------------------ | ----------------------------------------------------------- |
| `users_customuser`       | Customer info including name and sign-up date               |
| `savings_savingsaccount` | Transaction data, owner IDs, and amount info                |
| `plans_plan`             | Defines plan type (savings or investment)                   |
