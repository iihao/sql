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
	
	RG AS(select 
		rg.GroupGUID,
		rg.BUGUID,rg.BUName,
		rg.ProjName,rg.ProjGUID,
		rg.ParentProjGUID,rg.ParentProjName,
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then 1 else 0 end)) as  '本日认购套数',
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then rg.BldArea else 0 end)) as  '本日认购面积',
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then rg.CjrmbTotal else 0 end))/10000 as  '本日认购金额',
	
		SUM((case when (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then 1 else 0 end)) as  '本月认购套数',
		SUM((case when (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then rg.BldArea else 0 end)) as  '本月认购面积',
		SUM((case when  (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then rg.CjrmbTotal else 0 end))/10000 as  '本月认购金额',
	
		SUM((case when Year(rg.qsdate)=Year(GETDATE())  then 1 else 0 end)) as  '本年认购套数',
		SUM((case when   Year(rg.qsdate)=Year(GETDATE()) then rg.BldArea else 0 end)) as  '本年认购面积',
		SUM((case when    Year(rg.qsdate)=Year(GETDATE()) then rg.CjrmbTotal else 0 end))/10000 as  '本年认购金额',
	
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then 1 else 0 end)) as  '本周认购套数',
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then rg.BldArea else 0 end)) as  '本周认购面积',
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then rg.CjrmbTotal else 0 end))/10000 as  '本周认购金额',
	
		SUM(1) as  '累计认购套数',
		SUM( rg.BldArea ) as  '累计认购面积',
		SUM( rg.CjrmbTotal )/10000 as  '累计认购金额'
	from 
		(
		select '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23' as GroupGUID,mu.BUGUID,p.ProjName ,mu.BUName,o.BldArea AS BldArea,o.CjRmbTotal AS CjrmbTotal,o.QSDate AS qsdate,
			p.p_projectId as ProjGUID,p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName
		from s_order o left join s_Trade t on o.TradeGUID=t.TradeGUID 
			left join  myBusinessUnit mu on t.BUGUID=mu.BUGUID
			inner join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project) p on t.ProjGUID=p.p_projectId
			left join p_project p1 on p.NewParentCode = p1.ProjCode
		where (O.Status='激活')  and  p1.p_projectId IS NOT NULL
		union all
		select  '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23'  as GroupGUID,mu.BUGUID,p.ProjName ,mu.BUName,c.BldArea,c.CjRmbTotal,isnull(t.RGOrderQsDate,C.QsDate),
			p.p_projectId as ProjGUID,p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName
		from  s_Contract c left join s_Trade t on c.TradeGUID=t.TradeGUID 
			left join  myBusinessUnit mu on t.BUGUID=mu.BUGUID
			inner join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project) p on t.ProjGUID=p.p_projectId
			left join p_project p1 on p.NewParentCode = p1.ProjCode
		where C.Status='激活' and   p1.p_projectId IS NOT NULL
		)rg
	group by
		rg.GroupGUID,rg.BUGUID,rg.BUName,rg.ProjName,rg.ProjGUID,rg.ParentProjGUID,rg.ParentProjName
	),
	
	QY AS (
	select 
		rg.GroupGUID,
		rg.BUGUID,rg.BUName,
		rg.ProjName,rg.ProjGUID,
		rg.ParentProjGUID,rg.ParentProjName,
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then 1 else 0 end)) as  '本日签约套数',
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then rg.BldArea else 0 end)) as  '本日签约面积',
		SUM((case when  DATEDIFF(D,rg.qsdate,GETDATE())=0 then rg.CjrmbTotal else 0 end))/10000 as  '本日签约金额',
	
		SUM((case when (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then 1 else 0 end)) as  '本月签约套数',
		SUM((case when (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then rg.BldArea else 0 end)) as  '本月签约面积',
		SUM((case when  (Year(rg.qsdate)=Year(GETDATE()) and Month(rg.qsdate)=Month(GETDATE())) then rg.CjrmbTotal else 0 end))/10000 as  '本月签约金额',
	
		SUM((case when Year(rg.qsdate)=Year(GETDATE())  then 1 else 0 end)) as  '本年签约套数',
		SUM((case when   Year(rg.qsdate)=Year(GETDATE()) then rg.BldArea else 0 end)) as  '本年签约面积',
		SUM((case when    Year(rg.qsdate)=Year(GETDATE()) then rg.CjrmbTotal else 0 end))/10000 as  '本年签约金额',
	
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then 1 else 0 end)) as  '本周签约套数',
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then rg.BldArea else 0 end)) as  '本周签约面积',
		SUM((case when  DATEDIFF(week,rg.qsdate,GETDATE())=0 then rg.CjrmbTotal else 0 end))/10000 as  '本周签约金额',
	
		SUM( 1 ) as  '累计签约套数',
		SUM(rg.BldArea ) as  '累计签约面积',
		SUM(rg.CjrmbTotal )/10000 as  '累计签约金额'
	from 
		(
		select  '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23'  as GroupGUID,mu.BUGUID,p.ProjName ,mu.BUName,c.BldArea AS BldArea,c.CjRmbTotal AS CjrmbTotal,C.QsDate AS qsdate,
		p.p_projectId as ProjGUID,p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName
					from  s_Contract c left join s_Trade t on c.TradeGUID=t.TradeGUID
					left join  myBusinessUnit mu on t.BUGUID=mu.BUGUID
					inner join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project) p on t.ProjGUID=p.p_projectId
					left join p_project p1 on p.NewParentCode = p1.ProjCode
					where C.Status='激活' and   p1.p_projectId IS NOT NULL
		)rg
	group by
		rg.GroupGUID,rg.BUGUID,rg.BUName,rg.ProjName,rg.ProjGUID,rg.ParentProjGUID,rg.ParentProjName
		),
	
	HK AS (select 
	hk.GroupGUID,
	hk.BUGUID,hk.BUName,
	hk.ProjName,hk.ProjGUID,
	hk.ParentProjGUID,hk.ParentProjName,
	sum(isnull((case when   hk.ItemType='贷款类房款' and hk.ItemName='银行按揭' and DATEDIFF(D,hk.GetDate,GETDATE())=0 then 1 else 0 end),0)) as '本日银行按揭套数',
	sum((case when   hk.ItemType='贷款类房款' and hk.ItemName='公积金' and DATEDIFF(D,hk.GetDate,GETDATE())=0 then 1 else 0 end)) as '本日公积金套数',
	sum(isnull((case when  DATEDIFF(D,hk.GetDate,GETDATE())=0 and hk.ItemType='贷款类房款' then isnull(Amount,0) else 0 end),0))/10000 as '本日贷款类收款',
	sum((case when  DATEDIFF(D,hk.GetDate,GETDATE())=0 and hk.ItemType='非贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '本日非贷款类收款',
	sum((case when  DATEDIFF(D,hk.GetDate,GETDATE())=0 then isnull(Amount,0) else 0 end))/10000 as '本日收款',
	sum((case when  DATEDIFF(week,hk.GetDate,GETDATE())=0 then isnull(Amount,0) else 0 end))/10000 as '本周收款',
	
	sum((case when   hk.ItemType='贷款类房款' and hk.ItemName='银行按揭' and (Year(hk.GetDate)=Year(GETDATE()) and Month(hk.GetDate)=Month(GETDATE())) then 1 else 0 end)) as '本月银行按揭套数',
	sum((case when   hk.ItemType='贷款类房款' and hk.ItemName='公积金' and (Year(hk.GetDate)=Year(GETDATE()) and Month(hk.GetDate)=Month(GETDATE())) then 1 else 0 end)) as '本月公积金套数',
	sum((case when  (Year(hk.GetDate)=Year(GETDATE()) and Month(hk.GetDate)=Month(GETDATE())) and hk.ItemType='贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '本月贷款类收款',
	sum((case when  (Year(hk.GetDate)=Year(GETDATE()) and Month(hk.GetDate)=Month(GETDATE())) and hk.ItemType='非贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '本月非贷款类收款',
	sum((case when (Year(hk.GetDate)=Year(GETDATE()) and Month(hk.GetDate)=Month(GETDATE())) then  isnull(Amount,0) else 0 end))/10000 as '本月收款',
	
	sum((case when  (Year(hk.GetDate)=Year(GETDATE()) ) and hk.ItemType='贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '本年贷款类收款',
	sum((case when  (Year(hk.GetDate)=Year(GETDATE()) ) and hk.ItemType='非贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '本年非贷款类收款',
	sum((case when Year(hk.GetDate)=Year(GETDATE())  then isnull(Amount,0) else 0 end))/10000 as '本年收款',
	
	sum((case when   hk.ItemType='贷款类房款' and hk.ItemName='银行按揭' then 1 else 0 end)) as '银行按揭套数',
	sum((case when   hk.ItemType='贷款类房款' and hk.ItemName='公积金' then 1 else 0 end)) as '公积金套数',
	sum((case when   hk.ItemType='贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '累计贷款类收款',
	sum((case when   hk.ItemType='非贷款类房款' then isnull(Amount,0) else 0 end))/10000 as '累计非贷款类收款',
	sum(isnull(Amount,0))/10000 as '累计收款金额' from
	(
	select  '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23'  as GroupGUID,mu.BUGUID,p.ProjName ,mu.BUName,sg.ItemName,sg.ItemType,sg.Amount,sg.GetDate,
	p.p_projectId as ProjGUID,p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName
	from vs_Voucher2GetinDetail_rpt  sg
	left join  myBusinessUnit mu on sg.BUGUID=mu.BUGUID
	left join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project)
	 p on sg.ProjGUID=p.p_projectId
	left join  p_project p1 
	on p.NewParentCode = p1.ProjCode
	left join  s_trade st on sg.saleguid=st.tradeguid
	
	left join s_voucher v on v.vouchguid=sg.vouchguid
	where sg.ItemType in ('非贷款类房款','贷款类房款')  
	 and sg.saleguid is not null and ISNULL(v.vouchstatus,'')<>'作废' 
	and p1.p_projectId IS NOT NULL) hk
	group by hk.GroupGUID,hk.BUGUID,hk.BUName,hk.ProjName,hk.ProjGUID,hk.ParentProjGUID,hk.ParentProjName
	),
	
	TDTF AS (
	select 
	'11B11DB4-E907-4F1F-8835-B9DAAB6E1F23'  as GroupGUID,
	mu.BUGUID,mu.BUName,
	p.p_projectId as ProjGUID,p.ProjName,
	p1.p_projectId as ParentProjGUID,p1.ProjName as ParentProjName,
	SUM(case when DATEDIFF(D,O.CloseDate,GETDATE())=0 and O.CloseReason='退房' then 1 else 0 end ) AS [本日认购退房套数],
	SUM(case when DATEDIFF(D,C.CloseDate,GETDATE())=0 and C.CloseReason='退房' then 1 else 0 end ) AS [本日签约退房套数],
	SUM(case when (DATEDIFF(D,O.CloseDate,GETDATE())=0 and O.CloseReason='退房') or (DATEDIFF(D,C.CloseDate,GETDATE())=0 and C.CloseReason='退房') 
	then 1 else 0 end ) AS [本日总退房套数],
	SUM(CASE WHEN O.CloseReason='退房' THEN 1 ELSE 0 END) AS [认购退房套数],
	SUM(CASE WHEN C.CloseReason='退房' THEN 1 ELSE 0 END) AS [签约退房套数],
	SUM(CASE WHEN C.CloseReason='退房' OR O.CloseReason='退房' THEN 1 ELSE 0 END) AS [退房总套数]
	from s_Trade t
	left join s_Order o on t.TradeGUID=o.TradeGUID
	left join s_Contract c on t.TradeGUID=c.TradeGUID
	left join  myBusinessUnit mu on t.BUGUID=mu.BUGUID
	left join (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project) p on t.ProjGUID=p.p_projectId
	left join p_project p1 on p.NewParentCode = p1.ProjCode
	  where t.CloseReason='退房'  group by mu.BUGUID,mu.BUName,p.p_projectId,p.ProjName,p1.p_projectId,p1.ProjName
	
	)
	--分期维度（项目GUID）
	select LDLF.ProjGUID as buguid,LDLF.ProjGUID,LDLF.ProjName,GETDATE() AS 当前时间,
	isnull(LDLF.本日来电,0)as 本日来电,isnull(LDLF.本日来访,0)as 本日来访,
	isnull(ldlf.本日老客来访,0)as 本日老客来访,isnull(ldlf.本日新客来访,0)as 本日新客来访,
	isnull(ldlf.本月老客来访,0)as 本月老客来访,isnull(ldlf.本月新客来访,0)as 本月新客来访,
	isnull(LDLF.本月来电,0)as 本月来电,isnull(LDLF.本月来访,0)as 本月来访,
	isnull(LDLF.累计来电,0)as 累计来电, isnull(LDLF.累计来访,0)as 累计来访 ,
	
	isnull(rg.本日认购套数,0)as 本日认购套数,isnull(rg.本日认购面积,0)as 本日认购面积,isnull(rg.本日认购金额,0)as 本日认购金额,
	isnull(rg.本月认购套数,0)as 本月认购套数,isnull(rg.本月认购面积,0)as 本月认购面积,isnull(rg.本月认购金额,0)as 本月认购金额,
	isnull(rg.本年认购套数,0)as 本年认购套数,isnull(rg.本年认购面积,0)as 本年认购面积,isnull(rg.本年认购金额,0)as 本年认购金额,
	isnull(rg.累计认购套数,0)as 累计认购套数,isnull(rg.累计认购面积,0)as 累计认购面积,isnull(rg.累计认购金额,0)as 累计认购金额,
	
	isnull(QY.本日签约套数,0)as 本日签约套数,isnull(QY.本日签约面积,0)as 本日签约面积,isnull(QY.本日签约金额,0)as 本日签约金额,
	isnull(QY.本月签约套数,0)as 本月签约套数,isnull(QY.本月签约面积,0)as 本月签约面积,isnull(QY.本月签约金额,0)as 本月签约金额,
	isnull(QY.本年签约套数,0)as 本年签约套数,isnull(QY.本年签约面积,0)as 本年签约面积,isnull(QY.本年签约金额,0)as 本年签约金额,
	isnull(QY.累计签约套数,0)as 累计签约套数,isnull(QY.累计签约面积,0)as 累计签约面积,isnull(QY.累计签约金额,0)as 累计签约金额,
	isnull(RG.累计认购套数-QY.累计签约套数 ,0) as 累计认购未签约套数,
	isnull(RG.累计认购金额-QY.累计签约金额 ,0) AS 累计认购未签约金额,
	
	isnull(HK.本日贷款类收款,0)as 本日贷款类收款 ,isnull(HK.本日非贷款类收款,0)as 本日非贷款类收款,isnull(HK.本日收款,0)as 本日收款, 
	isnull(HK.本月贷款类收款,0)as 本月贷款类收款,isnull(HK.本月非贷款类收款,0)as 本月非贷款类收款,isnull(HK.本月收款,0)as 本月收款,
	isnull(HK.本年贷款类收款,0)as 本年贷款类收款,isnull(HK.本年非贷款类收款,0)as 本年非贷款类收款,isnull(HK.本年收款,0)as 本年收款,
	isnull(HK.累计贷款类收款,0)as 累计贷款类收款,isnull(HK.累计非贷款类收款,0)as 累计非贷款类收款,isnull(HK.累计收款金额,0)as 累计收款金额,
	
	isnull(TDTF.本日签约退房套数,0)as 本日签约退房套数,isnull(TDTF.本日认购退房套数,0)as 本日认购退房套数,isnull(TDTF.本日总退房套数,0)as 本日总退房套数,
	isnull(TDTF.签约退房套数,0)as 签约退房套数,isnull(TDTF.认购退房套数,0)as 认购退房套数,isnull(TDTF.退房总套数,0)as 退房总套数
	 from LDLF 
	left join RG on LDLF.ProjName=rg.ProjName
	left join QY on RG.ProjName=qy.ProjName
	left join HK on HK.ProjName=QY.ProjName
	left join TDTF on TDTF.ProjName=HK.ProjName
	union all
	--项目维度（父级项目GUID）
	select LDLF.ParentProjGUID as buguid,LDLF.ParentProjGUID,LDLF.ParentProjName,GETDATE() AS 当前时间,
	sum(LDLF.本日来电),sum(LDLF.本日来访),
	sum(ldlf.本日老客来访),sum(ldlf.本日新客来访),
	sum(ldlf.本月老客来访),sum(ldlf.本月新客来访),
	sum(LDLF.本月来电),sum(LDLF.本月来访),
	sum(LDLF.累计来电),sum(LDLF.累计来访),
	
	sum(rg.本日认购套数),sum(rg.本日认购面积),sum(rg.本日认购金额),
	sum(rg.本月认购套数),sum(rg.本月认购面积),sum(rg.本月认购金额),
	sum(rg.本年认购套数),sum(rg.本年认购面积),sum(rg.本年认购金额),
	sum(rg.累计认购套数),sum(rg.累计认购面积),sum(rg.累计认购金额),
	
	sum(QY.本日签约套数),sum(QY.本日签约面积),sum(QY.本日签约金额),
	sum(QY.本月签约套数),sum(QY.本月签约面积),sum(QY.本月签约金额),
	sum(QY.本年签约套数),sum(QY.本年签约面积),sum(QY.本年签约金额),
	sum(QY.累计签约套数),sum(QY.累计签约面积),sum(QY.累计签约金额),
	
	sum(RG.累计认购套数)-sum(QY.累计签约套数) AS 累计认购未签约套数,
	sum(RG.累计认购金额)-sum(QY.累计签约金额) AS 累计认购未签约金额,
	
	sum(HK.本日贷款类收款),sum(HK.本日非贷款类收款),sum(HK.本日收款), 
	sum(HK.本月贷款类收款),sum(HK.本月非贷款类收款),sum(HK.本月收款),
	sum(HK.本年贷款类收款),sum(HK.本年非贷款类收款),sum(HK.本年收款),
	sum(HK.累计贷款类收款),sum(HK.累计非贷款类收款),sum(HK.累计收款金额),
	
	sum(TDTF.本日签约退房套数),sum(TDTF.本日认购退房套数),sum(TDTF.本日总退房套数),
	sum(TDTF.签约退房套数),sum(TDTF.认购退房套数),sum(TDTF.退房总套数)
	from LDLF 
	left join RG on LDLF.ProjName=rg.ProjName
	left join QY on RG.ProjName=qy.ProjName
	left join HK on HK.ProjName=LDLF.ProjName
	left join TDTF on TDTF.ProjName=HK.ProjName group by ldlf.ParentProjGUID,ldlf.ParentProjName
	
	union all
	--公司维度
	select LDLF.BUGUID as buguid,LDLF.BUGUID as projguid,ldlf.BUName as buname,GETDATE() AS 当前时间,
	sum(LDLF.本日来电),sum(LDLF.本日来访),
	sum(ldlf.本日老客来访),sum(ldlf.本日新客来访),
	sum(ldlf.本月老客来访),sum(ldlf.本月新客来访),
	sum(LDLF.本月来电),sum(LDLF.本月来访),
	sum(LDLF.累计来电),sum(LDLF.累计来访),
	
	sum(rg.本日认购套数),sum(rg.本日认购面积),sum(rg.本日认购金额),
	sum(rg.本月认购套数),sum(rg.本月认购面积),sum(rg.本月认购金额),
	sum(rg.本年认购套数),sum(rg.本年认购面积),sum(rg.本年认购金额),
	sum(rg.累计认购套数),sum(rg.累计认购面积),sum(rg.累计认购金额),
	
	sum(QY.本日签约套数),sum(QY.本日签约面积),sum(QY.本日签约金额),
	sum(QY.本月签约套数),sum(QY.本月签约面积),sum(QY.本月签约金额),
	sum(QY.本年签约套数),sum(QY.本年签约面积),sum(QY.本年签约金额),
	sum(QY.累计签约套数),sum(QY.累计签约面积),sum(QY.累计签约金额),
	
	sum(RG.累计认购套数)-sum(QY.累计签约套数) AS 累计认购未签约套数,
	sum(RG.累计认购金额)-sum(QY.累计签约金额) AS 累计认购未签约金额,
	
	sum(HK.本日贷款类收款),sum(HK.本日非贷款类收款),sum(HK.本日收款), 
	sum(HK.本月贷款类收款),sum(HK.本月非贷款类收款),sum(HK.本月收款),
	sum(HK.本年贷款类收款),sum(HK.本年非贷款类收款),sum(HK.本年收款),
	sum(HK.累计贷款类收款),sum(HK.累计非贷款类收款),sum(HK.累计收款金额),
	
	sum(TDTF.本日签约退房套数),sum(TDTF.本日认购退房套数),sum(TDTF.本日总退房套数),
	sum(TDTF.签约退房套数),sum(TDTF.认购退房套数),sum(TDTF.退房总套数)
	 from LDLF 
	left join RG on LDLF.ProjName=rg.ProjName
	left join QY on RG.ProjName=qy.ProjName
	left join HK on HK.ProjName=QY.ProjName
	left join TDTF on TDTF.ProjName=HK.ProjName group by ldlf.BUGUID,ldlf.BUName
	
	union all
	--集团维度
	select LDLF.GroupGUID as buguid,LDLF.GroupGUID as projguid,'集团' as buname,GETDATE() AS 当前时间,
	sum(LDLF.本日来电),sum(LDLF.本日来访),
	sum(ldlf.本日老客来访),sum(ldlf.本日新客来访),
	sum(ldlf.本月老客来访),sum(ldlf.本月新客来访),
	sum(LDLF.本月来电),sum(LDLF.本月来访),
	sum(LDLF.累计来电),sum(LDLF.累计来访),
	
	sum(rg.本日认购套数),sum(rg.本日认购面积),sum(rg.本日认购金额),
	sum(rg.本月认购套数),sum(rg.本月认购面积),sum(rg.本月认购金额),
	sum(rg.本年认购套数),sum(rg.本年认购面积),sum(rg.本年认购金额),
	sum(rg.累计认购套数),sum(rg.累计认购面积),sum(rg.累计认购金额),
	
	sum(QY.本日签约套数),sum(QY.本日签约面积),sum(QY.本日签约金额),
	sum(QY.本月签约套数),sum(QY.本月签约面积),sum(QY.本月签约金额),
	sum(QY.本年签约套数),sum(QY.本年签约面积),sum(QY.本年签约金额),
	sum(QY.累计签约套数),sum(QY.累计签约面积),sum(QY.累计签约金额),
	
	sum(RG.累计认购套数)-sum(QY.累计签约套数) AS 累计认购未签约套数,
	sum(RG.累计认购金额)-sum(QY.累计签约金额) AS 累计认购未签约金额,
	
	sum(HK.本日贷款类收款),sum(HK.本日非贷款类收款),sum(HK.本日收款), 
	sum(HK.本月贷款类收款),sum(HK.本月非贷款类收款),sum(HK.本月收款),
	sum(HK.本年贷款类收款),sum(HK.本年非贷款类收款),sum(HK.本年收款),
	sum(HK.累计贷款类收款),sum(HK.累计非贷款类收款),sum(HK.累计收款金额),
	
	sum(TDTF.本日签约退房套数),sum(TDTF.本日认购退房套数),sum(TDTF.本日总退房套数),
	sum(TDTF.签约退房套数),sum(TDTF.认购退房套数),sum(TDTF.退房总套数)
	 from LDLF 
	left join RG on LDLF.ProjName=rg.ProjName
	left join QY on RG.ProjName=qy.ProjName
	left join HK on HK.ProjName=QY.ProjName
	left join TDTF on TDTF.ProjName=HK.ProjName group by ldlf.GroupGUID
	 