select * from general_hospital.encounters

--1 subquries
-- subqueries are inside queries. Can be used to select, update, create, delete statements
-- Makes code more efficient - can do more in a single query
-- makes your code more readable - queries can be more self_contained

-- different subqueries --

-- basic sub query - FROM clause
-- Common table expression/ WITH clauses
-- Comparisions with main data set
---------------------------------------------------------------------


-- subqueries in FROM clauses - SELECT statement inside a SELECT statement
SELECT col_1, col_2, ...
FROM (
	SELECT col_1, col_2,...
	FROM table_name
)table_alias
-----------------------------------------------------------------------



select * 

from (
 select *
 from general_hospital.patients
 where date_of_birth >= '2000-01-01'
 order by master_patient_id
	) p
	
where p.name ilike 'm%'	;


-- sub queries in JOIN clause -------
SELECT t1.col_1, t2.col_2,...
FROM table_1 t1
inner join (
	SELECT col_1 from table_2
)t2 on t1.col.col_1 = t2.col_2

----------------------------------------------------

-- select surgaries in the month of novembar 2016 and then joining them to our patient table 
-- to only get patient who only born after the january 1990



select * from general_hospital.patients


select * 
from  (
	select * 
	from general_hospital.surgical_encounters
	where surgical_admission_date 
		between '2016-11-01' and '2016-11-30'
	) se
inner join (
	select master_patient_id 
	from general_hospital.patients 
	where date_of_birth >= '1990-01-01'
	) p on se.master_patient_id = p.master_patient_id	
	
	
-- common table expression  CTE

-- provide a way to break down complex queries and make them easier to understand.
-- CTEs create tables that only exist for single query
-- CTEs can be re-used in a single query
-- GOOD for performing complex, multi step calculations

-- identifyed by with clause

with table_name AS (select ...)
-- can be used with CREATE; SELECT; UPDATE; DELETE operations.

--------------------------------------------------------
select * 
from (
 select *
 from general_hospital.patients
 where date_of_birth >= '2000-01-01'
 order by master_patient_id
	) p	
where p.name ilike 'm%'	;

--

with young_patients as(
	select *
 	from general_hospital.patients
 	where date_of_birth >= '2000-01-01'

)
select * from young_patients
where name ilike 'm%';
--
-- number of surgaries by the counties, for counties which have more than 1500 patients

select * from general_hospital.surgical_encounters
select * from general_hospital.patients

select distinct(county) from general_hospital.patients

-- number of surgaries by the counties, for counties which have more than 1500 patients
with top_counties as(
	select county,count(*) as number_of_patients
	from general_hospital.patients
	group by county
	having count(*) > 1500
	), -- county, number_of_patients
	county_patients as (
		select p.master_patient_id, p.county
		from general_hospital.patients p
		inner join top_counties t on 
		p.county = t.county -- joining here by county
	
	) -- patient_id, county
select p.county, count(s.surgery_id) as num_surgaries
from general_hospital.surgical_encounters s
inner join county_patients p on 
		s.master_patient_id = p.master_patient_id
group by p.county


with top_counties as(
	select county,count(*) as number_of_patients
	from general_hospital.patients
	group by county
	having count(*) > 1500
	)
select * from top_counties








select * from general_hospital.accounts

select * from general_hospital.departments

select * from general_hospital.encounters

select * from general_hospital.hospitals

select * from general_hospital.orders_procedures

select * from general_hospital.patients

select * from general_hospital.physicians

select * from general_hospital.practices

select * from general_hospital.surgical_costs

select * from general_hospital.surgical_encounters


select * from general_hospital.vitals



-- subqueries for comparision

-- subqueries can be used in FROM and JOIN clause, but  also in WHERE and HAVING clause
-- useful for writing comparisions against values not known beforehand.
-- can be used with most comparision operations of interest >, >=. <, <=, !=, <>, LIKE etc.

-- EXAMPLE SYNTAX WITH >=
select col_1, col_2,...
from table_1
where col_1 >= (select avg(col_1) from table_2)

---------------------------------------------------------------------------------------------------------------------

-- surgaries where the total cost is greater than average total cost
 
with total_cost as(

		select surgery_id, sum(resource_cost) as total_surgery_cost
		from general_hospital.surgical_costs
		group by surgery_id
	)
	
	select *
	from total_cost
	where total_surgery_cost > (
							select avg(total_surgery_cost) 
							from total_cost
	);
	
	
	
select * 
from general_hospital.vitals
where 
bp_diastolic > (select min(bp_diastolic) from general_hospital.vitals)
and bp_systolic < (select max(bp_systolic) from general_hospital.vitals)
;
	
	
-- subqueries with IN and NOT IN

