create database case_zomato;
use case_zomato;

select * from zomato limit 50;
select * from countrytable;

-- 1) Help Zomato in identifying the cities with poor Restaurant ratings

select city,avg(rating) from zomato
group by city
order by avg(rating) asc;                 

-- dynamic rank calculation 

with cte1 as (
with cte as (
select city,rating,
rank() over (partition by city order by rating desc) as rnk
from zomato
)
select city, avg(rnk) as avg_rnk from cte
group by city
)
select city,avg_rnk from cte1
where avg_rnk < (select avg(avg_rnk) from cte1);



-- another process

with cte as(
select City, round(avg(Rating)) as avg_rating
from zomato
group by City)
select city, avg_rating
from cte
where avg_rating < (select round(avg(Rating)) as avg_rating from zomato);





-- 2) Mr.roy is looking for a restaurant in kolkata which provides online delivery.
-- Help him choose the best restaurant

select Res_identify,City,Has_Online_delivery,Rating
from zomato
where city = "kolkata" and Has_Online_delivery = "yes"
order by rating desc limit 1;



with cte as(
select RestaurantID, City, Rating, Votes,
rank() over(Order by Rating desc, Votes desc) as rnk
from zomato
where City = "Kolkata" and Has_Online_delivery = "Yes")
select *
from cte
where rnk = 1;





-- 3) Help Peter in finding the best rated Restraunt for Pizza in New Delhi.

select Res_identify,City,Cuisines,Rating
from zomato
where city = "new delhi" and cuisines = "pizza"
order by rating desc limit 1;


with c as 
(select RestaurantID, City, Cuisines, Rating, votes,
rank() over(partition by City order by rating desc, votes desc) as Rnk
from zomato
where City = "New Delhi" and Cuisines like "%Pizza%")
select * from c
where Rnk = 1;





-- 4)Enlist most affordable and highly rated restaurants city wise.

select city,avg(Average_Cost_for_two) as affordable,avg(rating) as rate
from zomato
group by city
order by 2 asc, 3 desc;                                      


-- for dynamic calculation
with cte as (
select city, RestaurantID, average_cost_for_two, rating,
rank() over (partition by city order by average_cost_for_two asc, rating desc, votes desc) as rnk
from zomato
where average_cost_for_two > 0
)
select * from cte where rnk = 1;





-- 5)Help Zomato in identifying the restaurants with poor offline services

select Res_identify,Has_Online_delivery,rating
from zomato
where Has_Online_delivery = "no"   
order by rating asc;                                     

         
-- for dynamic calculation
with cte as (
select Res_identify,rating,
rank() over (order by rating desc) as rnk
from zomato
where Has_Online_delivery = "no"
)
select * from cte
where rnk < (select avg(rnk) from cte);                 
               





-- 6)Help zomato in identifying those cities which have atleast 3 restaurants with ratings >= 4.9
  -- In case there are two cities with the same result, sort them in alphabetical order.

select city,count(RestaurantID) as cnt
from zomato
where rating >= 4.9
group by city
having cnt >= 3
order by 1 asc;                  



-- 7) What are the top 5 countries with most restaurants linked with Zomato?

select country,count(country) as linked_with_zom
from zomato z inner join countrytable ct using(countrycode)
group by country
order by 2 desc limit 5;                                              


-- for dynamic calculation
with cte as (
select country, count(country),
rank() over (order by count(country) desc) rnk
from zomato z inner join countrytable ct using(countrycode)
group by country
)
select * from cte
where rnk <= 5;


-- 8) What is the average cost for two across all Zomato listed restaurants? 

select avg(Average_Cost_for_two) as avg_cost_two
from zomato;    




-- 9) Group the restaurants basis the average cost for two into: 
-- Luxurious Expensive, Very Expensive, Expensive, High, Medium High, Average. 
-- Then, find the number of restaurants in each category.

select max(Average_Cost_for_two), min(Average_Cost_for_two)
from zomato;
  
  
select RestaurantID, city, Res_identify,Average_Cost_for_two,
dense_rank() over (order by average_cost_for_two desc) as Bucket
from zomato
where average_cost_for_two > 0;  
  
  
  
select RestaurantID, city, Average_Cost_for_two,
case
	when Bucket < 10 then "Luxurious Expensive"
    when Bucket < 25 then "Very Expensive"
    when Bucket < 50 then "Expensive"
    when Bucket < 90 then "High"
    when Bucket < 120 then "Medium High"
    else "Average"
end as category
from(  
select RestaurantID, city, Res_identify,Average_Cost_for_two,
dense_rank() over (order by average_cost_for_two desc) as Bucket
from zomato
where average_cost_for_two > 0) as temp_table;  
     

-- another way

with cte1 as (
with cte as (
select RestaurantID, Res_identify, city, Average_Cost_for_two,
dense_rank() over (order by Average_Cost_for_two desc) as drnk
from zomato
where Average_Cost_for_two > 0
)
select restaurantid, city, average_cost_for_two,
case    when drnk < 10 then "Luxurious Expensive"
		when drnk < 25 then "Very Expensive"
		when drnk < 50 then "Expensive"
		when drnk < 90 then "High"
		when drnk < 120 then "Medium High"
		else "Average"
end as category 
from cte
)
select category, count(*) from cte1 group by category;

-- 10) List the top 5 restaurants with highest rating with maximum votes.

with cte as (
select RestaurantID,Res_identify,rating,Votes,
rank() over (order by rating desc , votes desc ) as rnk
from zomato
)
select res_identify,rating,votes,rnk
from cte
where rnk <= 5;          

