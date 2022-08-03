/*回溯*/
SET DATEFIRST 1
DECLARE @now Date =GetDate() /*本日*/
DECLARE @yesterday Date =DATEADD(day, -1, @now) /*昨日*/
DECLARE @weekstartday Date =DATEADD(WEEK, DATEDIFF(WEEK, 0, CONVERT(DATETIME, @now, 120) - 1), 0) /*本周一*/
DECLARE @weekendday Date =DATEADD(DAY, 6, DATEADD(WEEK, DATEDIFF(WEEK, 0, CONVERT(DATETIME,@now, 120) - 1), 0)) /*本周日*/
DECLARE @monthstartday Date =DATEADD(day, 1 - day(@now), @now) /*本月始*/
DECLARE @monthendday Date =DATEADD(day, -1, DATEADD(month, 1, @monthstartday)) /*本月末*/
DECLARE @yearstartday Date =cast(year(@now) as varchar(4)) + '-01-01'; /*本年始*/
DECLARE @yearendday Date =DATEADD(day, -1, DATEADD(year, 1, @yearstartday)) /*本年末*/
DECLARE @quarterstartday Date =DATEADD(month, (datepart(quarter, @now) - 1) * 3, @yearstartday) /*本季始*/
DECLARE @quarterendday Date =DATEADD(day, -1, DATEADD(quarter, 1, @quarterstartday)); /*本季末*/
WITH 
QY AS (
	SELECT 
		ProjGUID,
		SUM(CASE WHEN HsTjDate = @now  THEN ts ELSE 0 END) AS 本日签约套数 ,
		SUM(CASE WHEN HsTjDate = @now  THEN BldArea ELSE 0 END) AS 本日签约面积 ,
		SUM(CASE WHEN HsTjDate = @now  THEN RmbAmount ELSE 0 END)/10000 AS 本日签约金额 ,
	
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 本日住宅签约套数 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 本日住宅签约面积 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='住宅' THEN RmbAmount ELSE 0 END)/10000 AS 本日住宅签约金额 ,
		
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 本月住宅签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday AND a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 本月住宅签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='住宅' 	THEN RmbAmount ELSE 0 END)/10000 AS 本月住宅签约金额 ,	
			
		SUM(CASE WHEN a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 累计住宅签约套数 ,
		SUM(CASE WHEN a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 累计住宅签约面积 ,
		SUM(CASE WHEN a.TopProductTypeName='住宅'  THEN RmbAmount ELSE 0 END)/10000 AS 累计住宅签约金额 ,

		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 本日商业签约套数 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 本日商业签约面积 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='商业' THEN RmbAmount ELSE 0 END)/10000 AS 本日商业签约金额 ,
		
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 本月商业签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday AND a.TopProductTypeName='商业'  THEN BldArea ELSE 0 END) AS 本月商业签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='商业' 	THEN RmbAmount ELSE 0 END)/10000 AS 本月商业签约金额 ,	
		
		SUM(CASE WHEN a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 累计商业签约套数 ,
		SUM(CASE WHEN a.TopProductTypeName='商业'  THEN BldArea ELSE 0 END) AS 累计商业签约面积 ,
		SUM(CASE WHEN a.TopProductTypeName='商业'  THEN RmbAmount ELSE 0 END)/10000 AS 累计商业签约金额 ,

		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 本日车位签约套数 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 本日车位签约面积 ,
		SUM(CASE WHEN HsTjDate = @now AND a.TopProductTypeName='车库/库房' THEN RmbAmount ELSE 0 END)/10000 AS 本日车位签约金额 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 本月车位签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday AND a.TopProductTypeName='车库/库房'  THEN BldArea ELSE 0 END) AS 本月车位签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  AND a.TopProductTypeName='车库/库房' 	THEN RmbAmount ELSE 0 END)/10000 AS 本月车位签约金额 ,	
		
		SUM(CASE WHEN a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 累计车位签约套数 ,
		SUM(CASE WHEN a.TopProductTypeName='车库/库房'  THEN BldArea ELSE 0 END) AS 累计车位签约面积 ,
		SUM(CASE WHEN a.TopProductTypeName='车库/库房'  THEN RmbAmount ELSE 0 END)/10000 AS 累计车位签约金额 ,
		
		
		---------
		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN ts ELSE 0 END) AS 本周签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN BldArea ELSE 0 END) AS 本周签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN RmbAmount ELSE 0 END)/10000  AS 本周签约金额 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN ts ELSE 0 END) AS 本月签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN BldArea ELSE 0 END) AS 本月签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN RmbAmount ELSE 0 END)/10000  AS 本月签约金额 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN ts ELSE 0 END) AS 本年签约套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN BldArea ELSE 0 END) AS 本年签约面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN RmbAmount ELSE 0 END)/10000  AS 本年签约金额 ,
		ISNULL(SUM(ISNULL(Ts, 0)), 0)       AS 累计签约套数,
		ISNULL(SUM(ISNULL(BldArea, 0)), 0)  AS 累计签约面积,
		--ISNULL(SUM(ISNULL(OCJTotal,0)),0)	AS 签约表价,
		ISNULL(SUM(ISNULL(RmbAmount, 0)), 0)/10000 AS 累计签约金额
	FROM dbo.data_wide_s_SaleHsData A WITH (NOLOCK)
	WHERE   TradeType = '签约'
	GROUP BY
		ProjGUID
),
RG AS (
SELECT 
		ProjGUID,
		SUM(CASE WHEN HsTjDate = @now  THEN ts ELSE 0 END) AS 本日认购套数 ,
		SUM(CASE WHEN HsTjDate = @now  THEN BldArea ELSE 0 END) AS 本日认购面积 ,
		SUM(CASE WHEN HsTjDate = @now  THEN OCjTotal ELSE 0 END)/10000  AS 本日认购金额 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 本日住宅认购套数 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 本日住宅认购面积 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='住宅'  THEN OCJTotal ELSE 0 END)/10000  AS 本日住宅认购金额 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 本日商业认购套数 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='商业'  THEN BldArea ELSE 0 END) AS 本日商业认购面积 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='商业'  THEN OCJTotal ELSE 0 END)/10000  AS 本日商业认购金额 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 本日车位认购套数 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='车库/库房'  THEN BldArea ELSE 0 END) AS 本日车位认购面积 ,
		SUM(CASE WHEN HsTjDate = @now and a.TopProductTypeName='车库/库房'  THEN OCJTotal ELSE 0 END)/10000  AS 本日车位认购金额 ,
		
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 本月住宅认购套数 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 本月住宅认购面积 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='住宅'  THEN OCJTotal ELSE 0 END)/10000  AS 本月住宅认购金额 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 本月商业认购套数 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='商业'  THEN BldArea ELSE 0 END) AS 本月商业认购面积 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='商业'  THEN OCJTotal ELSE 0 END)/10000  AS 本月商业认购金额 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 本月车位认购套数 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='车库/库房'  THEN BldArea ELSE 0 END) AS 本月车位认购面积 ,
		SUM(CASE WHEN HsTjDate  BETWEEN @monthstartday AND @monthendday  and a.TopProductTypeName='车库/库房'  THEN OCJTotal ELSE 0 END)/10000  AS 本月车位认购金额 ,

		SUM(CASE WHEN   a.TopProductTypeName='住宅'  THEN ts ELSE 0 END) AS 累计住宅认购套数 ,
		SUM(CASE WHEN   a.TopProductTypeName='住宅'  THEN BldArea ELSE 0 END) AS 累计住宅认购面积 ,
		SUM(CASE WHEN   a.TopProductTypeName='住宅'  THEN OCJTotal ELSE 0 END)/10000  AS 累计住宅认购金额 ,
		SUM(CASE WHEN   a.TopProductTypeName='商业'  THEN ts ELSE 0 END) AS 累计商业认购套数 ,
		SUM(CASE WHEN   a.TopProductTypeName='商业'  THEN BldArea ELSE 0 END) AS 累计商业认购面积 ,
		SUM(CASE WHEN   a.TopProductTypeName='商业'  THEN OCJTotal ELSE 0 END)/10000  AS 累计商业认购金额 ,
		SUM(CASE WHEN   a.TopProductTypeName='车库/库房'  THEN ts ELSE 0 END) AS 累计车位认购套数 ,
		SUM(CASE WHEN   a.TopProductTypeName='车库/库房'  THEN BldArea ELSE 0 END) AS 累计车位认购面积 ,
		SUM(CASE WHEN   a.TopProductTypeName='车库/库房'  THEN OCJTotal ELSE 0 END)/10000  AS 累计车位认购金额 ,

		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN ts ELSE 0 END) AS 本周认购套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN BldArea ELSE 0 END) AS 本周认购面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @weekstartday AND @weekendday  THEN OCJTotal ELSE 0 END)/10000  AS 本周认购金额 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN ts ELSE 0 END) AS 本月认购套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN BldArea ELSE 0 END) AS 本月认购面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @monthstartday AND @monthendday  THEN OCJTotal ELSE 0 END)/10000  AS 本月认购金额 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN ts ELSE 0 END) AS 本年认购套数 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN BldArea ELSE 0 END) AS 本年认购面积 ,
		SUM(CASE WHEN HsTjDate BETWEEN @yearstartday AND @yearendday  THEN OCJTotal ELSE 0 END)/10000  AS 本年认购金额 ,
		ISNULL(SUM(ISNULL(Ts, 0)), 0)       AS 累计认购套数,
		ISNULL(SUM(ISNULL(BldArea, 0)), 0)  AS 累计认购面积,
		--ISNULL(SUM(ISNULL(OCjTotal, 0)), 0) AS 认购协议金额,
		ISNULL(SUM(ISNULL(RmbAmount, 0)), 0)/10000  AS 累计认购金额/*认购未签约购按认购协议金额，已签约的按成交金额*/
	FROM dbo.data_wide_s_SaleHsData A  WITH (NOLOCK) 
	WHERE  TradeType IN ('签约', '认购','小订') and CreateReason<>'撤销签约' and CloseReason<>'撤销签约'
	GROUP BY
		ProjGUID
),
HK AS (
	SELECT
		Getin.ProjGUID,
		SUM(CASE WHEN Getin.SkDate = @now AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日非贷款类回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @weekstartday AND @weekendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本周回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @weekstartday AND @weekendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本周非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @weekstartday AND @weekendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本周贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @yearstartday AND @yearendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本年回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @yearstartday AND @yearendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本年非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @yearstartday AND @yearendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本年贷款类回款,
		SUM(CASE WHEN (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计回款,
		SUM(CASE WHEN Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计非贷款类回款,
		SUM(CASE WHEN Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计贷款类回款,

		SUM(CASE WHEN Getin.SkDate = @now AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日住宅回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日住宅非贷款类回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日住宅贷款类回款,

		SUM(CASE WHEN Getin.SkDate = @now AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日商业回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日商业非贷款类回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日商业贷款类回款,

		SUM(CASE WHEN Getin.SkDate = @now AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日车位回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日车位非贷款类回款,
		SUM(CASE WHEN Getin.SkDate = @now AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本日车位贷款类回款,

		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月住宅回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月住宅非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月住宅贷款类回款,

		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月商业回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月商业非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月商业贷款类回款,

		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月车位回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月车位非贷款类回款,
		SUM(CASE WHEN Getin.SkDate BETWEEN @monthstartday AND @monthendday AND Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 本月车位贷款类回款,

		SUM(CASE WHEN  (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计住宅回款,
		SUM(CASE WHEN  Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计住宅非贷款类回款,
		SUM(CASE WHEN Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='住宅' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计住宅贷款类回款,

		SUM(CASE WHEN  (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计商业回款,
		SUM(CASE WHEN  Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计商业非贷款类回款,
		SUM(CASE WHEN  Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='商业' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计商业贷款类回款,

		SUM(CASE WHEN  (Getin.ItemType='非贷款类房款' OR Getin.ItemType='贷款类房款')  AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计车位回款,
		SUM(CASE WHEN Getin.ItemType='非贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计车位非贷款类回款,
		SUM(CASE WHEN  Getin.ItemType='贷款类房款' AND Getin.IsFk = 1 and getin.TopProductTypeName='车库/库房' THEN Getin.RmbAmount ELSE 0 END)/10000  AS 累计车位贷款类回款
			/*按揭公积金款项备用
			SUM(CASE WHEN Getin.ItemNameGUID = '9165FAED-227A-465D-AA5D-D24BED655677' /*银行按揭*/ THEN Getin.RmbAmount ELSE 0 END) AS AjAmount,
			SUM(CASE WHEN Getin.ItemNameGUID = 'C3190DC3-C295-4A98-B7AC-9DFF7D7A0091' /*公积金*/ THEN Getin.RmbAmount ELSE 0 END) AS GjjAmount,
			*/
	FROM data_wide_s_Getin Getin
	
	WHERE Getin.SaleType != '预约单'
		AND Getin.SaleType != '预收款'
		AND ISNULL(Getin.VouchStatus, '') != '作废'
	GROUP BY
		Getin.ProjGUID
),
TF AS (
	SELECT  
	ProjGUID,
	SUM(CASE WHEN CloseDate = @now  THEN 1 ELSE 0 END) AS 本日退房套数 ,
	SUM(CASE WHEN CloseDate = @now  THEN CjBldArea ELSE 0 END) AS 本日退房面积 ,
	SUM(CASE WHEN CloseDate = @now  THEN CjTotal ELSE 0 END)/10000  AS 本日退房金额 ,
	SUM(CASE WHEN CloseDate = @now  AND Reason='认购退房' THEN 1 ELSE 0 END) AS 本日认购退房套数 ,
	SUM(CASE WHEN CloseDate = @now  AND Reason='签约退房' THEN 1 ELSE 0 END) AS 本日签约退房套数 ,

	SUM(CASE WHEN CloseDate BETWEEN @weekstartday AND @weekendday  THEN 1 ELSE 0 END) AS 本周退房套数 ,
	SUM(CASE WHEN CloseDate BETWEEN @weekstartday AND @weekendday  THEN CjBldArea ELSE 0 END) AS 本周退房面积 ,
	SUM(CASE WHEN CloseDate BETWEEN @weekstartday AND @weekendday  THEN CjTotal ELSE 0 END)/10000  AS 本周退房金额 ,
	SUM(CASE WHEN CloseDate BETWEEN @monthstartday AND @monthendday  THEN 1 ELSE 0 END) AS 本月退房套数 ,
	SUM(CASE WHEN CloseDate BETWEEN @monthstartday AND @monthendday  THEN CjBldArea ELSE 0 END) AS 本月退房面积 ,
	SUM(CASE WHEN CloseDate BETWEEN @monthstartday AND @monthendday  THEN CjTotal ELSE 0 END)/10000  AS 本月退房金额 ,
	SUM(CASE WHEN CloseDate BETWEEN @yearstartday AND @yearendday  THEN 1 ELSE 0 END) AS 本年退房套数 ,
	SUM(CASE WHEN CloseDate BETWEEN @yearstartday AND @yearendday  THEN CjBldArea ELSE 0 END) AS 本年退房面积 ,
	SUM(CASE WHEN CloseDate BETWEEN @yearstartday AND @yearendday  THEN CjTotal ELSE 0 END)/10000  AS 本年退房金额 ,
	sum(1) 累计退房套数,
	SUM(CASE WHEN Reason='认购退房' THEN 1 ELSE 0 END) AS 累计认购退房套数 ,
	SUM(CASE WHEN Reason='签约退房' THEN 1 ELSE 0 END) AS 累计签约退房套数 ,
	sum(CjBldArea) 累计退房面积,
	sum(CjTotal) 累计退房金额
FROM(
	SELECT ProjGUID,OCloseDate AS CloseDate,
		OCjBldArea AS CJBldArea,OCjTotal AS CJTotal,'认购退房' AS Reason
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE OCloseReason='退房' 
	UNION ALL
	SELECT ProjGUID,CCloseDate,
		CCjBldArea,CCjTotal,'签约退房'
	FROM dbo.data_wide_s_Trade WITH(NOLOCK) 
	WHERE CCloseReason='退房' 
	)T
GROUP BY  ProjGUID
),
LDLF AS (
	SELECT  
		ProjGUID,
		SUM(CASE WHEN FirstGjDate = @now AND ZcStatus = '问询' THEN 1 ELSE 0 END) AS 本日来电 ,
		SUM(CASE WHEN FirstGjDate = @now AND ZcStatus = '看房' THEN 1 ELSE 0 END) AS 本日来访 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @weekstartday AND @weekendday AND ZcStatus = '问询' THEN 1 ELSE 0 END) AS 本周来电 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @weekstartday AND @weekendday AND ZcStatus = '看房' THEN 1 ELSE 0 END) AS 本周来访 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @monthstartday AND @monthendday AND ZcStatus = '问询' THEN 1 ELSE 0 END) AS 本月来电 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @monthstartday AND @monthendday AND ZcStatus = '看房' THEN 1 ELSE 0 END) AS 本月来访 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @yearstartday AND @yearendday AND ZcStatus = '问询' THEN 1 ELSE 0 END) AS 本年来电 ,
		SUM(CASE WHEN FirstGjDate BETWEEN @yearstartday AND @yearendday AND ZcStatus = '看房' THEN 1 ELSE 0 END) AS 本年来访 ,
		SUM(CASE WHEN ZcStatus = '问询' THEN 1 ELSE 0 END) AS 累计来电 ,
		SUM(CASE WHEN ZcStatus = '看房' THEN 1 ELSE 0 END) AS 累计来访 
	FROM    data_wide_s_Opportunity
	GROUP BY ProjGUID
),
WS AS (
	SELECT 
	r.ProjGUID,
	SUM(case when Status in ('销控','待售') then 1 else 0 end) as 未售套数,
	SUM(case when Status in ('销控','待售') then Total else 0 end)/10000 as 未售金额,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='住宅' then 1 else 0 end) as 住宅未售套数,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='住宅' then Total else 0 end)/10000 as 住宅未售金额,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='商业' then 1 else 0 end) as 商业未售套数,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='商业' then Total else 0 end)/10000 as 商业未售金额,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='车位' then 1 else 0 end) as 车位未售套数,
	SUM(case when Status in ('销控','待售') and r.TopProductTypeName='车位' then Total else 0 end)/10000 as 车位未售金额,

	SUM(t.YsDkFk-t.Ssdkfk)/10000 as 贷款类未收,
	SUM(t.YsFdkFk-t.Ssfdkfk)/10000 as 非贷款类未收,
	SUM(t.YsFk-t.Ssfk)/10000 as 总未收,
	
	SUM(case when t.TopProductTypeName='住宅' then t.YsDkFk-t.Ssdkfk else 0 end)/10000 as 住宅贷款类未收,
	SUM(case when t.TopProductTypeName='住宅' then t.YsFdkFk-t.Ssfdkfk else 0 end)/10000 as 住宅非贷款类未收,
	SUM(case when t.TopProductTypeName='住宅' then t.Ysfk-t.Ssfk else 0 end)/10000 as 住宅总未收,
	
	SUM(case when t.TopProductTypeName='商业' then t.YsDkFk-t.Ssdkfk else 0 end)/10000 as 商业贷款类未收,
	SUM(case when t.TopProductTypeName='商业' then t.YsFdkFk-t.Ssfdkfk else 0 end)/10000 as 商业非贷款类未收,
	SUM(case when t.TopProductTypeName='商业' then t.YsFk-t.Ssfk else 0 end)/10000 as 商业总未收,
	
	SUM(case when t.TopProductTypeName='车位' then t.YsDkFk-t.Ssdkfk else 0 end)/10000 as 车位贷款类未收,
	SUM(case when t.TopProductTypeName='车位' then t.YsFdkFk-t.Ssfdkfk else 0 end)/10000 as 车位非贷款类未收,
	SUM(case when t.TopProductTypeName='车位' then t.YsFk-t.Ssfk else 0 end)/10000 as 车位总未收
	FROM data_wide_s_Room r
	LEFT JOIN data_wide_s_Trade t on r.RoomGUID=t.RoomGUID and (t.OStatus='激活' or t.CStatus='激活')
	GROUP BY r.ProjGUID
),
PROJ AS (
		 select proj.p_projectId as ProjGUID,
				parent.p_projectId as ParentGUID,
				proj.ProjName as ProjName,
				parent.ProjName as ParentProjName,
				proj.BUGUID,
				proj.HierarchyCode,
				parent.HierarchyCode as ParentHierarchyCode
		 from data_wide_mdm_Project proj with(nolock )
			left join data_wide_mdm_Project parent on proj.ParentGUID= parent.p_projectId
		 where proj.IfEnd =1 and proj.ApplySys like '%0011%'
)
SELECT 
	P.ProjGUID AS BUGUID,P.ProjGUID,
	P.ProjName,'项目维度' AS wd,
	RG.本日认购套数,
	RG.本日认购面积,
	RG.本日认购金额,
	RG.本周认购套数,
	RG.本周认购面积,
	RG.本周认购金额,
	RG.本月认购套数,
	RG.本月认购面积,
	RG.本月认购金额,
	RG.本年认购套数,
	RG.本年认购面积,
	RG.本年认购金额,
	RG.累计认购套数,
	RG.累计认购面积,
	RG.累计认购金额,
	RG.本日车位认购套数,
	RG.本日车位认购面积,
	RG.本日车位认购金额,
	RG.本日住宅认购套数,
	RG.本日住宅认购面积,
	RG.本日住宅认购金额,
	RG.本日商业认购套数,
	RG.本日商业认购面积,
	RG.本日商业认购金额,
	RG.本月车位认购套数,
	RG.本月车位认购面积,
	RG.本月车位认购金额,
	RG.本月住宅认购套数,
	RG.本月住宅认购面积,
	RG.本月住宅认购金额,
	RG.本月商业认购套数,
	RG.本月商业认购面积,
	RG.本月商业认购金额,
	
	RG.累计车位认购套数,
	RG.累计车位认购面积,
	RG.累计车位认购金额,
	RG.累计住宅认购套数,
	RG.累计住宅认购面积,
	RG.累计住宅认购金额,
	RG.累计商业认购套数,
	RG.累计商业认购面积,
	RG.累计商业认购金额,

	QY.本日签约套数,
	QY.本日签约面积,
	QY.本日签约金额,

	QY.本日车位签约套数,
	QY.本日车位签约面积,
	QY.本日车位签约金额,
	QY.本日住宅签约套数,
	QY.本日住宅签约面积,
	QY.本日住宅签约金额,
	QY.本日商业签约套数,
	QY.本日商业签约面积,
	QY.本日商业签约金额,
	QY.本月车位签约套数,
	QY.本月车位签约面积,
	QY.本月车位签约金额,
	QY.本月住宅签约套数,
	QY.本月住宅签约面积,
	QY.本月住宅签约金额,
	QY.本月商业签约套数,
	QY.本月商业签约面积,
	QY.本月商业签约金额,
	QY.本周签约套数,
	QY.本周签约面积,
	QY.本周签约金额,
	QY.本月签约套数,
	QY.本月签约面积,
	QY.本月签约金额,
	QY.本年签约套数,
	QY.本年签约面积,
	QY.本年签约金额,
	QY.累计签约套数,
	QY.累计签约面积,
	QY.累计签约金额,

	QY.累计车位签约套数,
	QY.累计车位签约面积,
	QY.累计车位签约金额,
	QY.累计住宅签约套数,
	QY.累计住宅签约面积,
	QY.累计住宅签约金额,
	QY.累计商业签约套数,
	QY.累计商业签约面积,
	QY.累计商业签约金额,


	ISNULL(TF.本日退房套数,0) 本日退房套数,
	ISNULL(TF.本日认购退房套数,0) 本日认购退房套数,
	ISNULL(TF.本日签约退房套数,0) 本日签约退房套数,
	ISNULL(TF.本日退房面积,0) 本日退房面积,
	ISNULL(TF.本日退房金额,0) 本日退房金额,
	ISNULL(TF.本周退房套数,0) 本周退房套数,
	ISNULL(TF.本周退房面积,0) 本周退房面积,
	ISNULL(TF.本周退房金额,0) 本周退房金额,
	ISNULL(TF.本月退房套数,0) 本月退房套数,
	ISNULL(TF.本月退房面积,0) 本月退房面积,
	ISNULL(TF.本月退房金额,0) 本月退房金额,
	ISNULL(TF.本年退房套数,0) 本年退房套数,
	ISNULL(TF.本年退房面积,0) 本年退房面积,
	ISNULL(TF.本年退房金额,0) 本年退房金额,
	ISNULL(TF.累计退房套数,0) 累计退房套数,
	ISNULL(TF.累计认购退房套数,0) 累计认购退房套数,
	ISNULL(TF.累计签约退房套数,0) 累计签约退房套数,
	ISNULL(TF.累计退房面积,0) 累计退房面积,
	ISNULL(TF.累计退房金额,0) 累计退房金额,

	HK.本日回款,
	HK.本日贷款类回款,
	HK.本日非贷款类回款,
	HK.本周回款,
	HK.本周贷款类回款,
	HK.本周非贷款类回款,
	HK.本月回款,
	HK.本月贷款类回款,
	HK.本月非贷款类回款,
	HK.本年回款,
	HK.本年贷款类回款,
	HK.本年非贷款类回款,
	HK.累计回款,
	HK.累计贷款类回款,
	HK.累计非贷款类回款,

	HK.本日住宅回款,
	HK.本日住宅贷款类回款,
	HK.本日住宅非贷款类回款,
	HK.本月住宅回款,
	HK.本月住宅贷款类回款,
	HK.本月住宅非贷款类回款,
	HK.累计住宅回款,
	HK.累计住宅贷款类回款,
	HK.累计住宅非贷款类回款,

	HK.本日商业回款,
	HK.本日商业贷款类回款,
	HK.本日商业非贷款类回款,
	HK.本月商业回款,
	HK.本月商业贷款类回款,
	HK.本月商业非贷款类回款,
	HK.累计商业回款,
	HK.累计商业贷款类回款,
	HK.累计商业非贷款类回款,

	HK.本日车位回款,
	HK.本日车位贷款类回款,
	HK.本日车位非贷款类回款,
	HK.本月车位回款,
	HK.本月车位贷款类回款,
	HK.本月车位非贷款类回款,
	HK.累计车位回款,
	HK.累计车位贷款类回款,
	HK.累计车位非贷款类回款,

	WS.贷款类未收,
	WS.非贷款类未收,
	WS.住宅贷款类未收,
	WS.住宅非贷款类未收,
	WS.车位贷款类未收,
	WS.车位非贷款类未收,
	WS.商业贷款类未收,
	WS.商业非贷款类未收,
	WS.未售套数,
	WS.未售金额,
	WS.住宅未售套数,
	WS.住宅未售金额,
	WS.商业未售套数,
	WS.商业未售金额,
	WS.车位未售套数,
	WS.车位未售金额,
	WS.总未收,
	WS.住宅总未收,
	WS.车位总未收,
	WS.商业总未收,
	


	LDLF.本日来电,
	LDLF.本日来访,
	LDLF.本周来电,
	LDLF.本周来访,
	LDLF.本月来电,
	LDLF.本月来访,
	LDLF.本年来电,
	LDLF.本年来访,
	LDLF.累计来电,
	LDLF.累计来访
FROM PROJ P
LEFT JOIN RG ON RG.ProjGUID=P.ProjGUID
LEFT JOIN QY ON QY.ProjGUID=P.ProjGUID
LEFT JOIN HK ON HK.ProjGUID=P.ProjGUID
LEFT JOIN TF ON TF.ProjGUID=P.ProjGUID
LEFT JOIN LDLF ON LDLF.ProjGUID=P.ProjGUID
LEFT JOIN WS ON WS.ProjGUID=P.ProjGUID

union all


SELECT 
	BUGUID AS BUGUID,BUGUID,
	'全公司','公司维度' AS wd,
	SUM(RG.本日认购套数),
	SUM(RG.本日认购面积),
	SUM(RG.本日认购金额),
	SUM(RG.本周认购套数),
	SUM(RG.本周认购面积),
	SUM(RG.本周认购金额),
	SUM(RG.本月认购套数),
	SUM(RG.本月认购面积),
	SUM(RG.本月认购金额),
	SUM(RG.本年认购套数),
	SUM(RG.本年认购面积),
	SUM(RG.本年认购金额),
	SUM(RG.累计认购套数),
	SUM(RG.累计认购面积),
	SUM(RG.累计认购金额),
	SUM(RG.本日车位认购套数),
	SUM(RG.本日车位认购面积),
	SUM(RG.本日车位认购金额),
	SUM(RG.本日住宅认购套数),
	SUM(RG.本日住宅认购面积),
	SUM(RG.本日住宅认购金额),
	SUM(RG.本日商业认购套数),
	SUM(RG.本日商业认购面积),
	SUM(RG.本日商业认购金额),
	
	SUM(RG.本月车位认购套数),
	SUM(RG.本月车位认购面积),
	SUM(RG.本月车位认购金额),
	SUM(RG.本月住宅认购套数),
	SUM(RG.本月住宅认购面积),
	SUM(RG.本月住宅认购金额),
	SUM(RG.本月商业认购套数),
	SUM(RG.本月商业认购面积),
	SUM(RG.本月商业认购金额),
	
	SUM(RG.累计车位认购套数),
	SUM(RG.累计车位认购面积),
	SUM(RG.累计车位认购金额),
	SUM(RG.累计住宅认购套数),
	SUM(RG.累计住宅认购面积),
	SUM(RG.累计住宅认购金额),
	SUM(RG.累计商业认购套数),
	SUM(RG.累计商业认购面积),
	SUM(RG.累计商业认购金额),

	SUM(QY.本日签约套数),
	SUM(QY.本日签约面积),
	SUM(QY.本日签约金额),

	SUM(QY.本日车位签约套数),
	SUM(QY.本日车位签约面积),
	SUM(QY.本日车位签约金额),
	SUM(QY.本日住宅签约套数),
	SUM(QY.本日住宅签约面积),
	SUM(QY.本日住宅签约金额),
	SUM(QY.本日商业签约套数),
	SUM(QY.本日商业签约面积),
	SUM(QY.本日商业签约金额),
	
	SUM(QY.本月车位签约套数),
	SUM(QY.本月车位签约面积),
	SUM(QY.本月车位签约金额),
	SUM(QY.本月住宅签约套数),
	SUM(QY.本月住宅签约面积),
	SUM(QY.本月住宅签约金额),
	SUM(QY.本月商业签约套数),
	SUM(QY.本月商业签约面积),
	SUM(QY.本月商业签约金额),
	
	SUM(QY.本周签约套数),
	SUM(QY.本周签约面积),
	SUM(QY.本周签约金额),
	SUM(QY.本月签约套数),
	SUM(QY.本月签约面积),
	SUM(QY.本月签约金额),
	SUM(QY.本年签约套数),
	SUM(QY.本年签约面积),
	SUM(QY.本年签约金额),
	SUM(QY.累计签约套数),
	SUM(QY.累计签约面积),
	SUM(QY.累计签约金额),

	SUM(QY.累计车位签约套数),
	SUM(QY.累计车位签约面积),
	SUM(QY.累计车位签约金额),
	SUM(QY.累计住宅签约套数),
	SUM(QY.累计住宅签约面积),
	SUM(QY.累计住宅签约金额),
	SUM(QY.累计商业签约套数),
	SUM(QY.累计商业签约面积),
	SUM(QY.累计商业签约金额),

	ISNULL(SUM(TF.本日退房套数),0),
	ISNULL(SUM(TF.本日认购退房套数),0),
	ISNULL(SUM(TF.本日签约退房套数),0),
	ISNULL(SUM(TF.本日退房面积),0),
	ISNULL(SUM(TF.本日退房金额),0),
	ISNULL(SUM(TF.本周退房套数),0),
	ISNULL(SUM(TF.本周退房面积),0),
	ISNULL(SUM(TF.本周退房金额),0),
	ISNULL(SUM(TF.本月退房套数),0),
	ISNULL(SUM(TF.本月退房面积),0),
	ISNULL(SUM(TF.本月退房金额),0),
	ISNULL(SUM(TF.本年退房套数),0),
	ISNULL(SUM(TF.本年退房面积),0),
	ISNULL(SUM(TF.本年退房金额),0),
	ISNULL(SUM(TF.累计退房套数),0),
	ISNULL(SUM(TF.累计认购退房套数),0),
	ISNULL(SUM(TF.累计签约退房套数),0),
	ISNULL(SUM(TF.累计退房面积),0),
	ISNULL(SUM(TF.累计退房金额),0),

	SUM(HK.本日回款),
	SUM(HK.本日贷款类回款),
	SUM(HK.本日非贷款类回款),
	SUM(HK.本周回款),
	SUM(HK.本周贷款类回款),
	SUM(HK.本周非贷款类回款),
	SUM(HK.本月回款),
	SUM(HK.本月贷款类回款),
	SUM(HK.本月非贷款类回款),
	SUM(HK.本年回款),
	SUM(HK.本年贷款类回款),
	SUM(HK.本年非贷款类回款),
	SUM(HK.累计回款),
	SUM(HK.累计贷款类回款),
	SUM(HK.累计非贷款类回款),

	SUM(HK.本日住宅回款),
	SUM(HK.本日住宅贷款类回款),
	SUM(HK.本日住宅非贷款类回款),
	SUM(HK.本月住宅回款),
	SUM(HK.本月住宅贷款类回款),
	SUM(HK.本月住宅非贷款类回款),
	SUM(HK.累计住宅回款),
	SUM(HK.累计住宅贷款类回款),
	SUM(HK.累计住宅非贷款类回款),

	SUM(HK.本日商业回款),
	SUM(HK.本日商业贷款类回款),
	SUM(HK.本日商业非贷款类回款),
	SUM(HK.本月商业回款),
	SUM(HK.本月商业贷款类回款),
	SUM(HK.本月商业非贷款类回款),
	SUM(HK.累计商业回款),
	SUM(HK.累计商业贷款类回款),
	SUM(HK.累计商业非贷款类回款),

	SUM(HK.本日车位回款),
	SUM(HK.本日车位贷款类回款),
	SUM(HK.本日车位非贷款类回款),
	SUM(HK.本月车位回款),
	SUM(HK.本月车位贷款类回款),
	SUM(HK.本月车位非贷款类回款),
	SUM(HK.累计车位回款),
	SUM(HK.累计车位贷款类回款),
	SUM(HK.累计车位非贷款类回款),

	SUM(WS.贷款类未收),
	SUM(WS.非贷款类未收),
	SUM(WS.住宅贷款类未收),
	SUM(WS.住宅非贷款类未收),
	SUM(WS.车位贷款类未收),
	SUM(WS.车位非贷款类未收),
	SUM(WS.商业贷款类未收),
	SUM(WS.商业非贷款类未收),
	SUM(WS.未售套数),
	SUM(WS.未售金额),
	SUM(WS.住宅未售套数),
	SUM(WS.住宅未售金额),
	SUM(WS.商业未售套数),
	SUM(WS.商业未售金额),
	SUM(WS.车位未售套数),
	SUM(WS.车位未售金额),
	SUM(WS.总未收),
	SUM(WS.住宅总未收),
	SUM(WS.车位总未收),
	SUM(WS.商业总未收),


	SUM(LDLF.本日来电),
	SUM(LDLF.本日来访),
	SUM(LDLF.本周来电),
	SUM(LDLF.本周来访),
	SUM(LDLF.本月来电),
	SUM(LDLF.本月来访),
	SUM(LDLF.本年来电),
	SUM(LDLF.本年来访),
	SUM(LDLF.累计来电),
	SUM(LDLF.累计来访)
FROM PROJ P
LEFT JOIN RG ON RG.ProjGUID=P.ProjGUID
LEFT JOIN QY ON QY.ProjGUID=P.ProjGUID
LEFT JOIN HK ON HK.ProjGUID=P.ProjGUID
LEFT JOIN TF ON TF.ProjGUID=P.ProjGUID
LEFT JOIN LDLF ON LDLF.ProjGUID=P.ProjGUID
LEFT JOIN WS ON WS.ProjGUID=P.ProjGUID
GROUP BY p.BUGUID