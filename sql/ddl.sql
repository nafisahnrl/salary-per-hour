create table employees(
	employe_id int
	,branch_id int
	,salary int
	,join_date date
	,resign_date date
	,primary key(employe_id)
);

create table timesheets(
	timesheet_id int
	,employee_id int
	,date date
	,checkin time
	,checkout time
	,primary key(timesheet_id)
	,constraint fk_employee_id
		foreign key(employee_id)
			references employees(employe_id)
);

create table salary_per_hour(
	year int
	,month int
	,branch_id int
	,salary_per_hour decimal(10,2)
	,primary key(year,month,branch_id)
);
