 
--declare @var_BgnDate datetime='2021-01-01'
--declare @var_EndDate datetime='2022-01-01';
with 
 rpt_p_Room        
 as        
 ( select  mu.BUName ,mu.BUGUID, sr.ProjGUID ,p.ProjName, p.RightsRate,p.x_isMerge as isMerge,sr.RoomGUID,
  sr.BldGUID ,sb.BldName ,sb.ProductTypeGUID,pmpt.Name ProductTypeName,sr.Status ,
  sr.BldArea, sr.Total,
  cast(case when sr.Status='签约' or sr.Status='认购' then c.CjRmbTotal 
		else (case when isnull(sr.DjTotal,0)<>0 then sr.DjTotal else isnull(mb.targetUnitPrice,0)*
		(case when charindex('车位',pmpt.Name)>0 or charindex('车库',pmpt.Name)>0 then 1 else sr.BldArea end) end) end 
		as decimal(18,2))  as RoomHz
	from  dbo.s_Room  sr WITH ( NOLOCK ) 
		INNER join dbo.s_Building  sb WITH ( NOLOCK ) on sr.BldGUID = sb.BldGUID            
		INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
		INNER JOIN p_Project P WITH ( NOLOCK ) on sr.ProjGUID = p.p_projectId
		INNER JOIN myBusinessUnit mu WITH ( NOLOCK ) ON mu.BUGUID = sr.BUGUID and mu.IsEndCompany=1 and mu.BUType=1
		inner join mdm_Building mb on sb.MasterBldGUID=mb.BuildingGUID
		left outer join s_contract c WITH ( NOLOCK ) on sr.RoomGUID=c.RoomGUID and c.status='激活'
  -- WHERE sb.BldGUID in (select BldGuid from @dtBld) and sb.ProductTypeGUID in (select ProdGuid from @dtProd)
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
--WHERE sb.BldGUID in (select BldGuid from @dtBld)  
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
--WHERE sb.BldGUID in (select BldGuid from @dtBld) 
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
WHERE --sb.BldGUID in (select BldGuid from @dtBld)  AND 
T.TradeStatus='激活'
	   and (vs.status = '激活' or (vs.status = '关闭' and vs.CloseReason = '转签约'))
),

 rpt_Getin
as (
SELECT  vs.RoomGUID,
		sum(case when ((datediff(day,vs.qsdate,@var_BgnDate)<=0 and datediff(day,vs.qsdate,@var_EndDate)>=0) 
		and datediff(day,ss.SkDate,@var_EndDate)>=0) or (datediff(day,vs.qsdate,@var_BgnDate)>0 
		and (datediff(day,ss.SkDate,@var_BgnDate)<=0 and datediff(day,ss.SkDate,@var_EndDate)>=0)) then ss.dk else 0 end) as bqdk,
		sum(case when ((datediff(day,vs.qsdate,@var_BgnDate)<=0 and datediff(day,vs.qsdate,@var_EndDate)>=0) 
		and datediff(day,ss.SkDate,@var_EndDate)>=0) or (datediff(day,vs.qsdate,@var_BgnDate)>0 
		and (datediff(day,ss.SkDate,@var_BgnDate)<=0 and datediff(day,ss.SkDate,@var_EndDate)>=0)) then ss.fdk else 0 end) as bqfdk,
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
WHERE --sb.BldGUID in (select BldGuid from @dtBld) and 
( vs.status = '激活')
GROUP BY vs.RoomGUID
),
bqrg as (
select 
z.x_ProjGUID,
x_xscpytGUID,
x_xscpyename,
sum(x_rgts) 本期认购套数,sum(x_rgmj) 本期认购面积,sum(x_rgje) 本期认购金额,
sum(x_qyts) 本期签约套数,sum(x_qymj) 本期签约面积,sum(x_qyje) 本期签约金额,
sum(x_hkje) 本期回款金额
from x_xsqkzb z
left join  x_xsqkmxb mx on z.xsqkzbGUID=mx.x_xsqkzbGUID
where x_xstjsj between @var_BgnDate and @var_EndDate
group by 
z.x_ProjGUID,
x_xscpytGUID,
x_xscpyename
),
ljrg as (
select 
z.x_ProjGUID,
x_xscpytGUID,
x_xscpyename,
sum(x_rgts) 累计认购套数,sum(x_rgmj) 累计认购面积,sum(x_rgje) 累计认购金额,
sum(x_qyts) 累计签约套数,sum(x_qymj) 累计签约面积,sum(x_qyje) 累计签约金额,
sum(x_hkje) 累计回款金额
from x_xsqkzb z
left join  x_xsqkmxb mx on z.xsqkzbGUID=mx.x_xsqkzbGUID
group by 
z.x_ProjGUID,
x_xscpytGUID,
x_xscpyename
),
ljhz as (
select 
x_ProjGUID,
x_hzcpytGUID,
x_hzcpyename,
sum(x_Hzts) 货值套数,
sum(x_Hzmj) 货值面积,
sum(x_Hzje) 货值金额
from x_xmxshzzb z
left join x_xmxshzmxb mx on z.xmxshzzbGUID=mx.x_xmxshzzbGUID
group by 
x_ProjGUID,
x_hzcpytGUID,
x_hzcpyename)

