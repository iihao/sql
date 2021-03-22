
select t.proj_name,
sum(case when t.brlf<>0 then 1 else 0 end) 本日来访,
sum(case when t.bzlf<>0 then 1 else 0 end) 本周来访,
sum(case when t.bylf<>0 then 1 else 0 end) 本月来访,
sum(case when t.ljlf<>0 then 1 else 0 end) 累积来访,

sum(case when t.brld<>0 then 1 else 0 end) 本日来电,
sum(case when t.bzld<>0 then 1 else 0 end) 本周来电,
sum(case when t.byld<>0 then 1 else 0 end) 本月来电,
sum(case when t.ljld<>0 then 1 else 0 end) 累积来电

from
(
select proj_name,
sum(case when TO_DAYS(gj_date)=TO_DAYS(now()) and gjfs_text='来访' then 1 else 0 end) as brlf,
sum(case when YEARWEEK(DATE_FORMAT(gj_date,'%Y-%m-%d'),1) = YEARWEEK(NOW(),1) and gjfs_text='来访' then 1 else 0 end) as bzlf,
sum(case when DATE_FORMAT(gj_date,'%Y%m') = DATE_FORMAT(CURDATE(),'%Y%m') and gjfs_text='来访' then 1 else 0 end) as bylf,
sum(case when gjfs_text='来访' then 1 else 0 end) as ljlf,

sum(case when TO_DAYS(gj_date)=TO_DAYS(now()) and gjfs_text='来电' then 1 else 0 end) as brld,
sum(case when YEARWEEK(DATE_FORMAT(gj_date,'%Y-%m-%d'),1) = YEARWEEK(NOW(),1) and gjfs_text='来电' then 1 else 0 end) as bzld,
sum(case when DATE_FORMAT(gj_date,'%Y%m') = DATE_FORMAT(CURDATE(),'%Y%m') and gjfs_text='来电' then 1 else 0 end) as byld,
sum(case when gjfs_text='来电' then 1 else 0 end) as ljld

from fdw_standard_gjjl_detail_realtime
where  
is_effective_type='是' 
and gj_from<>'交易反补'
and is_deleted=0
group by cst_id,proj_name
)t
group by t.proj_name

union all 


select '集团',
sum(case when t.brlf<>0 then 1 else 0 end) 本日来访,
sum(case when t.bzlf<>0 then 1 else 0 end) 本周来访,
sum(case when t.bylf<>0 then 1 else 0 end) 本月来访,
sum(case when t.ljlf<>0 then 1 else 0 end) 累积来访,

sum(case when t.brld<>0 then 1 else 0 end) 本日来电,
sum(case when t.bzld<>0 then 1 else 0 end) 本周来电,
sum(case when t.byld<>0 then 1 else 0 end) 本月来电,
sum(case when t.ljld<>0 then 1 else 0 end) 累积来电

from
(
select proj_name,
sum(case when TO_DAYS(gj_date)=TO_DAYS(now()) and gjfs_text='来访' then 1 else 0 end) as brlf,
sum(case when YEARWEEK(DATE_FORMAT(gj_date,'%Y-%m-%d'),1) = YEARWEEK(NOW(),1) and gjfs_text='来访' then 1 else 0 end) as bzlf,
sum(case when DATE_FORMAT(gj_date,'%Y%m') = DATE_FORMAT(CURDATE(),'%Y%m') and gjfs_text='来访' then 1 else 0 end) as bylf,
sum(case when gjfs_text='来访' then 1 else 0 end) as ljlf,

sum(case when TO_DAYS(gj_date)=TO_DAYS(now()) and gjfs_text='来电' then 1 else 0 end) as brld,
sum(case when YEARWEEK(DATE_FORMAT(gj_date,'%Y-%m-%d'),1) = YEARWEEK(NOW(),1) and gjfs_text='来电' then 1 else 0 end) as bzld,
sum(case when DATE_FORMAT(gj_date,'%Y%m') = DATE_FORMAT(CURDATE(),'%Y%m') and gjfs_text='来电' then 1 else 0 end) as byld,
sum(case when gjfs_text='来电' then 1 else 0 end) as ljld

from fdw_standard_gjjl_detail_realtime
where  
is_effective_type='是' 
and gj_from<>'交易反补'
and is_deleted=0
group by cst_id,proj_name
)t
