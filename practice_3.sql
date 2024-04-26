--- RANGE PARTITIONING -------

--Ranges: specify a range of values to put into each table partitions ---
-- Lists: list out the values  ... lost of rows
--- A hash : 



select * from general_hospital.surgical_encounters

create table general_hospital.surgical_encounters_pertitioned (

		surgery_id integer not null,
		master_patient_id integer not null,
		surgical_admission_date date not null,
		surgical_discharge_date date
) partition by range (surgical_admission_date);



select * from general_hospital.surgical_encounters_pertitioned


-- do partition explicitely

select distinct extract (year from surgical_admission_date)
from general_hospital.surgical_encounters

create table surgical_encounters_y2016
	partition of general_hospital.surgical_encounters_pertitioned
	for values from ('2016-01-01') to ('2017-01-01');
	
	
create table surgical_encounters_y2017
	partition of general_hospital.surgical_encounters_pertitioned
	for values from ('2017-01-01') to ('2018-01-01');
	
create table surgical_encounters_default
	partition of general_hospital.surgical_encounters_pertitioned
	default;
	
	
	
	
insert into general_hospital.surgical_encounters_pertitioned
	select 
		surgery_id,
		master_patient_id,
		surgical_admission_date,
		surgical_discharge_date
	from general_hospital.surgical_encounters;
	

create index on  general_hospital.surgical_encounters_pertitioned
	(surgical_admission_date);


select extract(year from surgical_admission_date),
	count(*)
from general_hospital.surgical_encounters
group by 1;

select 
	count(*),
	max(surgical_admission_date),
	min(surgical_admission_date)
from surgical_encounters_y2016

select 
	count(*),
	max(surgical_admission_date),
	min(surgical_admission_date)
from surgical_encounters_y2017


select 
	count(*),
	max(surgical_admission_date),
	min(surgical_admission_date)
from surgical_encounters_default





-- partitioning table explicitely by list --- small number of known values

-- small number of hosptall id --- seperate it

select * from general_hospital.departments

create table departments_partitioned (

	hospital_id integer not null,
	department_id integer not null,
	department_name text,
	speciality_description text

) partition by list(hospital_id);


select * from departments_partitioned



select distinct hospital_id
from general_hospital.departments


create table departments_h111000
	partition of departments_partitioned
	for values in (111000);
	
create table departments_h9900006
	partition of departments_partitioned
	for values in (9900006);

create table departments_h112000
	partition of departments_partitioned
	for values in (112000);

create table departments_h115000
	partition of departments_partitioned
	for values in (115000);

create table departments_h114000
	partition of departments_partitioned
	for values in (114000);	
	
	
	
-- hash partitioning ----

select * from general_hospital.orders_procedures


create table general_hospital.orders_procedures_partitioned (

	order_procedure_id int not null,
	patient_encounter_id int not null,
	ordering_provider_id int references general_hospital.physicians(id),
	order_cd text,
	order_procedure_description text

)partition by hash (order_procedure_id, patient_encounter_id)



create table orders_procedures_hash0
	partition of general_hospital.orders_procedures_partitioned
	for values with (modulus 3, remainder 0);
	
create table orders_procedures_hash1
	partition of general_hospital.orders_procedures_partitioned
	for values with (modulus 3, remainder 1);
	
create table orders_procedures_hash2
	partition of general_hospital.orders_procedures_partitioned
	for values with (modulus 3, remainder 2);
	
	
-- insert data --- 

insert into general_hospital.orders_procedures_partitioned
	select 
		order_procedure_id,
		patient_encounter_id,
		ordering_provider_id,
		order_cd,
		order_procedure_description
	from general_hospital.orders_procedures;
	
	
select 'hash0', count(*)
from orders_procedures_hash0
union
select 'hash1', count(*)
from orders_procedures_hash1
union
select 'hash2', count(*)
from orders_procedures_hash2;

-- table inheritance ----

 create table general_hospital.visit ( ---- parent table
 
 		id serial not null primary key,
	 	start_datetime timestamp,
	 	end_datetime timestamp
 
 );
 
 
 create table general_hospital.emergency_visit( ---- child table
 
 	 emergency_department_id int not null,
	 triage_level int,
	 triage_datetime timestamp
 
 )inherits (general_hospital.visit);


insert into general_hospital.emergency_visit
	values (default, '2022-01-01 12:00:00', null, 12, 3, null);
	