-- just like we can use subqueries with numerical comparisions, we can use them for list coomparisions
-- IN  and NOT IN keywords.
-- useful for comparing sets of values where set is not known beforehand

-- example : 
select col_1, col_2;...
from table_1
where col_1 in (
	select col_1 from table_2
)
 
-- with IN and NOT IN , we select a column
-- with other comparision operators, we select a single value.
-- NOTE: subqueries with IN and NOT IN can often be written as joins, depending on performance

--------------------------------------------------------------------------------------------------------

-- filter from patient table who have had surgaries
select * 
from general_hospital.patients
where master_patient_id in(
		select distinct master_patient_id from general_hospital.surgical_encounters
)
order by master_patient_id;

select distinct p.master_patient_id 
from general_hospital.patients p
inner join general_hospital.surgical_encounters s
		on p.master_patient_id = s.master_patient_id
order by p.master_patient_id

-- filter from patient table who not have had surgaries
select * 
from general_hospital.patients
where master_patient_id not in(
		select distinct master_patient_id from general_hospital.surgical_encounters
)
order by master_patient_id;


-- subqueries with ANY ALL

-- similar to IN and NOT IN, ANY and ALL provide a way to compare single values with a result set.
-- ANY and ALL must be predicted by an operator : >, >=, <, >=, =, !=, <>, LIKE, ...
--can be used in WHERE or HAVING clauses.

-- the subquery for ANY has to return one column.
-- then, the query will check to see if the comparision with any of the values in the subquery evaluates true.
-- similar in some ways to a boolean OR- As long as one  comparision is true. expression evaluates to true.

-- example:
select col_1, col_2;...
fro table_1
where col_1>= any(
	select col_1 from table_2
)

-- SOME is equivalent to ANY
-- IN is equivalent to =ANY
-- will evaluate to false if subquery returns no rows
-- CAREFULL--- if no success/true values for comparision and at least one null evaluation for operator, result will be null

-- The subquery for AND also has to return one column
-- Then, the query will check to see if the comparision with all of the values in the subquery evaluates to true.
-- similar in some ways to a Boolean AND  - All comparisions in the experssions must evaluate to True

-- example:

select col_1, col_2,..
from table_1
where col_1>= all(
	select col_1 from table_2
)

-- NOT IN is equivalent to <> ALL
-- CAREFULL --- if no false values from comparision and at least one null evaluation for opertaor, results will be null


--------------------------------------------------------------------------------------------------

-- surgical total profit is greater than the average cost of all diagnosis
-- this surgaries profit was greater than average of other surgaries total cost

select *
from general_hospital.surgical_encounters
where total_profit > all(

	select avg(total_cost)
	from general_hospital.surgical_encounters
	group by diagnosis_description

);

-- diagnosis whose average length of stay is less than or equal to the average length of stay for all encounter
-- by the department

select 
	diagnosis_description, 
	avg(surgical_discharge_date - surgical_admission_date) as length_of_stay
from general_hospital.surgical_encounters
group by diagnosis_description -- avg lentgh of stay by dignosis description from surgical_encounters table 
having avg(surgical_discharge_date - surgical_admission_date) <=
		all(
			select 
				avg(extract(day from patient_discharge_datetime - patient_admission_datetime))
			from general_hospital.encounters
			group by department_id
		)

-- look at unit who sow all types of surgical cases or all type of surgical type

select 
	unit_name, 
	string_agg(distinct surgical_type, ',') as case_types
from general_hospital.surgical_encounters
group by unit_name
having string_agg(distinct surgical_type, ',') like all( --- each unit name has seen all distinct case types (DayCase,Elective,NonElective)
	select string_agg(distinct surgical_type, ',')
	from general_hospital.surgical_encounters

)

-- EXISTS in subqueries
-- use EXISTS to see whether a subquery returns any results.
-- used with WHERE clause.
-- Evaluated only  to see if at least one row is returned- TRUE if so, FALSE otherwise.
-- output list is usually not important, so the coding convention is EXISTS(SELECT 1 FROM ...)

-- example: 
SELECT col_1, col_2,...
from table_1
where exists (
	select 1 from table_2 where...
)

-- can be used with NOT keyword, just like IN/NOT IN
-- subqueries with EXISTS can sometimes be inefficient and have poor performance depend on schema design and query writting
-- NOTE: when subquery returns null, result of EXISTS evaluates to True
---------------------------------------------------------------------------------------------------------------------------

