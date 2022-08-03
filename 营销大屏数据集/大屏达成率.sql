DECLARE
@jtGuid UNIQUEIDENTIFIER;

SET @jtGuid ='11B11DB4-E907-4F1F-8835-B9DAAB6E1F23';
DECLARE
@now DATETIME;
SET @now = CONVERT(VARCHAR(20), GETDATE(), 23);
DECLARE
@year INT;
SET @year = YEAR(@now);
DECLARE
@month INT;
SET @month = MONTH(@now);
WITH budget
	 AS (SELECT ISNULL(SUM(BudgetContractAmount) / 10000, 0) AS BudgetContractAmount, --计划签约金额(亿元)
				ISNULL(SUM(BudgetOrderAmount) / 10000, 0)    AS BudgetOrderAmount,    --计划认购金额(亿元)
				ISNULL(SUM(BudgetGetinAmount) / 10000, 0)    AS BudgetGetinAmount,    --计划回款金额(亿元)
				[Year]                                       AS Year,
				BUGUID                                       AS BUGUID
		 FROM dbo.data_wide_s_SalesBudget WITH (NOLOCK)
		 WHERE Month = 13
		 GROUP BY BUGUID,
				  [Year]
),
budget2
	 AS (SELECT ISNULL(SUM(BudgetContractAmount) / 10000, 0) AS BudgetContractAmount, --计划签约金额(亿元)
				ISNULL(SUM(BudgetOrderAmount) / 10000, 0)    AS BudgetOrderAmount,    --计划认购金额(亿元)
				ISNULL(SUM(BudgetGetinAmount) / 10000, 0)    AS BudgetGetinAmount,    --计划回款金额(亿元)
				[Year]                                       AS Year,
				@jtGuid                                       AS BUGUID
		 FROM dbo.data_wide_s_SalesBudget WITH (NOLOCK)
		 WHERE Month = 13
		 GROUP BY 
				  [Year]
),
 /*实际签约*/
 actualContract
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际签约金额(亿元)
				[Year]                            AS Year,
				BUGUID                            AS BUGUID
		 FROM (
				  SELECT ISNULL(CNetAmount, 0) AS total,
						 YEAR(StatisticalDate)       AS [Year],
						 BUGUID
				  FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) a
		 GROUP BY BUGUID,
				  [Year]
 ),
  /*集团实际签约*/
 actualContract2
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际签约金额(亿元)
				[Year]                            AS Year,
				@jtGuid                            AS BUGUID
		 FROM (
				  SELECT ISNULL(CNetAmount, 0) AS total,
						 YEAR(StatisticalDate)       AS [Year]
				  FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) a
		 GROUP BY 
				  [Year]
 ),
 /*实际认购*/
 actualOrder
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际认购金额(亿元)
				[Year]                            AS Year,
				BUGUID                            AS BUGUID
		 FROM (
				  SELECT ISNULL(ONetAmount, 0) AS total,
						 YEAR(StatisticalDate)      AS [Year],
						 BUGUID
				  FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) a
		 GROUP BY BUGUID,
				  [Year]
 ),
  /*集团实际认购*/
 actualOrder2
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际认购金额(亿元)
				[Year]                            AS Year,
				@jtGuid                            AS BUGUID
		 FROM (
				  SELECT ISNULL(ONetAmount, 0) AS total,
						 YEAR(StatisticalDate)      AS [Year]
				  FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) a
		 GROUP BY 
				  [Year]
 ),
 /*实际回款*/
 actualGetin
	 AS (SELECT ISNULL(SUM(Amount), 0) / 100000000 Amount, --实际回款金额(亿元)
				[Year] AS                          Year,
				BUGUID AS                          BUGUID
		 FROM (
				  SELECT HousingAmount    AS Amount,
						 YEAR(StatisticalDate) AS [Year],
						 BUGUID
				  FROM dbo.data_wide_dws_s_Return WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) data_wide_s_Getin
		 GROUP BY BUGUID,
				  [Year]
 ),
 /*集团实际回款*/
 actualGetin2
	 AS (SELECT ISNULL(SUM(Amount), 0) / 100000000 Amount, --实际回款金额(亿元)
				[Year] AS                          Year,
				@jtGuid AS                          BUGUID
		 FROM (
				  SELECT HousingAmount    AS Amount,
						 YEAR(StatisticalDate) AS [Year],
						 BUGUID
				  FROM dbo.data_wide_dws_s_Return WITH (NOLOCK)
				  WHERE StatisticalDate <= @now
			  ) data_wide_s_Getin
		 GROUP BY 
				  [Year]
 )
