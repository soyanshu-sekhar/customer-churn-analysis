USE PROJECTS

select top 5 * 
from customer_churn_cleaned

select 
count (*) 
from customer_churn_cleaned

SELECT
Churn_Label,
COUNT(*) AS customers,
ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM customer_churn_cleaned),2) AS percentage
FROM customer_churn_cleaned
GROUP BY Churn_Label;

--What is the overall churn rate?

SELECT 
ROUND(AVG (CAST (CHURN_VALUE AS FLOAT))*100,2)
FROM customer_churn_cleaned

--Which contract type has the highest churn?
SELECT 
COUNT(*) AS TOTAL_CUSTOMERS,
CONTRACT,
ROUND(AVG(CAST(CHURN_VALUE AS FLOAT))*100,2) AS CHURN_RATE
FROM customer_churn_cleaned
GROUP BY CONTRACT

--Which internet service has the highest churn?

SELECT 
COUNT(*) AS customers,
INTERNET_SERVICE,
ROUND(AVG(CAST(CHURN_VALUE AS FLOAT))*100,2) AS CHURN_RATE
FROM CUSTOMER_CHURN_CLEANED
GROUP BY INTERNET_SERVICE

--Top churn reasons

SELECT TOP 10
COUNT(*) AS CHURN_COUNT,
CHURN_REASON
FROM CUSTOMER_CHURN_CLEANED
WHERE CHURN_LABEL='YES'
GROUP BY CHURN_REASON
ORDER BY CHURN_COUNT DESC

--Rank contract types by churn
WITH CTE AS (
SELECT 
CONTRACT,
ROUND(AVG(CAST(CHURN_VALUE AS FLOAT))*100,2) AS CHURN_RATE
FROM CUSTOMER_CHURN_CLEANED 
GROUP BY CONTRACT
)
SELECT
CONTRACT,
CHURN_RATE,
DENSE_RANK()OVER(ORDER BY CHURN_RATE DESC) AS RNK 
FROM CTE

--Which Customer Segment Is Most At Risk?

with customer_segment as(
select
churn_value,
case
   when tenure_months <= 12 then '0-12 Months'
    when tenure_months <= 24 then '13-24 Months'
    when tenure_months <= 36 then '25-36 Months'
	when tenure_months <= 48 then '37-48 Months'
	when tenure_months <= 60 then '49-60 Months'
	else '61-72 Months'
end as tenure_group
from CUSTOMER_CHURN_CLEANED
)
select
count(*) as cutomers,
tenure_group,
round(avg(cast(churn_value as float))*100,2) as churn_rate
FROM customer_segment
group by tenure_group
order by churn_rate desc

--Top Churn Reasons Ranked

with churn_reason as (
select 
count(*) as cust_base,
churn_reason
from customer_churn_cleaned
where churn_label='yes'
group by churn_label,churn_reason
)
select 
cust_base,
churn_reason,
dense_rank()over(order by cust_base) as rnk
from churn_reason

--Highest Churn Combination

select 
count(*) as subs,
internet_service,
contract,
round(avg(cast(churn_value as float))*100,2) as churn_rate
from customer_churn_cleaned
group by internet_service,contract
order by churn_rate desc

--High Value Customers Leaving

select 
churn_label,
avg(cltv) as avg_cltv
from customer_churn_cleaned
group by churn_label

--Top 3 Cities With Highest Churn

with city_cte as (
select 
count(*) as customer,
city,
sum(churn_value) as customer_left,
round(avg(cast(churn_value as float))*100,2) as churn_rate
from customer_churn_cleaned
group by city
having count(*) >=20
)
select top 3 city,customer,customer_left,churn_rate
from city_cte
order by churn_rate desc

--Find top payment methods associated with churn.

with payment_cte as (
select 
count(*) as churned_customers,
payment_method
from customer_churn_cleaned
where churn_label='yes'
group by payment_method
)
select 
payment_method,
churned_customers,
row_number()over(order by churned_customers desc) as rnk
from payment_cte

select * from customer_churn_cleaned
--top 5 highest-risk customer segments

with risk_cte as (
select count(*) as customers,
contract,
internet_service,
round(avg(cast(churn_value as float))*100,2) as churn_rate
from customer_churn_cleaned
group by contract,internet_service
)
select top 5 contract,
internet_service,
customers,
churn_rate
from risk_cte
order by churn_rate desc;

-----------------------------------------------FINAL BUSINESS RECOMMENDATIONS-------------------------------------------------------

--Target Month-to-month Fiber Optic customers first
--Offer annual-contract discounts, retention bundles, speed upgrades, or service-quality outreach.
--Improve the first-year customer experience
--Earlier analysis showed first-year churn at 47.4%. Create onboarding, support check-ins, and early retention offers.
--Investigate Fiber service value and competitor gaps
--Churn reasons mentioned better speeds, more data, and network reliability. Review pricing, reliability, and competitor packages.
--Encourage automatic payments
--Offer incentives to switch to automatic payment.
--Review city-level issues carefully
--Check whether Santa Rosa, North Hollywood, and Modesto have service outages, coverage issues, or competitor pressure.