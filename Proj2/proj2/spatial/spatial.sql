-- COMP3311 17s1 Project 2
--
-- Section 2 Template

--------------------------------------------------------------------------------
-- Q4
--------------------------------------------------------------------------------

drop function if exists skyline_naive(text) cascade;

-- This function calculates skyline in O(n^2)
drop function skyline_naive(text) cascade;
create or replace function skyline_naive(dataset text)
	returns table (x integer, y integer) 
as $$
BEGIN
	EXECUTE
		'create or replace view ' || $1 || '_skyline_naive(x,y) as 
			select f.x as x, f.y as y
			from ' || $1 || ' f
			except
				select a.x, a.y
				from ' || $1 || ' a, ' || $1 || ' b
				where (a.x <= b.x and a.y < b.y) or (a.x < b.x and a.y <= b.y)
			order by x
			;'
	RETURN;
END
$$ language plpgsql;



--------------------------------------------------------------------------------
-- Q5
--------------------------------------------------------------------------------

drop function if exists skyline(text) cascade;

-- SORRY FOR THE HACKINESS
create or replace function skyline(dataset text) 
    returns table (x integer, y integer)
as $$
BEGIN
	EXECUTE
		'create or replace view ' || $1 || '_skyline(x,y) as 
		select distinct a.x as x, max(a.y) as y
		from 
			(
			select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
			from 
			(
				select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
				from 
				(
					select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
					from 
					(
						select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
						from 
						(
							select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
							from 
							(
								select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
								from 
								(
									select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
									from 
									(
										select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
										from 
										(
											select distinct a.x as x, max(a.y) as y, lag(a.x, 1, 0) over (order by a.y desc) as lagx
											from 
												(
												select a.y as y, a.x as x, lag(a.x, 1, 0) over (order by a.y desc) as lagx
												from 
													(select a.y as y, a.x as x
													from ' || $1 || ' a
													order by a.y desc, a.x desc) as a
												group by a.y, a.x
												order by a.y desc, a.x desc
												) as a
											where a.x > a.lagx
											group by a.y, a.x
											order by a.x
											) as a
										where a.x > a.lagx
										group by a.y, a.x
										order by a.x
										) as a
									where a.x > a.lagx
									group by a.y, a.x
									order by a.x
									) as a
								where a.x > a.lagx
								group by a.y, a.x
								order by a.x
								) as a
							where a.x > a.lagx
							group by a.y, a.x
							order by a.x
							) as a
						where a.x > a.lagx
						group by a.y, a.x
						order by a.x
						) as a
					where a.x > a.lagx
					group by a.y, a.x
					order by a.x
					) as a
				where a.x > a.lagx
				group by a.y, a.x
				order by a.x
				) as a
			where a.x > a.lagx
			group by a.y, a.x
			order by a.x
			) as a
		where a.x > a.lagx
		group by a.x
		order by a.x';
	RETURN;
END
$$ language plpgsql;


--------------------------------------------------------------------------------
-- Q6
--------------------------------------------------------------------------------

drop function if exists skyband_naive(text) cascade;

-- This function calculates skyband in O(n^2)

create or replace function skyband_naive(dataset text, k integer) 
    returns table (x integer, y integer)
as $$
BEGIN
	EXECUTE
		'create or replace view ' || $1 || '_skyband_naive(x,y) as 
			(select a.x, a.y
			from (
				select b.x, b.y, count(b.x) as counter
				from ' || $1 || ' a, ' || $1 || ' b
				where (a.x >= b.x and a.y > b.y) or (a.x > b.x and a.y >= b.y)
				group by b.x, b.y
				order by b.x
				) a
			where a.counter < ' || $2 || '
			)
			UNION
			(select f.x as x, f.y as y
			from ' || $1 || ' f
			except
				select a.x, a.y
				from ' || $1 || ' a, ' || $1 || ' b
				where (a.x <= b.x and a.y < b.y) or (a.x < b.x and a.y <= b.y)
			order by x
			)
		;'
	RETURN;
END
$$ language plpgsql;

--------------------------------------------------------------------------------
-- Q7
--------------------------------------------------------------------------------

drop function if exists skyband(text, integer) cascade;

-- This function simply creates a view to store skyband
create or replace function skyband(dataset text, k integer) 
    returns table (x integer, y integer)
as $$
BEGIN
	EXECUTE
		'create or replace view ' || $1 || '_skyband(x,y) as 
			select * from skyband_naive(''' || $1 || ''', ' || $2 || ')
		;'
	RETURN;
END
$$ language plpgsql;


create or replace view lagged_set
as
select a.y as y, a.x as x, lag(a.x, 1, 0) over (order by a.y desc) as lagx
from 
	(select a.y as y, a.x as x
	from small a
	order by a.y desc, a.x desc) as a
group by a.y, a.x
order by a.y desc, a.x desc

;
