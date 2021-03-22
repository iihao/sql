select p1.ProjName as ParentProjName,o.CstAllName,o.CstAllTel,FirstGjDate,Gfyt,Gfyx,Homearea,MainMediaName,OppSource,Remarks,Status,StatusReason,Zygw
from  s_Opportunity o 
left join  myBusinessUnit mu on o.BUGUID=mu.BUGUID
inner join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project)
 p on o.ProjGUID=p.p_projectId
left join p_project p1 on p.NewParentCode = p1.ProjCode
where  p1.ProjName='南崇·和悦城' and datediff(day,o.CreatedTime,getdate())=1S

getdate()


select 
call_cst_count as 本日来电客户数,
visit_cst_count as 本日来访客户数,* 
from fdt_pj_ydxs_cst 
where dim_name='南崇•和悦城' 
and dim_date_type='day'
order by modified_on_odps desc

select 
sum(1) as 本日来访
from fdw_standard_gjjl_detail_realtime
where TO_DAYS(gj_date)=TO_DAYS(now())
and proj_name='南崇•和悦城' 
and is_effective_type='是' 
and gjfs_text='来访'
and gj_from='来访登记'
and is_deleted=0

select 
sum(1) as 累计来访,
sum(case when t.ljlf=1 then 1 else 0 end) 累积新客来访 ，
sum(case when t.ljlf>1 then 1 else 0 end) 累积老客来访 
from
(
select 
sum(1) as ljlf
from fdw_standard_gjjl_detail_realtime
where  
proj_name='南崇•和悦城' 
and is_effective_type='是' 
and gjfs_text='来访'
and gj_from<>'交易反补'
and is_deleted=0
group by cst_id
)t


select 
sum(1) as 累积来访
from fdw_standard_gjjl_detail_realtime
where  
proj_name='南崇•和悦城' 
and is_effective_type='是' 
and gjfs_text='来访'
and gj_from<>'系统反补'
and is_deleted=0
