
select * from customer;
select * from bike;
select * from rental;
select * from membership_type;
select * from membership;

--Question 1:
/*
Emily would like to know how many bikes the shop owns by category. Can you get this for her? Display the category name and the number of
bikes the shop owns in each category (call this column number_of_bikes ). Show only the categorieswhere the number of bikes is greater 
than 2.
*/
--Solution:
select category, count(1) as number_of_bikes 
from bike
group by category
having count(1) >= 2;

--Question 2:
/*
Emily needs a list of customer names with the total number of memberships purchased by each. For each customer, display the customer's 
name and the count of memberships purchased (call this column membership_count ). Sort the results by membership_count , starting with 
the customer who has purchased the highest number of memberships. Keep in mind that some customers may not have purchased any 
memberships yet. In such a situation, display 0 for the membership_count .
*/
--Solution:
select c.name as customer_name, count(m.id) as membership_count
from customer c
left join membership m on c.id = m.customer_id
group by c.name
order by membership_count desc;

--Question 3:
/*
Emily is working on a special offer for the winter months. Can you help her prepare a list of new rental prices? For each bike, 
display its ID, category, old price per hour (call this column old_price_per_hour), discounted price per hour 
(call it new_price_per_hour), old price per day (call it old_price_per_day), and discounted price per day (call it new_price_per_day).
		1. Electric bikes should have a 10% discount for hourly rentals and a 20% discount for daily rentals. 
		2. Mountain bikes should have a 20% discount forhourly rentals and a 50% discount for daily rentals. 
		3. All other bikes should have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits.
*/
--Solution:
select id, category
, price_per_hour as old_price_per_hour
, case when category = 'electric' then round(price_per_hour - (0.1*price_per_hour),2) 
	   when category = 'mountain bike' then round(price_per_hour - (0.2*price_per_hour),2)
	   else round(price_per_hour - (0.5*price_per_hour),2)
end as new_price_per_hour
, price_per_day as old_price_per_day
, case when category = 'electric' then round(price_per_day - (0.2 * price_per_day),2) 
	   when category = 'mountain bike' then round(price_per_day - (0.5 * price_per_day),2)
	   else round(price_per_day - (0.5 * price_per_day),2)
end as new_price_per_day
from bike;

--Question 4:
/*
Emily is looking for counts of the rented bikes and of the available bikes in each category. Display the number of available bikes 
(call this column available_bikes_count ) and the number of rented bikes (call this column rented_bikes_count ) by bike category.
*/
--Solution:
select category 
, count(case when status = 'available' then 1 end) as available_bikes_count
, count(case when status = 'rented' then 1 end) as rented_bikes_count
from bike
group by category;

--Question 5:
/*
Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across
all the years. Display the total revenue from rentals for each month, the total for eachyear, and the total across all the years. 
Do not take memberships into account. There should be 3 columns: 1]year 2]month 3]revenue. Sort the results chronologically. 
Display the year total after all the month totals for the corresponding year. Show the all-time total as the last row.
The resulting table looks something like this:
year 	month 	revenue
2022 	11 		200.00
2022 	12 		150.00
2022 	null 	350.00
2023 	1 		110.00
...
2023 	10 		335.00
2023 	null 	1370.00
null 	null 	1720.00
*/
--Solution:
select 
 extract(year from start_timestamp) as year
, extract(month from start_timestamp) as month
, sum(total_paid) as total_revenue
from rental
group by  extract(year from start_timestamp) , extract(month from start_timestamp)
union all
select 
 extract(year from start_timestamp) as year
, null as month
, sum(total_paid) as total_revenue
from rental
group by  extract(year from start_timestamp)
union all
select 
 null as year
, null as month
, sum(total_paid) as total_revenue
from rental
order by year, month; -- this query is not much easy to read, also little bit slower and sql has read table 3 different times.

select extract(year from start_timestamp) as year
, extract(month from start_timestamp) as month
, sum(total_paid) as total_revenue
from rental
group by grouping sets ((year, month),(year), ())
order by year, month;
--Question 6:
/*
Emily has asked you to get the total revenue from memberships for each combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this column membership_type_name ), and the total revenue 
(call this columntotal_revenue ) for every combination of year, month, and membership type.Sort the results by year, month, and 
name of membership type.
*/
--Solution:
select extract(year from end_date) as year
, extract(month from end_date) as month
, mt.name as membership_type_name
, sum(total_paid) as total_revenue
from membership m
join membership_type mt on m.membership_type_id = mt.id
group by year, month, mt.name
order by year, month, mt.name;

--Question 7:
/*
Next, Emily would like data about memberships purchased in 2023, with subtotals and grand totals for all the different combinations of 
membership types and months.
Display the total revenue from memberships purchased in 2023 for each combination of month and membership type. Generate subtotals and
grand totals for all possible combinations. There should be 3 columns: 1]membership_type_name 2]month 3]total_revenue.
Sort the results by membership type name alphabetically and then chronologically by month.
*/
--Solution:
select name
, extract(month from end_date) as mnth
, sum(total_paid) as total_revenue
from membership m
join membership_type mt on m.membership_type_id = mt.id
where extract(year from end_date) = 2023
group by grouping sets ((name,mnth), (name), ())
order by name, mnth;

select name
, extract(month from end_date) as mnth
, sum(total_paid) as total_revenue
from membership m
join membership_type mt on m.membership_type_id = mt.id
where extract(year from end_date) = 2023
group by cube (name,mnth)
order by name, mnth;
--Question: 8
/*
Now it's time for the final task. Emily wants to segment customers based on the number of rentals and see the count of customers 
in each segment. Use your SQL skills to get this! Categorize customers based on their rental history as follows:
	1. Customers who have had more than 10 rentals are categorized as 'more
		than 10'.
	2. Customers who have had 5 to 10 rentals (inclusive) are categorized as
		'between 5 and 10'.
	3. Customers who have had fewer than 5 rentals should be categorized as
		'fewer than 5'.
Calculate the number of customers in each category. Display two columns: rental_count_category (the rental count category) and 
customer_count (the number of customers in each category).
*/
--Solution:
with cte as
	(select customer_id, count(id) as rental_count
	, case when count(id) > 10 then 'more than 10'
		  when count(id) >= 5 and count(id) <= 10 then 'between 5 and 10'
		  when count(id) < 5 then 'fewer than 5'
		end as category
	from rental
	group by customer_id)
select category as rental_count_category
, count(1) as customer_count
from cte
group by category
order by customer_count;

drop table if exists customer;
drop table if exists bike;
drop table if exists rental;
drop table if exists membership_type;
drop table if exists membership;