DECLARE
@jtGuid UNIQUEIDENTIFIER;

DECLARE
@now DATETIME;
SET @now = CONVERT(VARCHAR(20), getdate(), 23);
DECLARE
@year INT;
SET @year = YEAR(@now);
DECLARE
@month INT;
SET @month = MONTH(@now);
WITH Nums as (
select -11 as Num
union all
select -10 as Num
union all
select -9 as Num
union all
select -8 as Num
union all
select -7 as Num
union all
select -6 as Num
union all
select -5 as Num
union all
select -4 as Num
union all
select -3 as Num
union all
select -2 as Num
union all
select -1 as Num
union all
select 0 as Num
union all
select 1 as Num
union all
select 2 as Num
union all
select 3 as Num
union all
select 4 as Num
union all
select 5 as Num
union all
select 6 as Num
union all
select 7 as Num
union all
select 8 as Num
union all
select 9 as Num
union all
select 10 as Num
union all
select 11 as Num
union all
select 12 as Num
union all
select 13 as Num
union all
select 14 as Num
union all
select 15 as Num
union all
select 16 as Num
union all
select 17 as Num
union all
select 18 as Num
union all
select 19 as Num
union all
select 20 as Num
union all
select 21 as Num
union all
select 22 as Num

),
 /*十三个月*/
months AS (select YEAR(DATEADD(month, -Num, @now)) as Year, MONTH(DATEADD(month, -Num, @now)) as Month from Nums),

 /*本年-已发生月份的目标，排除本月*/
 budget_was_hanpening
	 AS (SELECT SUM(ISNULL(BudgetContractAmount, 0)) / 10000 AS BudgetContractAmount, --计划签约金额(亿元)
				SUM(ISNULL(BudgetOrderAmount, 0)) / 10000    AS BudgetOrderAmount,    --计划认购金额(亿元)
				SUM(ISNULL(BudgetGetinAmount, 0)) / 10000    AS BudgetGetinAmount,    --计划回款金额(亿元)
				[Year]                                       AS Year,
				[Month]                                       AS Month,
				BUGUID                                       AS BUGUID
		 FROM dbo.data_wide_s_SalesBudget WITH (NOLOCK)
	  --   WHERE Month<@month and Year=@year
		 GROUP BY BUGUID,
				  [Year],
				  [Month]
),
 /*本年-未发生月份的目标，包括本月*/
 budget_not_hanpening
	 AS (SELECT SUM(ISNULL(BudgetContractAmount, 0)) / 10000 AS BudgetContractAmount, --计划签约金额(亿元)
				SUM(ISNULL(BudgetOrderAmount, 0)) / 10000    AS BudgetOrderAmount,    --计划认购金额(亿元)
				SUM(ISNULL(BudgetGetinAmount, 0)) / 10000    AS BudgetGetinAmount,    --计划回款金额(亿元)
				[Year]                                       AS Year,
				[Month]                                       AS Month,
				BUGUID                                       AS BUGUID
		 FROM dbo.data_wide_s_SalesBudget WITH (NOLOCK)
		-- WHERE Month <13 and Month>=@month and Year=@year
		 GROUP BY BUGUID,
				  [Year],
				  [Month]
),
  /*本年-已发生月份的实际认购，排除本月*/
 actualOrder
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际签约金额(亿元)
				[Year]                            AS Year,
				[Month]                           AS Month,
				BUGUID                            AS BUGUID
		 FROM (
				  SELECT ISNULL(OCjTotal, 0) AS total,
						 YEAR(HsTjDate)       AS [Year],
						 Month(HsTjDate)       AS [Month],
						 BUGUID
				  FROM  dbo.data_wide_s_SaleHsData WITH (NOLOCK)
				  WHERE HsTjDate <= @now
			  ) a
		-- WHERE  Month<@month and Year=@year
		 GROUP BY BUGUID,
				  [Year],
				  [Month]
 ),
 /*本年-已发生月份的实际签约，排除本月*/
 actualContract
	 AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际签约金额(亿元)
				[Year]                            AS Year,
				[Month]                           AS Month,
				BUGUID                            AS BUGUID
		 FROM (
				  SELECT ISNULL(RmbAmount, 0) AS total,
						 YEAR(HsTjDate)       AS [Year],
						 Month(HsTjDate)       AS [Month],
						 BUGUID
				  FROM  dbo.data_wide_s_SaleHsData WITH (NOLOCK)
				  WHERE HsTjDate <= @now and TradeType='签约'
			  ) a
		-- WHERE  Month<@month and Year=@year
		 GROUP BY BUGUID,
				  [Year],
				  [Month]
 ),
 /*本年-已发生月份的实际回款，排除本月*/
 actualGetin
	 AS (SELECT ISNULL(SUM(Amount), 0) / 100000000 Amount, --实际回款金额(亿元)
				[Year] AS                          Year,
				[Month]                                       AS Month,
				BUGUID AS                          BUGUID
		 FROM (
				  SELECT ISNULL(RmbAmount,0)    AS Amount,
						 YEAR(SkDate) AS [Year],
						 Month(SkDate)       AS [Month],
						 BUGUID
				  FROM dbo.data_wide_s_Getin WITH (NOLOCK)
				  WHERE SkDate <= @now
			  ) data_wide_s_Getin
		 --WHERE  Month<@month and Year=@year
		 GROUP BY BUGUID,
				  [Year],
				  [Month]
 )
