--- sql user defined - functions ---

create function general_hospital.f_test_function(a int, b int)
 	returns int
	language sql
	as
	'select $1 + $2;';
	
select general_hospital.f_test_funtion(1,2);

create function general_hospital.f_plpgsql_function(a int, b int)
	returns int
	as $$
	begin
		return a + b;
	end;
	$$ language plpgsql;



select general_hospital.f_plpgsql_function(1, 2);

select general_hospital.f_plpgsql_function(a=>1, b=>2);

-- length of stay for patients
create function general_hospital.f_calculate_los(start_time timestamp, end_time timestamp)
		returns numeric
		as $$
		begin
			return round((extract(epoch from (end_time  - start_time))/ 3600)::numeric, 2); --- calculate in hours
		end;
		
		$$ language plpgsql;
		
		
select 
	patient_admission_datetime,
	patient_discharge_datetime,
	general_hospital.f_calculate_los(patient_admission_datetime, patient_discharge_datetime) as length_of_stay
from general_hospital.encounters;
		
--select * from general_hospital.f_calculate_los();

--- find defined function also routine definations
select *
from information_schema.routines
where routine_schema = 'general_hospital';


-- modifying user define function -- ---

create or replace function general_hospital.f_calculate_los(start_time timestamp, end_time timestamp)
	returns numeric
	as $$
	begin
		return round(
				(extract(epoch from (end_time - start_time))/3600)::numeric, 4 ---epoch for extracting second
		);
	end;
	$$ language plpgsql; 
	

select 
	patient_admission_datetime,
	patient_discharge_datetime,
	general_hospital.f_calculate_los(patient_admission_datetime, patient_discharge_datetime) as length_of_stay
from general_hospital.encounters;


drop function if exists general_hospital.f_test_funtion;


alter function general_hospital.f_calculate_los
	rename to f_calculate_los_hours;
	

select * from general_hospital.patients;








-- create a function to mask text fields using the md5() function


create function general_hospital.mask_text_fields(patient_name character)
	returns character
	as $$
	begin
		return MD5(patient_name) ;
	end;
	$$ language plpgsql;
	
select 
	general_hospital.mask_text_fields(name) as name_as_mask
	from general_hospital.patients;
	
	
	
create function general_hospital.f_masked_field(field text)
	returns text
	language plpgsql
	as $$
	begin
		return md5(field);
	end;
	$$;
	
select 
	name,
	general_hospital.f_masked_field(name) as name_as_mask
	from general_hospital.patients;
	

-- update the function so that it returns a string with 'patient' + the first 8 digits of the hash.
	--- extra credit: add handling for null names
	
create or replace function general_hospital.mask_text_fields(patient_name character)
	returns character
	as $$
	begin
		return round(MD5(patient_name), 8 ::  not null);
	end;
	$$ language plpgsql;
	
select 
	'patient' + general_hospital.mask_text_fields(name) as name_as_mask
	from general_hospital.patients;
	
	
create or replace function general_hospital.f_masked_field(field text)
	returns text
	language plpgsql
	as $$
	begin
		if field is null then
			return null;
		else
			return concat('patient ',left(md5(field), 8));
		end if;
	end;
	$$;
	
select 
	name,
	general_hospital.f_masked_field(name) as name_as_mask
	from general_hospital.patients;
	
select general_hospital.f_masked_field(null); -- no null value

-- change the name of the function so it more explicitly refers to masking a patients name
	
	
	
	
alter function general_hospital.f_masked_field
	rename to f_masked_patient_name;	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

