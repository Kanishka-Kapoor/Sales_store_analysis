--SQL PROJECT--
create database SQL_project;
use SQL_project;

--imported data using wizard--
select * from sales_table;

--create a copy of our table and give it a name
select * into sales_table2 from sales_table;
select * from sales_table2;

--DATA CLEANING- step 1- checking for duplicates

select transaction_id, count(*)
from sales_table2
group by transaction_id
having count(transaction_id) > 1;

--TXN240646
--TXN342128
--TXN855235
--TXN981773
--cte- common table expression- temporary table
with cte as (
select *,
 ROW_NUMBER() over (partition by transaction_id order by transaction_id) as row_num
 from sales_table2
 )
 delete from cte
 where row_num = 2

 select * from cte
 where transaction_id in ('TXN240646','TXN342128','TXN855235',
'TXN981773')

--step 2- correction of headers(wrong spellings)
EXEC sp_rename'sales_table2.quantiy', 'quantity','COLUMN' 
EXEC sp_rename'sales_table2.prce', 'price', 'column'

--step 3- check datatype
select column_name,DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
 where table_name = 'sales_table2';

 ALTER TABLE sales_table2
ALTER COLUMN quantity INT;

ALTER TABLE sales_table2
ALTER COLUMN price float;

alter table sales_table2
alter column customer_age int;

alter table sales_table2
alter column product_id varchar(50);

ALTER TABLE sales_table2
ALTER COLUMN transaction_id VARCHAR(50);

select * from sales_table2;

-- step 4-- checking null values
--checking null count

SELECT 
    COUNT(*) - COUNT(transaction_id) AS transaction_id_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(customer_name) AS customer_name_nulls,
    COUNT(*) - COUNT(customer_age) AS customer_age_nulls,
    COUNT(*) - COUNT(gender) AS gender_nulls,
    COUNT(*) - COUNT(product_id) AS product_id_nulls,
    COUNT(*) - COUNT(product_name) AS product_name_nulls,
    COUNT(*) - COUNT(product_category) AS product_category_nulls,
    COUNT(*) - COUNT(quantity) AS quantity_nulls,
    COUNT(*) - COUNT(price) AS price_nulls,
    COUNT(*) - COUNT(payment_mode) AS payment_mode_nulls,
    COUNT(*) - COUNT(purchase_date) AS purchase_date_nulls,
    COUNT(*) - COUNT(time_of_purchase) AS time_of_purchase_nulls,
    COUNT(*) - COUNT(status) AS status_nulls
FROM sales_table2;

--treating null values
select * from sales_table2
where transaction_id is null
or 
customer_id is null
or 
customer_name is null 
or 
customer_age is null
or 
gender is null
or 
product_id is null
or 
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or 
status is null

delete from sales_table2
where transaction_id is null;

select * from sales_table2
where customer_name = 'Ehsaan Ram';

update sales_table2
set customer_id = 'CUST9494'
where transaction_id ='TXN977900'

select * from sales_table2
where customer_name = 'Damini Raju';

update sales_table2
set customer_id = 'CUST1401'
where transaction_id = 'TXN985663';

select * from sales_table2
where customer_id = 'CUST1003';

update sales_table2
set customer_name = 'Mahika Saini', customer_age = 35,
gender = 'Male'
where transaction_id = 'TXN432798';

--step 5-- cleaning inconsistency in data
select * from sales_table2;

select distinct gender
from sales_table2;

update sales_table2
set gender = 'M'
where gender = 'Male'

update sales_table2
set gender = 'F'
where gender = 'Female'

select distinct payment_mode
from sales_table2;

update sales_table2
set payment_mode = 'Credit Card'
where payment_mode = 'CC'

--QUESTION 1--
--DATA ABALYSIS--
--What are the top 5 sold products by quantity? ans- veggies, sofa, dining table, fruits and wardrobe
select top 5 product_name, sum(quantity) as total_quantity_sold
from sales_table2
where status = 'delivered'
group by product_name
order by total_quantity_sold desc;
--business problem- we don't know which products are the most in demand.
--business impact- helps priortitise stock and boost sales through targeted promotions.

--QUESTION 2--
--Which products are most frequently cancelled? ans-
select  top 5 product_name, count(*) as cancelled_products
from sales_table2
where status = 'cancelled'
group by product_name
order by cancelled_products desc;