SELECT *,
   签约目标-实际签约 as 签约_目标差额,
   认购目标-实际认购 as 认购_目标差额,
   回款目标-实际回款 as 回款_目标差额,
   CASE
	   WHEN 实际签约 = 0 THEN
		   0
	   WHEN 签约目标 = 0 THEN
		   1
	   ELSE
		   实际签约 / 签约目标
	   END AS 签约达成率,
   CASE
	   WHEN 实际认购 = 0 THEN
		   0
	   WHEN 认购目标 = 0 THEN
		   1
	   ELSE
		   实际认购 / 认购目标
	   END AS 认购达成率,
   CASE
	   WHEN 实际回款 = 0 THEN
		   0
	   WHEN 回款目标 = 0 THEN
		   1
	   ELSE
		   实际回款 / 回款目标
	   END AS 回款达成率
FROM (
	 SELECT ROUND(ISNULL(budget.BudgetContractAmount, 0), 2) AS 签约目标,
			ROUND(ISNULL(budget.BudgetOrderAmount, 0), 2)    AS 认购目标,
			ROUND(ISNULL(budget.BudgetGetinAmount, 0), 2)    AS 回款目标,
			ROUND(ISNULL(actualContract.Amount, 0), 2)       AS 实际签约,
			ROUND(ISNULL(actualOrder.Amount, 0), 2)          AS 实际认购,
			ROUND(ISNULL(actualGetin.Amount, 0), 2)          AS 实际回款,
			@year                                            AS Year,
			bu.BUGUID                                        AS ScopeId,
			bu.BUName as 公司,
			'' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget
						ON budget.BUGUID = bu.BUGUID
							AND budget.Year = @year
			  LEFT JOIN actualContract
						ON actualContract.Year = @year
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder
						ON actualOrder.Year = @year
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year = @year
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 UNION ALL 
	 SELECT TOP 10 
			ROUND(ISNULL(budget.BudgetContractAmount, 0), 2) AS 签约目标,
			ROUND(ISNULL(budget.BudgetOrderAmount, 0), 2)    AS 认购目标,
			ROUND(ISNULL(budget.BudgetGetinAmount, 0), 2)    AS 回款目标,
			ROUND(ISNULL(actualContract.Amount, 0), 2)       AS 实际签约,
			ROUND(ISNULL(actualOrder.Amount, 0), 2)          AS 实际认购,
			ROUND(ISNULL(actualGetin.Amount, 0), 2)          AS 实际回款,
			@year                                            AS Year,
			bu.BUGUID                                        AS ScopeId,
			bu.BUName as 公司,
			'实际签约-Top10' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget
						ON budget.BUGUID = bu.BUGUID
							AND budget.Year = @year
			  LEFT JOIN actualContract
						ON actualContract.Year = @year
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder
						ON actualOrder.Year = @year
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year = @year
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 ORDER BY 实际签约 DESC 
	 UNION ALL 
	 SELECT TOP 20 
			ROUND(ISNULL(budget.BudgetContractAmount, 0), 2) AS 签约目标,
			ROUND(ISNULL(budget.BudgetOrderAmount, 0), 2)    AS 认购目标,
			ROUND(ISNULL(budget.BudgetGetinAmount, 0), 2)    AS 回款目标,
			ROUND(ISNULL(actualContract.Amount, 0), 2)       AS 实际签约,
			ROUND(ISNULL(actualOrder.Amount, 0), 2)          AS 实际认购,
			ROUND(ISNULL(actualGetin.Amount, 0), 2)          AS 实际回款,
			@year                                            AS Year,
			bu.BUGUID                                        AS ScopeId,
			bu.BUName as 公司,
			'实际签约-Top20' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget
						ON budget.BUGUID = bu.BUGUID
							AND budget.Year = @year
			  LEFT JOIN actualContract
						ON actualContract.Year = @year
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder
						ON actualOrder.Year = @year
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year = @year
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 ORDER BY 实际签约 DESC 
	 UNION ALL
	 ----------
	 SELECT TOP 10 
			ROUND(ISNULL(budget.BudgetContractAmount, 0), 2) AS 签约目标,
			ROUND(ISNULL(budget.BudgetOrderAmount, 0), 2)    AS 认购目标,
			ROUND(ISNULL(budget.BudgetGetinAmount, 0), 2)    AS 回款目标,
			ROUND(ISNULL(actualContract.Amount, 0), 2)       AS 实际签约,
			ROUND(ISNULL(actualOrder.Amount, 0), 2)          AS 实际认购,
			ROUND(ISNULL(actualGetin.Amount, 0), 2)          AS 实际回款,
			@year                                            AS Year,
			bu.BUGUID                                        AS ScopeId,
			bu.BUName as 公司,
			'实际回款-Top10' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget
						ON budget.BUGUID = bu.BUGUID
							AND budget.Year = @year
			  LEFT JOIN actualContract
						ON actualContract.Year = @year
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder
						ON actualOrder.Year = @year
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year = @year
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 ORDER BY 实际回款 DESC 
	 UNION ALL 
	 SELECT TOP 20 
			ROUND(ISNULL(budget.BudgetContractAmount, 0), 2) AS 签约目标,
			ROUND(ISNULL(budget.BudgetOrderAmount, 0), 2)    AS 认购目标,
			ROUND(ISNULL(budget.BudgetGetinAmount, 0), 2)    AS 回款目标,
			ROUND(ISNULL(actualContract.Amount, 0), 2)       AS 实际签约,
			ROUND(ISNULL(actualOrder.Amount, 0), 2)          AS 实际认购,
			ROUND(ISNULL(actualGetin.Amount, 0), 2)          AS 实际回款,
			@year                                            AS Year,
			bu.BUGUID                                        AS ScopeId,
			bu.BUName as 公司,
			'实际回款-Top20' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget
						ON budget.BUGUID = bu.BUGUID
							AND budget.Year = @year
			  LEFT JOIN actualContract
						ON actualContract.Year = @year
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder
						ON actualOrder.Year = @year
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year = @year
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 ORDER BY 实际回款 DESC 
	 --------
	 UNION ALL
	 SELECT ROUND(SUM(budget2.BudgetContractAmount), 2) AS 签约目标,
			ROUND(SUM(budget2.BudgetOrderAmount), 2)    AS 认购目标,
			ROUND(SUM(budget2.BudgetGetinAmount), 2)    AS 回款目标,
			ROUND(SUM(actualContract2.Amount), 2)       AS 实际签约,
			ROUND(SUM(actualOrder2.Amount), 2)          AS 实际认购,
			ROUND(SUM(actualGetin2.Amount), 2)          AS 实际回款,
			@year                                      AS Year,
			@jtGuid                                    AS ScopeId,
			'集团',
			'' AS ObjectType
	 FROM data_wide_mdm_BusinessUnit bu
			  LEFT JOIN budget2
						ON budget2.BUGUID = bu.BUGUID
							AND budget2.Year = @year
			  LEFT JOIN actualContract2
						ON actualContract2.Year = @year
							AND actualContract2.BUGUID = bu.BUGUID
			  LEFT JOIN actualOrder2
						ON actualOrder2.Year = @year
							AND actualOrder2.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin2
						ON actualGetin2.Year = @year
							AND actualGetin2.BUGUID = bu.BUGUID
	 WHERE bu.BUGUID=@jtGuid
 ) t
where Year = Year(@now)
