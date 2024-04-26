select * 
from payment
limit 2

select customer_id, count(rental_id)
from payment
group by customer_id
order by customer_id

select customer_id
from payment
group by customer_id

select count(distinct(customer_id))
from payment


-- who rent more cds

select customer_id, sum(amount) as expanse
from payment
group by customer_id -- (sum(amount)) total amount par customer id
order by expanse desc

select staff_id,customer_id, sum(amount) as expanse
from payment
group by staff_id, customer_id  -- total amount (sum(amount)) spend per staff per customer
order by staff_id, customer_id

select date(payment_date), sum(amount) 
from payment
group by date(payment_date)
order by sum(amount) desc

--- select time(payment_date) from payment

-- how many payment did each staff member handle and who  gets the bonus
select staff_id, count(amount)
from payment 
group by staff_id
order by count(amount) desc


select * from film limit 2

-- what is the average replacement cost per MPAA rating
select rating, round(avg(replacement_cost),2) as avg_replc_cost
from film
group by rating
order by avg(replacement_cost) desc

-- top 5 customer by total spend
select customer_id, sum(amount)
from payment
group by customer_id
order by sum(amount) desc
limit 5

select customer_id, sum(amount) 
from payment
where customer_id not in(184, 87, 477)
group by customer_id

select customer_id, sum(amount) 
from payment
group by customer_id
having sum(amount) > 100


select store_id, count(customer_id) as store_count
from customer
group by store_id
having count(customer_id) > 300

--customer that have 40 or more transaction payments
select customer_id, count(rental_id) 
from payment
group by customer_id
having count(rental_id) >= 40

--- customer id who have spent mor ethan 100 in payment transactions with staff_id 2
select staff_id, customer_id, sum(amount)
from payment
group by staff_id, customer_id
having staff_id = 2 and sum(amount) > 100
order by staff_id, customer_id asc

select customer_id, sum(amount)
from payment
where staff_id = 2
group by customer_id
having sum(amount) > 100



-- Return the customer IDs of customers who have 
-- spent at least $110 with the staff member who has an ID of 2.
select customer_id, sum(amount)
from payment
where staff_id = 2
group by customer_id
having sum(amount) >= 110

--How many films begin with the letter J?

Select count(*)
from film
where title like 'J%'

-- What customer has the highest customer ID number 
-- whose name starts with an 'E' and has an address ID lower than 500?

select first_name, last_name from customer
where first_name like 'E%' and address_id < 500
order by customer_id desc
limit 1



select amount as rental_price
from payment

--- alias (e.g - AS) operator gets executed 
--  at the very end of the query --  not usable in group by




select count(amount) as  num_transactions
from payment

select customer_id, sum(amount) as total_spent
from payment
group by customer_id
having sum(amount) > 100


select  payment_id, payment.customer_id, first_name
from payment inner join customer 
on payment.customer_id = customer.customer_id

-- outer join -- deal with values only present in one of the tables being joined

-- privacy policy: make sure we dont have any information which 
-- is essentially unique to payment and not associate with customer ore vice versa

select count(distinct(customer_id))
from customer

select count(distinct(customer_id))
from payment


select * from customer
full outer join payment on customer.customer_id = payment.customer_id
where customer.customer_id = null  -- only unique to customer table
or payment.payment_id is null -- only unique to payment table


-- left join == left outer join
-- join == inner join
-- right join == right outer join

select  *
from film

select * from inventory


--- what are the emails of the customers who lives in California
select * from customer
select * from address
select *  from payment 

select district,email
from customer inner join address on customer.address_id = address.address_id
where address.district = 'California'



-- get a list of all movie where Nick Wahlberg has been in
select * from actor
where first_name = 'Nick' and last_name = 'Wahlberg'

select * from film

select * from film_actor

---

select actor.actor_id,actor.first_name, actor.last_name, film.film_id, film.title
from actor 
inner join film_actor
on actor.actor_id = film_actor.actor_id
inner join film
on film_actor.film_id = film.film_id
where actor.first_name = 'Nick' and actor.last_name = 'Wahlberg'


show all

show timezone

select now() -- time stamp information fpr right now
select timeofday()
select current_time


select * from payment

select extract(year from payment_date) as year_
from payment


select age(payment_date) from payment

select to_char(payment_date, 'Month-YYYY') from payment


select distinct(to_char(payment_date, 'Month') )
from payment

-- count the transaction happen in monday

select count(to_char(payment_date, 'day'))
from payment
where to_char(payment_date, 'day') like 'monday%'

select count(*)
from payment
where extract(dow from payment_date) = 1 


select * from payment

select *  from film

-- what percantage to the rental rate and replacment cost
select round(rental_rate/replacement_cost, 2) * 100 as percent_cost from film 


select * from customer

select length(first_name), first_name
from customer

select upper(first_name) || ' ' || upper(last_name) as full_name from customer 


select lower(left(first_name,1)) || lower(last_name) || '@gmail.com'
from customer


select * from film

select title, rental_rate from film
where rental_rate > (select avg(rental_rate) from film) -- subquery exicuted first

-- select film with certain return date
select film_id,film.title
from film
where film_id in
(select inventory.film_id 
from rental
inner join inventory on inventory.inventory_id = rental.inventory_id
where return_date between '2005-05-29' and '2005-05-30')
order by film_id

-- names of the custimers who have paid 11 at least once
select first_name, last_name from customer as c
where exists
(select * 
 from payment as p
where p.customer_id = c.customer_id and amount > 11)

-- find the all pairs of films that have the same length
select f1.title, f2.title 
from film as f1
inner join film as f2
on f1.film_id != f2.film_id
and f1.length = f2.length

 
























































-- showing film either be in film table or both in film table  and inventory table
-- not showing film which in only inventory table but not in film table
select film.film_id, title, inventory_id, store_id
from  film left outer join inventory on inventory.film_id = film.film_id
where inventory.film_id is null --  not in inventory














 














