SELECT distinct 认购金额,实际认购,签约金额,实际签约,
   回款金额,实际回款,
   认购目标,
   签约目标,
   回款目标,
   CASE
	   WHEN 实际认购 = 0 THEN
		   0
	   WHEN 认购目标 = 0 THEN
		   1
	   ELSE
		   实际认购 / 认购目标
	   END AS 认购达成率,
   CASE
	   WHEN 实际签约 = 0 THEN
		   0
	   WHEN 签约目标 = 0 THEN
		   1
	   ELSE
		   实际签约 / 签约目标
	   END AS 签约达成率,
   CASE
	   WHEN 实际回款 = 0 THEN
		   0
	   WHEN 回款目标 = 0 THEN
		   1
	   ELSE
		   实际回款 / 回款目标
	   END AS 回款达成率,
	  Year*12+Month       as Sort,
			  cast(Year as nvarchar) + '年' + cast(Month as nvarchar) + '月'      as Label,
	  Year as 年,
	  case when Month>=@month then 0 else 1 end IsHapeningMonth,
	  ScopeId
FROM (
	 SELECT ROUND(SUM(ISNULL(actualOrder.Amount, ISNULL(budget_not_hanpening.BudgetOrderAmount,0))), 2) AS 认购金额,
			ROUND(SUM(ISNULL(actualOrder.Amount,0)), 2) AS 实际认购,
			ROUND(SUM(ISNULL(budget_was_hanpening.BudgetOrderAmount, 0)), 2) AS 认购目标,
			ROUND(SUM(ISNULL(actualContract.Amount, ISNULL(budget_not_hanpening.BudgetContractAmount,0))), 2) AS 签约金额,
			ROUND(SUM(ISNULL(actualContract.Amount, 0)), 2) AS 实际签约,
			ROUND(SUM(ISNULL(budget_was_hanpening.BudgetContractAmount, 0)), 2) AS 签约目标,
			ROUND(SUM(ISNULL(actualGetin.Amount, ISNULL(budget_not_hanpening.BudgetGetinAmount,0))), 2)    AS 回款金额,
			ROUND(SUM(ISNULL(actualGetin.Amount, 0)), 2)    AS 实际回款,
			ROUND(SUM(ISNULL(budget_was_hanpening.BudgetGetinAmount, 0)), 2)    AS 回款目标,
			months.Year                                            AS Year,
			months.Month                                            AS Month,
			bu.BUGUID                                             AS ScopeId
	 FROM data_wide_mdm_BusinessUnit bu
		 cross join months
			  LEFT JOIN budget_not_hanpening
						ON budget_not_hanpening.BUGUID = bu.BUGUID
							AND budget_not_hanpening.Year =  months.Year and months.Month = budget_not_hanpening.Month
			  LEFT JOIN budget_was_hanpening
						ON budget_was_hanpening.BUGUID = bu.BUGUID
							AND budget_was_hanpening.Year =  months.Year and months.Month = budget_was_hanpening.Month
				LEFT JOIN actualOrder
						ON actualOrder.Year =  months.Year and
									 months.Month = actualOrder.Month
							AND actualOrder.BUGUID = bu.BUGUID
			  LEFT JOIN actualContract
						ON actualContract.Year =  months.Year and
									 months.Month = actualContract.Month
							AND actualContract.BUGUID = bu.BUGUID
			  LEFT JOIN actualGetin
						ON actualGetin.Year =  months.Year and months.Month = actualGetin.Month
							AND actualGetin.BUGUID = bu.BUGUID
	 WHERE IsEndCompany = 1
	 GROUP BY bu.BUGUID,months.Year ,
			months.Month
 ) t order by Label
 