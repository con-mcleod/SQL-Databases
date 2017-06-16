--
-- check.sql ... checking functions
--
--

--
-- Helper functions
--

create or replace function
	proj2_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj2_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj2_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj2_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj2_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj2_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj2_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj2_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj2_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj2_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
			   'from (('||_query||') except '||
			   '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
			    'from ((select * from '||_res||') '||
			    'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj2_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj2_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj2_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj2_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array[
				'q1', 'q2', 'q3'
				];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 2
--


create or replace function check_q1() returns text
as $chk$
select proj2_check('function','q1','q1_expected',
                   $$select * from q1('ECO%',  6)$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj2_check('function','q2','q2_expected',
                   $$select * from q2(2220747)$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj2_check('function','q3','q3_expected',
                   $$select * from q3(52,20,8)$$)
$chk$ language sql;

--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
	pattern_number integer, 
	uoc_number integer
);

drop table if exists q2_expected;
create table q2_expected (
    cid integer,
    term  char(4),
    code  char(8),
    name  text,
    uoc  integer,
    mark  integer,
    grade  char(2),
    rank  integer,
    totalEnrols  integer
);

drop table if exists q3_expected;
create table q3_expected (
    unswid integer, 
	staff_name text, 
	teaching_rechods text
);


COPY q1_expected (pattern_number, uoc_number) FROM stdin;
79	5
\.

COPY q2_expected (cid, term, code, name, uoc, mark, grade, rank, totalEnrols) FROM stdin;
6295	03s1	HIST5233	Mod China: History & Historiog	8	89	HD	1	1
14104	05s1	ARTS5024	Research Writing	6	72	CR	3	4
20053	06s1	HIST7012	Thesis Proposal P/T	12	\N	SY	\N	0
23640	06s2	HIST7050	MA Thesis P/T	0	\N	RC	\N	0
27396	07s1	HIST8302	Masters (Rsch) Part-Time	0	\N	NC	\N	0
\.

COPY q3_expected (unswid, staff_name, teaching_rechods) FROM stdin;
8254273	Chris Sorrell	MATS1464, 10, Materials Science & Engineering, School of\nMATS6605, 9, Materials Science & Engineering, School of\n
9282965	Chris Winder	SESC9810, 9, Risk & Safety Science, School of\nSESC9820, 9, Risk & Safety Science, School of\n
3053938	Susan Hagon	GENS4001, 9, Physics, School of\nPHYS5012, 9, Physics, School of\n
\.































