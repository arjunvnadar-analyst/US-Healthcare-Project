-- Project - Retail_Analysis

use retail_analysis;

-- ?? Problem statement ??
-- Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the 
-- unique values and remove the the original table from the databases and replace the name of the new table with the original name.

select transactionid, count(*)
from sales_transaction
group by transactionid
having count(*) > 1;

create table new as
select distinct *
from sales_transaction;

drop table sales_transaction;

alter table new
rename to sales_transaction;

select *
from sales_transaction;

-- ?? Problem statement ??
-- Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
-- Also, update those discrepancies to match the price in both the tables.

select a.transactionid, a.price as transactionprice, b.price as  inventorypprice
from sales_transaction a
join product_inventory b 
on a.productid = b.productid 
where a.price <> b.price;

update sales_transaction a
join product_inventory b
on a.productid = b.productid
set a.price = b.price
where a.price <> b.price;

select *
from sales_transaction;

-- ?? Problem statement ??
-- Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.

select count(*)
from customer_profiles
where location is null;

update customer_profiles
set location = "Unknown"
where location is null;

select *
from customer_profiles;

-- ?? Problem statement ??
-- Write a SQL query to summarize the total sales and quantities sold per product by the company.

select  productid, sum( quantitypurchased ) as totalunitssold, sum(price) as totalsales
from sales_transaction
group by productid
order by totalsales desc;

-- ?? Problem statement ??
-- Write a SQL query to count the number of transactions per customer to understand purchase frequency.

select customerid, count(*) as numberoftransactions
from sales_transaction
group by customerid
order by numberoftransactions desc;

-- ?? Problem statement ??
-- Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the 
-- product categories which needs to be promoted in the marketing campaigns.

select  a.category, sum(b.quantitypurchased) as totalunitssold, sum(b.quantitypurchased*b.price) as totalsales
from product_inventory a
join sales_transaction b
on a.productid = b.productid
group by category
order by totalsales desc;

-- ?? Problem statement ??
-- Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will
-- help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

select productid, sum(quantitypurchased*price) as totalrevenue
from sales_transaction
group by productid
order by totalrevenue desc
limit 10;

-- ?? Problem statement ??
-- Write a SQL query to find the ten products with the least amount of units sold from the sales transactions,
--  provided that at least one unit was sold for those products.

select productid, sum(quantitypurchased) as totalunitssold
from sales_transaction
group by productid
order by totalunitssold asc
limit 10;

-- ?? Problem statement ??
-- Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

select transactiondate as datetrans, count(transactiondate) as transaction_count, sum(quantitypurchased) as totalunitssold,
sum(quantitypurchased*price) as totalsales
from sales_transaction
group by datetrans
order by datetrans desc;

-- ?? Problem statement ??
-- Write a SQL query to understand the month on month growth rate of sales of the company which will help understand
--  the growth trend of the company.

with cte_1 as
(select month(transactiondate) as month, round(sum(quantitypurchased*price),2) as total_sales
from sales_transaction
group by month),

cte_2 as (select *, round(lag(total_sales,1) over(order by month asc),2) as previous_month_sales
from cte_1)

select * ,round( ((total_sales- previous_month_sales)/previous_month_sales)*100, 2) as mom_growth_percentage
from cte_2;

-- ?? Problem statement ??
-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on 
-- the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

select customerid, count(*) as numberoftransactions, sum(quantitypurchased*price) as totalspent
from sales_transaction
group by customerid
having numberoftransactions > 10 and totalspent > 1000
order by totalspent desc;

-- ?? Problem statement ??
-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer, which will
-- help us understand the customers who are occasional customers or have low purchase frequency in the company.

select customerid, count(*) as numberoftransactions, sum(quantitypurchased*price) as totalspent
from sales_transaction
group by customerid
having numberoftransactions <=2 
order by numberoftransactions,  totalspent desc;

-- ?? Problem statement ??
-- Write a SQL query that describes the total number of purchases made by each customer against each productID to understand
-- the repeat customers in the company.

select customerid, productid, count(*) as timespurchased
from sales_transaction
group by customerid, productid
having timespurchased > 1
order by timespurchased desc;

-- ?? Problem statement ??
-- Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular
 -- company to understand the loyalty of the customer.
 
 with cte_1 as (select customerid, min(transactiondate) as firstpurchase, max(transactiondate) as lastpurchase,
datediff(max(transactiondate),min(transactiondate)) as daysbetweenpurchases
from sales_transaction
group by customerid
having daysbetweenpurchases > 0)

select *
from cte_1
order by daysbetweenpurchases desc;

-- ?? Problem statement ??
-- Write an SQL query that segments customers based on the total quantity of products they have purchased. Also,
-- count the number of customers in each segment which will help us target a particular segment for marketing.

CREATE TABLE customer_segment AS
SELECT
    A.CustomerID,
    A.TotalQuantityPurchased,
    CASE
        WHEN A.TotalQuantityPurchased > 30 THEN 'High'
        WHEN A.TotalQuantityPurchased BETWEEN 11 AND 30 THEN 'Med' -- Corrected segment name
        WHEN A.TotalQuantityPurchased BETWEEN 1 AND 10 THEN 'Low'
        ELSE 'No Orders'
    END AS CustomerSegment
FROM
    -- Subquery (A) calculates the total quantity purchased per customer
    (
        SELECT
            CustomerID,
            SUM(QuantityPurchased) AS TotalQuantityPurchased
        FROM
            sales_transaction
        GROUP BY
            CustomerID
    ) A;

-- Note: To include customers with 0 orders who are NOT in sales_transaction,
-- a LEFT JOIN with Customer_Profiles would be needed in subquery (A).

SELECT
    CustomerSegment,
    COUNT(CustomerID) AS "COUNT(*)"
FROM
    customer_segment
WHERE
    CustomerSegment IN ('Low', 'Med', 'High') -- Filters to include only requested segments
GROUP BY
    CustomerSegment
ORDER BY
    CustomerSegment DESC; -- Returning in any order is fine, but sorting ensures consistency.




                                                                   



