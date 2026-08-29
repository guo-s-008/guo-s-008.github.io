create database RFM_analysis;


use rfm_analysis;

create TABLE sales_2015(
nember_id varchar(20) ,
order_id varchar(20),
submit_date date,
order_amount decimal(18,2));

CREATE table sales_2016 like sales_2015;
CREATE table sales_2017 like sales_2015;
CREATE table sales_2018 like sales_2015;

create table member_level(
member_id varchar(20),
menber_level tinyint
);


SELECT '2015' AS year_name, COUNT(*) AS row_count FROM sales_2015
UNION ALL
SELECT '2016', COUNT(*) FROM sales_2016
UNION ALL
SELECT '2017', COUNT(*) FROM sales_2017
UNION ALL
SELECT '2018', COUNT(*) FROM sales_2018
UNION ALL
SELECT '会员等级', COUNT(*) FROM member_level;


select count(*) full_data,count(distinct order_id) distinct_data, count(*)-count(distinct order_id) over_data from sales_2015;



SELECT
    order_id,
    COUNT(*) AS occurrence_count
FROM sales_2015
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC
LIMIT 20;


SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN nember_id IS NULL THEN 1 ELSE 0 END) AS null_member_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN submit_date IS NULL THEN 1 ELSE 0 END) AS null_submit_date,
    SUM(CASE WHEN order_amount IS NULL THEN 1 ELSE 0 END) AS null_order_amount
    SUM(
        CASE
            WHEN nember_id IS NULL
             AND order_id IS NULL
             AND submit_date IS NULL
             AND order_amount IS NULL
            THEN 1
            ELSE 0
        END
    ) AS completely_blank_rows

FROM sales_2015;




delete from sales_2015
where nember_id is NULL
and order_id is NULL
and submit_date is NULL
and order_amount is NULL;




SELECT
    '2015' AS sales_year,
    COUNT(*) AS total_rows,  SUM(
        CASE WHEN nember_id IS NULL
              AND order_id IS NULL
              AND submit_date IS NULL
              AND order_amount IS NULL
             THEN 1 ELSE 0 END
    ) AS blank_rows
FROM sales_2015

UNION ALL

SELECT
    '2016',
    COUNT(*),SUM(
        CASE WHEN nember_id IS NULL
              AND order_id IS NULL
              AND submit_date IS NULL
              AND order_amount IS NULL
             THEN 1 ELSE 0 END
    )
FROM sales_2016

UNION ALL

SELECT
    '2017',
    COUNT(*),SUM(
        CASE WHEN nember_id IS NULL
              AND order_id IS NULL
              AND submit_date IS NULL
              AND order_amount IS NULL
             THEN 1 ELSE 0 END
    )
FROM sales_2017

UNION ALL

SELECT
    '2018',
    COUNT(*),SUM(
        CASE WHEN nember_id IS NULL
              AND order_id IS NULL
              AND submit_date IS NULL
              AND order_amount IS NULL
             THEN 1 ELSE 0 END
    )
FROM sales_2018;



DELETE FROM sales_2016
WHERE nember_id IS NULL
  AND order_id IS NULL
  AND submit_date IS NULL
  AND order_amount IS NULL;

DELETE FROM sales_2017
WHERE nember_id IS NULL
  AND order_id IS NULL
  AND submit_date IS NULL
  AND order_amount IS NULL;

DELETE FROM sales_2018
WHERE nember_id IS NULL
  AND order_id IS NULL
  AND submit_date IS NULL
  AND order_amount IS NULL;
	
	
	
	
	
	
create or replace view v_sales_all_improt as 

select 
	2015 as slaes_year,
	nember_id,
	order_id,
	submit_date,
	order_amount
	from sales_2015
union all 

select
 2016 as slaes_year,
	nember_id,
	order_id,
	submit_date,
	order_amount
	from sales_2016
union all  
	select
 2017 as slaes_year,
	nember_id,
	order_id,
	submit_date,
	order_amount
	from sales_2017
union all  
	select
 2018 as slaes_year,
	nember_id,
	order_id,
	submit_date,
	order_amount
	from sales_2018
  
-- 	查找每个年份的空数据行
select slaes_year, count(*), 
sum(case when nember_id is null and order_id is null and submit_date is null and order_amount is null 
 then 1
  else 0 end) null_date
  from v_sales_all_improt
  group by slaes_year
  order by slaes_year;
	
	
	
	
	drop table if exists sales_clean;
-- 	创建清洗初始表
	create table sales_clean AS
	select 
	slaes_year,
	trim(nember_id) nember_id,
	trim(order_id) order_id,
	submit_date,
	order_amount
	from v_sales_all_improt
	where nember_id is not null 
				and 
				trim(nember_id) <> '' 
				and
				order_id is not null 
				and 
				trim(order_id) <> '' 
				and
				submit_date is not null 
				and 
				order_amount is not null 
				and 
				order_amount >1;
	
	
	
