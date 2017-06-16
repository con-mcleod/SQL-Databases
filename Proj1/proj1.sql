-- COMP3311 17s1 Project 1
--
-- MyMyUNSW Solution Template


-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
select b.unswid,b.name
from Buildings b
	join Rooms r on (b.id=r.building)
group by b.id
having count(r.id) > 30 
;

-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
select p.name, u.longname, f.phone, a.starting
from people p
	join affiliations a on (a.staff=p.id)
	join staff_roles r on (a.role = r.id)
	join orgunits u on (a.orgunit = u.id)
	join orgunit_types t on (u.utype = t.id)
	join staff f on (f.id=p.id)
where r.name = 'Dean'
	and t.name = 'Faculty'
	and (a.ending is null)
;

-- Q3: get details of the longest-serving and shortest-serving current Deans of Faculty
create or replace view LongestServingDoF(status, name, faculty, starting)
as
select 'Longest serving'::text, Q2.name, Q2.faculty, Q2.starting
from Q2
where starting = (select min(starting) from Q2)
;

create or replace view ShortestServingDoF(status, name, faculty, starting)
as
select 'Shortest serving'::text, Q2.name, Q2.faculty, Q2.starting
from Q2
where starting = (select max(starting) from Q2)
;

create or replace view Q3(status, name, faculty, starting)
as
(select * from LongestServingDoF)
union
(select * from ShortestServingDoF)
;


-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
select cast(uoc/eftsload as numeric(4,1)), count(uoc/eftsload)
from subjects
where eftsload != 0 or eftsload != null 
group by cast(uoc/eftsload as numeric(4,1))
;



-- Q5: program enrolments from 10s1
create or replace view IntlStudSeng10S1 (studentID)
AS
SELECT DISTINCT (students.id)
FROM Program_enrolments, Streams, Students, People, Semesters, Stream_enrolments
WHERE Program_enrolments.student = Students.id
	AND Program_enrolments.semester = Semesters.id
	AND Program_enrolments.id = Stream_enrolments.partof
	AND Semesters.year = '2010'
	AND Semesters.term = 'S1'
	AND Streams.id = Stream_enrolments.stream
	AND Streams.code = 'SENGA1'
	AND Students.stype = 'intl'
;

create or replace view Q5a(num)
as
SELECT count(studentID) from IntlStudSeng10S1
;

create or replace view LocalStudCompSci10S1 (id)
AS
SELECT DISTINCT (students.id)
FROM Program_enrolments, Programs, Semesters, Students
WHERE Program_enrolments.student = Students.id
	AND Program_enrolments.semester = Semesters.id
	AND Program_enrolments.program = Programs.id
	AND Programs.code = '3978'
	AND Programs.name = 'Computer Science'
	AND Semesters.year = '2010'
	AND Semesters.term = 'S1'
	AND Students.stype = 'local'
;

create or replace view Q5b(num)
as
SELECT count(id) from LocalStudCompSci10S1
;

/* all students enrolled in 10S1 in degrees offered by Faculty of Engineering */

create or replace view EngineeringStudents10s1 (id)
AS
SELECT DISTINCT (people.unswid) as id
from students, semesters, OrgUnits, Programs, people, program_enrolments
where programs.offeredby = orgunits.id
	and program_enrolments.program = programs.id
	and program_enrolments.student = people.id
	and program_enrolments.semester = semesters.id
	and semesters.year = '2010' 
	and semesters.term = 'S1'
	and orgunits.name = 'Faculty of Engineering'
group by people.id
;

create or replace view Q5c(num)
as
SELECT count(id) from EngineeringStudents10s1
;

-- Q6: course CodeName
create or replace function Q6(text) returns text
as
$$
Select CONCAT ((subjects.code), ' ', (subjects.name))
from subjects
where subjects.code = $1;
$$ language sql;


-- Q7: Percentage of growth of students enrolled in Database Systems
create or replace view Q7 (year, term, perc_growth)
as
SELECT Semesters.year, Semesters.term, count(Course_enrolments.student)
FROM subjects, semesters, course_enrolments, courses, students, program_enrolments
WHERE subjects.name = 'Database Systems'
	AND semesters.term <> 'X1'
	AND semesters.term <> 'X2'
	AND subjects.code = 'COMP3311'
	AND course_enrolments.student = students.id
	AND course_enrolments.course = courses.id
	and courses.subject = subjects.id
	and program_enrolments.student = students.id
	and program_enrolments.semester = semesters.id
GROUP BY semesters.year, semesters.term
ORDER BY semesters.year, semesters.term
;

/*

-- Q8: Least popular subjects
create or replace view Q8(subject)
as
SELECT subjects.name, subjects.code
FROM subjects, courses, people, course_enrolments, students
#courseOffering >= 20
#distinct course_enrolments <= 20 for last 20 courseofferings 
#return subjects
#put results into Q6 function
;
*/


-- Q9: Database Systems pass rate for both semester in each year
create or replace view Q9(year, s1_pass_rate, s2_pass_rate)
as
SELECT Semesters.year, s1pass/s1total as s1_pass_rate, s2pass/s2total as s2_pass_rate
FROM 
	SELECT year, count(marks) as s1total, 
	count(case when marks = 'pass' then 1 else null end) as s1pass
	FROM subjects, semesters, course_enrolments, courses, program_enrolments
	WHERE subjects.name = 'Database Systems'
		AND semesters.term = 'S1'
		and subjects.code = 'COMP3311'
		and course_enrolments.marks >= 50
		AND course_enrolments.student = students.id
		AND course_enrolments.course = courses.id
		and courses.subject = subjects.id
		and program_enrolments.student = students.id
		and program_enrolments.semester = semesters.id


;

/*

-- Q10: find all students who failed all black series subjects
create or replace view Q10(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



*/

/*
$ ssh grieg
$ source /srvr/z5058240/env
$ pgs start
navigate to my directory (cd --> cd Project1Directory)
edit my proj1.sql document to answer the questions
$ psql proj1
$ \i proj1.sql
$ select check_all();
$ \q
$ pgs stop

*/
