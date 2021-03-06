set hive.stats.column.autogather=false;
set hive.stats.dbclass=fs;
set hive.compute.query.using.stats=true;
set hive.explain.user=false;
create table over10k_n23(
           t tinyint,
           si smallint,
           i int,
           b bigint,
           f float,
           d double,
           bo boolean,
           s string,
           ts timestamp, 
           `dec` decimal,  
           bin binary)
       row format delimited
       fields terminated by '|'
       TBLPROPERTIES ("hive.serialization.decode.binary.as.base64"="false");

load data local inpath '../../data/files/over10k' into table over10k_n23;

create table stats_tbl_part_n0(
           t tinyint,
           si smallint,
           i int,
           b bigint,
           f float,
           d double,
           bo boolean,
           s string,
           ts timestamp, 
           `dec` decimal,  
           bin binary) partitioned by (dt int);


from over10k_n23 
insert overwrite table stats_tbl_part_n0 partition (dt=2010) select t,si,i,b,f,d,bo,s,ts,`dec`,bin where t>0 and t<30 
insert overwrite table stats_tbl_part_n0 partition (dt=2014) select t,si,i,b,f,d,bo,s,ts,`dec`,bin where t > 30 and t<60;

analyze table stats_tbl_part_n0 partition(dt) compute statistics;
analyze table stats_tbl_part_n0 partition(dt=2010) compute statistics for columns t,si,i,b,f,d,bo,s,bin;
analyze table stats_tbl_part_n0 partition(dt=2014) compute statistics for columns t,si,i,b,f,d,bo,s,bin;

explain 
select count(*), count(1), sum(1), count(s), count(bo), count(bin), count(si), max(i), min(b), max(f), min(d) from stats_tbl_part_n0 where dt = 2010;
select count(*), count(1), sum(1), count(s), count(bo), count(bin), count(si), max(i), min(b), max(f), min(d) from stats_tbl_part_n0 where dt = 2010;
explain 
select count(*), count(1), sum(1), sum(2), count(s), count(bo), count(bin), count(si), max(i), min(b), max(f), min(d) from stats_tbl_part_n0 where dt > 2010;
select count(*), count(1), sum(1), sum(2), count(s), count(bo), count(bin), count(si), max(i), min(b), max(f), min(d) from stats_tbl_part_n0 where dt > 2010;

select count(*) from stats_tbl_part_n0;
select count(*)/2 from stats_tbl_part_n0;
drop table stats_tbl_part_n0;
set hive.compute.query.using.stats=false;