-- business problem- frequent cancellations affect revenue and customer trust.
--business impact- identify poor performing products to improve quality or remove from catalogue.


--QUESTION 3--
--What time of the day has the highest no of purchases?
select * from sales_table2;

select
case
when datepart(hour, time_of_purchase) between 0 and 5 then 'night'
when datepart(hour, time_of_purchase) between 6 and 11 then 'morning'
when datepart(hour, time_of_purchase) between 12 and 17 then 'afternoon'
when datepart(hour, time_of_purchase) between 18 and 23 then 'evening'
end as time_of_day,
count(*) as total_orders
from sales_table2
group by
case
when datepart(hour, time_of_purchase) between 0 and 5 then 'night'
when datepart(hour, time_of_purchase) between 6 and 11 then 'morning'
when datepart(hour, time_of_purchase) between 12 and 17 then 'afternoon'
when datepart(hour, time_of_purchase) between 18 and 23 then 'evening'
end
order by total_orders desc
--business problem- find peak sales times
--business impact- optimize staffing, promotions, and server loads.

--QUES 4
--Who are the top 5 hughest spending customers?
select * from sales_table2;

select top 5 customer_name, 
FORMAT(sum(price*quantity), 'C0', 'en-IN') as total_amount_spent 
from sales_table2
group by customer_name
order by sum(price*quantity) DESC

--n is number format, C is currency and  0 is no decimal places
--buss prob solved- identifying VIP customers
-- impact- personalised offers, loyalty rewards and retention.

--QUES 5
--Which product categories generate the highest revenue?
select  product_category, 
format(sum(price*quantity), 'C0', 'EN-IN') as revenue
from sales_table2
group by product_category
order by sum(price*quantity) desc
--prob solved- identify top performing product category
--impact- allowing the business to invest more in high margin or high demand categories.

--QUES 6
--What is the return/cancellation percentage per product category?
select * from sales_table2;
--cancellation

select product_category, 
FORMAT(count(case when status = 'cancelled' then 1 end) *100.0/count(*), 'N3') + '%' as cancelled_percent
from sales_table2
group by product_category
order by cancelled_percent DESC

--RETURNED
select product_category, 
FORMAT(count(case when status = 'returned' then 1 end) *100.0/count(*), 'N3') + '%' as returned_percent
from sales_table2
group by product_category
order by returned_percent DESC

--buss prob- monitor dissatisfaction trends per category
--buss impact- reduce returns, improve product description/expectations.

--QUES 7
--What is the most preferred payment mode?
select * from sales_table2

select payment_mode, count(payment_mode) as count_of_mode
from sales_table2
group by payment_mode
order by count_of_mode desc

--problem solved- payment option most preferred by a customer
--buss impact- streamline payment processing, prioritise popular modes.

--QUES 8
--How does age group affect purchasing behaviour?
select * from sales_table2
select min(customer_age), max( customer_age) from sales_table2;

select
 case
     when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
     when customer_age between 36 and 50 then '36-50'
     else '51+'
end as customer_age,
format(sum(price*quantity), 'C0', 'EN-IN') as total_purchase
from sales_table2
group by case
     when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
     when customer_age between 36 and 50 then '36-50'
     else '51+'
     end
order by total_purchase desc

--BUSS PROB SOLVED- understanding customer demographics
--buss impact- targeting marketing segments by age

--  QUES 9
--What is the monthly sales trend?
select * from sales_table2

select
YEAR(purchase_date) as Years,
MONTH(purchase_date) as Months,
format(sum(price*quantity), 'C0', 'EN-IN') as total_sales,
sum(quantity) as total_quantity
from sales_table2
group by year(purchase_date), Month(purchase_date)
order by Months

--PROBLEM SOLVED- Sales fluctuations go unnoticed
-- impact- plan inventory and marketing according to seasonal trends.


-- QUES 10
--Are certain genders targeting more specific product categories?

select *
from (
select gender, product_category
from sales_table2
) as source_table
pivot(
count(gender)
for gender in ([M], [F])
) as pivot_table
order by  product_category
--problem solved- gender based product references
--impact- personalised ads, gender- focused campaigns.