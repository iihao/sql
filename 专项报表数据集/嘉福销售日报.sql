with 
jh as (
	select 
		sum(case when ISNULL(OppSource,'')='来电' and datediff(d,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as brld,
		sum(case when ISNULL(OppSource,'')='来电' and datediff(d,'2000-1-3',CreatedTime)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then 1 else 0 end) as bzld,
		sum(case when ISNULL(OppSource,'')='来电' and datediff(m,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as byld,
		sum(case when ISNULL(OppSource,'')='来电' and datediff(yy,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as bnld,
		sum(case when ISNULL(OppSource,'')='来电' then 1 else 0 end) as ljld,
		----------------------------------------------------------------
		sum(case when ISNULL(OppSource,'')='来访' and datediff(d,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as brlf,
		sum(case when ISNULL(OppSource,'')='来访' and datediff(d,'2000-1-3',CreatedTime)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then 1 else 0 end) as bzlf,
		sum(case when ISNULL(OppSource,'')='来访' and datediff(m,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as bylf,
		sum(case when ISNULL(OppSource,'')='来访' and datediff(yy,CreatedTime,@var_CurrDate)=0 then 1 else 0 end) as bnlf,
		sum(case when ISNULL(OppSource,'')='来访' then 1 else 0 end) as ljlf,
		----------------------------------------------------------------
		ProjGUID
	from 
		s_Opportunity
	where
		ProjGUID=@var_ProjGUID
		and ISNULL(Status,'')<>'丢失'
	group by
		ProjGUID
),

rg as (
	select
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as brzzrgts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then 1 else 0 end) as bzzzrgts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as byzzrgts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as bnzzrgts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 then 1 else 0 end) as ljzzrgts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as brzzrgje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then o.CjRmbTotal/10000 else 0 end) as bzzzrgje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as byzzrgje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as bnzzrgje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 then o.CjRmbTotal/10000 else 0 end) as ljzzrgje,
		----------------------------------------------------------------
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as brsbrgts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then 1 else 0 end) as bzsbrgts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as bysbrgts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as bnsbrgts,
		sum(case when charindex('商办',pt.HierarchyName)>0 then 1 else 0 end) as ljsbrgts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as brsbrgje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then o.CjRmbTotal/10000 else 0 end) as bzsbrgje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as bysbrgje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as bnsbrgje,
		sum(case when charindex('商办',pt.HierarchyName)>0 then o.CjRmbTotal/10000 else 0 end) as ljsbrgje,
		----------------------------------------------------------------
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as brcwrgts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then 1 else 0 end) as bzcwrgts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as bycwrgts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then 1 else 0 end) as bncwrgts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 then 1 else 0 end) as ljcwrgts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as brcwrgje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,'2000-1-3',o.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then o.CjRmbTotal/10000 else 0 end) as bzcwrgje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(m,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as bycwrgje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(yy,o.QSDate,@var_CurrDate)=0 then o.CjRmbTotal/10000 else 0 end) as bncwrgje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 then o.CjRmbTotal/10000 else 0 end) as ljcwrgje,
		----------------------------------------------------------------
		o.ProjGUID
	from
		s_order o
		inner join s_Room r on o.RoomGUID=r.RoomGUID
		inner join s_Building b on r.BldGUID=b.BldGUID
		inner join p_MasterDataProductType pt on b.ProductTypeGUID=pt.p_MasterDataProductTypeId
	where
		o.ProjGUID=@var_ProjGUID
		and o.status='激活'
	group by
		o.ProjGUID
),

