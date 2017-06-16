-- COMP3311 17s1 Project 1
--
-- MyMyUNSW Solution Template


-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
select buildings.unswid as unswid, buildings.name as name
from buildings, rooms
where buildings.id = rooms.building
group by buildings.unswid, buildings.name
having count (*) > 30 
;

-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
SELECT people.name, OrgUnits.longname as faculty, staff.phone, affiliations.starting
FROM people, affiliations, OrgUnits, Staff, staff_roles, orgunit_types
WHERE staff.id = people.id
	AND orgunits.utype = orgunit_types.id
	AND orgunit_types.name = 'Faculty'
	AND Staff_roles.name = 'Dean'
	AND affiliations.staff = staff.id
	AND affiliations.orgUnit = orgunits.id
	AND affiliations.role = staff_roles.id
	AND affiliations.ending IS NULL
;

-- Q3: get details of the longest-serving and shortest-serving current Deans of Faculty
create or replace view Q3(status, name, faculty, starting)
as


(select Cast('Longest Serving' as text) as status, name, faculty, min(starting) as starting
	from Q2
	group by name, faculty, starting
	order by starting
	limit 2)
UNION
(select Cast('Shortest Serving' as text) as status, name, faculty, max(starting) as starting
	from Q2
	group by name, faculty, starting
	order by starting DESC
	limit 1)
order by starting
;


-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
SELECT 
	CAST((CAST(uoc as float) / NULLIF(CAST(eftsload as float),0))
	as numeric(4,1)) as ratio, count(*)
FROM 
	Subjects
GROUP BY 
	ratio
HAVING 
	CAST((CAST(uoc as float) / NULLIF(CAST(eftsload as float),0)) 
	as numeric(4,1)) IS NOT NULL
;

/*

-- Q5: program enrolments from 10s1
create or replace view Q5a(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

create or replace view Q5b(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

create or replace view Q5c(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q6: course CodeName
create or replace function
	Q6(text) returns text
as
$$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language sql;



-- Q7: Percentage of growth of students enrolled in Database Systems
create or replace view Q7(year, term, perc_growth)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q8: Least popular subjects
create or replace view Q8(subject)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q9: Database Systems pass rate for both semester in each year
create or replace view Q9(year, s1_pass_rate, s2_pass_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



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
