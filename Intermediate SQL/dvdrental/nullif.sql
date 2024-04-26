create table depts(
first_name varchar(50),
	department varchar(50)

)

insert into depts(first_name, department)
values('Vinton', 'A'),
	('Lauren', 'A'),
	('Claraie', 'B');
	
	select * from depts
	
	
select (
sum(case when department ='A' then 1 else 0 end)/	
sum(case when department ='B' then 1 else 0 end)		
) as department_ratio
from depts


delete from depts
where department = 'B'

select * from depts

select (
sum(case when department ='A' then 1 else 0 end)/
nullif(sum(case when department ='B' then 1 else 0 end),0)
		
) as department_ratio
from depts









