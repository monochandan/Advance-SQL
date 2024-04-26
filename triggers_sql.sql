-- triggers ---
drop function if exists general_hospital.f_clean_physician_name;

create or replace function general_hospital.f_clean_physician_name()
	returns trigger
	language plpgsql
	as $$
	begin
		if NEW.first_name is null or NEW.last_name is null then
			raise exception 'Name can not be null';
		else
			NEW.first_name = trim(NEW.first_name);
			NEW.last_name =  trim(NEW.last_name);
			NEW.full_name = concat(NEW.last_name, ', ', NEW.first_name);
			return NEW;
		end if;
		
	end;
	$$;

-- to attach with the physician table --
create trigger tr_clean_physician_name
	before insert
	on general_hospital.physicians
	for each row
	execute procedure general_hospital.f_clean_physician_name();
	
	
	
select * from general_hospital.physicians



insert into general_hospital.physicians values
	('John', 'Doe', 'Something', 12345);
	
select *
from general_hospital.physicians
where id = 12345


--- enabling and disabling triggers ---

alter table general_hospital.physicians
	enable trigger tr_clean_physician_name;

alter table general_hospital.physicians
	disable trigger tr_clean_physician_name;


insert into general_hospital.physicians values
	('John', null, 'Something', 12347);

select *
from general_hospital.physicians
where id = 12346	
	
-- modifying and dropping triggers ---

alter trigger tr_clean_physician_name on general_hospital.physicians
	rename to tr_clean_name;
	
drop trigger if exists tr_clean_name on general_hospital.physicians;



-- create a trigger named my_trigger that runs after an update to surgical_encounters to update surgical_costs if that total costs changes

create function f_update_surgical_costs()
	returns trigger
	language plpgsql
	as $$
	declare
		num_resources int;
	begin
		-- Get the resource count
		select count(*) into num_resources
		from general_hospital.surgical_costs
		where surgery_id = NEW.surgery_id;
		
		-- Update costs table
		if NEW.total_cost != OLD.total_cost then
			update general_hospital.surgical_costs
			set resource_cost = NEW.total_cost / num_resources
			where surgery_id = NEW.surgery_id;
		end if;
		return NEW; -- return new record
	end;
	$$;


create trigger my_trigger
	after update
	on general_hospital.surgical_encounters
	for each row
		execute procedure f_update_surgical_costs();
		
-- rename the trigger to tr_update_surgical_costs

alter trigger my_trigger on general_hospital.surgical_encounters
	rename to tr_update_surgical_costs;
	
-- check that teh trigger works by updating the cost of one surgery

select * from general_hospital.surgical_encounters;

update general_hospital.surgical_encounters
	set total_cost = total_cost + 1000
	where surgery_id = 14615;
	
select * from general_hospital.surgical_encounters
where surgery_id = 14615;

select *
from general_hospital.surgical_costs
where surgery_id = 14615;

select sum(resource_cost)
from general_hospital.surgical_costs
where surgery_id = 14615;

-- drop the trigger

drop trigger tr_update_surgical_costs on general_hospital.surgical_encounters;
