select T.ProjGUID,T.ProjName,
sum(t.本期认购套数) 本期认购套数,
sum(t.本期认购面积) 本期认购面积,
sum(t.本期认购金额) 本期认购金额,
sum(t.本期签约套数) 本期签约套数,
sum(t.本期签约面积) 本期签约面积,
sum(t.本期签约金额) 本期签约金额,
sum(t.本期签约回款_合计) 本期回款,
sum(t.累计认购套数) 累计认购套数,
sum(t.累计认购面积) 累计认购面积,
sum(t.累计认购金额) 累计认购金额,
sum(t.累计签约套数) 累计签约套数,
sum(t.累计签约面积) 累计签约面积,
sum(t.累计签约金额) 累计签约金额,
sum(t.累计签约回款_合计) 累计回款,
sum(t.总货量套数) 总货量套数,
sum(t.总货量面积) 总货量面积,
sum(t.总货量金额) 总货量金额,
sum(t.未售剩余套数) 未售剩余套数,
sum(t.未售剩余面积) 未售剩余面积,
sum(t.未售剩余金额) 未售剩余金额,

sum(x.x_Mbrgts) 目标认购套数,
sum(x.x_Mbrgmj) 目标认购面积,
sum(x.x_Mbrgje) 目标认购金额,
sum(x.x_Mbqyts) 目标签约套数,
sum(x.x_Mbqymj) 目标签约面积,
sum(x.x_Mbqyje) 目标签约金额,
sum(x.x_Mbhkje) 目标回款金额,

case when sum(x.x_Mbrgje)=0 then 0 else 
sum(t.本期认购金额)/sum(x.x_Mbrgje) end as 本期认购完成率,
case when sum(x.x_Mbqymj)=0 then 0 else 
sum(t.本期签约面积)/sum(x.x_Mbqymj) end as 本期签约面积完成率,
case when sum(x.x_Mbqyje)=0 then 0 else 
sum(t.本期签约金额)/sum(x.x_Mbqyje) end as 本期签约完成率,
case when sum(x.x_Mbhkje)=0 then 0 else 
sum(t.本期签约回款_合计)/sum(x.x_Mbhkje) end as 本期回款完成率

