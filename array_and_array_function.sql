-- Array and Array function ---
with resources as ( --- CTE
	select 
		surgery_id,
		array_agg(distinct resource_name order by resource_name) as resource_array -- array operator
	from general_hospital.surgical_costs
	group by surgery_id
)

select
	r1.surgery_id,
	r2.surgery_id,
	r1.resource_array
	
from resources r1
left outer join resources r2
	on r1.surgery_id != r2.surgery_id -- for 2 different surgery id
	and r.resource_array = r2.resource_array; --- resource used for those 2 different surgery are same
where 
	r1.resource_array @> array['Full Blood Count'] :: varchar[]; --- full blood count in the resource array (@> array comperision operator)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
