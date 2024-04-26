--- views -----


--- crearte views --
select * from general_hospital.surgical_encounters 

create view general_hospital.v_monthly_surgery_states_by_department as
select 
	to_char(surgical_admission_date, 'YYYY-MM'),
	unit_name,
	count(surgery_id) as num_surgaries,
	sum(total_cost) as total_cost,
	sum(total_profit) as total_profit
	
from general_hospital.surgical_encounters
group by to_char(surgical_admission_date, 'YYYY-MM'), unit_name
order by unit_name, to_char(surgical_admission_date, 'YYYY-MM');

select * from general_hospital.v_monthly_surgery_states_by_department;

select *
from information_schema.views
where table_schema = 'general_hospital';

-- defination from information schema ---- 
 SELECT to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text) AS to_char,
    unit_name,
    count(surgery_id) AS num_surgaries,
    sum(total_cost) AS total_cost,
    sum(total_profit) AS total_profit
   FROM general_hospital.surgical_encounters
  GROUP BY (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text)), unit_name
  ORDER BY unit_name, (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text));
  
---------

--- modifying and deleting views ----


drop view if exists public.v_monthly_surgery_states_by_department;



create or replace view general_hospital.v_monthly_surgery_states as
select
	to_char(surgical_admission_date, 'YYYY-MM') as year_month,
	count(surgery_id) as num_surgeries,
	sum(total_cost) as total_cost,
	sum(total_profit) as total_profit
	
from general_hospital.surgical_encounters
group by 1
order by 1;

select * from general_hospital.v_monthly_surgery_states;

alter view if exists general_hospital.v_monthly_surgery_states
rename to view_monthly_surgery_stats


select * from  general_hospital.view_monthly_surgery_stats;

--- updatable views ----

select distinct department_id
from general_hospital.encounters
order by 1;

create view general_hospital.v_encounters_departments_22100005 as
select
	patient_encounter_id,
	admitting_provider_id,
	department_id,
	patient_in_icu_flag
from general_hospital.encounters
where department_id = 22100005;

select * from general_hospital.v_encounters_departments_22100005;

insert into general_hospital.v_encounters_departments_22100005 values
	(123456, 5611, 22100006, 'Yes'); ---NO ERROR without check option
	
select * 
from general_hospital.encounters
where patient_encounter_id = 123456;

create or replace view general_hospital.v_encounters_departments_22100005 as
select
	patient_encounter_id,
	admitting_provider_id,
	department_id,
	patient_in_icu_flag
from general_hospital.encounters
where department_id = 22100005
with check option;


insert into general_hospital.v_encounters_departments_22100005 values
	(123457, 5611, 22100006, 'Yes'); -- ERROR with check option -- 22100006 


select * from general_hospital.v_encounters_departments_22100005;



update general_hospital.v_encounters_departments_22100005 values
	set department_id = 22100006
	where patient_encounter_id = 4915064; -- ERROR violate check option




--- materialized view ----

-- with data statement : it will be populated by the data selected in the select statement

-- with no data : then the materialized view will be created but it will not be populated with the underlying data

select *
from general_hospital.surgical_encounters;

create materialized view general_hospital.v_monthly_surgery_stats as
select
	to_char(surgical_admission_date, 'YYYY-MM'),
	unit_name,
	count(surgery_id) as num_surgeries,
	sum(total_cost) as total_cost,
	sum(total_profit) as total_profit
from general_hospital.surgical_encounters
group by 1, 2
order by 2, 1
with no data;

select * from general_hospital.v_monthly_surgery_stats;


refresh materialized view general_hospital.v_monthly_surgery_stats;


alter materialized view general_hospital.v_monthly_surgery_stats
	rename to mv_monthly_surgery_stats;



alter materialized view general_hospital.mv_monthly_surgery_stats
	rename column to_char to year_month;


select * from general_hospital.mv_monthly_surgery_stats;



select *
from pg_matviews;




--materialized view defination
 SELECT to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text) AS year_month,
    unit_name,
    count(surgery_id) AS num_surgeries,
    sum(total_cost) AS total_cost,
    sum(total_profit) AS total_profit
   FROM general_hospital.surgical_encounters
  GROUP BY (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text)), unit_name
  ORDER BY unit_name, (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text));
----




--- recursive view ----

create recursive view general_hospital.v_fibonacci(a, b) as
	select 1 as a, 1 as b
	union all
	select b, a+b
	from v_fibonacci
	where b < 200;

select * from general_hospital.v_fibonacci;


create recursive view general_hospital.v_orders (order_procedure_id, order_parent_order_id, level) as
	select
		order_procedure_id,
		order_parent_order_id,
		0 as level
	from  general_hospital.orders_procedures
	where order_parent_order_id is null
	
	union all
	
	select 
		op.order_procedure_id,
		op.order_parent_order_id,
		o.level + 1 as level
	from general_hospital.orders_procedures op
	inner join v_orders o
		on op.order_parent_order_id = o.order_procedure_id; 
		
		
select * from general_hospital.v_orders
order by level desc;




-- creae view for primary care patients by excluding sensitive geographic / address information (but include pcp name)

select * from general_hospital.patients;

create view general_hospital.v_patients_primary_care as
select
	p.master_patient_id,
	p.name as patient_name,
	p.gender, 
	p.primary_language,
	p.date_of_birth,
	p.pcp_id,
	ph.full_name as pcp_name
from general_hospital.patients p
	left outer join general_hospital.physicians ph
				on p.pcp_id = ph.id;
				
				
				
select * from general_hospital.v_patients_primary_care;




-- create a unpopulated materialized view mv_hospital_encounters reporting on
-- the number of encounters and icu patients by year/month by hospital

create materialized view general_hospital.mv_hospital_encounters as

select
	h.hospital_id,
	h.hospital_name,
	to_char(patient_admission_datetime, 'YYYY-MM') as year_month,
	count(patient_encounter_id) as num_encounters,
	count(nullif(patient_in_icu_flag, 'no')) as num_icu_patients
	
from general_hospital.encounters e
left outer join general_hospital.departments d
	on e.department_id = d.department_id
left outer join general_hospital.hospitals h
	on d.hospital_id = h.hospital_id
group by 1,2,3
order by 1, 3
with no data;

--- populate the new materialized view and alter the name to mv_hospital_encounters_statistics

refresh materialized view general_hospital.mv_hospital_encounters;

select * from general_hospital.mv_hospital_encounters;

alter materialized view general_hospital.mv_hospital_encounters
	rename to mv_hospital_encounters_statistics;

-- create a primary care patients vew for pcp_id = 4121 and prevent unwanted inserts/updates
	-- set a default value for pcp_id
	-- check that inserts work as expected

select * from general_hospital.physicians
where id = 4121;

create view general_hospital.v_patients_primary_maleham as
select
	p.master_patient_id,
	p.name as patient_name,
	p.gender,
	p.primary_language,
	p.pcp_id,
	p.date_of_birth
from general_hospital.patients p
where p.pcp_id = 4121 
with check option;

-- alter view st as default

alter view general_hospital.v_patients_primary_maleham
	alter column pcp_id set default 4121;



drop view general_hospital.v_patients_primary_care_maleham;

alter view general_hospital.v_patients_primary_maleham
	rename to v_patients_primary_care_maleham;
	
	
	
	
insert into general_hospital.v_patients_primary_care_maleham values
	(120, 'John Doe', 'Male', 'ENGLISH', default, '2003-07-09');
	


insert into general_hospital.v_patients_primary_care_maleham values
	(1206, 'John Doe', 'Male', 'ENGLISH', 4122, '2003-07-09'); --- can not enter other than 4121









  
  