DROP TABLE IF EXISTS rfm_base;
-- 创建RFM基础表
CREATE TABLE rfm_base AS
SELECT
    slaes_year AS year,
    nember_id,

-- datediff 函数，使用两个日期相减 
-- str_to_date 函数， 使得前者转化为后者的日期格式
-- concat 函数，使得两个参数进行拼接成字符串
-- 距离年底多少天-R
    DATEDIFF(
        STR_TO_DATE(
            CONCAT(slaes_year, '-12-31'),
            '%Y-%m-%d'
        ),
        MAX(submit_date)
    ) AS r,
-- 计算订单数据量-F
    COUNT(order_id) AS f,
	

-- round 函数进行数据内容的四舍五入，前者为格式化的额数据，后者为保留几位小数
-- 计算一共花销多少钱-M
    ROUND(SUM(order_amount), 2) AS m

FROM sales_clean
GROUP BY slaes_year, nember_id desc;



-- 检查RFM基础表
-- 每年有多少会员账户，多少订单量，合计多少消费额，最小的在线日期与最大在线日期
select 
year,count(*) nemder_count,
sum(f) order_count,
round(sum(m),2) sales_amount,
min(r) min_r,
max(r) max_r 
from rfm_base
group by year
order by year;

-- 进一步检查


SELECT
    MIN(r) AS min_r,
    MAX(r) AS max_r,
    MIN(f) AS min_f,
    MAX(f) AS max_f,
    MIN(m) AS min_m,
    MAX(m) AS max_m
FROM rfm_base;




-- RFM评分和分群

| 指标 | 分数规则 | 原因 |
|---|---|---|
| R | R≤79为3，R≤255为2，否则1 	| 越近购买越好 |
| F | F≤2为1，F≤5为2，否则3 		| 购买越频繁越好 |
| M | M≤69为1，M≤1199为2，否则3 | 消费越高越好 |



-- 先写子查询，得到数据，再查询，再where过滤，再group分组，再聚合，再having过滤，再order排序，再limit分页



DROP TABLE IF EXISTS rfm_score;

CREATE TABLE rfm_score AS
SELECT
    x.*,
    CONCAT(
        x.r_score,
        x.f_score,
        x.m_score
    ) AS rfm_group
FROM (
    SELECT
        year,
        nember_id,
        r,
        f,
        m,

        CASE
            WHEN r <= 79 THEN 3
            WHEN r <= 255 THEN 2
            ELSE 1
        END AS r_score,

        CASE
            WHEN f <= 2 THEN 1
            WHEN f <= 5 THEN 2
            ELSE 3
        END AS f_score,

        CASE
            WHEN m <= 69 THEN 1
            WHEN m <= 1199 THEN 2
            ELSE 3
        END AS m_score

    FROM rfm_base
) AS x;



-- 检查评分结果

select year, rfm_group, count(*) from rfm_score
group by year, rfm_group
order by year, count(*)desc ;



-- 检查会员等级表重复ID
-- trim 函数，去字符串掉收尾空格
-- <>表示不等于
-- '' 空字符
select
    member_id,
    count(*) as row_count
from member_level
where member_id is not null
  and trim(member_id) <> ''
group by member_id
having count(*) > 1
order by row_count desc
limit 20;



-- 简历规范会员等级表

drop table if exists member_level_clean;

create table member_level_clean as
select
    trim(member_id) as member_id,
    menber_level member_level
from member_level
where member_id is not null
  and trim(member_id) <> '';
	
-- 	建立唯一索引为member——id，报错这表示id不唯一上方检测错误
create unique index idx_member_level_id
on member_level_clean(member_id);





create or replace view v_rfm_detail as
select
    r.year,
    r.nember_id,

    coalesce(
        cast(m.member_level as char),
        '未登记'
    ) as member_level,

    r.r,
    r.f,
    r.m,
    r.r_score,
    r.f_score,
    r.m_score,
    r.rfm_group,

    case
        when r.rfm_group = '333'
            then '绝对忠诚高价值'

        when r.rfm_group in ('233', '223', '133')
            then '一般高价值'

        when r.rfm_group in ('313', '213', '322', '323', '332')
            then '潜力价值'

        when r.rfm_group in ('112', '113')
            then '可挽回用户'

        when r.rfm_group in ('212', '211', '311', '312')
            then '可发展用户'

        else '低价值或待观察'
    end as segment_name

from rfm_score as r

left join member_level_clean as m
    on r.nember_id = m.member_id;





-- 检查关联结果
select
    year,
    count(*) as total_members,
sum(
        case
            when member_level = '未登记' then 1
            else 0
        end
    ) as unregistered_members,

    round(
        sum(
            case
                when member_level = '未登记' then 1
                else 0
            end
        )
        /
        count(*) * 100,
        2
    ) as unregistered_rate