qy as (select
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约套数  else 0 end) as brzzqyts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约套数 else 0 end) as bzzzqyts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as byzzqyts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as bnzzqyts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 then pt.签约套数 else 0 end) as ljzzqyts,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as brzzqyje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约成交金额/10000 else 0 end) as bzzzqyje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as byzzqyje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as bnzzqyje,
		sum(case when charindex('住宅',pt.HierarchyName)>0 then pt.签约成交金额/10000 else 0 end) as ljzzqyje,
		----------------------------------------------------------------
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as brsbqyts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约套数 else 0 end) as bzsbqyts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as bysbqyts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as bnsbqyts,
		sum(case when charindex('商办',pt.HierarchyName)>0 then pt.签约套数 else 0 end) as ljsbqyts,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as brsbqyje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约成交金额 /10000 else 0 end) as bzsbqyje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as bysbqyje,
		sum(case when charindex('商办',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as bnsbqyje,
		sum(case when charindex('商办',pt.HierarchyName)>0 then pt.签约成交金额/10000 else 0 end) as ljsbqyje,
		----------------------------------------------------------------
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as brcwqyts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约套数 else 0 end) as bzcwqyts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as bycwqyts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约套数 else 0 end) as bncwqyts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 then pt.签约套数 else 0 end) as ljcwqyts,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as brcwqyje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(d,'2000-1-3',pt.QSDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then pt.签约成交金额/10000 else 0 end) as bzcwqyje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(m,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as bycwqyje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 and datediff(yy,pt.QSDate,@var_CurrDate)=0 then pt.签约成交金额/10000 else 0 end) as bncwqyje,
		sum(case when charindex('车位车库',pt.HierarchyName)>0 then pt.签约成交金额/10000 else 0 end) as ljcwqyje,
		----------------------------------------------------------------
		pt.p_projectId
	from
	(
		 select    t3.ProjName,t3.p_projectId  , QsDate, pt.业态 HierarchyName , (ISNULL(c.Ts, 0)) AS 签约套数 ,          (c.area ) AS  签约建筑面积2,   (c.BldArea ) AS  签约建筑面积 ,
							 (ISNULL(c.RmbAmount, 0)) AS 签约成交金额  FROM   	 (select ss.*,case when sr.RoomInfo like '%车库%' or sr.roominfo like '%车位%'  then 1*ss.Ts else  sr.bldarea*ss.Ts end as area   from s_SaleHSData  ss left join s_room sr on sr.roomguid =ss.roomguid )  c
							left  JOIN dbo.s_Room r ON c.RoomGUID = r.RoomGUID
							left JOIN dbo.s_Building t1 ON r.BldGUID = t1.BldGUID
							left JOIN ( select   Name 产品名称 ,p_MasterDataProductTypeId 产品ID,ParentId 业态ID, ParentName  业态 ,IsCar 是否车位,ManagementAttributes 是否可售   from p_MasterDataProductType where ParentId <>'00000000-0000-0000-0000-000000000000') pt		ON pt.产品ID =T1.ProductTypeGUID
							LEFT JOIN p_Project T3 ON T3.p_projectId=c.ProjGUID 
									INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = r.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
			where 
				--	a.QsDate between @var_BgnDate and @var_enddate 
			  --		and mu.BUGUID in ((select ProjGuid from @dt项目))
			  --      and 
					c.TradeType ='签约'            
			  --   and a.TradeType ='认购'--此处不能添加认购判断条件。否则会导致最后一次认购转签约业绩被扣减。认购-1，签约+ 于转签约时完成互冲，不影响数据
		  --       group by t3.BUGUID ,mu.BUName,t3.ProjName,t3.p_projectId ,t2.产品名称,t2.产品ID  ,t1.BldName,t1.BldGUID 
			 
)pt
	group by
		pt.p_projectId



),

sjhk as (
	select 
		sum(case when datediff(d,g.GetDate,@var_CurrDate)=0 then hk else 0 end) as brsjhk,
		sum(case when datediff(d,'2000-1-3',g.GetDate)/7=datediff(d,'2000-1-3',@var_CurrDate)/7 then hk else 0 end) as bzsjhk,
		sum(case when datediff(m,g.GetDate,@var_CurrDate)=0 then hk else 0 end) as bysjhk,
		sum(case when datediff(yy,g.GetDate,@var_CurrDate)=0 then hk else 0 end) as bnsjhk,
		sum(hk) as ljsjhk,
		g.ProjGUID
	from (
		select 
			g.ProjGUID,
			g.GetDate,
			g.RmbAmount/10000 as hk
		from 
			s_getin g
			inner join s_Voucher v on v.VouchGUID=g.VouchGUID
		where 
			g.ProjGUID=@var_ProjGUID
			and ISNULL(v.VouchStatus,'')<>'作废'
	) g
	group by
		g.ProjGUID
),

