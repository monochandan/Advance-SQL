-- export import data with copy --

-- insert is very slow for bulk operation --

copy general_hospital.physicians to 'C:\Users\Public\physicians.csv'
	with delimiter ',' csv header;
	
create table general_hospital.physicians_2 (

	first_name text,
	last_name text,
	full_name text,
	id int
	
);

copy general_hospital.physicians_2 from 'C:\Users\Public\physicians.csv'
	with delimiter ',' csv header; 

select * from general_hospital.physicians_2;