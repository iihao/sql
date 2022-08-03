with LDLF AS(
select 
 ldlf.GroupGUID,GETDATE() AS 当前时间,
 ldlf.BUGUID,mu.buname,
	 p.ProjName,p.p_projectId as ProjGUID
	 ,p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName,
sum(case when wd='brld' and CstTel_idx=1 then 1 else 0 end  ) AS '本日来电',
sum(case when wd='byld' and CstTel_idx=1 then 1 else 0 end  ) AS '本月来电',
sum(case when wd='bnld' and CstTel_idx=1 then 1 else 0 end  ) AS '本年来电',
sum(case when wd='ljld' and CstTel_idx=1 then 1 else 0 end  ) AS '累计来电',
sum(case when wd='brlf' and CstTel_idx=1 then 1 else 0 end  ) AS '本日来访',
sum(case when wd='ljlf' and CstTel_idx=2 and DATEDIFF(D,GjDate,GETDATE())=0  then 1 else 0 end  ) AS '本日老客来访',
sum(case when wd='brlf' and CstTel_idx=1 then 1 else 0 end  )-sum(case when wd='ljlf' and CstTel_idx=2 and DATEDIFF(D,GjDate,GETDATE())=0  then 1 else 0 end  ) AS '本日新客来访',
sum(case when wd='bylf' and CstTel_idx=1 then 1 else 0 end  ) AS '本月来访',
sum(case when wd='ljlf' and CstTel_idx=1 and Year(GjDate)=Year(GETDATE()) and Month(GjDate)=Month(GETDATE())  then 1 else 0 end  ) AS '本月新客来访',
sum(case when wd='ljlf' and CstTel_idx=2 and Year(GjDate)=Year(GETDATE()) and Month(GjDate)=Month(GETDATE())  then 1 else 0 end  ) AS '本月老客来访',
sum(case when wd='bnlf' and CstTel_idx=1 then 1 else 0 end  ) AS '本年来访',
sum(case when wd='ljlf' and CstTel_idx=1 and Month(GjDate)=Month(GETDATE())  then 1 else 0 end  ) AS '本年新客来访',
sum(case when wd='ljlf' and CstTel_idx=2 and Month(GjDate)=Month(GETDATE())  then 1 else 0 end  ) AS '本年老客来访',
sum(case when wd='ljlf' and CstTel_idx=1 then 1 else 0 end  ) AS '累计来访'
from (select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'brld' as wd
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx
	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where  DATEDIFF(D,GjDate,GETDATE())=0 and gjfs= '客户来电' 
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'byld'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx
	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where Year(GjDate)=Year(GETDATE()) and Month(GjDate)=Month(GETDATE()) and gjfs= '客户来电' 
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'bnld'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx
	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where Year(GjDate)=Year(GETDATE())  and gjfs ='客户来电'
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'ljld'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where  gjfs= '客户来电'	
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'brlf'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where  DATEDIFF(D,GjDate,GETDATE())=0 and gjfs= '现场接待'
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'bylf'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where Year(GjDate)=Year(GETDATE()) and Month(GjDate)=Month(GETDATE()) and gjfs= '现场接待' 
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'bnlf'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where Year(GjDate)=Year(GETDATE())  and gjfs= '现场接待'
union all
select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,o.BUGUID,o.ProjGUID,o.OppGUID,gjfs,GjDate,o.CstAllTel,'ljlf'
	,row_number() over (partition by o.CstAllTel  order by o.CstAllTel) as CstTel_idx
	,row_number() over (partition by o.OppGUID  order by o.OppGUID) as GUID_idx	from  s_Opportunity o 
	inner join  s_OppGjRecord c on c.OppGUID=o.OppGUID 
	where  gjfs= '现场接待'

	)ldlf
left join  myBusinessUnit mu on ldlf.BUGUID=mu.BUGUID
inner join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project)
p on ldlf.ProjGUID=p.p_projectId
left join p_project p1 on p.NewParentCode = p1.ProjCode
where    p1.p_projectId IS NOT NULL 
group by
	ldlf.GroupGUID,ldlf.BUGUID,mu.BUName,p.ProjName,p.p_projectId,p1.p_projectId ,p1.ProjName 
	),