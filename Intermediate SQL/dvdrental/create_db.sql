create table account(
	user_id serial primary key,
	user_name varchar(50) unique not null,
	password varchar(50) not null,
	email varchar(250) unique not null,
	created_on timestamp not null,
	last_log_in timestamp 

) 

create table job(
	job_id serial primary key,
	job_name varchar(200) unique not null

)

create table account_job(
	user_id integer references account(user_id),
	job_id integer references job(job_id),
	hire_date timestamp
)


select * from account

insert into account(user_name, password, email, created_on)
values
('Jose', 'password','jode@gmail.com',current_timestamp)

insert into job(job_name)
values
('Astronaut')

select * from job

insert into job(job_name)
values
('Presedent')

insert into account_job(user_id, job_id, hire_date)
values
(1, 1, current_timestamp)

select * from account_job

insert into account_job(user_id, job_id, hire_date)
values
(10, 10, current_timestamp)

select * from account

update account
set last_log_in = current_timestamp

update account
set last_log_in = created_on


update account_job
set hire_date = account.created_on
from account
where account_job.user_id = account.user_id

select * from account_job

select * from account


update account
set last_log_in = current_timestamp
returning email,created_on, last_log_in



select * from job

insert into job(job_name)
values
('Cowboy')

delete from job
where job_name = 'Cowboy'
returning job_id, job_name




create table information(
info_id serial primary key,
	title varchar(500) not null,
	person varchar(50) not null
)


select * from information

alter table information 
rename to new_info

select * from new_info


alter table new_info 
rename column person to people

select * from new_info

insert into new_info(title)
values
('some new title')

alter table new_info
alter column people drop not null


select * from new_info

alter table new_info
drop column people



alter table new_info
drop column if exists people


create table employees(
emp_id serial primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	birthdate date check(birthdate > '1990-01-01'),
	hire_date date check(hire_date > birthdate),
	salary integer check(salary > 0)
)

insert into employees(first_name, last_name, birthdate, hire_date, salary)
values('hose',
	  'portila',
	  '1990-11-03',
	  '2010-01-01',
	  100)
	  
	  insert into employees(first_name, last_name, birthdate, hire_date, salary)
values('Samy',
	  'smith',
	  '1990-11-03',
	  '2010-01-01',
	  100)
	  
	  select * from employees
































