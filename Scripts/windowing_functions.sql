SELECT salesId, sales.inventoryId, sales.employeeId, employee.firstName, employee.lastName, inventory.modelId, model.model
FROM sales
INNER JOIN employee
ON sales.employeeId = employee.employeeId
INNER JOIN inventory
ON sales.inventoryId = inventory.inventoryId
JOIN model
ON inventory.modelId = model.modelId
ORDER BY sales.employeeId;

SELECT
    sales.salesId,
    sales.inventoryId,
    sales.employeeId,
    employee.firstName,
    employee.lastName,
    inventory.modelId,
    model.model,
    COUNT(*) OVER (PARTITION BY sales.employeeId, inventory.modelId) AS numSold
FROM sales
INNER JOIN employee ON sales.employeeId = employee.employeeId
INNER JOIN inventory ON sales.inventoryId = inventory.inventoryId
INNER JOIN model ON inventory.modelId = model.modelId
ORDER BY sales.employeeId, numSold DESC;


-- Create a report showing sales per month and an annual total

--get the needed data
SELECT strftime('%Y', soldDate) AS soldYear,
strftime('%m', soldDate) AS soldMonth,
salesAmount
from sales;

-- apply the grouping
SELECT strftime('%Y',soldDate) as soldYear,
strftime('%m',soldDate) as soldMonth,
SUM(salesAmount) as salesAmount
from sales
GROUP BY soldYear, soldMonth
ORDER BY soldYear, soldMonth;

-- add the window fucntion - simplify with cte

with cte_sales as (
SELECT strftime('%Y', soldDate) AS soldYear, 
  strftime('%m', soldDate) AS soldMonth,
  SUM(salesAmount) AS salesAmount
FROM sales
GROUP BY soldYear, soldMonth
)
SELECT soldYear, soldMonth, salesAmount,
  SUM(salesAmount) OVER (
    PARTITION BY soldYear 
    ORDER BY soldYear, soldMonth) AS AnnualSales_RunningTotal
FROM cte_sales
ORDER BY soldYear, soldMonth;

SELECT strftime('%Y-%m', soldDate) as MonthSold,
COUNT(*) as NumberCarsSold,
LAG(COUNT(*),1,0) OVER calMonth as LastMonthCarsSold
FROM sales
GROUP BY strftime('%Y-%m', soldDate)
WINDOW calMonth AS (ORDER BY strftime('%Y-%m', soldDate))
ORDER BY strftime('%Y-%m',soldDate);