-- get all the encounters with an order or at least one order
select e.*
from general_hospital.encounters e
where exists(
	select 1
	from general_hospital.orders_procedures o
	where e.patient_encounter_id = o.patient_encounter_id
)

-- all patient who dont have have surgaries
select p.*
from general_hospital.patients p
where not exists(
       	select 1
		from general_hospital.surgical_encounters s
		where s.master_patient_id = p.master_patient_id
)
-------------------------------------------------------------------------------------------------------------------------

-- RECURSIVE CTEs ------------------------------------------------------------------------------------------------------
-- recursion involves a function or process referring to itself
-- recursive CTEs in postgres provide a powerfull tool constructing or analyzing network or tree like relationships
	-- employees and managers
	-- orders and parent orders
-- start with a non recursive base term in WITH clause, continue with recursive term

-- example:
with recursive table_alias as (
	{{non-recursive query}}
	union[all]
	{{recursive query}}
)
select *
from table_alias;

-- classic example of recursion is the fibonacci sequence

f(n) = f(n-1) + f(n-2)
f(1) = 1
f(2) = 1
1,1,2,3,5,8,13,21.....

with recursive fibonacci as(
	select 1 as a, 1 as b
	union all
	select b, a+b
	from fibonacci
)
select a, b
from fibonacci
limit 10;

--------------------------------------------------------------------------------------------------------------------
-- WINDOW function----------------------------------------------------------------------------------------------------------

-- OVER , PARTITION BY, ORDER BY

-- look at the average length of stay for all surgaries but compare that to individual surgaries 

select 
	surgery_id,
	(surgical_discharge_date - surgical_admission_date) as los,
	avg(surgical_discharge_date - surgical_admission_date)
		over() as avg_los
from general_hospital.surgical_encounters

-- compare over and under length of stay

with surgical_los as(

	select 
		surgery_id,
		(surgical_discharge_date - surgical_admission_date) as los,
		avg(surgical_discharge_date - surgical_admission_date)
			over() as avg_los
	from general_hospital.surgical_encounters
	)
	
select 
	*,
	round(los - avg_los,2) as over_under
	from surgical_los


-- count balance ranking by diagnosis icd

select 
	account_id,
	primary_icd,
	total_account_balance,
	rank()
		over(partition by primary_icd order by total_account_balance desc) -- window function
	as account_rank_by_icd
from general_hospital.accounts

-- avg total profit and the sum total cost of all total surgaries by sergon

-- sergion is going to be our window of interest
select
	s.surgery_id, 
	p.full_name,
	s.total_profit,
	avg(total_profit) over w as avg_total_profit,
	s.total_cost,
	sum(total_cost) over w as total_surgeon_cost
from general_hospital.surgical_encounters s
left outer join general_hospital.physicians p
on s.surgeon_id = p.id
window w as (partition by s.surgeon_id) -- window clause
-- we keep the details of the individual surgeries including the surgeon name then we can use the aggregate functions


-- dynamic calculation function


-- want rank of the surgical cost by surgeon and than the (ROW_NUMBER) profitability by surgeon and diagnosis 
-- 2 different window function

select
	s.surgery_id,
	p.full_name,
	s.total_cost,
	rank() over(partition by surgeon_id order by total_cost asc) as cost_rank, --- rank by surgical cost
	s.diagnosis_description,	
	row_number() over
		(partition by surgeon_id, diagnosis_description
			order by total_profit desc) as profit_row_number, -- proftability
	s.total_profit
	
from general_hospital.surgical_encounters s
left outer join general_hospital.physicians p
	on s.surgeon_id = p.id
order by s.surgeon_id, s.diagnosis_description
 
-- cost_rank is giving least costly and most costly rank for every surgeon 


-- what is the last and next visit by patient from the encounters 


select
	patient_encounter_id,
	master_patient_id,
	patient_admission_datetime,
	patient_discharge_datetime,
	lag(patient_discharge_datetime) over w as previous_discharge_date,
	lead(patient_admission_datetime) over w as next_admission_date
from general_hospital.encounters
window w as(partition by master_patient_id order by patient_admission_datetime)
order by master_patient_id, patient_admission_datetime;

------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- find all surgeries that occurred within 30 days of a previous surgery
-- my attempt--------------------------------------------------------------
with occured_surgaries as
(
	select
		surgery_id,
		surgical_type,
		diagnosis_description,
		admission_description,
		discharge_description,
		lag(surgical_discharge_date) over w as previous_surgical_discharge_date,
		lead(surgical_admission_date) over w as next_surgical_admission_date

	from general_hospital.surgical_encounters
	window w as (partition by surgical_type order by diagnosis_description)
	order by surgery_id, diagnosis_description desc
	)

