delete from salary_per_hour;

with monthly_employee_details as (
select distinct employee_id 
	,branch_id
	,date_part('year',date) as year 
	,date_part('month',date) as month 
	,case when to_char(date,'YYYY-MM')=to_char(join_date,'YYYY-MM') 
		and (resign_date is null or to_char(date,'YYYY-MM')!=to_char(resign_date,'YYYY-MM')) 
			then (date_part('day',date(date_trunc('MONTH', date) + INTERVAL '1 MONTH' - INTERVAL '1 day')) - date_part('day',join_date))*salary/date_part('day',date(date_trunc('MONTH', date) + INTERVAL '1 MONTH' - INTERVAL '1 day')) 
	when to_char(date,'YYYY-MM')!=to_char(join_date,'YYYY-MM') 
		and to_char(date,'YYYY-MM')=to_char(resign_date,'YYYY-MM') 
			then date_part('day',resign_date)*salary/date_part('day',date(date_trunc('MONTH', date) + INTERVAL '1 MONTH' - INTERVAL '1 day'))
	when to_char(date,'YYYY-MM')=to_char(join_date,'YYYY-MM') 
		and to_char(date,'YYYY-MM')=to_char(resign_date,'YYYY-MM') 
			then (date_part('day',resign_date) - date_part('day',join_date))*salary/date_part('day',date(date_trunc('MONTH', date) + INTERVAL '1 MONTH' - INTERVAL '1 day'))
	else salary end salary
from timesheets t 
join employees e 
	on t.employee_id = e.employe_id
)
, monthly_branch_salary as (
select 
	branch_id
	,year
	,month
	,count(1) as emp_amount
	,sum(salary) as total_salary
from monthly_employee_details
group by
	branch_id
	,year 
	,month
)
, monthly_branch_hours as (
select 
	branch_id
	,date_part('year',date) as year 
	,date_part('month',date) as month 
	,sum(case when checkin is null then (extract(epoch from checkout) - extract(epoch from make_time(0,0,0)))/3600 
			when checkout is null then (extract(epoch from make_time(23,59,59)) - extract(epoch from checkin))/3600
			when checkout < checkin then (extract(epoch from ((date+1)+checkout)) - extract(epoch from (date+checkin)))/3600
			else (extract(epoch from checkout) - extract(epoch from checkin))/3600 end) as total_hours
from timesheets t
join employees e on t.employee_id = e.employe_id  
group by
branch_id 
,date_part('year',date)
,date_part('month',date)
)
insert into salary_per_hour (year,month,branch_id,salary_per_hour)
select 
	mh.year
	,mh.month
	,mh.branch_id
	,ms.total_salary/mh.total_hours as salary_per_hour
from monthly_branch_hours mh
join monthly_branch_salary ms on mh.year = ms.year
	and mh.month=ms.month
	and mh.branch_id = ms.branch_id;
	