select * from general_hospital.emergency_visit

select * from general_hospital.visit

insert into general_hospital.visit values (default, '2022-03-02 11:00:00', '2022-03-03 12:00:00');

select * from only general_hospital.visit



---primary key break doe´wn in inherited table


insert into general_hospital.emergency_visit 
				values (2, '2022-03-01 11:00:00', '2022-03-03 12:00:00', 1, 1, null)
				
				
select *
from general_hospital.emergency_visit

select * from general_hospital.visit



-- create and populate a new encounters table partitioned by hospital_id

---1 create partition base table
create table general_hospital.encounters_partitioned (

	hospital_id int not null, -- this are comming from departments table other are from encounter table 
	patient_encounter_id int not null,
	master_patient_id int not null, --- this constraint giving the error
	admitting_provider_id int references general_hospital.physicians (id),
	department_id int references general_hospital.departments (department_id),
	patient_admission_datetime timestamp,
	patient_discharge_datetime timestamp,
	constraint encounters_partitioned_pk primary key
		(hospital_id, patient_encounter_id)
	
)partition by list(hospital_id);

-- check how many partition do we needed
select distinct d.hospital_id
from general_hospital.encounters e
	left outer join general_hospital.departments d
		on e.department_id = d.department_id
order by 1;


--- create partitions we need 5 partitions

create table general_hospital.encounters_h111000
	partition of general_hospital.encounters_partitioned
	for values in (111000);


create table general_hospital.encounters_h112000
	partition of general_hospital.encounters_partitioned
	for values in (112000);


create table general_hospital.encounters_h114000
	partition of general_hospital.encounters_partitioned
	for values in (114000);

create table general_hospital.encounters_h115000
	partition of general_hospital.encounters_partitioned
	for values in (115000);

create table general_hospital.encounters_h9900006
	partition of general_hospital.encounters_partitioned
	for values in (9900006);


create table general_hospital.encounters_default
	partition of general_hospital.encounters_partitioned
	default;
	
	
---- insert into those partitiones

insert into general_hospital.encounters_partitioned
select
	d.hospital_id,
	e.patient_encounter_id,
	e.master_patient_id,
	e.admitting_provider_id,
	e.department_id,
	e.patient_admission_datetime,
	e.patient_discharge_datetime
from general_hospital.encounters e
left outer join general_hospital.departments d
	on e.department_id = d.department_id

select *
from general_hospital.encounters_h115000

create index on general_hospital.encounters_partitioned(patient_encounter_id)

-- create a new vitals table partitioned by a datetime 
-- field (hint: try the patient_admission_datetime field in encounters)

--selects

-- create table
create table general_hospital.vitals_partitioned
(
	patient_encounter_id int not null references general_hospital.encounters (patient_encounter_id), --- vital --join-- encounter
	collection_datetime timestamp not null, --- encounter ( patient_admission_datetime )
	bp_diastolic int, --vital
	bp_systolic int, -- vital
	bmi numeric, --- vital
	temprature numeric, -- vital
	weight int --- vital

)partition by range (collection_datetime);


-- create partitiones

select distinct extract(year from patient_admission_datetime)
from general_hospital.encounters

create table general_hospital.vitals_y2015
	partition of general_hospital.vitals_partitioned
	for values from ('2015-01-01') to ('2016-01-01');


create table general_hospital.vitals_y2016
	partition of general_hospital.vitals_partitioned
	for values from ('2016-01-01') to ('2017-01-01');


create table general_hospital.vitals_y2017
	partition of general_hospital.vitals_partitioned
	for values from ('2017-01-01') to ('2018-01-01');

create table general_hospital.vitals_default
	partition of general_hospital.vitals_partitioned
	default;
	
-- insert the values
select * from general_hospital.vitals

select * from general_hospital.encounters

insert into general_hospital.vitals_partitioned
select
	e.patient_encounter_id,
	e.patient_admission_datetime as collection_datetime,
	v.bp_diastolic,
	v.bp_systolic,
	v.bmi,
	v.temperature as temprature,
	v.weight
		
from general_hospital.vitals v 
left outer join general_hospital.encounters e
	on v.patient_encounter_id = e.patient_encounter_id;
	
	
	
select *
from general_hospital.vitals_y2016
	
	
	
select distinct extract(year from collection_datetime)
from general_hospital.vitals_y2016









	
	
	
	
	
	
	
	