khhk as (
	select 
		sum(case when (datediff(d,c.QSDate,@var_CurrDate)=0 and datediff(d,g.SkDate,@var_CurrDate)>=0) or ((datediff(d,c.QSDate,@var_CurrDate)>0) and datediff(d,g.SkDate,@var_CurrDate)=0) then g.dk else 0 end) as brkhdk,		
		sum(case when ((c.w=datediff(d,'2000-1-3',@var_CurrDate)/7 and g.w<=datediff(d,'2000-1-3',@var_CurrDate)/7) or (c.w<datediff(d,'2000-1-3',@var_CurrDate)/7 and g.w=datediff(d,'2000-1-3',@var_CurrDate)/7)) then g.dk else 0 end) as bzkhdk,		
		sum(case when ((c.y=year(@var_CurrDate) and c.m=month(@var_CurrDate)) and (g.y<year(@var_CurrDate) or (g.y=year(@var_CurrDate) and g.m<=month(@var_CurrDate)))) or ((c.y<year(@var_CurrDate) or (c.y=year(@var_CurrDate) and c.m<month(@var_CurrDate))) and (g.y=year(@var_CurrDate) and g.m=month(@var_CurrDate))) then g.dk else 0 end) as bykhdk,
		sum(case when (c.y=year(@var_CurrDate) and g.y<=year(@var_CurrDate)) or (c.y<year(@var_CurrDate) and g.y=year(@var_CurrDate)) then g.dk else 0 end) as bnkhdk,
		sum(g.dk) as ljkhdk,
		----------------------------------------------------------------
		sum(case when (datediff(d,c.QSDate,@var_CurrDate)=0 and datediff(d,g.SkDate,@var_CurrDate)>=0) or ((datediff(d,c.QSDate,@var_CurrDate)>0) and datediff(d,g.SkDate,@var_CurrDate)=0) then g.fdk else 0 end) as brkhfdk,		
		sum(case when ((c.w=datediff(d,'2000-1-3',@var_CurrDate)/7 and g.w<=datediff(d,'2000-1-3',@var_CurrDate)/7) or (c.w<datediff(d,'2000-1-3',@var_CurrDate)/7 and g.w=datediff(d,'2000-1-3',@var_CurrDate)/7)) then g.fdk else 0 end) as bzkhfdk,		
		sum(case when ((c.y=year(@var_CurrDate) and c.m=month(@var_CurrDate)) and (g.y<year(@var_CurrDate) or (g.y=year(@var_CurrDate) and g.m<=month(@var_CurrDate)))) or ((c.y<year(@var_CurrDate) or (c.y=year(@var_CurrDate) and c.m<month(@var_CurrDate))) and (g.y=year(@var_CurrDate) and g.m=month(@var_CurrDate))) then g.fdk else 0 end) as bykhfdk,
		sum(case when (c.y=year(@var_CurrDate) and g.y<=year(@var_CurrDate)) or (c.y<year(@var_CurrDate) and g.y=year(@var_CurrDate)) then g.fdk else 0 end) as bnkhfdk,
		sum(g.fdk) as ljkhfdk,
		----------------------------------------------------------------
		c.ProjGUID
	from
	(
		select 
			c.ProjGUID,
			c.TradeGUID,
			c.QSDate,
			YEAR(c.QSDate) as y,
			MONTH(c.QSDate) as m,
			datediff(d,'2000-1-3',c.QSDate)/7 as w
		from 
			s_Contract c
		where 
			c.ProjGUID=@var_ProjGUID
			and c.status='激活'
	) c
	inner join (
		select 
			g.*,
			YEAR(SkDate) as y,
			MONTH(SkDate) as m,
			datediff(d,'2000-1-3',SkDate)/7 as w
		from (
			select 
				g.SaleGUID,
				case when v.VouchType='放款单' then v.KpDate else v.SkDate end as SkDate,
				case when g.ItemType='非贷款类房款' then g.RmbAmount/10000 else 0 end as fdk,
				case when g.ItemType='贷款类房款' then g.RmbAmount/10000 else 0 end as dk
			from 
				s_Voucher v 
				inner join s_getin g on v.VouchGUID=g.VouchGUID
			where 
				ISNULL(v.VouchStatus,'')<>'作废'			
		) g
	) g on c.TradeGUID=g.SaleGUID
	group by 
		c.ProjGUID
),

yqqk as (
	select 
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and datediff(d,c.QSDate,getdate())>60 then f.RmbYe else 0 end) as aj,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and datediff(d,c.QSDate,getdate())>60 then f.RmbYe else 0 end) as gjj,
		sum(case when (f.ItemType='非贷款类房款') and datediff(d,c.QSDate,getdate())>60 then f.RmbYe else 0 end) as lk,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and datediff(d,c.QSDate,getdate())>60 then f.RmbYe else 0 end) as hj,
		c.ProjGUID
	from 
		p_Project p
		inner join s_Contract c on c.ProjGUID=p.p_projectId
		left outer join (
			select 
				TradeGUID,ItemType,ItemName,
				lastDate,
				RmbAmount/10000 as RmbAmount,
				RmbYe/10000 as RmbYe,
				DsAmount/10000 as DsAmount
			from s_Fee f
			where ItemType='贷款类房款' or ItemType='非贷款类房款'
		) f on c.TradeGUID=f.TradeGUID
	where
		c.ProjGUID=@var_ProjGUID
		and c.status='激活'
	group by 
		c.ProjGUID
)

