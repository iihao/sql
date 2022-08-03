USE [dotnet_erp60]
GO

/****** Object:  StoredProcedure [dbo].[rts_签约回款统计监控]    Script Date: 04/29/2021 15:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[rts_签约回款统计监控]
	@var_BUGUIDs varchar(max),
	@var_bgndate datetime,
	@var_enddate datetime
as
begin

declare @cd datetime
set @cd=GETDATE()
declare @dtBU table (BUGUID uniqueidentifier);    
insert into @dtBU(BUGUID) select Value from dbo.fn_Split1(@var_BUGUIDs,',');

with 
ss as (
	select 
		p.BUGUID,
		c.ProjGUID,
		b.ProductTypeGUID,
		c.TradeGUID,
		sum(case when (g.ItemType='贷款类房款' and g.ItemName='银行按揭') then g.RmbAmount else 0 end) as AjAmount,
		sum(case when (g.ItemType='贷款类房款' and g.ItemName='公积金') then g.RmbAmount else 0 end) as GjjAmount,
		sum(case when (g.ItemType='非贷款类房款') then g.RmbAmount else 0 end) as LkAmount,
		sum(case when (g.ItemType='贷款类房款' or g.ItemType='非贷款类房款') then g.RmbAmount else 0 end) as HjAmount
	from 
		p_Project p
		inner join s_Contract c on c.ProjGUID=p.p_projectId
		inner join s_Room r on c.RoomGUID=r.RoomGUID
		inner join s_Building b on r.BldGUID=b.BldGUID
		left outer join (
			select 
				g.SaleGUID,g.ItemType,g.ItemName,
				g.RmbAmount/10000 as RmbAmount
			from 
				s_Voucher v 
				inner join s_getin g on v.VouchGUID=g.VouchGUID
			where 
				ISNULL(v.VouchStatus,'')<>'作废'
		) g on c.TradeGUID=g.SaleGUID
	where
		c.status='激活'
		and c.QSDate BETWEEN @var_BgnDate AND @var_EndDate
		and p.BUGUID in (select BUGUID from @dtBU)
	group by 
		p.BUGUID,c.ProjGUID,b.ProductTypeGUID,c.TradeGUID
),
ys as (
	select 
		p.BUGUID,
		c.ProjGUID,
		b.ProductTypeGUID,b.ProductTypeName,
		c.TradeGUID,
		c.CjRmbTotal/10000 as CjRmbTotal,
		sum(f.DsAmount) as DsAmount,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') then f.RmbAmount else 0 end) as AjAmount,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') then f.RmbAmount else 0 end) as GjjAmount,
		sum(case when (f.ItemType='非贷款类房款') then f.RmbAmount else 0 end) as LkAmount,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') then f.RmbAmount else 0 end) as HjAmount,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') then f.RmbYe else 0 end) as AjYe,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') then f.RmbYe else 0 end) as GjjYe,
		sum(case when (f.ItemType='非贷款类房款') then f.RmbYe else 0 end) as LkYe,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') then f.RmbYe else 0 end) as HjYe,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and (datediff(d,f.lastDate,getdate()) between 0 and 60) and f.RmbYe >0 then  f.RmbYe else 0 end) as AjYeYq,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and (datediff(d,f.lastDate,getdate()) between 0 and 60) and f.RmbYe >0 then f.RmbYe else 0 end) as GjjYeYq,
		sum(case when (f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 0 and 60) and f.RmbYe >0  then f.RmbYe else 0 end) as LkYeYq,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 0 and 60) then f.RmbYe else 0 end) as HjYeYq,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and (datediff(d,f.lastDate,getdate()) between 61 and 120) and f.RmbYe >0 then  f.RmbYe else 0 end) as AjYeYq60,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and (datediff(d,f.lastDate,getdate())between 61 and 120) and f.RmbYe >0 then f.RmbYe else 0 end) as GjjYeYq60,
		sum(case when (f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 61 and 120) and f.RmbYe >0  then f.RmbYe else 0 end) as LkYeYq60,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 61 and 120) then f.RmbYe else 0 end) as HjYeYq60,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and (datediff(d,f.lastDate,getdate()) between 121 and 180) and f.RmbYe >0 then  f.RmbYe else 0 end) as AjYeYq120,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and (datediff(d,f.lastDate,getdate())between 121 and 180) and f.RmbYe >0 then f.RmbYe else 0 end) as GjjYeYq120,
		sum(case when (f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 121 and 180) and f.RmbYe >0  then f.RmbYe else 0 end) as LkYeYq120,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate()) between 121 and 180) then f.RmbYe else 0 end) as HjYeYq120,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and (datediff(d,f.lastDate,getdate())>180) and f.RmbYe >0 then  f.RmbYe else 0 end) as AjYeYq180,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and (datediff(d,f.lastDate,getdate())>180) and f.RmbYe >0 then f.RmbYe else 0 end) as GjjYeYq180,
		sum(case when (f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate())>180) and f.RmbYe >0  then f.RmbYe else 0 end) as LkYeYq180,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and (datediff(d,f.lastDate,getdate())>180) then f.RmbYe else 0 end) as HjYeYq180,

		sum(case when (f.ItemType='贷款类房款' and f.ItemName='银行按揭') and datediff(d,f.lastDate,getdate())<=0 and f.RmbYe >0 then f.RmbYe else 0 end) as AjYeWYq,
		sum(case when (f.ItemType='贷款类房款' and f.ItemName='公积金') and datediff(d,f.lastDate,getdate())<=0 and f.RmbYe >0 then f.RmbYe else 0 end) as GjjYeWyq,
		sum(case when (f.ItemType='非贷款类房款') and datediff(d,f.lastDate,getdate())<=0 and f.RmbYe >0 then f.RmbYe else 0 end) as LkYeWyq,
		sum(case when (f.ItemType='贷款类房款' or f.ItemType='非贷款类房款') and datediff(d,f.lastDate,getdate())<=0 and f.RmbYe >0 then f.RmbYe else 0 end) as HjYeWyq
	from 
		p_Project p
		inner join s_Contract c on c.ProjGUID=p.p_projectId
		inner join s_Room r on c.RoomGUID=r.RoomGUID
		inner join s_Building b on r.BldGUID=b.BldGUID
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
		c.status='激活'
		and c.QSDate BETWEEN @var_BgnDate AND @var_EndDate
		and p.BUGUID in (select BUGUID from @dtBU)
	group by 
		p.BUGUID,c.ProjGUID,b.ProductTypeGUID,c.TradeGUID,c.CjRmbTotal,b.ProductTypeName
)

select 
	t.*
from (
	select 
		'公司维度' as 维度类型,
		bu.BUName as 维度名称,
		1 as SortOrder,
		isnull(ys.CjRmbTotal,0) as CjRmbTotal,
		isnull(ys.DsAmount,0) as DsAmount,
		isnull(ys.YsAjAmount,0) as YsAjAmount,
		isnull(ys.YsGjjAmount,0) as YsGjjAmount,
		isnull(ys.YsLkAmount,0) as YsLkAmount,
		isnull(ys.YsHjAmount,0) as YsHjAmount,
		isnull(ys.YsAjYe,0) as YsAjYe,
		isnull(ys.YsGjjYe,0) as YsGjjYe,
		isnull(ys.YsLkYe,0) as YsLkYe,
		isnull(ys.YsHjYe,0) as YsHjYe,
		isnull(ys.YsAjYeYq,0) as YsAjYeYq,
		isnull(ys.YsGjjYeYq,0) as YsGjjYeYq,
		isnull(ys.YsLkYeYq,0) as YsLkYeYq,
		isnull(ys.YsHjYeYq,0) as YsHjYeYq,

		isnull(ys.YsAjYeYq60,0) as YsAjYeYq60,
		isnull(ys.YsGjjYeYq60,0) as YsGjjYeYq60,
		isnull(ys.YsLkYeYq60,0) as YsLkYeYq60,
		isnull(ys.YsHjYeYq60,0) as YsHjYeYq60,

		isnull(ys.YsAjYeYq120,0) as YsAjYeYq120,
		isnull(ys.YsGjjYeYq120,0) as YsGjjYeYq120,
		isnull(ys.YsLkYeYq120,0) as YsLkYeYq120,
		isnull(ys.YsHjYeYq120,0) as YsHjYeYq120,


		isnull(ys.YsAjYeYq180,0) as YsAjYeYq180,
		isnull(ys.YsGjjYeYq180,0) as YsGjjYeYq180,
		isnull(ys.YsLkYeYq180,0) as YsLkYeYq180,
		isnull(ys.YsHjYeYq180,0) as YsHjYeYq180,

		isnull(ys.YsAjYeWyq,0) as YsAjYeWyq,
		isnull(ys.YsGjjYeWyq,0) as YsGjjYeWyq,
		isnull(ys.YsLkYeWyq,0) as YsLkYeWyq,
		isnull(ys.YsHjYeWyq,0) as YsHjYeWyq,
		isnull(ss.SsAjAmount,0) as SsAjAmount,
		isnull(ss.SsGjjAmount,0) as SsGjjAmount,
		isnull(ss.SsLkAmount,0) as SsLkAmount,
		isnull(ss.SsHjAmount,0) as SsHjAmount,
		bu.BUGUID
	from
		myBusinessUnit bu
		left outer join (
			select
				sum(ys.CjRmbTotal) as CjRmbTotal,
				sum(ys.DsAmount) as DsAmount,
				sum(ys.AjAmount) as YsAjAmount,
				sum(ys.GjjAmount) as YsGjjAmount,
				sum(ys.LkAmount) as YsLkAmount,
				sum(ys.HjAmount) as YsHjAmount,
				sum(ys.AjYe) as YsAjYe,
				sum(ys.GjjYe) as YsGjjYe,
				sum(ys.LkYe) as YsLkYe,
				sum(ys.HjYe) as YsHjYe,
				sum(ys.AjYeYq) as YsAjYeYq,
				sum(ys.GjjYeYq) as YsGjjYeYq,
				sum(ys.LkYeYq) as YsLkYeYq,
				sum(ys.HjYeYq) as YsHjYeYq,
				sum(ys.AjYeWyq) as YsAjYeWyq,

				sum(ys.AjYeYq60) as YsAjYeYq60,
				sum(ys.GjjYeYq60) as YsGjjYeYq60,
				sum(ys.LkYeYq60) as YsLkYeYq60,
				sum(ys.HjYeYq60) as YsHjYeYq60,

				sum(ys.AjYeYq120) as YsAjYeYq120,
				sum(ys.GjjYeYq120) as YsGjjYeYq120,
				sum(ys.LkYeYq120) as YsLkYeYq120,
				sum(ys.HjYeYq120) as YsHjYeYq120,

				sum(ys.AjYeYq180) as YsAjYeYq180,
				sum(ys.GjjYeYq180) as YsGjjYeYq180,
				sum(ys.LkYeYq180) as YsLkYeYq180,
				sum(ys.HjYeYq180) as YsHjYeYq180,

				sum(ys.GjjYeWyq) as YsGjjYeWyq,
				sum(ys.LkYeWyq) as YsLkYeWyq,
				sum(ys.HjYeWyq) as YsHjYeWyq,
				BUGUID
			from ys
			group by BUGUID			
		) ys on bu.BUGUID=ys.BUGUID
		left outer join (
			select
				sum(ss.AjAmount) as SsAjAmount,
				sum(ss.GjjAmount) as SsGjjAmount,
				sum(ss.LkAmount) as SsLkAmount,
				sum(ss.HjAmount) as SsHjAmount,
				BUGUID
			from ss
			group by BUGUID	
		) ss on bu.BUGUID=ss.BUGUID
	where bu.IsEndCompany=1 and bu.BUType=1 and bu.BUGUID in (select BUGUID from @dtBU)

	union all

	select 
		'项目维度' as 维度类型,
		p.ProjName as 维度名称,
		2 as SortOrder,
		isnull(ys.CjRmbTotal,0) as CjRmbTotal,
		isnull(ys.DsAmount,0) as DsAmount,
		isnull(ys.YsAjAmount,0) as YsAjAmount,
		isnull(ys.YsGjjAmount,0) as YsGjjAmount,
		isnull(ys.YsLkAmount,0) as YsLkAmount,
		isnull(ys.YsHjAmount,0) as YsHjAmount,
		isnull(ys.YsAjYe,0) as YsAjYe,
		isnull(ys.YsGjjYe,0) as YsGjjYe,
		isnull(ys.YsLkYe,0) as YsLkYe,
		isnull(ys.YsHjYe,0) as YsHjYe,
		isnull(ys.YsAjYeYq,0) as YsAjYeYq,
		isnull(ys.YsGjjYeYq,0) as YsGjjYeYq,
		isnull(ys.YsLkYeYq,0) as YsLkYeYq,
		isnull(ys.YsHjYeYq,0) as YsHjYeYq,

		isnull(ys.YsAjYeYq60,0) as YsAjYeYq60,
		isnull(ys.YsGjjYeYq60,0) as YsGjjYeYq60,
		isnull(ys.YsLkYeYq60,0) as YsLkYeYq60,
		isnull(ys.YsHjYeYq60,0) as YsHjYeYq60,

		isnull(ys.YsAjYeYq120,0) as YsAjYeYq120,
		isnull(ys.YsGjjYeYq120,0) as YsGjjYeYq120,
		isnull(ys.YsLkYeYq120,0) as YsLkYeYq120,
		isnull(ys.YsHjYeYq120,0) as YsHjYeYq120,

		isnull(ys.YsAjYeYq180,0) as YsAjYeYq180,
		isnull(ys.YsGjjYeYq180,0) as YsGjjYeYq180,
		isnull(ys.YsLkYeYq180,0) as YsLkYeYq180,
		isnull(ys.YsHjYeYq180,0) as YsHjYeYq180,

		isnull(ys.YsAjYeWyq,0) as YsAjYeWyq,
		isnull(ys.YsGjjYeWyq,0) as YsGjjYeWyq,
		isnull(ys.YsLkYeWyq,0) as YsLkYeWyq,
		isnull(ys.YsHjYeWyq,0) as YsHjYeWyq,
		isnull(ss.SsAjAmount,0) as SsAjAmount,
		isnull(ss.SsGjjAmount,0) as SsGjjAmount,
		isnull(ss.SsLkAmount,0) as SsLkAmount,
		isnull(ss.SsHjAmount,0) as SsHjAmount,
		p.p_projectId
	from
		p_Project p
		left outer join (
			select
				sum(ys.CjRmbTotal) as CjRmbTotal,
				sum(ys.DsAmount) as DsAmount,
				sum(ys.AjAmount) as YsAjAmount,
				sum(ys.GjjAmount) as YsGjjAmount,
				sum(ys.LkAmount) as YsLkAmount,
				sum(ys.HjAmount) as YsHjAmount,
				sum(ys.AjYe) as YsAjYe,
				sum(ys.GjjYe) as YsGjjYe,
				sum(ys.LkYe) as YsLkYe,
				sum(ys.HjYe) as YsHjYe,
				sum(ys.AjYeYq) as YsAjYeYq,
				sum(ys.GjjYeYq) as YsGjjYeYq,
				sum(ys.LkYeYq) as YsLkYeYq,
				sum(ys.HjYeYq) as YsHjYeYq,

				sum(ys.AjYeYq60) as YsAjYeYq60,
				sum(ys.GjjYeYq60) as YsGjjYeYq60,
				sum(ys.LkYeYq60) as YsLkYeYq60,
				sum(ys.HjYeYq60) as YsHjYeYq60,

				sum(ys.AjYeYq120) as YsAjYeYq120,
				sum(ys.GjjYeYq120) as YsGjjYeYq120,
				sum(ys.LkYeYq120) as YsLkYeYq120,
				sum(ys.HjYeYq120) as YsHjYeYq120,

				sum(ys.AjYeYq180) as YsAjYeYq180,
				sum(ys.GjjYeYq180) as YsGjjYeYq180,
				sum(ys.LkYeYq180) as YsLkYeYq180,
				sum(ys.HjYeYq180) as YsHjYeYq180,


				sum(ys.AjYeWyq) as YsAjYeWyq,
				sum(ys.GjjYeWyq) as YsGjjYeWyq,
				sum(ys.LkYeWyq) as YsLkYeWyq,
				sum(ys.HjYeWyq) as YsHjYeWyq,
				ProjGUID
			from ys
			group by ProjGUID			
		) ys on p.p_projectId=ys.ProjGUID
		left outer join (
			select
				sum(ss.AjAmount) as SsAjAmount,
				sum(ss.GjjAmount) as SsGjjAmount,
				sum(ss.LkAmount) as SsLkAmount,
				sum(ss.HjAmount) as SsHjAmount,
				ProjGUID
			from ss
			group by ProjGUID	
		) ss on p.p_projectId=ss.ProjGUID
	where p.IfEnd=1 and p.BUGUID in (select BUGUID from @dtBU)

	union all

	select 
		'业态维度' as 维度类型,
		ys.ProductTypeName as 维度名称,
		3 as SortOrder,
		isnull(ys.CjRmbTotal,0) as CjRmbTotal,
		isnull(ys.DsAmount,0) as DsAmount,
		isnull(ys.YsAjAmount,0) as YsAjAmount,
		isnull(ys.YsGjjAmount,0) as YsGjjAmount,
		isnull(ys.YsLkAmount,0) as YsLkAmount,
		isnull(ys.YsHjAmount,0) as YsHjAmount,
		isnull(ys.YsAjYe,0) as YsAjYe,
		isnull(ys.YsGjjYe,0) as YsGjjYe,
		isnull(ys.YsLkYe,0) as YsLkYe,
		isnull(ys.YsHjYe,0) as YsHjYe,
		isnull(ys.YsAjYeYq,0) as YsAjYeYq,
		isnull(ys.YsGjjYeYq,0) as YsGjjYeYq,
		isnull(ys.YsLkYeYq,0) as YsLkYeYq,
		isnull(ys.YsHjYeYq,0) as YsHjYeYq,

		isnull(ys.YsAjYeYq60,0) as YsAjYeYq60,
		isnull(ys.YsGjjYeYq60,0) as YsGjjYeYq60,
		isnull(ys.YsLkYeYq60,0) as YsLkYeYq60,
		isnull(ys.YsHjYeYq60,0) as YsHjYeYq60,

		isnull(ys.YsAjYeYq120,0) as YsAjYeYq120,
		isnull(ys.YsGjjYeYq120,0) as YsGjjYeYq120,
		isnull(ys.YsLkYeYq120,0) as YsLkYeYq120,
		isnull(ys.YsHjYeYq120,0) as YsHjYeYq120,

		isnull(ys.YsAjYeYq180,0) as YsAjYeYq180,
		isnull(ys.YsGjjYeYq180,0) as YsGjjYeYq180,
		isnull(ys.YsLkYeYq180,0) as YsLkYeYq180,
		isnull(ys.YsHjYeYq180,0) as YsHjYeYq180,

		isnull(ys.YsAjYeWyq,0) as YsAjYeWyq,
		isnull(ys.YsGjjYeWyq,0) as YsGjjYeWyq,
		isnull(ys.YsLkYeWyq,0) as YsLkYeWyq,
		isnull(ys.YsHjYeWyq,0) as YsHjYeWyq,
		isnull(ss.SsAjAmount,0) as SsAjAmount,
		isnull(ss.SsGjjAmount,0) as SsGjjAmount,
		isnull(ss.SsLkAmount,0) as SsLkAmount,
		isnull(ss.SsHjAmount,0) as SsHjAmount,
		ys.ProductTypeGUID
	from
		(
			select
				sum(ys.CjRmbTotal) as CjRmbTotal,
				sum(ys.DsAmount) as DsAmount,
				sum(ys.AjAmount) as YsAjAmount,
				sum(ys.GjjAmount) as YsGjjAmount,
				sum(ys.LkAmount) as YsLkAmount,
				sum(ys.HjAmount) as YsHjAmount,
				sum(ys.AjYe) as YsAjYe,
				sum(ys.GjjYe) as YsGjjYe,
				sum(ys.LkYe) as YsLkYe,
				sum(ys.HjYe) as YsHjYe,
				sum(ys.AjYeYq) as YsAjYeYq,
				sum(ys.GjjYeYq) as YsGjjYeYq,
				sum(ys.LkYeYq) as YsLkYeYq,
				sum(ys.HjYeYq) as YsHjYeYq,

				sum(ys.AjYeYq60) as YsAjYeYq60,
				sum(ys.GjjYeYq60) as YsGjjYeYq60,
				sum(ys.LkYeYq60) as YsLkYeYq60,
				sum(ys.HjYeYq60) as YsHjYeYq60,

				sum(ys.AjYeYq120) as YsAjYeYq120,
				sum(ys.GjjYeYq120) as YsGjjYeYq120,
				sum(ys.LkYeYq120) as YsLkYeYq120,
				sum(ys.HjYeYq120) as YsHjYeYq120,

				sum(ys.AjYeYq180) as YsAjYeYq180,
				sum(ys.GjjYeYq180) as YsGjjYeYq180,
				sum(ys.LkYeYq180) as YsLkYeYq180,
				sum(ys.HjYeYq180) as YsHjYeYq180,


				sum(ys.AjYeWyq) as YsAjYeWyq,
				sum(ys.GjjYeWyq) as YsGjjYeWyq,
				sum(ys.LkYeWyq) as YsLkYeWyq,
				sum(ys.HjYeWyq) as YsHjYeWyq,
				ProductTypeGUID,ProductTypeName
			from ys
			group by ProductTypeGUID,ProductTypeName			
		) ys 
		left outer join (
			select
				sum(ss.AjAmount) as SsAjAmount,
				sum(ss.GjjAmount) as SsGjjAmount,
				sum(ss.LkAmount) as SsLkAmount,
				sum(ss.HjAmount) as SsHjAmount,
				ProductTypeGUID
			from ss
			group by ProductTypeGUID
		) ss on ys.ProductTypeGUID=ss.ProductTypeGUID


	
) t
order by t.SortOrder,t.维度名称

end




GO







USE [dotnet_erp60]
GO

/****** Object:  StoredProcedure [dbo].[rts_jf_销售报表纵向维度分析_1903]    Script Date: 04/29/2021 15:15:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE Proc [dbo].[rts_jf_销售报表纵向维度分析_1903]          
  @var_buguids varchar(max),       
  @var_projGuids varchar(max),       
  @var_bldguids varchar(max),       
  @var_bgndate datetime,
  @var_enddate datetime
as
begin
declare @dtBld table (BldGuid uniqueidentifier);    
insert into @dtBld(BldGuid) select Value from dbo.fn_Split1(@var_bldguids,',');  

with 
 rpt_p_Room        
 as        
 ( select  mu.BUName ,mu.BUGUID, sr.ProjGUID ,p.ProjName, sr.RoomGUID,
  sr.BldGUID ,sb.BldName ,sb.ProductTypeGUID,pmpt.Name ProductTypeName,sr.Status ,
  sr.BldArea, sr.Total,sr.BaBldPrice,sr.BaTotal,sr.DjTotal,sr.DjBldPrice,
  cast(case when sr.Status='签约' then c.CjRmbTotal 
		when sr.Status='认购' then o.CjRmbTotal
		else (case when isnull(sr.DjTotal,0)<>0 then sr.DjTotal else isnull(mb.targetUnitPrice,0)*
		(case when charindex('车位',pmpt.Name)>0 or charindex('车库',pmpt.Name)>0 then 1 else sr.BldArea end) end) end 
		as decimal(18,2))  as RoomHz
	from  dbo.s_Room  sr WITH ( NOLOCK ) 
		INNER join dbo.s_Building  sb WITH ( NOLOCK ) on sr.BldGUID = sb.BldGUID            
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN p_Project P WITH ( NOLOCK ) on sr.ProjGUID = p.p_projectId
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = sr.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		inner join mdm_Building mb on sb.MasterBldGUID=mb.BuildingGUID
		left  join s_contract c WITH ( NOLOCK ) on sr.RoomGUID=c.RoomGUID and c.status='激活'
		left  join s_order o WITH ( NOLOCK ) on sr.RoomGUID=o.RoomGUID and o.status='激活'
   WHERE sb.BldGUID in (select BldGuid from @dtBld)
 ) ,			
 tf
AS ( 
	SELECT  Buguid,
			BUName,
			ProjGUID,
			ProjName,
			ProductTypeGUID,
			ProductTypeName,
			BldGUID,
			BldName,
			RoomGUID,
			OCloseReason,
			CCloseReason,
			OCloseDate,
			CCloseDate,
			OCjBldArea,
			OCjTotal,
			CCjBldArea,
			CCjTotal
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE OCloseReason='退房' OR CCloseReason='退房'
 ),
rpt_Sale    
as (
SELECT  mu.BUName ,mu.BUGUID, vs.RoomGUID,
		pp.ProjCode ,
		pp.ProjName ,
		pmpt.Name AS ProductTypeName ,
		sb.BldGUID ,sb.BldName,
		vs.PayFormName,
		ROUND(sr.BldArea, 2) AS BldArea ,
		ROUND(vs.CjRmbTotal , 2) CjRmbTotal ,
		ROUND(ys.QkTotal, 2) AS QkTotal,
		vs.QsDate,
		vs.YqyDate,
		'认购' as saletype
FROM    s_Order vs WITH ( NOLOCK )
		INNER JOIN p_Project pp WITH ( NOLOCK ) ON vs.ProjGUID = pp.p_projectId
		INNER JOIN s_room sr WITH ( NOLOCK ) ON vs.RoomGUID = sr.RoomGUID
		INNER JOIN s_Building sb WITH ( NOLOCK ) ON sr.BldGUID = sb.BldGUID
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = vs.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		LEFT JOIN ( select f.TradeGUID,  
					sum(case when ItemType in ('贷款类房款','非贷款类房款') then  f.RmbYe - f.DsAmount else 0 end ) QkTotal
					from s_Fee f WITH ( NOLOCK )
					group by f.TradeGUID )ys ON ys.TradeGUID=vs.TradeGUID
WHERE sb.BldGUID in (select BldGuid from @dtBld)  
	   and vs.status = '激活'
UNION ALL
SELECT  mu.BUName ,mu.BUGUID, vs.RoomGUID,
		pp.ProjCode ,
		pp.ProjName ,
		pmpt.Name AS ProductTypeName ,
		sb.BldGUID ,sb.BldName,
		vs.PayFormName,
		ROUND(sr.BldArea, 2) AS BldArea ,
		ROUND(vs.CjRmbTotal , 2) CjRmbTotal ,
		ROUND(ys.QkTotal, 2) AS QkTotal,
		vs.QsDate,
		null,
		'签约' as saletype
FROM    s_Contract vs WITH ( NOLOCK )
		INNER JOIN p_Project pp WITH ( NOLOCK ) ON vs.ProjGUID = pp.p_projectId
		INNER JOIN s_room sr WITH ( NOLOCK ) ON vs.RoomGUID = sr.RoomGUID
		INNER JOIN s_Building sb WITH ( NOLOCK ) ON sr.BldGUID = sb.BldGUID
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = vs.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		LEFT JOIN ( select f.TradeGUID,  
					sum(case when ItemType in ('贷款类房款','非贷款类房款') then  f.RmbYe - f.DsAmount else 0 end ) QkTotal
					from s_Fee f WITH ( NOLOCK )
					group by f.TradeGUID )ys ON ys.TradeGUID=vs.TradeGUID    
WHERE sb.BldGUID in (select BldGuid from @dtBld) 
	   and ( vs.status = '激活')
),

rpt_Sale2    
as (
SELECT  mu.BUName ,mu.BUGUID, vs.RoomGUID,
		pp.ProjCode ,
		pp.ProjName ,
		pmpt.Name AS ProductTypeName ,
		sb.BldGUID ,sb.BldName,
		vs.PayFormName,
		ROUND(sr.BldArea, 2) AS BldArea ,
		ROUND(vs.CjRmbTotal , 2) CjRmbTotal ,
		ROUND(ys.QkTotal, 2) AS QkTotal,
		vs.QsDate,
		'认购' as saletype
FROM    s_Order vs WITH ( NOLOCK )
		INNER JOIN p_Project pp WITH ( NOLOCK ) ON vs.ProjGUID = pp.p_projectId
		INNER JOIN s_room sr WITH ( NOLOCK ) ON vs.RoomGUID = sr.RoomGUID
		INNER JOIN s_Building sb WITH ( NOLOCK ) ON sr.BldGUID = sb.BldGUID
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = vs.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		LEFT JOIN s_Trade T ON T.TradeGUID=VS.TradeGUID
		LEFT JOIN ( select f.TradeGUID,  
					sum(case when ItemType in ('贷款类房款','非贷款类房款') then  f.RmbYe - f.DsAmount else 0 end ) QkTotal
					from s_Fee f WITH ( NOLOCK )
					group by f.TradeGUID )ys ON ys.TradeGUID=vs.TradeGUID
WHERE sb.BldGUID in (select BldGuid from @dtBld)  AND T.TradeStatus='激活'
	   and (vs.status = '激活' or (vs.status = '关闭' and vs.CloseReason = '转签约'))
),

 rpt_Getin
as (
SELECT  vs.RoomGUID,
		sum(case when ((datediff(day,vs.qsdate,@var_BgnDate)<=0 and datediff(day,vs.qsdate,@var_EndDate)>=0) and datediff(day,ss.SkDate,@var_EndDate)>=0) or (datediff(day,vs.qsdate,@var_BgnDate)>0 and (datediff(day,ss.SkDate,@var_BgnDate)<=0 and datediff(day,ss.SkDate,@var_EndDate)>=0)) then ss.dk else 0 end) as bqdk,
		sum(case when ((datediff(day,vs.qsdate,@var_BgnDate)<=0 and datediff(day,vs.qsdate,@var_EndDate)>=0) and datediff(day,ss.SkDate,@var_EndDate)>=0) or (datediff(day,vs.qsdate,@var_BgnDate)>0 and (datediff(day,ss.SkDate,@var_BgnDate)<=0 and datediff(day,ss.SkDate,@var_EndDate)>=0)) then ss.fdk else 0 end) as bqfdk,
		sum(ss.dk) as ljdk,
		sum(ss.fdk)as ljfdk
FROM    s_Contract vs WITH ( NOLOCK )
		INNER JOIN p_Project pp WITH ( NOLOCK ) ON vs.ProjGUID = pp.p_projectId
		INNER JOIN s_room sr WITH ( NOLOCK ) ON vs.RoomGUID = sr.RoomGUID
		INNER JOIN s_Building sb WITH ( NOLOCK ) ON sr.BldGUID = sb.BldGUID
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = vs.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		left outer join (
			select 
				 g.SaleGUID,
				 case when v.VouchType='放款单' then v.KpDate else v.SkDate end as SkDate,
				 case when g.ItemType='贷款类房款' then g.RmbAmount else 0 end as dk,
				 case when g.ItemType='非贷款类房款' then g.RmbAmount else 0 end as fdk
			from s_Voucher v WITH ( NOLOCK ) inner join s_getin g WITH ( NOLOCK ) on v.VouchGUID=g.VouchGUID
			where ISNULL(v.VouchStatus,'')<>'作废'
		) ss on vs.TradeGUID=ss.SaleGUID
WHERE sb.BldGUID in (select BldGuid from @dtBld)
	   and ( vs.status = '激活')
GROUP BY vs.RoomGUID
),
p as (SELECT  
			BldGUID,
			BldName,
			--RoomGUID,
			--OCloseReason,
			--CCloseReason,
			--OCloseDate,
			--CCloseDate,
			sum(1) 签约退房套数,
			sum(CCjBldArea) 签约退房面积,
			sum(CCjTotal) 签约退房金额
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE CCloseReason='退房' and CCloseDate BETWEEN @var_BgnDate AND @var_EndDate
	group by BldGUID,BldName),
v as (SELECT  
			BldGUID,
			BldName,
			--RoomGUID,
			--OCloseReason,
			--CCloseReason,
			--OCloseDate,
			--CCloseDate,
			sum(1) 认购退房套数,
			sum(OCjBldArea) 认购退房面积,
			sum(OCjTotal) 认购退房金额
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE OCloseReason='退房' and OCloseDate BETWEEN @var_BgnDate AND @var_EndDate
	group by BldGUID,BldName)

--总货量	已推剩余量		未推剩余量		已售情况	回款情况(元）		
 select t.*,p.签约退房套数,p.签约退房面积,p.签约退房金额,v.认购退房金额,v.认购退房套数,v.认购退房面积 from(
select  a.BUName,a.ProjName,a.ProductTypeName,a.BldName,a.BldGUID,
		 isnull(SUM(1),0)  AS 总货量套数,    
		 isnull(SUM(a.BldArea ),0)  AS 总货量面积, 
		 isnull(SUM(a.RoomHz ),0)  AS 动态总货量, 
		 AVG(a.BaBldPrice) AS 目标均价,
		 AVG(a.DjBldPrice) AS 保底均价,
		 SUM(a.BaTotal) AS 目标货值,
		 SUM(a.DjTotal) AS 保底货值,
		 isnull(SUM(case when a.status = '销控' then 1 else 0 end ),0)  AS 未推套数,    
		 isnull(SUM(case when a.status = '销控' then a.BldArea else 0 end  ),0)  AS 未推面积, 
		 isnull(SUM(case when a.status = '销控' then a.RoomHz else 0 end  ),0)  AS 未推金额, 
		 isnull(SUM(case when a.status in ('待售','预留','小订') then 1 else 0 end ),0)  AS 已推套数,    
		 isnull(SUM(case when a.status in ('待售','预留','小订') then a.BldArea else 0 end  ),0)  AS 已推面积, 
		 isnull(SUM(case when a.status in ('待售','预留','小订') then a.RoomHz else 0 end  ),0)  AS 已推金额, 
		 isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 本期认购套数,
		 isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then d.BldArea else 0 end),0) as 本期认购面积,
		 isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then d.CjRmbTotal else 0 end),0) as 本期认购金额,
		isnull(sum(case when a.Status ='销控' then 0 else 1 end),0)-isnull(sum(case when d.saletype='认购' and d.QSDate <=	@var_EndDate then 1 else 0 end),0) as 本期放盘未售套数,
		isnull(sum(case when a.Status ='销控' then 0 else a.BldArea end),0)-isnull(sum(case when d.saletype='认购' and d.QSDate <=	@var_EndDate then d.BldArea else 0 end),0) as 本期放盘未售面积,
		isnull(sum(case when a.Status ='销控' then 0 else a.RoomHz end),0)-isnull(sum(case when d.saletype='认购' and d.QSDate <=	@var_EndDate then d.CjRmbTotal else 0 end),0) as 本期放盘未售金额,

		 isnull(sum(case when 
		 d.QSDate  BETWEEN @var_BgnDate AND @var_EndDate and
		 b.saletype='签约' and  (b.QSDate>@var_EndDate or b.QSDate<@var_BgnDate ) then 1 else 0 end),0)
		 +isnull(sum(case when b.saletype='认购' and b.QSDate  BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0)
		  as 本期认购未签约套数,
				   isnull(sum(case when 
		 d.QSDate  BETWEEN @var_BgnDate AND @var_EndDate and
		 b.saletype='签约' and  (b.QSDate>@var_EndDate or b.QSDate<@var_BgnDate ) then b.BldArea else 0 end),0)
		 +isnull(sum(case when b.saletype='认购' and b.QSDate  BETWEEN @var_BgnDate AND @var_EndDate then b.BldArea else 0 end),0)
		  as 本期认购未签约面积,
				   isnull(sum(case when 
		 d.QSDate  BETWEEN @var_BgnDate AND @var_EndDate and
		 b.saletype='签约' and  (b.QSDate>@var_EndDate or b.QSDate<@var_BgnDate ) then b.CjRmbTotal else 0 end),0)
		 +isnull(sum(case when b.saletype='认购' and b.QSDate  BETWEEN @var_BgnDate AND @var_EndDate then b.CjRmbTotal else 0 end),0)
		  as 本期认购未签约金额,
		


		 isnull(sum(case when d.saletype='认购' then 1 else 0 end),0) as 累计认购套数,
		 isnull(sum(case when d.saletype='认购' then d.BldArea else 0 end),0) as 累计认购面积,
		 isnull(sum(case when d.saletype='认购' then d.CjRmbTotal else 0 end),0) as 累计认购金额,

		 isnull(sum(case when b.saletype='认购' then 1 else 0 end),0) as 累计认购未签约套数,
		 isnull(sum(case when b.saletype='认购' then b.BldArea else 0 end),0) as 累计认购未签约面积,
		 isnull(sum(case when b.saletype='认购' then b.CjRmbTotal else 0 end),0) as 累计认购未签约金额,

		 isnull(sum(case when b.saletype='认购' and GETDATE()>b.YqyDate then 1 else 0 end),0) as 累计逾期认购未签约套数,
		 isnull(sum(case when b.saletype='认购' and GETDATE()>b.YqyDate then b.BldArea else 0 end),0) as 累计逾期认购未签约面积,
		 isnull(sum(case when b.saletype='认购' and GETDATE()>b.YqyDate then b.CjRmbTotal else 0 end),0) as 累计逾期认购未签约金额,

		 isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 本期签约套数,
		 isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then b.BldArea else 0 end),0) as 本期签约面积,
		 isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then b.CjRmbTotal else 0 end),0) as 本期签约金额,
		 isnull(sum(case when b.saletype='签约' then 1 else 0 end),0) as 累计签约套数,
		 isnull(sum(case when b.saletype='签约' then b.BldArea else 0 end),0) as 累计签约面积,
		 isnull(sum(case when b.saletype='签约' then b.CjRmbTotal else 0 end),0) as 累计签约金额,
		 
		 isnull(sum(c.bqdk),0) as 本期签约回款_贷款类房款,
		 isnull(sum(c.bqfdk),0) as 本期签约回款_非贷款类房款,
		 isnull(sum(c.bqdk),0)+isnull(sum(c.bqfdk),0) as 本期签约回款_合计,
		 isnull(sum(c.ljdk),0) as 累计签约回款_贷款类房款,
		 isnull(sum(c.ljfdk),0) as 累计签约回款_非贷款类房款,
		 isnull(sum(c.ljdk),0)+isnull(sum(c.ljfdk),0) as 累计签约回款_合计,
		 isnull(COUNT(b.RoomGUID ),0)  AS 已售套数,    
		 isnull(SUM(b.BldArea ),0)  AS 已售面积, 
		 isnull(SUM(b.CjRmbTotal ),0)  AS 已售金额,
		 isnull(SUM(b.QkTotal ),0)  AS 未回款
from 
rpt_p_Room a 
left join rpt_Sale b ON a.RoomGUID = b.RoomGUID
left join rpt_Getin c ON a.RoomGUID = c.RoomGUID
left join rpt_Sale2 d ON a.RoomGUID = d.RoomGUID


group by a.BUName,a.ProjName,a.ProductTypeName,a.BldName,a.bldGUID ) t 
left join v on t.BldGUID=v.BldGUID
left join p on t.BldGUID=p.BldGUID

end 

--			sum(CCjBldArea) qymj,
			--sum(CCjTotal) qyje
--isnull(sum(case when t.OCloseReason='退房' and t.OCloseDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 认购退房套数,
--		 isnull(sum(case when t.OCloseReason='退房' and t.OCloseDate BETWEEN @var_BgnDate AND @var_EndDate then t.OCjBldArea else 0 end),0) as 认购退房面积,
--		 isnull(sum(case when t.OCloseReason='退房' and t.OCloseDate BETWEEN @var_BgnDate AND @var_EndDate then t.OCjTotal else 0 end),0) as 认购退房金额,
--		 isnull(sum(case when t.CCloseReason='退房' and t.CCloseDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 签约退房套数,
--		 isnull(sum(case when t.CCloseReason='退房' and t.CCloseDate BETWEEN @var_BgnDate AND @var_EndDate then t.CCjBldArea else 0 end),0) as 签约退房面积,
--		 isnull(sum(case when t.CCloseReason='退房' and t.CCloseDate BETWEEN @var_BgnDate AND @var_EndDate then t.CCjTotal else 0 end),0) as 签约退房金额,

GO





