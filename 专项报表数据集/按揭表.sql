SELECT  
--ROW_NUMBER() OVER(ORDER BY r.RoomInfo desc) as xh,
bu.BUFullName BUName,
c.ProjGUID ,
p.ProjectFullName ,
r.RoomInfo,
c.PayFormName,
case when ss.ServiceItemEnum=2 then c.AjBank when ss.ServiceItemEnum=5 then c.GjjBank else null end as AjBank,
t.BuyerAllNames,
p.HierarchyCode ,
b.BldGUID,
b.BldName ,
b.OrderFullCode ,
c.ContractGUID ,
ssp.ServiceProcCode as ServiceProcCode ,
ssp.ServiceProc ,       
ssp.CompleteDate,
ss.ServiceItem,
c.cjrmbtotal,
c.QSDate,
f.ss,
f.ys,
case when ss.ServiceItemEnum=2 then c.AjTotal when ss.ServiceItemEnum=5 thenSS c.GjjTotal else 0 end as DkTotal
FROM    vs_rpt_contract c
INNER JOIN vp_interface_project p WITH (NOLOCK) ON p.ProjectId = c.ProjGUID
INNER JOIN dbo.myBusinessUnit bu WITH (NOLOCK) ON p.BUGUID = bu.BUGUID
INNER JOIN s_room r WITH (NOLOCK) ON r.RoomGUID = c.RoomGuid
INNER JOIN s_Building b WITH (NOLOCK) ON b.BldGUID = r.BldGUID
INNER JOIN s_SaleService ss WITH (NOLOCK) ON ss.SaleGUID = c.ContractGUID AND 
(ss.ServiceItemEnum = 2 or ss.ServiceItemEnum = 5 )/*按揭服务*/ 
LEFT JOIN s_SaleServiceProc ssp ON  ssp.SaleServiceGUID=ss.s_SaleServiceGUID
left join s_Trade t on t.TradeGUID=c.TradeGUID
left join (select TradeGUID,,sum(RmbAmount) as ys,sum(RmbAmount)-sum(RmbYe) as ss from s_Fee group by TradeGUID) f on f.TradeGUID=t.TradeGUID
WHERE p.ProjectId IN ( @ProjGUID ) AND b.BldGUID IN ( @BldGUID )
and c.QSDate between @BgnDate and @EndDate


sum(case when ItemName='首期' then RmbAmount else 0 end) as yssf



SELECT DISTINCT WideGUID
FROM s_Contract Contract
LEFT JOIN s_SaleService s
ON Contract.ContractGUID = s.SaleGUID
WHERE s.SaleServiceGUID=@SaleServiceGUID




SELECT  WideGUID 
FROM (
	SELECT o.WideGUID,
		   o.OrderGUID AS SaleGUID
	FROM s_Order o
	WHERE o.OrderTypeEnum = 0
	UNION ALL
	SELECT c.WideGUID,
		   c.ContractGUID  AS SaleGUID
	FROM s_Contract c
) sale
INNER JOIN s_SaleModiApply ON sale.SaleGUID=s_SaleModiApply.SaleGUID OR s_SaleModiApply.NewSaleGUID = sale.SaleGUID
WHERE SaleModiApplyGUID=@SaleModiApplyGUID  AND s_SaleModiApply.ApplyStatusEnum = 1