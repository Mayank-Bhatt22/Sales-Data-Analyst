CREATE DATABASE Sales;

USE Sales;

DROP TABLE sales_data;

CREATE TABLE IF NOT EXISTS Sales_Data(
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,                         
    Sale_Date DATE,                                     
    Sales_Rep VARCHAR(50),                              
    Region VARCHAR(20),                                 
    Sales_Amount DECIMAL(10,2),
    Quantity_Sold INT,                
    Product_Category VARCHAR(50),             
    Unit_Cost DECIMAL(10,2),                     
    Unit_Price DECIMAL(10,2),                    
    Customer_Type VARCHAR(20),                         
    Discount DECIMAL(5,2),                             
    Payment_Method VARCHAR(50),                         
    Sales_Channel VARCHAR(20),                   
    Region_and_Sales_Rep VARCHAR(100)                
);

SELECT @@secure_file_priv;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_data.csv'
INTO TABLE Sales_Data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@csv_product_id, @csv_sale_date, @csv_sales_rep, @csv_region, @csv_sales_amount,
 @csv_quantity_sold, @csv_category, @csv_unit_cost, @csv_unit_price,
 @csv_customer_type, @csv_discount, @csv_payment_method, @csv_channel, @csv_region_rep)
SET
    Product_ID = NULL,  -- Auto increment
    Sale_Date = STR_TO_DATE(@csv_sale_date, '%c/%e/%Y'),  -- 👈 Converts 2/3/2023 correctly
    Sales_Rep = @csv_sales_rep,
    Region = @csv_region,
    Sales_Amount = @csv_sales_amount,
    Quantity_Sold = @csv_quantity_sold,
    Product_Category = @csv_category,
    Unit_Cost = @csv_unit_cost,
    Unit_Price = @csv_unit_price,
    Customer_Type = @csv_customer_type,
    Discount = @csv_discount,
    Payment_Method = @csv_payment_method,
    Sales_Channel = @csv_channel,
    Region_and_Sales_Rep = @csv_region_rep;

SET SQL_SAFE_UPDATES = 0;

SELECT Product_ID, Sale_Date FROM Sales_Data LIMIT 10;

# 1. Retrieve all records from the sales dataset.
SELECT * FROM sales_data;

# 2. Display all unique product categories available in the dataset.
SELECT DISTINCT Product_Category FROM sales_data;

# 3. Find all sales made by a specific Sales Representative (e.g., Alice).
SELECT * FROM sales_data WHERE Sales_Rep = 'Alice';

# 4. Get all transactions from the “North” region where the Sales_Amount is above 5000.
SELECT * FROM sales_data WHERE region = "North" AND Sales_Amount > 5000;

# 5. List all customers who paid via “Credit Card” and are ‘Returning’ customers.
SELECT * FROM sales_data WHERE Payment_Method = "Credit Card" AND customer_type = "Returning";

# 6. Retrieve sales records between ‘2023-01-01’ and ‘2023-06-30’.
SELECT * FROM sales_data WHERE sale_date BETWEEN '2023-01-01' AND '2023-06-30';

# 7. Calculate the total Sales_Amount for each Region.
SELECT Region, SUM(Sales_Amount) AS TotalSales FROM sales_data GROUP BY Region;

# 8. Find the average Unit_Price and Unit_Cost by Product_Category.
SELECT Product_Category, AVG(Unit_Price) AS Average_unit_price, AVG(Unit_Cost) AS Average_unit_cost FROM sales_data 
GROUP BY Product_Category;

# 9. Determine the total number of units sold (Quantity_Sold) by each Sales_Rep.
SELECT Sales_Rep, SUM(Quantity_Sold) AS Total_Units_Sold FROM Sales_Data GROUP BY Sales_Rep ORDER BY Total_Units_Sold DESC;

# 10. Identify the highest and lowest Sales_Amount in the dataset.
SELECT MAX(Sales_Amount) AS Max_Sales_Amount, MIN(Sales_Amount) Min_Sales_Amount FROM sales_data;

# 11. Find the total discount given across all transactions.
SELECT SUM(Discount) AS Total_Discount FROM sales_data;

# 12. Calculate the average Sales_Amount per month.
# (Hint: Use MONTH(Sale_Date) or equivalent date function.)
SELECT MONTHNAME(Sale_Date) AS Month_Name, AVG(Sales_Amount) AS Average_Sales_Amount FROM Sales_Data
GROUP BY MONTHNAME(Sale_Date), MONTH(Sale_Date) ORDER BY MONTH(Sale_Date);

# 13. Show the total sales and total quantity sold per Product_Category and Region.
SELECT Product_Category, Region, SUM(Sales_Amount) AS Total_Sales, SUM(Quantity_Sold) AS Total_Quantity_Sold FROM Sales_Data
GROUP BY Product_Category, Region ORDER BY Product_Category, Region;

# 14. Calculate profit for each transaction as
# Profit = (Unit_Price - Unit_Cost) * Quantity_Sold and display the top 10 most profitable transactions.
SELECT Product_ID, Sales_Rep, Region, Product_Category, (Unit_Price - Unit_Cost) * Quantity_Sold AS Profit FROM Sales_Data
ORDER BY Profit DESC LIMIT 10;

# 15. Find the best-performing Sales Representative based on total Sales_Amount.
SELECT Sales_Rep, sum(Sales_Amount) AS Total_sales_amount from Sales_Data GROUP BY Sales_Rep ORDER BY Total_sales_amount DESC LIMIT 1; 

