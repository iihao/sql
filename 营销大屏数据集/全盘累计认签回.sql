 DECLARE
 @jtGuid UNIQUEIDENTIFIER;
 SET @jtGuid ='11B11DB4-E907-4F1F-8835-B9DAAB6E1F23';
 
   /*集团实际签约*/
  with actualContract2
	  AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际签约金额(亿元)
				 @jtGuid                            AS BUGUID
		  FROM (
				   SELECT ISNULL(CNetAmount, 0) AS total,
						  YEAR(StatisticalDate)       AS [Year]
				   FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				   --WHERE StatisticalDate <= @now
			   ) a
		  
  ),
 
   /*集团实际认购*/
  actualOrder2
	  AS (SELECT ISNULL(SUM(total), 0) / 100000000 AS Amount, --实际认购金额(亿元)
				 @jtGuid                            AS BUGUID
		  FROM (
				   SELECT ISNULL(ONetAmount, 0) AS total,
						  YEAR(StatisticalDate)      AS [Year]
				   FROM dbo.data_wide_dws_s_SalesPerf WITH (NOLOCK)
				   --WHERE StatisticalDate <= @now
			   ) a
		 
  ),
  /*集团实际回款*/
  actualGetin2
	  AS (SELECT ISNULL(SUM(Amount), 0) / 100000000 Amount, --实际回款金额(亿元)
				 @jtGuid AS                          BUGUID
		  FROM (
				   SELECT HousingAmount    AS Amount,
						  YEAR(StatisticalDate) AS [Year],
						  BUGUID
				   FROM dbo.data_wide_dws_s_Return WITH (NOLOCK)
				  -- WHERE StatisticalDate <= @now
			   ) data_wide_s_Getin
		 
  )
 
 
	  SELECT 
			 ROUND(SUM(actualContract2.Amount), 2)       AS 实际签约,
			 ROUND(SUM(actualOrder2.Amount), 2)          AS 实际认购,
			 ROUND(SUM(actualGetin2.Amount), 2)          AS 实际回款,
			 @jtGuid                                    AS ScopeId,
			 '' AS ObjectType
	  FROM data_wide_mdm_BusinessUnit bu
			   LEFT JOIN actualContract2
						 ON actualContract2.BUGUID = bu.BUGUID
			   LEFT JOIN actualOrder2
						 ON actualOrder2.BUGUID = bu.BUGUID
			   LEFT JOIN actualGetin2
						 ON actualGetin2.BUGUID = bu.BUGUID
	  WHERE bu.BUGUID=@jtGuid
 