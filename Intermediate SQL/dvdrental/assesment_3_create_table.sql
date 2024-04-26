create table students(
	
	student_id serial primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	homeroom_number integer,
	phone varchar(20) unique not null,
	email varchar(100) unique,
	garduation_year integer
	
)

CREATE TABLE students(
student_id serial PRIMARY KEY,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL, 
homeroom_number integer,
phone VARCHAR(20) UNIQUE NOT NULL,
email VARCHAR(115) UNIQUE,
grad_year integer);



create table teachers(
	teacher_id serial primary key,	
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	homeroom_number integer,
	email varchar(100) unique,
	phone varchar(20) unique not null,
	department varchar(50)

)

CREATE TABLE teachers(
teacher_id serial PRIMARY KEY,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL, 
homeroom_number integer,
department VARCHAR(45),
email VARCHAR(20) UNIQUE,
phone VARCHAR(20) UNIQUE);

select * from students

select * from teachers

ALTER TABLE students
ALTER COLUMN phone TYPE varchar(50);

ALTER TABLE teachers
ALTER COLUMN phone TYPE varchar(50);


alter table students
alter column email type varchar(100)
 

insert into students(student_id,first_name, last_name,homeroom_number, phone, garduation_year )
values(1, 'Mark', 'Watney', 5, '777-555-1234', 2035)

insert into teachers(teacher_id, first_name, last_name, homeroom_number, department, email, phone)
values(1, 'Jonas', 'Salk', 5, 'Biology', 'jsalk@school.org', '777-555-4321')