from (

--总货量	已推剩余量		未推剩余量		已售情况	回款情况(元）		

select  '市政公用地产' as BUName,a.ProjGUID,a.ProjName,a.RightsRate,
case when a.isMerge=0 then '合并项目'  when a.isMerge=1 then '非合并项目' else null end as isMerge,


	isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 本期认购套数,
	isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then d.BldArea else 0 end),0) as 本期认购面积,
	isnull(sum(case when d.saletype='认购' and d.QSDate BETWEEN @var_BgnDate AND @var_EndDate then d.CjRmbTotal else 0 end),0)/10000 as 本期认购金额,
	
	isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then 1 else 0 end),0) as 本期签约套数,
	isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then b.BldArea else 0 end),0) as 本期签约面积,
	isnull(sum(case when b.saletype='签约' and b.QSDate BETWEEN @var_BgnDate AND @var_EndDate then b.CjRmbTotal else 0 end),0)/10000 as 本期签约金额,

	--isnull(sum(c.bqdk),0) as 本期签约回款_贷款类房款,
	--isnull(sum(c.bqfdk),0) as 本期签约回款_非贷款类房款,
	isnull(sum(c.bqdk),0)+isnull(sum(c.bqfdk),0)/10000 as 本期签约回款_合计,

	isnull(sum(case when d.saletype='认购' then 1 else 0 end),0) as 累计认购套数,
	isnull(sum(case when d.saletype='认购' then d.BldArea else 0 end),0) as 累计认购面积,
	isnull(sum(case when d.saletype='认购' then d.CjRmbTotal else 0 end),0)/10000 as 累计认购金额,

	isnull(sum(case when b.saletype='签约' then 1 else 0 end),0) as 累计签约套数,
	isnull(sum(case when b.saletype='签约' then b.BldArea else 0 end),0) as 累计签约面积,
	isnull(sum(case when b.saletype='签约' then b.CjRmbTotal else 0 end),0)/10000 as 累计签约金额,
		 

	--isnull(sum(c.ljdk),0) as 累计签约回款_贷款类房款,
	--isnull(sum(c.ljfdk),0) as 累计签约回款_非贷款类房款,
	isnull(sum(c.ljdk),0)+isnull(sum(c.ljfdk),0)/10000 as 累计签约回款_合计,

	isnull(SUM(1),0)  AS 总货量套数,    
	isnull(SUM(a.BldArea ),0)  AS 总货量面积, 
	isnull(SUM(a.RoomHz ),0)/10000  AS 总货量金额, 
 
	isnull(SUM(case when a.status in ('销控','待售','预留','小订') then 1 else 0 end ),0)  AS 未售剩余套数,    
	isnull(SUM(case when a.status in ('销控','待售','预留','小订') then a.BldArea else 0 end  ),0)  AS 未售剩余面积, 
	isnull(SUM(case when a.status in ('销控','待售','预留','小订') then a.RoomHz else 0 end  ),0)/10000  AS 未售剩余金额

	--isnull(COUNT(b.RoomGUID ),0)  AS 已售套数,    
	--isnull(SUM(b.BldArea ),0)  AS 已售面积, 
	--isnull(SUM(b.CjRmbTotal ),0)  AS 已售金额,
	--isnull(SUM(b.QkTotal ),0)  AS 未回款
from 
rpt_p_Room a 
left join rpt_Sale b ON a.RoomGUID = b.RoomGUID
left join rpt_Getin c ON a.RoomGUID = c.RoomGUID
left join rpt_Sale2 d ON a.RoomGUID = d.RoomGUID
--where a.ProjGUID in (@ProjGUID)
group by a.BUName,a.ProjName,a.ProjGUID ,a.RightsRate,a.isMerge



union all
select 
'市政公用地产' buname,
bqrg.x_ProjGUID,
p.ProjName,
p.RightsRate,
case when p.x_IsMerge=0 then '合并项目' when p.x_IsMerge=1 then '非合并项目' else null end as IsMerge,
sum(bqrg.本期认购套数),sum(bqrg.本期认购面积),sum(bqrg.本期认购金额),
sum(bqrg.本期签约套数),sum(bqrg.本期签约面积),sum(bqrg.本期签约金额),
sum(bqrg.本期回款金额),
sum(ljrg.累计认购套数),sum(ljrg.累计认购面积),sum(ljrg.累计认购金额),
sum(ljrg.累计签约套数),sum(ljrg.累计签约面积),sum(ljrg.累计签约金额),
sum(ljrg.累计回款金额),
sum(ljhz.货值套数),sum(ljhz.货值面积),sum(ljhz.货值金额),
sum(isnull(ljhz.货值套数,0))-sum(isnull(ljrg.累计认购套数,0)) AS 未售剩余套数,
sum(isnull(ljhz.货值面积,0))-sum(isnull(ljrg.累计认购面积,0)) AS 未售剩余面积,
sum(isnull(ljhz.货值金额,0))-sum(isnull(ljrg.累计认购金额,0)) AS 未售剩余金额
from bqrg
left join ljrg on bqrg.x_ProjGUID=ljrg.x_ProjGUID and bqrg.x_xscpytGUID=ljrg.x_xscpytGUID
 join ljhz on ljhz.x_ProjGUID=ljrg.x_ProjGUID and ljhz.x_hzcpytGUID=ljrg.x_xscpytGUID
inner join p_Project p on bqrg.x_ProjGUID=p.p_projectId 
--where bqrg.x_ProjGUID in (@ProjGUID)
group by 
bqrg.x_ProjGUID,
p.ProjName,
p.RightsRate,
x_IsMerge
)t
left join x_xsmbb x on t.ProjGUID= x.x_ProjGUID and year(x.x_Year)=year(GETDATE())

group by T.ProjGUID,T.ProjName


SELECT DATEDIFF(D,'2021-06-18',GETDATE()) [认识]
,DATEDIFF(D,'2022-02-06',GETDATE()) [见面]
,DATEDIFF(D,'2022-03-25',GETDATE()) [在一起]