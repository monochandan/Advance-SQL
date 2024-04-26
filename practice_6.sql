-- creating and calling stored procedures ---

create procedure general_hospital.sp_test_procedure()
	language plpgsql
	as $$
	begin
		drop table if exists general_hospital.test_table;
		create table general_hospital.test_table(
			id int 
		);
		commit;
	end;
	$$;
	
call general_hospital.sp_test_procedure();

-- routine defination

select *
from information_schema.routines
where routine_schema = 'general_hospital';


	begin
		drop table if exists general_hospital.test_table;
		create table general_hospital.test_table(
			id int 
		);
		commit;
	end;
	
	
	
	
-- modifying stored procedures ---

create or replace procedure general_hospital.sp_test_procedure()
	language plpgsql
	as $$
	begin
		drop table if exists general_hospital.test_table_new;
		create table general_hospital.test_table_new(
			id int 
		);
		commit;
	end;
	$$;




call general_hospital.sp_test_procedure();



-- moving test_procedure to new schema

alter procedure general_hospital.sp_test_procedure
	set schema public;
	
-- drop procedure

drop procedure if exists public.sp_test_procedure;




-- create a stored procedure to update cost of a surgery in both the surgical_encounters and surgical_cost table

drop procedure if exists general_hospital.sp_update_surgery_cost;

create procedure general_hospital.sp_update_surgery_cost(surgery_to_update int, cost_change numeric)
	language plpgsql
	as $$
	declare
		num_resources int;
	begin
		-- update surgical encounters
		update general_hospital.surgical_encounters
			set total_cost = total_cost + cost_change
			where surgery_id = surgery_to_update;
		commit;
		
		-- get number of resources
		select count(*) into num_resources -- getting all of the resources
		from general_hospital.surgical_costs
		where surgery_id = surgery_to_update;
		
		-- update cost table
		update general_hospital.surgical_costs
			set resource_cost = resource_cost + (cost_change / num_resources) -- cost is equally divided into all resources
			where surgery_id = surgery_to_update;
		commit;
	end;
	$$;
	
	

select * 
from general_hospital.surgical_encounters;


select sum(resource_cost) 
from general_hospital.surgical_costs
where surgery_id = 6518;

-- call the stored procedure to update a surgery and verify that it worked

call general_hospital.sp_update_surgery_cost(6518, 1000);

select * 
from general_hospital.surgical_encounters
where surgery_id = 6518;

select * 
from general_hospital.surgical_costs
where surgery_id = 6518;

-- use the stored procedure to reverse the previous operation

call general_hospital.sp_update_surgery_cost(6518, -1000);

select * 
from general_hospital.surgical_encounters
where surgery_id = 6518;

select * 
from general_hospital.surgical_costs
where surgery_id = 6518;

-- alter the name of the stored procedure


alter procedure general_hospital.sp_update_surgery_cost
	rename to sp_update_surgical_cost;
















	