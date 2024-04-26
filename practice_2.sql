-- GROUPING SETS
-- reporting over all number of objects
-- number of patients in patient table by state and by county

select
	state, 
	county,
	count(*) number_of_patients
from general_hospital.patients
group by grouping sets (

		(state), --aggrigate over the state
		(state, county), -- aggrigate over the state and county
		() -- aggrigate over the all columns
)
order by state desc, county asc

-- average profit by a surgeon in mission type and diagnosis

select
	p.full_name,
	se.admission_type,
	se.diagnosis_description,
	count(*) as num_surgeries,
	avg(total_profit) as avg_total_profit
from general_hospital.surgical_encounters se
left outer join general_hospital.physicians p 
		on se.surgeon_id = p.id
group by grouping sets(
	(p.full_name),
	(se.admission_type),
	(se.diagnosis_description),
	(p.full_name, se.admission_type),
	(p.full_name, se.diagnosis_description)

)

-- 	CUBE
-- looking at number of patients by looking at county using CUBE
select 
	state,
	county,
	count(*) as num_patients
from general_hospital.patients
group by cube(state, county)
order by state desc, county

-- grouping set of county alone
-- count all means total patienzs
-- same as previous 
		-- group by state
		-- total patient statewise


-- average profit by a surgeon in mission type and diagnosis

select
	p.full_name,
	se.admission_type,
	se.diagnosis_description,
	count(*) as num_surgeries,
	avg(total_profit) as avg_total_profit
from general_hospital.surgical_encounters se
left outer join general_hospital.physicians p 
		on se.surgeon_id = p.id
group by cube (p.full_name, se.admission_type,se.diagnosis_description)


--ROLLUP
-- some state, hospital and department level reporting for encounters

-- hierarchy -- STATE <-- falls into  HOSPITAL <-- falls into DEPARTMENT

select 
	h.state,
	h.hospital_name,
	d.department_name,
	count(e.patient_encounter_id) as num_encounters
from general_hospital.encounters e
left outer join general_hospital.departments d
	on e.department_id = d.department_id
left outer join general_hospital.hospitals h
	on d.hospital_id = d.hospital_id
group by rollup (h.state, h.hospital_name, d.department_name)
order by h.state desc, h.hospital_name, d.department_name


-- look at the average age by the city , county and state for the patients

-- hierarchy -- city in --> counnty in --> state

select 
	state,
	county,
	city,
	count(master_patient_id) as num_patient,
	avg(extract(year from age(now(), date_of_birth))) as avg_age
from general_hospital.patients p
group by rollup (p.city, p.county, p.state)
order by state, county, city

	
-- find the average pulse and average body surface area by weight, height adn weight/height
select 
	v.height,
	v.weight,
	avg(pulse) as avg_pulse,
	avg(body_surface_area) as avg_body_area
from general_hospital.vitals v
group by grouping sets (
	(v.weight),
	(v.height),
	(v.weight, v.height)

)
--
select 
	v.weight,
	v.height,
	avg(pulse) as avg_pulse,
	avg(body_surface_area) as avg_body_area
from general_hospital.vitals v
group by cube (weight, height)
order by height, weight

-- generate a report on surgical admission by year, month and day using rollup
with extract_day_year_month as(
	select
		master_patient_id,
		extract (year from surgical_admission_date) as year,
		extract	(day from surgical_admission_date) as day,
		extract	(month from surgical_admission_date) as month
	from general_hospital.surgical_encounters

)
select
	year,
	month,
	day,
	count(master_patient_id) as total_patient
from extract_day_year_month
group by rollup (year, month, day)
--
select
	date_part('year', surgical_admission_date) as year,
	date_part('month', surgical_admission_date) as month,
	date_part('day', surgical_admission_date) as day,
	count(surgery_id) as num_surgeries
from general_hospital.surgical_encounters
group by rollup(1,2,3)
order by 1, 2, 3

-- generate a report on the number of patients by primary language, citizenship,
-- primary language / citizenship, and primary kanguage/ethnicity

select
	p.primary_language,
	p.is_citizen,
	p.ethnicity,
	count(p.master_patient_id) as total_patients
	
from general_hospital.patients p
group by grouping sets (
	(p.primary_language),
	(p.is_citizen),
	(p.primary_language, p.is_citizen),
	(p.primary_language, p.ethnicity)
)


-- INFORMATION SCHEMA

select *
from information_schema.tables
where table_schema = 'general_hospital'
order by table_name

select *
from information_schema.columns
where table_schema = 'general_hospital'
order by table_name, ordinal_position

select *
from information_schema.columns
where
	table_schema = 'general_hospital'
	and column_name like '%id'
order by table_name

-- group by table name and data type 
select 
	table_name,
	data_type,
	count(*) as num_column
from information_schema.columns
where table_schema = 'general_hospital'
group by table_name, data_type
order by table_name, 3 desc ---> 3 (num_column) desc

--COMMENT
--table comment
comment on table general_hospital.vitals is
'patient vital sign data taken at the begining of the encounter'

select obj_description('general_hospital.vitals'::regclass)

-- column comment

comment on column general_hospital.accounts.primary_icd is
'primary internation classification of disease (ICD) code for the account'

select *
from information_schema.columns 
where table_schema = 'general_hospital'
	and table_name  = 'accounts'
	
select col_description('general_hospital.accounts'::regclass, 1)

-- 	ADDING AND DROPPING CONTRASINTS

-- ADDING
alter table general_hospital.surgical_encounters
add constraint check_positive_cost
check(total_cost > 0)

select *
from information_schema.table_constraints
where table_schema = 'general_hospital'
	and table_name = 'surgical_encounters'
	

