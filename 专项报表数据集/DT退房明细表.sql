SELECT  vs_rpt_checkout.ProjGUID ,
vs_rpt_checkout.BUGUID ,
mw.ProcessGUID,
vp_interface_project.ProjectFullName ,
s_room.RoomInfo ,
p_MasterDataProductType.Name AS ProductTypeName ,
pmpt2.Name AS fjProductTypeName ,
case when pmpt2.Name in ('车位') then 0 
	 when pmpt2.Name <> '车位' and p_MasterDataProductType.Name='储藏间' then 0 
	 else 1 end as ts,
s_Trade.BuyerAllNames ,
CONVERT(VARCHAR(10), vs_rpt_checkout.OrderQSDate, 121) AS OrderQSDate ,
CONVERT(VARCHAR(10), vs_rpt_checkout.ContractQSDate, 121) AS ContractQSDate ,
CONVERT(VARCHAR(10), vs_rpt_checkout.NetContractDate, 121) AS NetContractDate,
vs_rpt_checkout.CjRmbTotal ,
TotalGetin.BeforeRmbYe ,
vs_rpt_checkout.Reason ,
MAuditName,CONVERT(VARCHAR(10),MAuditDate ,121) AS AuditDate,
CONVERT(VARCHAR(10), vs_rpt_checkout.ExecDate, 121) AS ExecDate ,
vs_rpt_checkout.ExecName,
case when mwd.DomainValue=1 then '退定金退房'
when mwd.DomainValue=2 then '不足额扣款退房'
when mwd.DomainValue=3 then '足额扣款退房'
when mwd.DomainValue=4 then '法院判决书/司法调解书生效后退房' end AS 退房类型,
case when mwd2.DomainValue=1 then '是'
when mwd2.DomainValue=2 then '否' end AS 是否挞定款项,
mwd3.DomainValue AS 挞定金额,
mwd4.DomainValue AS 是否纳入考核比例,
mwd5.DomainValue AS 考核比例
FROM    vs_rpt_checkout WITH ( NOLOCK )
INNER JOIN vp_interface_project WITH ( NOLOCK ) ON vs_rpt_checkout.ProjGUID = vp_interface_project.ProjectId
INNER JOIN dbo.s_room WITH ( NOLOCK ) ON dbo.vs_rpt_checkout.RoomGuid = s_room.RoomGUID
INNER JOIN s_Trade WITH ( NOLOCK ) ON dbo.vs_rpt_checkout.TradeGUID = dbo.s_Trade.TradeGUID
INNER JOIN s_Building WITH ( NOLOCK ) ON s_Building.BldGUID = s_Room.BldGUID
INNER JOIN p_MasterDataProductType WITH ( NOLOCK ) ON p_MasterDataProductType.p_MasterDataProductTypeId = s_Building.ProductTypeGUID
INNER JOIN p_MasterDataProductType pmpt2 WITH ( NOLOCK ) ON p_MasterDataProductType.ParentId = pmpt2.p_MasterDataProductTypeId and p_MasterDataProductType.ParentId<>'00000000-0000-0000-0000-000000000000'
LEFT JOIN ( SELECT  s_Getin.SaleGUID ,
					SUM(BeforeRmbYe) AS BeforeRmbYe
			FROM    s_Getin WITH ( NOLOCK )
			WHERE   ( ItemTypeGUID = '4D402C5B-DE7B-437E-956F-8178DA46BBF2'
					  OR ItemTypeGUID = '716D2B9D-E1CF-4039-8DBE-8CB01CECA6FF'
					)
					AND s_Getin.StatusEnum NOT IN ( 1, 2 )
					AND dbo.s_Getin.IsSysCx = 0
			GROUP BY dbo.s_Getin.SaleGUID
		  ) TotalGetin ON s_Trade.TradeGUID = TotalGetin.SaleGUID
LEFT JOIN myWorkflowProcessEntity mw on vs_rpt_checkout.SaleModiApplyGUID=mw.BusinessGUID
LEFT JOIN (select  ProcessGUID,max(DomainName) DomainName,max(DomainValue) DomainValue from myWorkflowProcessEntityDomains
WHERE DomainName='退房类型' group by ProcessGUID) mwd on mw.ProcessGUID=mwd.ProcessGUID 
LEFT JOIN  (select  ProcessGUID,max(DomainName) DomainName,max(DomainValue) DomainValue from myWorkflowProcessEntityDomains
WHERE DomainName='是否挞定款项' group by ProcessGUID) mwd2 on mw.ProcessGUID=mwd2.ProcessGUID  
LEFT JOIN  (select  ProcessGUID,max(DomainName) DomainName,max(DomainValue) DomainValue from myWorkflowProcessEntityDomains
WHERE DomainName='挞定金额' group by ProcessGUID) mwd3 on mw.ProcessGUID=mwd3.ProcessGUID 
LEFT JOIN  (select  ProcessGUID,max(DomainName) DomainName,max(DomainValue) DomainValue from myWorkflowProcessEntityDomains
WHERE DomainName='是否纳入考核比例' group by ProcessGUID) mwd4 on mw.ProcessGUID=mwd4.ProcessGUID 
LEFT JOIN  (select  ProcessGUID,max(DomainName) DomainName,max(DomainValue) DomainValue from myWorkflowProcessEntityDomains
WHERE DomainName='考核比例' group by ProcessGUID) mwd5 on mw.ProcessGUID=mwd5.ProcessGUID 

order by mwd4.DomainValue
--WHERE   vs_rpt_checkout.ExecDate BETWEEN @BeginDate
--                                 AND     @EndDate
--        AND vs_rpt_checkout.ProjGUID IN ( @ProjGuids )

