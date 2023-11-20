use swiggy;

select * from delivery_partner;
select * from food;
select * from menu;
select * from order_details;
select * from orders;
select * from restaurants;
select * from users;

###################################################################
				# User who never ordered 
###################################################################
select user_id,name from users
where user_id not in(
select user_id from orders GROUP BY user_id);

##################################################################
				# Average Price per dish
##################################################################
with avg_price(f_id,average) as 
(select f_id,avg(price) from menu 
group by f_id)
select f.f_id,f.f_name,round(ap.average,2) as 'Average Price'
from food f 
inner join avg_price ap
on f.f_id = ap.f_id
order by ap.average desc;

########################################################################
		# Top restaurant by total number of orders in a given month 
########################################################################
DELIMITER $$
USE swiggy $$
drop procedure if exists `get_top_res_of_month` $$
CREATE  PROCEDURE `get_top_res_of_month`(in month_name VARCHAR(20))
BEGIN
select r.r_name,monthname(o.date),count(*) as 'No.of Orders' from restaurants r
inner join orders o 
on r.r_id = o.r_id
where monthname(o.date) = month_name
group by monthname(o.date),r.r_name
order by monthname(o.date),count(*) desc
limit 1; 
END$$ 
DELIMITER $$

call get_top_res_of_month('July');
call get_top_res_of_month('May');
call get_top_res_of_month('June');

###########################################################################
				# restaurants with monthly sales > x 
###########################################################################
DELIMITER $$
USE swiggy $$
drop procedure if exists `get_monthly_sales` $$
CREATE  PROCEDURE `get_monthly_sales`(in month_name VARCHAR(20),in sales int)
BEGIN
select r.r_name as 'Restaurant',sum(o.amount) as 'Sales',monthname(date) as 'Month'
from orders o 
inner join restaurants r 
on o.r_id = r.r_id
where monthname(date) = month_name
group by o.r_id,monthname(date),r.r_name
having sum(amount) > sales
order by monthname(date) desc;
END$$ 
DELIMITER $$

call get_monthly_sales('June',500);

#######################################################################
			# restaurants with maximum repeated users
#######################################################################
with repeated_users(res_name,user_name,orders,rank_num)as
(select r.r_name as 'Restaurant',u.name as 'User',count(o.order_id) as 'No of Orders',
rank() over(partition by r.r_name order by count(o.order_id) desc) as 'rank'
from orders o
inner join restaurants r on o.r_id = r.r_id
inner join users u on o.user_id = u.user_id
group by u.name,r.r_name
order by r.r_name)
select *,count(rank_num)
from repeated_users
where rank_num = 1
group by res_name,user_name,orders,rank_num;

#################################################################
				# favorite food of a customer
#################################################################
with fav_food(food,user,count,row_num) as 
(select f.f_name as 'Food',u.name as 'User',count(od.f_id) as 'No.of Orders',
row_number() over(partition by u.name order by count(od.f_id) desc) as row_num
from order_details od 
inner join orders o on od.order_id = o.order_id
inner join food f on f.f_id = od.f_id
inner join users u on u.user_id = o.user_id 
group by f.f_name,u.name)
select user,food
from fav_food
where row_num =1;

########################################################################
				# orders of each delivery partner
########################################################################
with count_of_delivery(partner_id,count_del) as 
(select partner_id,count(partner_id) from orders 
group by partner_id)
select d.partner_id,d.partner_name,c.count_del as 'total orders of partner'
from delivery_partner d 
inner join count_of_delivery c
on d.partner_id = c.partner_id
order by d.partner_id asc;


