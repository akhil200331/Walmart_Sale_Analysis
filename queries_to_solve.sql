--check how many records are present?
select count(1) from sales_data;

--To get all data
select * from sales_data order by to_date(date,'dd/mm/yy') desc;


--Problems

--Q1. What are the different payment methods, and how many transactions and items were sold with  each method?

select payment_method,count(*) as transactions,sum(quantity) as items_sold 
from sales_data 
group by payment_method order by 2 desc,3 desc;


--Q2. Which category received the highest average rating in each branch?
with cte1 as(
select branch,category,avg(rating) as average_rating,
rank() over(partition by branch order by avg(rating) desc) as rnk 
from sales_data group by branch,category)
select branch,category,average_rating from cte1 where rnk=1;


--Q3. What is the busiest day of the week for each branch based on transaction volume?

with cte1 as(
select branch,
trim(to_char(to_date(date,'dd/mm/yy'),'Day')) as day_week,count(*) as transaction_volume,
rank() over(partition by branch order by count(*) desc) as rnk
from sales_data group by 1,2
)
select branch,day_week,transaction_volume from cte1 where rnk=1;


--Q4. How many items were sold through each payment method?

select payment_method,sum(quantity) as items_sold from sales_data group by 1;


--Q5. What are the average, minimum, and maximum ratings for each category in each city?

select city,category,avg(rating) as average_rating,
min(rating) as minimum_rating,
max(rating) as maximum_rating 
from sales_data group by 1,2 order by 1,2;


--Q6. What is the total profit for each category, ranked from highest to lowest?

select category,sum(total_amount) as total_revenue,
sum(total_amount*profit_margin) as total_profit 
from sales_data group by 1 order by 3 desc;


--Q7. What is the most frequently used payment method in each branch?

with cte1 as(
select branch,payment_method,count(*) as used_times,rank() over(partition by branch order by count(*) desc) as rnk from sales_data group by 1,2
)
select * from cte1 where rnk=1;


--Q8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

with cte1 as(
select branch,
case
when extract(HOUR from time::time)<12 then 'Morning'
when extract(HOUR from time::time) between 12 and 17 then 'Afternoon'
else 'Evening'
end as shift
from sales_data
)
select branch,shift,count(*) as transactions from cte1 group by 1,2 order by 1;


--Q9. Question: Which branch had the highest total sales revenue during weekends compared to weekdays?
with cte1 as(
select branch,
case
when trim(to_char(to_date(date,'dd/mm/yy'),'Day')) in ('Saturday','Sunday') then 'Weekend'
else 'Weekday' end as day_specific
,sum(total_amount) as total_sales_revenue from sales_data group by 1,2
)
select c1.branch,c1.total_sales_revenue AS weekend_sales,
COALESCE(c2.total_sales_revenue, 0) AS weekday_sales
from cte1 c1 left join cte1 c2 on c1.branch=c2.branch and c2.day_specific='Weekday' where c1.day_specific='Weekend' and c1.total_sales_revenue>coalesce(c2.total_sales_revenue,0);