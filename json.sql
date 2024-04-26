-- JSON AND JSON FUNCTIONS ------

--- json, jsonb

select '{"first_name": "Ben", "Last_name": "Doe"}'::jsonb-> 'first_name';

select
	json_build_object(
		'id', id,
		'first_name', first_name,
		'last_name', last_name
	)as physician_json
from general_hospital.physicians
order by first_name;