# 16. Find the region with the highest total profit.
SELECT Region, SUM((Unit_Price - Unit_Cost) * Quantity_Sold) AS Total_Profit FROM Sales_Data GROUP BY Region 
ORDER BY Total_Profit DESC LIMIT 1;

# 17. Get the top 5 products (Product_ID) with the highest total sales amount.
SELECT Product_ID AS Products, MAX(Sales_Amount) AS Highest_Total_Sales_Amount FROM sales_data GROUP BY Products
ORDER BY Highest_Total_Sales_Amount DESC LIMIT 5;

# 18. Find the average discount offered per Product_Category.
SELECT Product_Category, AVG(Discount) FROM sales_data GROUP BY Product_Category;

# 19. Identify which Sales_Channel (Online vs Retail) generates more revenue.
SELECT Sales_Channel, SUM(Sales_Amount) AS Total_Revenue FROM sales_data GROUP BY Sales_Channel ORDER BY Total_Revenue DESC;

# 20. For each Sales_Rep, calculate their average Sales_Amount per transaction.
SELECT Sales_Rep, AVG(Sales_Amount) AS Average_Sales_Amount FROM sales_data GROUP BY Sales_Rep;

# 21. Rank Sales Representatives by total revenue using a window function.
# (Hint: RANK() OVER (ORDER BY SUM(Sales_Amount) DESC))
SELECT Sales_Rep, SUM(Sales_Amount) AS Total_Revenue, RANK() OVER (ORDER BY SUM(Sales_Amount) DESC) AS Revenue_Rank
FROM sales_data GROUP BY Sales_Rep ORDER BY Revenue_Rank;

# 22. Find the percentage contribution of each Region to total sales.
# (Hint: Use subquery or window sum for total.)
SELECT Region, SUM(Sales_Amount) AS Total_Sales, ROUND((SUM(Sales_Amount) * 100/ (SELECT SUM(Sales_Amount) FROM sales_data)),1) 
AS Percentage_Contribution FROM sales_data GROUP BY Region ORDER BY Percentage_Contribution DESC;

# 23. Display monthly sales trends (Month vs Total Sales).
SELECT MONTH(Sale_Date) AS Month_Number, MONTHNAME(Sale_Date) AS Month_Name, SUM(Sales_Amount) AS Total_Sales FROM sales_data
GROUP BY MONTH(Sale_Date), MONTHNAME(Sale_Date) ORDER BY MONTH(Sale_Date);

# 24. Identify any Region-Sales_Rep combinations where the total discount given exceeds 20% of total sales.
SELECT Region, Sales_ReP, SUM(Discount) AS Total_Discount, SUM(Sales_Amount) AS Total_Sales, 
(SUM(Discount) / SUM(Sales_Amount)) * 100 AS Discount_Percentage FROM sales_data 
GROUP BY Region, Sales_Rep HAVING (SUM(Discount) / SUM(Sales_Amount)) * 100 > 20 ORDER BY Discount_Percentage DESC;

# 25. Compare the average sales amount between New and Returning customers.
SELECT Customer_type, AVG(Sales_amount) AS Average_Sales_amount FROM sales_data GROUP BY Customer_type;

# 26. Determine the correlation between Discount and Sales_Amount (Hint: Explore COVAR_POP() or analyze trends).
SELECT ROUND(Discount, 1) AS Discount_Level, AVG(Sales_Amount) AS Avg_Sales FROM sales_data GROUP BY ROUND(Discount, 1) 
ORDER BY Discount_Level;

# 27. Find the most frequently sold Product_Category for each Region.
WITH CategoryFrequency AS (SELECT Region, Product_Category, COUNT(*) AS Total_Sales, RANK() OVER (PARTITION BY Region 
ORDER BY COUNT(*) DESC) AS Rank_in_Region FROM sales_data GROUP BY Region, Product_Category)
SELECT Region, Product_Category, Total_Sales FROM CategoryFrequency WHERE Rank_in_Region = 1;

# 28. Calculate profit margin (%) for each Product_Category: (Total Profit / Total Sales_Amount) * 100.
SELECT Product_Category, SUM((Unit_Price - Unit_Cost) * Quantity_Sold) AS Total_Profit, SUM(Sales_Amount) AS Total_Sales,
ROUND((SUM((Unit_Price - Unit_Cost) * Quantity_Sold) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin_Percent FROM Sales_Data
GROUP BY Product_Category ORDER BY Profit_Margin_Percent DESC;

# 29. Find the top-performing month for each Sales Representative.
WITH MonthlySales AS (SELECT Sales_Rep, MONTH(Sale_Date) AS Sale_Month, YEAR(Sale_Date) AS Sale_Year, SUM(Sales_Amount) AS Total_Sales,
RANK() OVER (PARTITION BY Sales_Rep ORDER BY SUM(Sales_Amount) DESC) AS Sales_Rank FROM sales_data GROUP BY Sales_Rep, YEAR(Sale_Date),
MONTH(Sale_Date)) SELECT Sales_Rep, Sale_Year, Sale_Month, Total_Sales FROM MonthlySales WHERE Sales_Rank = 1;

# 30. Create a summary table showing each Region, total sales, total profit, and average discount.
SELECT Region, SUM(Sales_Amount) AS Total_Sales, SUM((Unit_Price - Unit_Cost) * Quantity_Sold) AS Total_Profit,
ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent FROM Sales_Data GROUP BY Region ORDER BY Total_Sales DESC;

SELECT * FROM sales_data;