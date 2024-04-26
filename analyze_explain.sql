-- EXPLAIN and EXPLAIN ANALYZE

--- query performance ---
select *
from general_hospital.surgical_encounters;

explain analyze
--explain
--explain (format yaml)
--explain (format xml)
--explain ( format json)
with surgical_los as (

	select
		se.surgery_id,
		se.surgical_admission_date,
		se.surgical_discharge_date,
		(se.surgical_discharge_date - se.surgical_admission_date) as los,
		avg(se.surgical_discharge_date - se.surgical_admission_date) over() as avg_los

	from general_hospital.surgical_encounters se
	where se.surgical_admission_date between '2016-01-01' and '2017-01-01'
)

select 
	*,
	round(los - avg_los,2) as over_under
	from surgical_los;
	
	
	
--yml

- Plan: 
    Node Type: "Subquery Scan"
    Parallel Aware: false
    Async Capable: false
    Alias: "surgical_los"
    Startup Cost: 0.00
    Total Cost: 782.29
    Plan Rows: 7410
    Plan Width: 80
    Plans: 
      - Node Type: "WindowAgg"
        Parent Relationship: "Subquery"
        Parallel Aware: false
        Async Capable: false
        Startup Cost: 0.00
        Total Cost: 726.72
        Plan Rows: 7410
        Plan Width: 48
        Plans: 
          - Node Type: "Seq Scan"
            Parent Relationship: "Outer"
            Parallel Aware: false
            Async Capable: false
            Relation Name: "surgical_encounters"
            Alias: "se"
            Startup Cost: 0.00
            Total Cost: 597.04
            Plan Rows: 7410
            Plan Width: 12
            Filter: "((surgical_admission_date >= '2016-01-01'::date) AND (surgical_admission_date <= '2017-01-01'::date))"
			
-- xml

<explain xmlns="http://www.postgresql.org/2009/explain">
  <Query>
    <Plan>
      <Node-Type>Subquery Scan</Node-Type>
      <Parallel-Aware>false</Parallel-Aware>
      <Async-Capable>false</Async-Capable>
      <Alias>surgical_los</Alias>
      <Startup-Cost>0.00</Startup-Cost>
      <Total-Cost>782.29</Total-Cost>
      <Plan-Rows>7410</Plan-Rows>
      <Plan-Width>80</Plan-Width>
      <Plans>
        <Plan>
          <Node-Type>WindowAgg</Node-Type>
          <Parent-Relationship>Subquery</Parent-Relationship>
          <Parallel-Aware>false</Parallel-Aware>
          <Async-Capable>false</Async-Capable>
          <Startup-Cost>0.00</Startup-Cost>
          <Total-Cost>726.72</Total-Cost>
          <Plan-Rows>7410</Plan-Rows>
          <Plan-Width>48</Plan-Width>
          <Plans>
            <Plan>
              <Node-Type>Seq Scan</Node-Type>
              <Parent-Relationship>Outer</Parent-Relationship>
              <Parallel-Aware>false</Parallel-Aware>
              <Async-Capable>false</Async-Capable>
              <Relation-Name>surgical_encounters</Relation-Name>
              <Alias>se</Alias>
              <Startup-Cost>0.00</Startup-Cost>
              <Total-Cost>597.04</Total-Cost>
              <Plan-Rows>7410</Plan-Rows>
              <Plan-Width>12</Plan-Width>
              <Filter>((surgical_admission_date &gt;= '2016-01-01'::date) AND (surgical_admission_date &lt;= '2017-01-01'::date))</Filter>
            </Plan>
          </Plans>
        </Plan>
      </Plans>
    </Plan>
  </Query>
</explain>
	

with surgical_los as(

	select 
		surgery_id,
		(surgical_discharge_date - surgical_admission_date) as los,
		avg(surgical_discharge_date - surgical_admission_date)
			over() as avg_los
	from general_hospital.surgical_encounters
	)
	
select 
	*,
	round(los - avg_los,2) as over_under
	from surgical_los