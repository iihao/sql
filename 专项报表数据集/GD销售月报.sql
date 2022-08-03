
SET DATEFIRST 1
--DECLARE @SelectDate Date =GetDate() /*本*/
DECLARE @weekstartday Date =DATEADD(WEEK, DATEDIFF(WEEK, 0, CONVERT(DATETIME, @SelectDate, 120) - 1), 0) /*本周一*/
DECLARE @weekendday Date =DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, CONVERT(DATETIME,@SelectDate, 120) - 1), 0)) /*本周周*/
DECLARE @monthstartday Date =DATEADD(day, 1 - day(@SelectDate), @SelectDate) /*本月始*/
DECLARE @monthendday Date =DATEADD(day, -1, DATEADD(month, 1, @monthstartday))/*本月末*/
declare @yearstartday Date =cast(year(@SelectDate) as varchar(4)) + '-01-01'
declare @yearendday Date =DATEADD(day, -1, DATEADD(year, 1, @yearstartday));

WITH
/*认购（回溯）*/
RG
AS (SELECT 
		ProjGUID,
		ProductTypeGUID,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN OCjBldArea ELSE 0 END) AS 本周认购面积,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN OCjTotal ELSE 0 END)/10000 AS 本周认购金额,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN ts ELSE　0 END) AS 本周认购套数,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN OCjBldArea ELSE 0 END) AS 本月认购面积,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN OCjTotal ELSE 0 END)/10000 AS 本月认购金额,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN ts ELSE　0 END) AS 本月认购套数,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN OCjBldArea ELSE 0 END) AS 本年认购面积,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN OCjTotal ELSE 0 END)/10000 AS 本年认购金额,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN ts ELSE　0 END) AS 本年认购套数
	FROM dbo.data_wide_s_SaleHsData WITH (NOLOCK)
	WHERE  TradeType IN ('签约', '认购','小订') and CreateReason<>'退房' and CloseReason<>'退房'
	group by ProjGUID,
		ProductTypeGUID
   ),
/*签约（回溯）*/
QY
AS (SELECT 
		ProjGUID,
		ProductTypeGUID,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN CCjBldArea ELSE 0 END) AS 本周签约面积,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN CCjTotal  ELSE 0 END)/10000 AS 本周签约金额,
		sum(CASE WHEN HsTjDate between @weekstartday and @weekendday  THEN 1  ELSE 0 END) AS 本周签约套数,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN CCjBldArea ELSE 0 END) AS 本月签约面积,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN CCjTotal  ELSE 0 END)/10000 AS 本月签约金额,
		sum(CASE WHEN HsTjDate between @monthstartday and @monthendday  THEN 1  ELSE 0 END) AS 本月签约套数,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN CCjBldArea ELSE 0 END) AS 本年签约面积,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN CCjTotal  ELSE 0 END)/10000 AS 本年签约金额,
		sum(CASE WHEN HsTjDate between @yearstartday and @yearendday  THEN 1  ELSE 0 END) AS 本年签约套数
	FROM dbo.data_wide_s_SaleHsData WITH (NOLOCK)
	WHERE  TradeType ='签约' and CreateReason<>'退房' and CloseReason<>'退房'
	group by ProjGUID,
		ProductTypeGUID
   
   ),
