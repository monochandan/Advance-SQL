select * from customer

-- between  case
select customer_id, 

case 
	when (customer_id <= 100) then 'Premium'
	when (customer_id between 100 and 200) then 'Plus'
	else 'Normal'
end as customer_class
from customer

-- equality case expression
select customer_id,
case customer_id
	when 2 then 'Winner'
	when 5 then ' Second Place'
	else 'Normal'
end as raffle_result
from customer


select * from film


select 
sum(case rental_rate
	when 0.99 then 1
	else 0
end) as bargains,

sum(case rental_rate
	when 2.99 then 1
	else 0
end) as regular,

sum(case rental_rate
	when 4.99 then 1
	else 0
end) as premium
from film

select * from film
select distinct(rating) from film

-- number of movies in per ratings
select 
sum(case rating
	when 'PG' then 1
	else 0
end) as total_movie_in_PG,

sum(case rating
	when 'R' then 1
	else 0
end) as total_movie_in_R,

sum(case rating
	when 'NC-17' then 1
	else 0
end) as total_movie_in_NC_17,

sum(case rating
	when 'PG-13' then 1
	else 0
end) as total_movie_in_PG_13,

sum(case rating
	when 'G' then 1
	else 0
end) as total_movie_in_G
from film

-- cast

select cast('5' as integer) as new_int

select '5':: integer


select * from rental

select char_length(cast(inventory_id as varchar)) from rental

-- nullif




















































