--Retrieve the total number of orders placed.

SELECT  count(*)as total_orders 
from orders;

--Calculate the total revenue generated from pizza sales.

SELECT sum(o.quantity * p.price) as total_revenue 
from pizzas as p 
join order_details as o 
on o.pizza_id=p.pizza_id;

--Identify the highest-priced pizza.

SELECT pt.name,p.pizza_id,p.pizza_type_id,max(p.price) as highest_price 
from pizzas as p 
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id;

--Identify the most common pizza size ordered.

SELECT p.size, count(*) as total_ordered 
from order_details as od 
join pizzas as p on p.pizza_id=od.pizza_id
group by p.size
order by total_ordered desc ;

--List the top 5 most ordered pizza types along with their quantities.

SELECT p.pizza_type_id,pt.name,sum(od.quantity) as quantities_ordered 
from pizzas as p 
join order_details as od on od.pizza_id = p.pizza_id
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
group by p.pizza_type_id ,pt.name
order by quantities_ordered DESC
limit 5;

--Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category,sum(od.quantity) as total_quantity 
from pizza_types as pt
join pizzas as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id
group by pt.category
order by total_quantity desc;

--Determine the distribution of orders by hour of the day.

SELECT strftime('%H', time) AS order_hour,count(order_id) as order_count 
FROM orders
group by strftime('%H', time); 


--Join relevant tables to find the category-wise distribution of pizzas.

SELECT category ,count(*) as total_pizzas 
from pizza_types
group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_orders),2) as avg_order 
from 
(SELECT date,sum(od.quantity) as total_orders 
from orders as o
join order_details as od on od.order_id= o.order_id
group by date);

--Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name,p.pizza_type_id,sum(od.quantity * p.price) as total_revenue 
from pizza_types as pt 
join pizzas as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id
group by pt.name
order by total_revenue desc
limit 3;


---Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category,round(sum(od.quantity * p.price) / (SELECT  round(SUM(od.quantity * p.price) ,2) as total_sales 
from 
order_details as od join pizzas as p on p.pizza_id=od.pizza_id)*100,2) as revenue 
from pizza_types as pt join pizzas as p on p.pizza_type_id=pt.pizza_type_id
join order_details as od on od.pizza_id= p.pizza_id
group by pt.category
order by revenue desc;


---Analyze the cumulative revenue generated over time.

select date,sum(revenue) over(order by date) as cum_rev 
from 
(SELECT o.date,sum(od.quantity* p.price) as revenue from orders as o
join order_details as od on od.order_id = o.order_id
join pizzas as p on p.pizza_id = od.pizza_id
group by o.date ) as sales;

---Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT * from 
(SELECT pt.category,pt.name,sum(od.quantity * p.price) as revenue,rank() over(partition by pt.category order by sum(od.quantity * p.price) desc) as rnk 
from pizza_types as pt join pizzas as p on p.pizza_type_id= pt.pizza_type_id
join order_details as od on od.pizza_id=p.pizza_id
group by  pt.category,pt.name) as t
where rnk <= 3 ;



