-- COMP3311 17s1 Project 2 Check
--
-- Section 2 Check

create or replace function
	proj2_function_exists(fname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=fname;
	return (_check > 0);
end;
$$ language plpgsql;

create or replace function
	proj2_view_exists(dataset text, fname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=dataset||'_'||fname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

drop type if exists TestingResult cascade;
create type TestingResult as (functions text, dataset text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	tableQ text;
	result text;
	out TestingResult;
	functions text[] := array['skyline_naive', 'skyline', 'skyband_naive', 'skyband'];
	datasets text[] := array['small', 'large'];
begin
	for i in array_lower(functions,1) .. array_upper(functions,1)
    loop
    	for j in array_lower(datasets,1) .. array_upper(datasets,1)
		loop
			result := check_res(functions[i], datasets[j]);
			out := (functions[i], datasets[j], result);
			return next out;
		end loop;
	end loop;
end;
$$ language plpgsql;

create or replace function
	check_res(functions text, dataset text) returns text
as $$
declare
    cnt_expected integer;
	cnt integer;
	cnt_extra integer;
	cnt_missing integer;
begin
    if (not proj2_function_exists(functions)) then
		return 'No '||functions||' function; did it load correctly?';
	end if;

    if (functions = 'skyband_naive' or functions = 'skyband') then
        execute 'select * from '||functions||'('''||dataset||''', 3)' into cnt;
    else
        execute 'select * from '||functions||'('''||dataset||''')' into cnt;
    end if;
	
	if (not proj2_view_exists(dataset, functions)) then
		return 'No '||dataset||'_'||functions||' view; did it load correctly?';
	end if;
	
	execute 'select count(*) from '||dataset||'_'||functions||'_expected' into cnt_expected;
	
	if (cnt < cnt_expected) then
	    return 'missing result tuples';
	elsif (cnt > cnt_expected) then
	    return 'extra result tuples';
	end if;
    
	execute 'select count(*) 
	         from( (select * from '||dataset||'_'||functions||'_expected)
                    except
                   (select * from '||dataset||'_'||functions||')
				 ) as A' into cnt_missing;
	execute 'select count(*) 
	         from( (select * from '||dataset||'_'||functions||')
                    except
                   (select * from '||dataset||'_'||functions||'_expected)
				 ) as A' into cnt_extra;
	
	if (cnt_missing > 0) then
	    return 'missing result tuples';
	elsif (cnt_extra > 0) then
	    return 'extra result tuples';
	else
	    return 'correct';
	end if;
end;
$$ language plpgsql;

--
-- Tables of expected results for test cases
--

drop table if exists small_skyline_naive_expected;
create table small_skyline_naive_expected (
     x integer,
     y integer
);

drop table if exists small_skyline_expected;
create table small_skyline_expected (
     x integer,
     y integer
);

drop table if exists small_skyband_naive_expected;
create table small_skyband_naive_expected (
     x integer,
     y integer
);

drop table if exists small_skyband_expected;
create table small_skyband_expected (
     x integer,
     y integer
);

drop table if exists large_skyline_naive_expected;
create table large_skyline_naive_expected (
     x integer,
     y integer
);

drop table if exists large_skyline_expected;
create table large_skyline_expected (
     x integer,
     y integer
);

drop table if exists large_skyband_naive_expected;
create table large_skyband_naive_expected (
     x integer,
     y integer
);

drop table if exists large_skyband_expected;
create table large_skyband_expected (
     x integer,
     y integer
);


COPY small_skyline_naive_expected (x, y) FROM stdin;
94	985
469	865
525	842
610	587
765	579
836	540
849	411
902	296
931	186
976	76
\.

COPY small_skyline_expected (x, y) FROM stdin;
94	985
469	865
525	842
610	587
765	579
836	540
849	411
902	296
931	186
976	76
\.

COPY small_skyband_naive_expected (x, y) FROM stdin;
73	940
94	985
115	864
366	862
448	837
469	865
507	826
525	842
610	587
711	511
765	579
790	335
836	540
849	411
869	237
894	122
902	296
931	186
976	76
\.

COPY small_skyband_expected (x, y) FROM stdin;
73	940
94	985
115	864
366	862
448	837
469	865
507	826
525	842
610	587
711	511
765	579
790	335
836	540
849	411
869	237
894	122
902	296
931	186
976	76
\.

COPY large_skyline_naive_expected (x, y) FROM stdin;
85	996
109	989
116	987
164	983
192	971
216	970
253	966
269	959
294	952
305	947
331	941
345	934
374	926
376	922
387	913
403	911
418	902
422	899
445	891
468	881
478	875
487	870
488	861
506	852
518	846
533	845
538	836
566	823
580	812
581	806
604	794
613	787
621	778
626	777
640	759
650	755
651	749
671	739
673	729
679	719
688	713
712	695
724	688
733	680
757	651
769	638
778	623
782	605
783	604
793	602
797	590
800	582
816	574
819	560
835	549
843	536
847	515
862	504
864	503
875	479
878	461
883	456
886	454
891	437
892	430
901	426
904	410
906	407
913	394
915	371
923	352
936	346
940	336
944	311
960	280
964	260
977	212
978	193
981	176
984	153
987	151
991	109
997	38
\.

COPY large_skyline_expected (x, y) FROM stdin;
85	996
109	989
116	987
164	983
192	971
216	970
253	966
269	959
294	952
305	947
331	941
345	934
374	926
376	922
387	913
403	911
418	902
422	899
445	891
468	881
478	875
487	870
488	861
506	852
518	846
533	845
538	836
566	823
580	812
581	806
604	794
613	787
621	778
626	777
640	759
650	755
651	749
671	739
673	729
679	719
688	713
712	695
724	688
733	680
757	651
769	638
778	623
782	605
783	604
793	602
797	590
800	582
816	574
819	560
835	549
843	536
847	515
862	504
864	503
875	479
878	461
883	456
886	454
891	437
892	430
901	426
904	410
906	407
913	394
915	371
923	352
936	346
940	336
944	311
960	280
964	260
977	212
978	193
981	176
984	153
987	151
991	109
997	38
\.

COPY large_skyband_naive_expected (x, y) FROM stdin;
8	994
38	993
85	996
94	986
100	985
109	989
116	987
133	980
143	974
146	974
164	983
192	971
216	970
225	962
229	962
233	959
253	966
269	959
288	942
294	952
305	947
315	940
324	929
331	941
337	924
345	934
366	922
374	926
374	917
376	922
387	913
403	911
413	901
415	895
418	902
420	890
422	899
429	888
437	886
445	891
468	881
473	864
478	875
482	863
487	870
488	861
493	848
495	846
506	852
518	846
533	845
536	826
538	836
539	818
544	817
566	823
566	813
579	804
580	812
581	806
604	794
612	780
613	787
621	778
626	777
626	770
629	753
640	759
644	749
650	755
651	749
655	737
662	735
671	739
673	729
673	717
679	719
680	706
683	699
688	713
691	695
712	695
719	688
724	688
725	677
733	680
744	640
757	651
757	637
762	624
769	638
775	608
776	607
776	606
778	623
782	605
783	604
793	602
794	587
796	580
797	590
800	582
812	558
816	574
819	560
820	542
823	547
827	539
830	528
835	549
841	522
842	515
843	536
847	515
856	493
862	504
864	503
873	469
875	479
878	461
880	448
883	456
884	445
886	454
891	437
891	434
892	430
899	408
901	426
904	410
906	407
911	367
913	394
915	371
918	351
923	352
923	343
934	327
936	346
937	326
939	314
940	336
943	289
944	311
946	273
953	266
958	261
960	280
962	229
962	228
964	260
975	204
976	202
977	212
978	193
981	176
982	148
984	153
986	120
987	151
989	106
989	86
991	109
991	5
995	2
997	38
\.

COPY large_skyband_expected (x, y) FROM stdin;
8	994
38	993
85	996
94	986
100	985
109	989
116	987
133	980
143	974
146	974
164	983
192	971
216	970
225	962
229	962
233	959
253	966
269	959
288	942
294	952
305	947
315	940
324	929
331	941
337	924
345	934
366	922
374	926
374	917
376	922
387	913
403	911
413	901
415	895
418	902
420	890
422	899
429	888
437	886
445	891
468	881
473	864
478	875
482	863
487	870
488	861
493	848
495	846
506	852
518	846
533	845
536	826
538	836
539	818
544	817
566	823
566	813
579	804
580	812
581	806
604	794
612	780
613	787
621	778
626	777
626	770
629	753
640	759
644	749
650	755
651	749
655	737
662	735
671	739
673	729
673	717
679	719
680	706
683	699
688	713
691	695
712	695
719	688
724	688
725	677
733	680
744	640
757	651
757	637
762	624
769	638
775	608
776	607
776	606
778	623
782	605
783	604
793	602
794	587
796	580
797	590
800	582
812	558
816	574
819	560
820	542
823	547
827	539
830	528
835	549
841	522
842	515
843	536
847	515
856	493
862	504
864	503
873	469
875	479
878	461
880	448
883	456
884	445
886	454
891	437
891	434
892	430
899	408
901	426
904	410
906	407
911	367
913	394
915	371
918	351
923	352
923	343
934	327
936	346
937	326
939	314
940	336
943	289
944	311
946	273
953	266
958	261
960	280
962	229
962	228
964	260
975	204
976	202
977	212
978	193
981	176
982	148
984	153
986	120
987	151
989	106
989	86
991	109
991	5
995	2
997	38
\.