from v_rfm_detail
group by year
order by year;



-- 年度指标视图


create or replace view v_rfm_year_summary as
select
    year,
-- 会员人数
    count(*) as member_count,
-- 订单数
    sum(f) as order_count,
-- 平均订单金额
    round(sum(m), 2) as sales_amount,

    round(
        sum(m) / nullif(sum(f), 0),
        2
    ) as avg_order_amount,
-- 平均每个会员花费
    round(
-- 	nullif 函数判断两者是否相等，相等返回null不等返回前者
        sum(m) / nullif(count(*), 0),
        2
    ) as avg_member_amount,
-- 仅购买一次的用户
    sum(
        case
            when f = 1 then 1
            else 0
        end
    ) as single_member_count,
-- 多次购买的用户
    sum(
        case
            when f >= 2 then 1
            else 0
        end
    ) as repeat_member_count,
-- 多次购买用户占比
    round(
        sum(
            case
                when f >= 2 then 1
                else 0
            end
        )
        /
        nullif(count(*), 0) * 100,
        2
    ) as repeat_member_rate

from v_rfm_detail
group by year;



-- 分群指标图

create or replace view v_rfm_group_summary as
select
    year,
    rfm_group,
    segment_name,

    count(*) as member_count,

    sum(f) as order_count,

    round(sum(m), 2) as sales_amount,

    round(
        sum(m) / nullif(sum(f), 0),
        2
    ) as avg_order_amount,

    round(
        sum(m) / nullif(count(*), 0),
        2
    ) as avg_member_amount

from v_rfm_detail

group by
    year,
    rfm_group,
    segment_name;
		
		
-- 检查分群人数		
select * from v_rfm_group_summary
order by year, member_count desc;







-- 创建分群排名视图

create or replace view v_rfm_group_rank as
select
    year,
    rfm_group,
    segment_name,
    member_count,
    order_count,
    sales_amount,
-- 计算会员占比， partition by year表示按年份进行分组，nullif确保某年的某个分群可能没人得到空字段后，返回值为0
    round(
        member_count
        /
        nullif(
            sum(member_count) over (
                partition by year
            ),
            0
        )
        * 100,
        2
    ) as member_share,

    dense_rank() over (
        partition by year
        order by member_count desc
    ) as member_rank,

    dense_rank() over (
        partition by year
        order by sales_amount desc
    ) as sales_rank

from v_rfm_group_summary;




-- 计算年度增长


create or replace view v_rfm_year_lag as
select
    year,
    member_count,
    order_count,
    sales_amount,
-- lag函数 读取字段内容 over（order by year）决定上一行是哪一年
    lag(member_count) over (
        order by year
    ) as previous_member_count,

    lag(order_count) over (
        order by year
    ) as previous_order_count,

    lag(sales_amount) over (
        order by year
    ) as previous_sales_amount

from v_rfm_year_summary;




-- 计算增长率
create or replace view v_rfm_year_growth as
select
    year,
    member_count,
    previous_member_count,

    round(
        (
            member_count - previous_member_count
        )
        /
        nullif(previous_member_count, 0)
        * 100,
        2
    ) as member_growth_rate,

    order_count,
    previous_order_count,

    round(
        (
            order_count - previous_order_count
        )
        /
        nullif(previous_order_count, 0)
        * 100,
        2
    ) as order_growth_rate,

    sales_amount,
    previous_sales_amount,

    round(
        (
            sales_amount - previous_sales_amount
        )
        /
        nullif(previous_sales_amount, 0)
        * 100,
        2
    ) as sales_growth_rate

from v_rfm_year_lag;





-- 计算每年每个分群占每年总会员数的占比

select
    year,
    rfm_group,
    member_count,
    round(member_count/sum(member_count)over (
        partition by rfm_group
    ),2) as year_member_count
from v_rfm_group_summary;








show full tables where table_type='view';

select * from v_rfm_year_summary
limit 10;




create or replace view v_rfm_year_summary_bi as
select
    s.*,
    str_to_date(
        concat(cast(s.year as char), '-01-01'),
        '%Y-%m-%d'
    ) as year_date
from v_rfm_year_summary as s;




create or replace view v_rfm_group_summary_bi as
select
    s.*,
    str_to_date(
        concat(cast(s.year as char), '-01-01'),
        '%Y-%m-%d'
    ) as year_date,
    round(
        s.member_count * 1.0
        / nullif(
            sum(s.member_count) over (
                partition by s.year
            ),
            0
        ),
        4
    ) as year_member_share
from v_rfm_group_summary as s;






create or replace view v_rfm_detail_bi as
select
    d.*,
    str_to_date(
        concat(cast(d.year as char), '-01-01'),
        '%Y-%m-%d'
    ) as year_date,
    coalesce(d.member_level, '未登记') as member_level_display
from v_rfm_detail as d;