TF
AS (
SELECT 
	ProductTypeGUID,ProjGUID,
	SUM(CASE WHEN CloseDate between @weekstartday and @weekendday  THEN 1 ELSE 0 END) AS 本周退房套数 ,
	SUM(CASE WHEN CloseDate between @weekstartday and @weekendday  THEN CjBldArea ELSE 0 END) AS 本周退房面积 ,
	SUM(CASE WHEN CloseDate between @weekstartday and @weekendday  THEN CjTotal ELSE 0 END)/10000  AS 本周退房金额 ,
	SUM(CASE WHEN CloseDate between @weekstartday and @weekendday  AND Reason='认购退房' THEN 1 ELSE 0 END) AS 本周认购退房套数 ,
	SUM(CASE WHEN CloseDate between @weekstartday and @weekendday  AND Reason='签约退房' THEN 1 ELSE 0 END) AS 本周签约退房套数 ,

	SUM(CASE WHEN CloseDate between @monthstartday and @monthendday  THEN 1 ELSE 0 END) AS 本月退房套数 ,
	SUM(CASE WHEN CloseDate between @monthstartday and @monthendday  THEN CjBldArea ELSE 0 END) AS 本月退房面积 ,
	SUM(CASE WHEN CloseDate between @monthstartday and @monthendday  THEN CjTotal ELSE 0 END)/10000  AS 本月退房金额 ,
	SUM(CASE WHEN CloseDate between @monthstartday and @monthendday  AND Reason='认购退房' THEN 1 ELSE 0 END) AS 本月认购退房套数 ,
	SUM(CASE WHEN CloseDate between @monthstartday and @monthendday  AND Reason='签约退房' THEN 1 ELSE 0 END) AS 本月签约退房套数 ,
	
	SUM(CASE WHEN CloseDate between @yearstartday and @yearendday  THEN 1 ELSE 0 END) AS 本年退房套数 ,
	SUM(CASE WHEN CloseDate between @yearstartday and @yearendday  THEN CjBldArea ELSE 0 END) AS 本年退房面积 ,
	SUM(CASE WHEN CloseDate between @yearstartday and @yearendday  THEN CjTotal ELSE 0 END)/10000  AS 本年退房金额 ,
	SUM(CASE WHEN CloseDate between @yearstartday and @yearendday  AND Reason='认购退房' THEN 1 ELSE 0 END) AS 本年认购退房套数 ,
	SUM(CASE WHEN CloseDate between @yearstartday and @yearendday  AND Reason='签约退房' THEN 1 ELSE 0 END) AS 本年签约退房套数
FROM(
	SELECT ProjGUID,ProductTypeGUID,OCloseDate AS CloseDate,
		OCjBldArea AS CJBldArea,OCjTotal AS CJTotal,'认购退房' AS Reason
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE OCloseReason='退房' 
	UNION ALL
	SELECT ProjGUID,ProductTypeGUID,CCloseDate,
		CCjBldArea,CCjTotal,'签约退房'
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE CCloseReason='退房' 
	)T
GROUP BY  ProductTypeGUID,ProjGUID

   ),
   HK AS (
	SELECT
		Getin.ProjGUID,
		Getin.ProductTypeGUID,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @weekstartday and @weekendday AND Getin.SaleType != '预约单' THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本周预约金回款,
		SUM(CASE WHEN  Getin.SkDate between @weekstartday and @weekendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本周总回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @weekstartday and @weekendday AND Getin.ItemType='非贷款类房款' 
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本周非贷款回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @weekstartday and @weekendday AND Getin.ItemNameGUID = '9165FAED-227A-465D-AA5D-D24BED655677' /*银行按揭*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本周按揭回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @weekstartday and @weekendday AND Getin.ItemNameGUID = 'C3190DC3-C295-4A98-B7AC-9DFF7D7A0091' /*公积金*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本周公积金回款,
		SUM(CASE WHEN Getin.VouchType='退款单' AND Getin.SkDate between @weekstartday and @weekendday  THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本周退款,

		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @monthstartday and @monthendday AND Getin.SaleType != '预约单' THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本月预约金回款,
		SUM(CASE WHEN  Getin.SkDate between @monthstartday and @monthendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月总回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @monthstartday and @monthendday AND Getin.ItemType='非贷款类房款' 
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月非贷款回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @monthstartday and @monthendday AND Getin.ItemNameGUID = '9165FAED-227A-465D-AA5D-D24BED655677' /*银行按揭*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本月按揭回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @monthstartday and @monthendday AND Getin.ItemNameGUID = 'C3190DC3-C295-4A98-B7AC-9DFF7D7A0091' /*公积金*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本月公积金回款,
		SUM(CASE WHEN Getin.VouchType='退款单' AND Getin.SkDate between @monthstartday and @monthendday  THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本月退款,
				
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @yearstartday and @yearendday AND Getin.SaleType != '预约单' THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本年预约金回款,
		SUM(CASE WHEN  Getin.SkDate between @yearstartday and @yearendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本年总回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @yearstartday and @yearendday AND Getin.ItemType='非贷款类房款' 
		AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本年非贷款回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @yearstartday and @yearendday AND Getin.ItemNameGUID = '9165FAED-227A-465D-AA5D-D24BED655677' /*银行按揭*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本年按揭回款,
		SUM(CASE WHEN Getin.VouchType<>'退款单' AND Getin.SkDate between @yearstartday and @yearendday AND Getin.ItemNameGUID = 'C3190DC3-C295-4A98-B7AC-9DFF7D7A0091' /*公积金*/ 
		THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本年公积金回款,
		SUM(CASE WHEN Getin.VouchType='退款单' AND Getin.SkDate between @yearstartday and @yearendday  THEN Getin.RmbAmount ELSE 0 END)/10000 AS 本年退款,
				
		
	FROM data_wide_s_Getin Getin
	WHERE  Getin.SaleType != '预收款'
		AND ISNULL(Getin.VouchStatus, '') != '作废'
	GROUP BY
		Getin.ProjGUID,
		Getin.ProductTypeGUID
)

select distinct r.ProjGUID,r.ParentProjName,r.ProjName,r.ProductTypeGUID,r.ProductTypeName,
ISNULL(RG.本周认购套数,0) 本周认购套数,ISNULL(RG.本周认购面积,0) 本周认购面积,ISNULL(RG.本周认购金额,0) 本周认购金额,
ISNULL(QY.本周签约套数,0) 本周签约套数,ISNULL(QY.本周签约面积,0) 本周签约面积,ISNULL(QY.本周签约金额,0) 本周签约金额,
ISNULL(TF.本周退房套数,0) 本周退房套数,ISNULL(TF.本周退房面积,0) 本周退房面积,ISNULL(TF.本周退房金额,0) 本周退房金额,
ISNULL(HK.本周预约金回款,0) 本周预约金回款,ISNULL(HK.本周非贷款回款,0) 本周非贷款回款,ISNULL(HK.本周按揭回款,0) 本周按揭回款,
ISNULL(HK.本周公积金回款,0) 本周公积金回款,ISNULL(HK.本周退款,0) 本周退款,ISNULL(HK.本周总回款,0) 本周总回款,

ISNULL(RG.本月认购套数,0) 本月认购套数,ISNULL(RG.本月认购面积,0) 本月认购面积,ISNULL(RG.本月认购金额,0) 本月认购金额,
ISNULL(QY.本月签约套数,0) 本月签约套数,ISNULL(QY.本月签约面积,0) 本月签约面积,ISNULL(QY.本月签约金额,0) 本月签约金额,
ISNULL(TF.本月退房套数,0) 本月退房套数,ISNULL(TF.本月退房面积,0) 本月退房面积,ISNULL(TF.本月退房金额,0) 本月退房金额,
ISNULL(HK.本月预约金回款,0) 本月预约金回款,ISNULL(HK.本月非贷款回款,0) 本月非贷款回款,ISNULL(HK.本月按揭回款,0) 本月按揭回款,
ISNULL(HK.本月公积金回款,0) 本月公积金回款,ISNULL(HK.本月退款,0) 本月退款,ISNULL(HK.本月总回款,0) 本月总回款,

ISNULL(RG.本年认购套数,0) 本年认购套数,ISNULL(RG.本年认购面积,0) 本年认购面积,ISNULL(RG.本年认购金额,0) 本年认购金额,
ISNULL(QY.本年签约套数,0) 本年签约套数,ISNULL(QY.本年签约面积,0) 本年签约面积,ISNULL(QY.本年签约金额,0) 本年签约金额,
ISNULL(TF.本年退房套数,0) 本年退房套数,ISNULL(TF.本年退房面积,0) 本年退房面积,ISNULL(TF.本年退房金额,0) 本年退房金额,
ISNULL(HK.本年预约金回款,0) 本年预约金回款,ISNULL(HK.本年非贷款回款,0) 本年非贷款回款,ISNULL(HK.本年按揭回款,0) 本年按揭回款,
ISNULL(HK.本年公积金回款,0) 本年公积金回款,ISNULL(HK.本年退款,0) 本年退款,ISNULL(HK.本年总回款,0) 本年总回款
 from data_wide_s_Room R 
left join RG on RG.ProjGUID=R.ProjGUID and RG.ProductTypeGUID=R.ProductTypeGUID
left join QY on RG.ProjGUID=QY.ProjGUID and RG.ProductTypeGUID=QY.ProductTypeGUID
left join TF on RG.ProjGUID=TF.ProjGUID and RG.ProductTypeGUID=TF.ProductTypeGUID
left join HK on RG.ProjGUID=HK.ProjGUID and RG.ProductTypeGUID=HK.ProductTypeGUID
WHERE r.ProjGUID in (@ProjGUID)
	
