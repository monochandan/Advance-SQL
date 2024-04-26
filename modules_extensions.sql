-- modules and extensions ---

select *
from pg_available_extensions
order by 1;

--install
create extension fuzzystrmatch schema general_hospital;

select *
from pg_available_extensions
order by 1;

select general_hospital.levenshtein('bigelow', 'bigalo');


create extension earthdistance CASCADE schema general_hospital;

select *
from general_hospital.hospitals;

select 
	p.latitude,
	p.longitude,
	h.latitude,
	h.longitude,
	general_hospital.earth_distance(
			ll_to_earth(cast(p.latitude as numeric), cast(p.longitude as numeric)),
			ll_to_earth(cast(h.latitude as numeric), cast(h.longitude as numeric))
	) / 1000 as distance_in_km
	
from general_hospital.patients p
inner join general_hospital.hospitals h
	on h.hospital_id = 111000;
	
	
	
	
general_hospital.point(p.longitude, p.latitude) <@> general_hospital.point(h.longitude, h.latitude) as distance_in_miles