select 
	t.* 
from (
	select
		p.ProjName,
		isnull(jh.brld,0) as ld,
		isnull(jh.brlf,0) as lf,
		isnull(rg.brzzrgts,0) as zzrgts,
		isnull(rg.brzzrgje,0) as zzrgje,
		isnull(rg.brsbrgts,0) as sbrgts,
		isnull(rg.brsbrgje,0) as sbrgje,
		isnull(rg.brcwrgts,0) as cwrgts,
		isnull(rg.brcwrgje,0) as cwrgje,
		isnull(qy.brzzqyts,0) as zzqyts,
		isnull(qy.brzzqyje,0) as zzqyje,
		isnull(qy.brsbqyts,0) as sbqyts,
		isnull(qy.brsbqyje,0) as sbqyje,
		isnull(qy.brcwqyts,0) as cwqyts,
		isnull(qy.brcwqyje,0) as cwqyje,
		isnull(sjhk.brsjhk,0) as sjhk,
		isnull(khhk.brkhfdk,0) as khfdk,
		isnull(khhk.brkhdk,0) as khdk,
		isnull(khhk.brkhfdk,0)+isnull(khhk.brkhdk,0) as khxj,
		null as yqqk,
		'本日累计' as tagName,
		1 as tagOrder
	from
		p_Project p
		left outer join jh on p.p_projectId=jh.ProjGUID
		left outer join rg on p.p_projectId=rg.ProjGUID
		left outer join qy on p.p_projectId=qy.p_projectId
		left outer join sjhk on p.p_projectId=sjhk.ProjGUID
		left outer join khhk on p.p_projectId=khhk.ProjGUID
	where
		p.p_projectId=@var_ProjGUID

	union all

	select
		p.ProjName,
		isnull(jh.bzld,0) as ld,
		isnull(jh.bzlf,0) as lf,
		isnull(rg.bzzzrgts,0) as zzrgts,
		isnull(rg.bzzzrgje,0) as zzrgje,
		isnull(rg.bzsbrgts,0) as sbzgts,
		isnull(rg.bzsbrgje,0) as sbzgje,
		isnull(rg.bzcwrgts,0) as cwrgts,
		isnull(rg.bzcwrgje,0) as cwrgje,
		isnull(qy.bzzzqyts,0) as zzqyts,
		isnull(qy.bzzzqyje,0) as zzqyje,
		isnull(qy.bzsbqyts,0) as sbqyts,
		isnull(qy.bzsbqyje,0) as sbqyje,
		isnull(qy.bzcwqyts,0) as cwqyts,
		isnull(qy.bzcwqyje,0) as cwqyje,
		isnull(sjhk.bzsjhk,0) as sjhk,
		isnull(khhk.bzkhfdk,0) as khfdk,
		isnull(khhk.bzkhdk,0) as khdk,
		isnull(khhk.bzkhfdk,0)+isnull(khhk.bzkhdk,0) as khxj,
		null as yqqk,
		'本周累计' as tagName,
		2 as tagOrder
	from
		p_Project p
		left outer join jh on p.p_projectId=jh.ProjGUID
		left outer join rg on p.p_projectId=rg.ProjGUID
		left outer join qy on p.p_projectId=qy.p_projectId
		left outer join sjhk on p.p_projectId=sjhk.ProjGUID
		left outer join khhk on p.p_projectId=khhk.ProjGUID
	where
		p.p_projectId=@var_ProjGUID

	union all

	select
		p.ProjName,
		isnull(jh.byld,0) as ld,
		isnull(jh.bylf,0) as lf,
		isnull(rg.byzzrgts,0) as zzrgts,
		isnull(rg.byzzrgje,0) as zzrgje,
		isnull(rg.bysbrgts,0) as sbygts,
		isnull(rg.bysbrgje,0) as sbygje,
		isnull(rg.bycwrgts,0) as cwrgts,
		isnull(rg.bycwrgje,0) as cwrgje,
		isnull(qy.byzzqyts,0) as zzqyts,
		isnull(qy.byzzqyje,0) as zzqyje,
		isnull(qy.bysbqyts,0) as sbqyts,
		isnull(qy.bysbqyje,0) as sbqyje,
		isnull(qy.bycwqyts,0) as cwqyts,
		isnull(qy.bycwqyje,0) as cwqyje,
		isnull(sjhk.bysjhk,0) as sjhk,
		isnull(khhk.bykhfdk,0) as khfdk,
		isnull(khhk.bykhdk,0) as khdk,
		isnull(khhk.bykhfdk,0)+isnull(khhk.bykhdk,0) as khxj,
		null as yqqk,
		'本月累计' as tagName,
		3 as tagOrder
	from
		p_Project p
		left outer join jh on p.p_projectId=jh.ProjGUID
		left outer join rg on p.p_projectId=rg.ProjGUID
		left outer join qy on p.p_projectId=qy.p_projectId
		left outer join sjhk on p.p_projectId=sjhk.ProjGUID
		left outer join khhk on p.p_projectId=khhk.ProjGUID
	where
		p.p_projectId=@var_ProjGUID

	union all

	select
		p.ProjName,
		isnull(jh.bnld,0) as ld,
		isnull(jh.bnlf,0) as lf,
		isnull(rg.bnzzrgts,0) as zzrgts,
		isnull(rg.bnzzrgje,0) as zzrgje,
		isnull(rg.bnsbrgts,0) as sbngts,
		isnull(rg.bnsbrgje,0) as sbngje,
		isnull(rg.bncwrgts,0) as cwrgts,
		isnull(rg.bncwrgje,0) as cwrgje,
		isnull(qy.bnzzqyts,0) as zzqyts,
		isnull(qy.bnzzqyje,0) as zzqyje,
		isnull(qy.bnsbqyts,0) as sbqyts,
		isnull(qy.bnsbqyje,0) as sbqyje,
		isnull(qy.bncwqyts,0) as cwqyts,
		isnull(qy.bncwqyje,0) as cwqyje,
		isnull(sjhk.bnsjhk,0) as sjhk,
		isnull(khhk.bnkhfdk,0) as khfdk,
		isnull(khhk.bnkhdk,0) as khdk,
		isnull(khhk.bnkhfdk,0)+isnull(khhk.bnkhdk,0) as khxj,
		null as yqqk,
		'本年累计' as tagName,
		4 as tagOrder
	from
		p_Project p
		left outer join jh on p.p_projectId=jh.ProjGUID
		left outer join rg on p.p_projectId=rg.ProjGUID
		left outer join qy on p.p_projectId=qy.p_projectId
		left outer join sjhk on p.p_projectId=sjhk.ProjGUID
		left outer join khhk on p.p_projectId=khhk.ProjGUID
	where
		p.p_projectId=@var_ProjGUID

	union all

	select
		p.ProjName,
		isnull(jh.ljld,0) as ld,
		isnull(jh.ljlf,0) as lf,
		isnull(rg.ljzzrgts,0) as zzrgts,
		isnull(rg.ljzzrgje,0) as zzrgje,
		isnull(rg.ljsbrgts,0) as sljgts,
		isnull(rg.ljsbrgje,0) as sljgje,
		isnull(rg.ljcwrgts,0) as cwrgts,
		isnull(rg.ljcwrgje,0) as cwrgje,
		isnull(qy.ljzzqyts,0) as zzqyts,
		isnull(qy.ljzzqyje,0) as zzqyje,
		isnull(qy.ljsbqyts,0) as sbqyts,
		isnull(qy.ljsbqyje,0) as sbqyje,
		isnull(qy.ljcwqyts,0) as cwqyts,
		isnull(qy.ljcwqyje,0) as cwqyje,
		isnull(sjhk.ljsjhk,0) as sjhk,
		isnull(khhk.ljkhfdk,0) as khfdk,
		isnull(khhk.ljkhdk,0) as khdk,
		isnull(khhk.ljkhfdk,0)+isnull(khhk.ljkhdk,0) as khxj,
		isnull(yqqk.aj,0)+isnull(yqqk.lk,0) as yqqk,
		'项目累计' as tagName,
		5 as tagOrder
	from
		p_Project p
		left outer join jh on p.p_projectId=jh.ProjGUID
		left outer join rg on p.p_projectId=rg.ProjGUID
		left outer join qy on p.p_projectId=qy.p_projectId
		left outer join sjhk on p.p_projectId=sjhk.ProjGUID
		left outer join khhk on p.p_projectId=khhk.ProjGUID
		left outer join yqqk on p.p_projectId=yqqk.ProjGUID
	where
		p.p_projectId=@var_ProjGUID
) t
order by
	t.tagOrder