alter table general_hospital.surgical_encounters
drop constraint check_positive_cost


-- ADDING AND DROPPING FOREIGN KEYS

-- adding
alter table  general_hospital.encounters
add constraint encounters_attending_provider_id_fk
foreign key (attending_provider_id)
references general_hospital.physicians (id)

-- showing
select *
from information_schema.table_constraints
where table_schema = 'general_hospital'
 and table_name = 'encounters'
 and constraint_type = 'FOREIGN KEY'
order by constraint_name

alter table general_hospital.encounters
drop constraint encounters_attending_provider_id_fk
 


-- Add comment for admitting ICD and verify that it was added (ICD - International Classification of Diseases)

comment on column general_hospital.accounts.admit_icd is 'ICD - International classification of diseases'

select *
from information_schema.columns
where table_schema = 'general_hospital'
	and table_name = 'accounts'
	
select col_description('general_hospital.accounts'::regclass, 2)

-- Add NOT NULL constraints on surgical_admission_date field

alter table general_hospital.surgical_encounters
alter column surgical_admission_date
set not null

select *
from information_schema.columns
where table_schema = 'general_hospital'
	and table_name = 'surgical_encounters'
	and is_nullable = 'NO'

alter table general_hospital.surgical_encounters
alter column surgical_admission_date
drop not null

-- Add constraints to ensure that patient_discharge_datetime is after patient_admission_datetime or empty


alter table general_hospital.encounters
add constraint discharge_after_admit
check (
	(patient_discharge_datetime > patient_admission_datetime) or
	(patient_discharge_datetime is null)
)

alter table general_hospital.encounters
drop constraint if exists discharge_after_admit 

-- DATABASE TRANSACTION
-- UPDATE and SET

-- 
select * from general_hospital.vitals

update general_hospital.vitals
	set bp_diastolic = 100	
where patient_encounter_id = 2690640


select * from general_hospital.vitals
where patient_encounter_id = 2690640


select *
from general_hospital.accounts





update general_hospital.accounts
	set total_account_balance = 0	
where account_id = 11419738


select * from general_hospital.accounts
where account_id = 11419738


-- BEGINNING AND END TRANSECTION
----------------------------------------------------------
begin transaction;
select now();

select * 
from general_hospital.physicians
order by id


update general_hospital.physicians
	set first_name = 'Bill',
		full_name = concat(last_name, ', Bill')
	where id = 1 
	
end transaction;
-------------------------------------------------------


select * 
from general_hospital.physicians
where id = 1


--------------------------------------------------------------------
begin transaction;

update general_hospital.physicians
	set first_name = 'Gage',
		full_name = concat(last_name, ', Gage')
	where id = 1
	
	
update general_hospital.physicians
	set first_name = 
	
	
rollback
-----------------------------------------------------------------------
select * 
from general_hospital.physicians
where id = 1


-- SAVE POINT

select *
from general_hospital.vitals

----------------------------------
begin
update general_hospital.vitals
	set bp_diastolic = 120
	where patient_encounter_id = 2570046
savepoint vitals_updated

update general_hospital.accounts
	set total_account_balance = 1000
	where account_id = 11417340
rollback to vitals_updated
commit
-------------------------------------------------------------------------

select *
from general_hospital.vitals
where patient_encounter_id = 2570046 -- value has changed

select *
from general_hospital.accounts --- value not changed
where account_id = 11417340

------------------------------------------------------------------------------------
begin
update general_hospital.vitals
	set bp_diastolic = 52
	where patient_encounter_id = 1854663
savepoint vitals_updated
update general_hospital.accounts
	set total_account_balance = 1000
	where account_id = 11417340
release savepoint vitals_updated
commit
------------------------------------------------------------------------------------------

select *
from general_hospital.vitals
where patient_encounter_id = 1854663  -- value changed

select *
from general_hospital.accounts
where account_id = 11417340 --  value changed



--- DATABASE LOCKS

select *
from general_hospital.physicians


begin
select now()

lock table general_hospital.physicians

rollback



-----
begin transaction
select now()

update general_hospital.physicians
	set first_name = 'Gage',
		full_name = concat(last_name, ', Gage')
		
select *
from general_hospital.physicians p
where full_name like  'Krollman, Gage'
rollback --- data has not changed
commit

select *
from general_hospital.physicians p
where full_name like  'Krollman, Bill'


update general_hospital.physicians
	set first_name = 'Bill',
		full_name = concat(last_name, ', Bill')
	where id = 1



begin transaction

drop table general_hospital.patients

rollback

--- revert our update to the physicians table inside transaction using lock table Krollman, Bill ---> Krollman, Gage

begin transaction
lock table general_hospital.physicians

update general_hospital.physicians
		set first_name = 'Gage',
			full_name = concat(last_name, ', Gage')
		where id = 1
commit

select *
from general_hospital.physicians
where id = 1


--- try dropping a table inside a transaction with roll back and confirm the table was not dropped

begin transaction

drop table general_hospital.practices

rollback

select *
from general_hospital.practices


-- do the following inside the transaction:
-- update the account balance for account_id 11417340 to be 15,077.90 dollar
--- create a save point
-- drop any table
-- rollback to the save point
-- commit the transaction
-- verify the changes made/not made
select *
from general_hospital.accounts
--
begin
update general_hospital.accounts
		set total_account_balance = 15077.90
	where account_id = 11417340
savepoint balance_update
drop table general_hospital.practices
rollback to balance_update
commit
--
select *
from general_hospital.accounts
where account_id = 11417340

select *
from general_hospital.practices
