select *,
	(next_surgical_admission_date - previous_surgical_discharge_date) as surgery_interval
from occured_surgaries
where (next_surgical_admission_date - previous_surgical_discharge_date) <= 30
order by (next_surgical_admission_date - previous_surgical_discharge_date) desc
----------------------------------------------------------------------------------------------------------
--- sol----------------------------------------
with surgeries_lagged as(
	select
		surgery_id, 
		master_patient_id,
		surgical_admission_date,
		surgical_discharge_date,
		lag(surgical_discharge_date) over
			(partition by master_patient_id order by surgical_admission_date)
		as previous_discharge_date
	from general_hospital.surgical_encounters
)
select
	*,
	(surgical_admission_date - previous_discharge_date)
		as days_between_surgaries
from surgeries_lagged
where (surgical_admission_date - previous_discharge_date) <= 30
--------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- for each department, find the 3 physicians with the most admissions
-- sol
with provider_department as(
	select
		admitting_provider_id,
		department_id,
		count(*) as num_encounters
	from general_hospital.encounters
	group by admitting_provider_id, department_id
),
pd_ranked as(
	select *,
	row_number() over(partition by department_id order by num_encounters desc)
		as encounter_rank
	from provider_department

)
select *,
	p.full_name, d.department_name, num_encounters, encounter_rank
from pd_ranked pd left outer join general_hospital.physicians p
 on pd.admitting_provider_id = p.id
 left outer join general_hospital.departments d on pd.department_id = d.department_id
 where encounter_rank <= 3
 
-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--- for each surgery, find any resources that accounted for more than 50% of total surgery cost
--- my attempt
with new_table as(
	select  s1.surgery_id, s1.diagnosis_description, s2.resource_name, s2.resource_cost, s1.total_cost,
	--rank() over(partition by s1.surgery_id order by s1.total_cost desc) as cost_rank,
	row_number() over
		(partition by s1.surgery_id, s1.diagnosis_description
			order by s2.resource_cost desc) as cost_row_number
	
	from general_hospital.surgical_encounters  s1
	inner join general_hospital.surgical_costs s2 on s1.surgery_id = s2.surgery_id
	 
	)
select * from new_table
where resource_cost >= total_cost/2
	
-- sol--
with total_cost as(
	select 
		surgery_id,
		resource_name,
		resource_cost,
		sum(resource_cost) over (partition by surgery_id) as total_surgery_cost
	from general_hospital.surgical_costs
	
)
select *, (resource_cost / total_surgery_cost) * 100 as pct_total_cost
from total_cost
where (resource_cost / total_surgery_cost) * 100 > 50
-------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

-- SELF JOIN

-- select all surgaries that have the same length
select
	se1.surgery_id as surgery_id1,
	(se1.surgical_discharge_date - se1.surgical_admission_date) as los1,
	se2.surgery_id as surgery_id2,
	(se2.surgical_discharge_date - se2.surgical_admission_date) as los2
from general_hospital.surgical_encounters se1
inner join general_hospital.surgical_encounters se2
		on (se1.surgical_discharge_date - se1.surgical_admission_date) 
		= (se2.surgical_discharge_date - se2.surgical_admission_date)


-- orders and parent orders in orders_procedure table
-- to get the hierarchies of the orders

select
	o1.order_procedure_id,
	o1.order_procedure_description,
	o1.order_parent_order_id,
	o2.order_procedure_description
from general_hospital.orders_procedures o1
inner join general_hospital.orders_procedures o2
		on o1.order_parent_order_id = o2.order_procedure_id 


-- CROSS JOIN

-- all hospitals with its departments

select
	h.hospital_name,
	d.department_name
from general_hospital.hospitals h
cross join general_hospital.departments d

-- FULL JOIN

-- select departments without hosptals

-- to see is there any departmnet without hospital 

select
	d.department_id,
	d.department_name
from general_hospital.departments d
full join general_hospital.hospitals h
		on d.hospital_id = h.hospital_id
where 
	h.hospital_id is null
	

--- any encounters without account or any account without encounters

select
	a.account_id,
	e.patient_encounter_id
from general_hospital.accounts a
full join general_hospital.encounters e
	on a.account_id = e.hospital_account_id
	
where a.account_id is null
		or e.patient_encounter_id is null
	
-- result is  -- this patients might not have surgaries in the hospital yet

select
	a.account_id,
	e.patient_encounter_id
from general_hospital.accounts a
full join general_hospital.encounters e
	on a.account_id = e.hospital_account_id
	
where a.account_id is null --- 2 encounters without account(payment) -- data quality issue


-- USING and NATURAL JOIN

