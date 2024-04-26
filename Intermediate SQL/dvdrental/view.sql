create view customer_info as 
select first_name, last_name, address from customer
inner join address
on customer.address_id = address.address_id

select * from customer_info


create  or replace view customer_info as
select first_name, last_name, address, district from customer
inner join address
on customer.address_id = address.address_id


drop view  if exists customer_info

alter view customer_info rename to c_info

select * from customer_info

select * from c_info









