-- Case Study Questions
## Which product has the highest price? Only return a single row.

select * from products 
order by price desc 
limit 1 ; 

## Which customer has made the most orders?
with customer_order  as ( select  c.customer_id , c.first_name , c.last_name , count(o.order_id) as order_count  from customers c 
join orders o 
using ( customer_id ) 
group by c.first_name
order by order_count desc limit 4 ) 
select customer_id , concat( first_name , " " , last_name ) as Full_Name , order_count 
from customer_order ;  

## What’s the total revenue per product?

 with revenue_product as  (select * ,(price*quantity) as revenue from products p 
join order_items oi  
using (product_id )) 
select product_id , product_name , sum(revenue) as total_revenue_earned 
from revenue_product 
group by product_name ; 

## Find the day with the highest revenue.
with highest_rev as ( select * ,(price*quantity) as revenue , dayname(order_date) as name_of_day from products p 
join order_items oi  
using (product_id ) 
join orders o 
using (order_id  )  ) 

select order_date, product_name , sum(revenue) as total_revenue , name_of_day 
from highest_rev 
group by order_date 
order by total_revenue desc 
limit 5 ; 

## Find the first order (by date) for each customer.
with first_order as 
(select * , rank() over( partition by customer_id  order by order_date ) as ranking  from orders
join customers c 
using (customer_id) ) 

select customer_id ,concat( first_name , " " , last_name ) as Full_Name , order_date 
from first_order 
where ranking = 1 ;

## Find the top 3 customers who have ordered the most distinct products.

with cte as ( select customer_id , count(distinct product_id ) as distinct_product 
from order_items oi 
join orders o 
using( order_id ) 
group by customer_id  ) 

select customer_id , concat( first_name , " " , last_name ) as Full_Name , distinct_product 
from cte 
join customers c using ( customer_id ) 
where distinct_product = (select max(distinct_product) from cte )  ; 


## Which product has been bought the least in terms of quantity?


with least_b as ( select * , sum(quantity) as total , dense_rank () over (order by sum(quantity) asc ) as ranking  from order_items 
join products p 
using ( product_id ) 
group by product_id ) 

select product_id , product_name , total 
from least_b
where ranking = 1 ; 

## What is the median order total?

select round( avg ( amount) , 2 ) median_order_total 
from( select oi.order_id , sum( oi.quantity * p.price ) amount 
from order_items oi 
join products p 
using ( product_id )  group by oi.order_id  ) a ; 


## For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
with classification as ( 
select  order_id , sum(price* quantity ) as revenue 
from  products p
join order_items oi 
using( product_id) 
group by order_id  ) 

select order_id ,  revenue , 
case when revenue > 300 then "EXPENSIVE" 
     when revenue > 100 then "AFFORDABLE" 
     ELSE "CHEAP" 
     END as order_classification 

 from classification  
 order by order_id desc ; 
 
 ## Find customers who have ordered the product with the highest price.

select c.customer_id  , concat( first_name , " " , last_name ) as Full_Name, product_name , price  
from products p 
join order_items oi 
using (product_id ) 
join orders o 
using ( order_id) 
join customers c
using ( customer_id ) 
where price IN ( select max( price) from products ) ;
