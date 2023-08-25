use swiggy;
select * from food;
select * from delivery_partner;
select * from menu;
select * from order_details;
select * from orders;
select * from restaurants;
select * from users;


#1. Find customers who have never ordered

select name 
from users 
where user_id not in (select user_id from orders);

#2. Average Price/dish

select f.f_name , avg(price)
from menu m
join food f 
on m.f_id = f.f_id
group by m.f_id,f.f_name;

-- 3. Find the top restaurant in terms of the number of orders for a given month

select monthname(date) as month, r.r_name,count(o.r_id)
from orders o
join restaurants r 
on o.r_id = r.r_id
-- where monthname(date)  like 'June'
group by month,o.r_id,r.r_name
order by monthname(date),count(o.r_id) desc;

-- 4. restaurants with monthly sales greater than x for 

select r.r_name,sum(amount) as 'tot',monthname(date)
from orders o
join restaurants r
on o.r_id = r.r_id
-- where monthname(date)  like 'July'  
group by o.r_id,r.r_name, monthname(date)
having sum(amount) >500
order by monthname(date), tot desc;

-- 5. Show all orders with order details for a particular customer in a particular date range
select o.order_id,o.user_id
from orders o
join users u 
on o.user_id = u.user_id
group by o.user_id,o.order_id;

-- 6. Find restaurants with max repeated customers 
select f.f_name,od.order_id
from order_details od
join food f
on od.f_id = f.f_id
order by f.f_name;
-- 7. Month over month revenue growth of swiggy
SELECT
    u.user_id,
    u.name,
    f.f_name AS favorite_food
FROM
    users u
JOIN (
    SELECT
        o.user_id,
        od.f_id,
        COUNT(od.f_id) AS food_count
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY
        o.user_id,
        od.f_id
    ORDER BY
        o.user_id,
        food_count DESC
) AS user_food_counts ON u.user_id = user_food_counts.user_id
JOIN food f ON user_food_counts.f_id = f.f_id
GROUP BY
    u.user_id,
    u.name;
-- 8. Customer - favorite food






