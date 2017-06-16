-- COMP3311 17s1 Project 2
--
-- Section 1 Template

--Q1: ...

-- table of all subjects with wrong EFTSL
-- e.g. select * from EFTSL
create or replace view EFTSL
as
select cast(uoc::decimal/48 as real) as EFTSL, name, code, uoc
from subjects
where eftsload <> (cast(subjects.uoc::decimal/48 as real))
order by code
;

-- table of subjects that have wrong EFTSL, same subject code as search, and 
-- uoc count greater than search
-- e.g. select * from Q1('ECO%', 6);
create or replace function Q1 (pattern text, uoc_threshold integer)
	returns table (pattern_number bigint, uoc_number bigint)
as $$
	select 
	(select count(*) from eftsl where eftsl.code like $1),
	(select count(*) from eftsl where eftsl.code like $1 and eftsl.uoc > $2)
	;
$$ language sql;


-- Q2: ...

-- table with results (sorry - it is a bit slow)
-- e.g. select * from Q2(2220747);
create or replace function Q2(stu_unswid integer)
	returns table (cid integer, term char(4), code char(8), name text, uoc integer, mark integer, grade char(2), rank bigint, totalEnrols bigint)
as $$

	select distinct c.id as cid, substr(sem.year::text,3,2)||lower(sem.term) as term, 
			sub.code as code, sub.name as Name,  sub.uoc, c_e.mark, c_e.grade,
			ranker(sub.code,substr(sem.year::text,3,2)||lower(sem.term), p.unswid) as rank, 
			totalEnrols(sub.code,substr(sem.year::text,3,2)||lower(sem.term)) as totalEnrols
	from People p
		join Students stu on (p.id = stu.id)
		join Course_enrolments c_e on (c_e.student = stu.id)
		join Courses c on (c.id = c_e.course)
		join Subjects sub on (c.subject = sub.id)
		join Semesters sem on (c.semester = sem.id)
		join Program_enrolments pge on (pge.student = p.id)
		join Programs prog on (prog.id = pge.program)
	where p.unswid = $1
	order by term
	;
$$ language sql;

-- function to return listed rankings of each student in a subject and semester
-- e.g. select * from rank('ARTS5024', '05s1', 2220747);
create or replace function ranker(subjCode varchar, yearSem char(4), stu_unswid integer)
	returns table (rank bigint)
as $$
	select rank 
	from (
		select sub.code as code, substr(sem.year::text,3,2)||lower(sem.term) as yearSem,
			sub.name as name, c_e.mark as mark, rank() over (order by mark), p.unswid as stu_unswid
		from people p
			join students stu on (p.id = stu.id)
			join Course_enrolments c_e on (c_e.student = stu.id)
			join courses c on (c.id = c_e.course)
			join Semesters sem on (c.semester = sem.id)
			join subjects sub on (c.subject = sub.id)
		where code like $1
			and yearSem = $2
		) as A

	where stu_unswid = $3
	
	;
$$ language sql;

-- function to return total number of enrols in a subject and semester
-- e.g. select * from totalEnrols('ARTS5024', '05s1');
create or replace function totalEnrols(subjCode varchar, yearSem char(4))
	returns table (totalEnrols bigint)
as $$
	select count(*)
	from (select sub.code as code, substr(sem.year::text,3,2)||lower(sem.term) as yearSem, sub.name as name
		from people p
			join students stu on (p.id = stu.id)
			join Course_enrolments c_e on (c_e.student = stu.id)
			join courses c on (c.id = c_e.course)
			join Semesters sem on (c.semester = sem.id)
			join subjects sub on (c.subject = sub.id)
		where code like $1
			and yearSem = $2
		) as A
	where yearSem = $2
	;
$$ language sql;

-- I DID NOT HAVE TIME TO TRY Q3 

/*
-- Q3: ...
create type TeachingRecord as (unswid integer, staff_name text, teaching_records text);

create or replace function Q3(org_id integer, num_sub integer, num_times integer) 
	returns setof TeachingRecord 
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;
*/