-- USING
select
	h.hospital_name,
	d.department_name
from general_hospital.departments d
inner join general_hospital.hospitals h
		using(hospital_id)

-- NATURAL JOIN
select
	h.hospital_name,
	d.department_name
from general_hospital.departments d
inner join general_hospital.hospitals h
		on d.hospital_id = h.hospital_id
		
		
-- find all combinations of physicians and practices in the database
select 
	p1.full_name,
	p2.name
from general_hospital.physicians p1
cross join general_hospital.practices p2 

--




--- find the average blood pressure (systolic, diastolic) by admitting provider
select e.admitting_provider_id, avg(bp_diastolic) as avg_diastolic, avg(bp_systolic) as avg_systolic
from general_hospital.encounters e inner join
	general_hospital.vitals v on 
	e.patient_encounter_id = v.patient_encounter_id
	group by e.admitting_provider_id

--
select 
	p.full_name,
	avg(bp_diastolic) as avg_diastolic, 
	avg(bp_systolic) as avg_systolic
from general_hospital.vitals v
inner join general_hospital.encounters e using(patient_encounter_id)
left outer join general_hospital.physicians p
			on e.admitting_provider_id = p.id 
group by p.full_name
	
--  find the number of surgaries in the surgical costs table without data in the surgical encounters table
select * 
from general_hospital.surgical_costs

select count(distinct sc.surgery_id)  
from general_hospital.surgical_costs sc
full join general_hospital.surgical_encounters se
	using(surgery_id)
where se.surgery_id is null -- without data in the surgical encounters table



-- UNION

-- get all the surgery ids accross the surgical encounters table and the surgical costs table

select surgery_id
from general_hospital.surgical_encounters
union
select surgery_id
from general_hospital.surgical_costs
order by surgery_id


select surgery_id
from general_hospital.surgical_encounters
union all  -- to keep all duplicates
select surgery_id
from general_hospital.surgical_costs
order by surgery_id

--INTERSECT
-- all the surgaries id in the both table surgery encounters and surgery cost
select surgery_id
from general_hospital.surgical_encounters
intersect
select surgery_id
from general_hospital.surgical_costs
order by surgery_id

-- want to look at patients with the patients in encounter and patient in surgical encounters so that we can 
-- build up a list of all the patient that we have seen 


with all_patients as(
	select master_patient_id
	from general_hospital.encounters
	intersect
	select master_patient_id
	from general_hospital.surgical_encounters 
)

select 
	ap.master_patient_id,
	p.name
from all_patients ap
left outer join general_hospital.patients p
		on ap.master_patient_id = p.master_patient_id

-- EXCEPT

--surgeries that are in the surgery cost table but not in the surgical encounter table

select surgery_id
from general_hospital.surgical_costs
except
select surgery_id
from general_hospital.surgical_encounters
order by surgery_id

-- take a look at depertments that are in the department table but not in the encounters table 

-- departments without associates encounters

with missing_departments as(
		select department_id
		from general_hospital.departments
		except
		select department_id
		from general_hospital.encounters-- any department id thats in the encounters table will be excluded from the list from the departments table 

)
select 
	m.department_id,
	d.department_name
from missing_departments m
left outer join general_hospital.departments d
	on m.department_id = d.department_id
	
	-- 6 department that dont have any encounters associated with them in the encounters table
	
	
-- generate a list of all physicians and physicians types in the encounters table (inclding their name)



	with providers as(
		select
			admitting_provider_id as provider_id,
			'admitting' as provider_type  
		from general_hospital.encounters
		union
		select
			discharging_provider_id,
			'discharging'
		from general_hospital.encounters 
		union
		select
			attending_provider_id,
			'attending'
		from general_hospital.encounters
	
	)
	select
		p1.provider_id,
		p1.provider_type,
		p2.full_name
	from providers p1
	left outer join general_hospital.physicians p2 
		on p1.provider_id = p2.id
	order by p2.full_name, p1.provider_type
	


-- find all primary care physicians(PCPs) who also are admitting providers


with admitting_pcps as(
	select pcp_id
	from general_hospital.patients
	intersect
	select admitting_provider_id
	from general_hospital.encounters
)
select 
	a.pcp_id,
	p.full_name
from admitting_pcps a
left outer join general_hospital.physicians p
	on a.pcp_id = p.id

-- determine whetehre there are any surgeons in the surgical encounters table who are not in the physicians table
--- if there is anything then data quality issue
with surgeons as(
	select surgeon_id
	from general_hospital.surgical_encounters
	except
	select id
	from general_hospital.physicians
)
select *
from surgeons









