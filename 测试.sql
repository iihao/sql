USE [dotnet_erp60]
GO

/****** Object:  StoredProcedure [dbo].[rts_jf_销售报表纵向维度分析_1903]    Script Date: 2021/3/5 10:11:55 ******/
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






