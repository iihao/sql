SET DATEFIRST 1
DECLARE @now Date =GetDate()
declare @yesterday Date =DATEADD(day, -1, @now)
declare @weekstartday Date =DATEADD(day, 1 - datepart(weekday, @now), @now)
declare @weekendday Date =DATEADD(day, -1, DATEADD(week, 1, @weekstartday))
declare @monthstartday Date =DATEADD(day, 1 - day(@now), @now)
declare @monthendday Date =DATEADD(day, -1, DATEADD(month, 1, @monthstartday))
declare @yearstartday Date =cast(year(@now) as varchar(4)) + '-01-01';
declare @yearendday Date =DATEADD(day, -1, DATEADD(year, 1, @yearstartday))
declare @quarterstartday Date =DATEADD(month, (datepart(quarter, @now) - 1) * 3, @yearstartday)
declare @quarterendday Date =DATEADD(day, -1, DATEADD(quarter, 1, @quarterstartday))

DECLARE @jtGuid UNIQUEIDENTIFIER;
SET @jtGuid = '11B11DB4-E907-4F1F-8835-B9DAAB6E1F23';

with [bu] AS (
	select BUGUID,BUName, HierarchyCode from data_wide_mdm_BusinessUnit WITH (NOLOCK) WHERE IsEndCompany =1
),
	 [proj] as (
		 select proj.p_projectId as projGuid,
				parent.p_projectId as parentGuid,
				proj.ProjName as ProjName,
				proj.ProjShortName,
				parent.ProjName as ParentProjName,
				proj.BUGUID,
				proj.HierarchyCode,
				parent.HierarchyCode as ParentHierarchyCode
		 from data_wide_mdm_Project proj with(nolock )
				  left join data_wide_mdm_Project parent on proj.ParentGUID= parent.p_projectId
		 where proj.IfEnd =1 and proj.ApplySys like '%0011%'
	 ),
	 -- 累计实际回款
	 [ActualGetIn] as (
		 SELECT isnull(SUM(ISNULL(LoanHousingAmount, 0)), 0)            AS [LoanHousingAmount],
				isnull(SUM(ISNULL(NonLoanHousingAmount, 0)), 0)         AS [NonLoanHousingAmount],
				isnull(SUM(ISNULL(SupplementaryAgreementAmount, 0)), 0) AS [SupplementaryAgreementAmount],
				isnull(SUM(ISNULL(HousingAmount, 0)), 0)                AS [HousingAmount],
				isnull(SUM(ISNULL(Report_BuildAmount, 0)), 0)           AS [Report_BuildAmount],
				isnull(SUM(ISNULL(Report_FirstAmount, 0)), 0)           AS [Report_FirstAmount],
				isnull(SUM(ISNULL(Report_EarnestAmount, 0)), 0)         AS [Report_EarnestAmount],
				isnull(SUM(ISNULL(Report_OtherAmount, 0)), 0)           AS [Report_OtherAmount],
				StatisticalDate,
				BUGUID,
				ProjGUID,
				ParentProjGUID,
				TopProductTypeGUID,
				ProjName,
				ParentProjName,
				TopProductTypeName,
				TopProductTypeCode,
				BUName
		 from (
				  SELECT LoanHousingAmount,
						 NonLoanHousingAmount,
						 HousingAmount,
						 SupplementaryAgreementAmount,
						 Report_BuildAmount,
						 Report_FirstAmount,
						 Report_EarnestAmount,
						 Report_OtherAmount,
						 StatisticalDate,
						 BUGUID,
						 ProjGUID,
						 ParentProjGUID,
						 TopProductTypeGUID,
						 ProjName,
						 ParentProjName,
						 TopProductTypeName,
						 TopProductTypeCode,
						 BUName
				  FROM dbo.data_wide_dws_s_Return WITH (NOLOCK)
			  ) A
		 group by  StatisticalDate,
				   BUGUID,
				   ProjGUID,
				   ParentProjGUID,
				   TopProductTypeGUID,
				   ProjName,
				   ParentProjName,
				   TopProductTypeName,
				   TopProductTypeCode,
				   BUName
	 )

select Convert(decimal(18, 4), [贷款类回款金额] / 10000.00)  as [贷款类回款金额],
	   Convert(decimal(18, 4), [非贷款类回款金额] / 10000.00) as [非贷款类回款金额],
	   Convert(decimal(18, 4), [补充协议款] / 10000.00)    as [补充协议款],
	   Convert(decimal(18, 4), [回款金额] / 10000.00)     as [回款金额],
	   Convert(decimal(18, 4), [楼款_模糊匹配] / 10000.00)     as [楼款_模糊匹配],
	   Convert(decimal(18, 4), [首期_模糊匹配] / 10000.00)     as [首期_模糊匹配],
	   Convert(decimal(18, 4), [定金_模糊匹配] / 10000.00)     as [定金_模糊匹配],
	   Convert(decimal(18, 4), [其他_模糊匹配] / 10000.00)     as [其他_模糊匹配],
	   HierarchyCode,
	   Object,
	   ScopeId,
	   ParentScopeId,
	   GrandParentScopeId,
	   ObjectType,
	   [维度]
from (
		 -- 公司
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName as Object,
				'昨日情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID and Cast(StatisticalDate as Date) = @yesterday
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'本日情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID and Cast(StatisticalDate as Date) = @now
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'本周情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID and StatisticalDate between @weekstartday and @weekendday
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'本月情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn
							on bu.BUGUID = ActualGetIn.BUGUID and StatisticalDate between @monthstartday and @monthendday
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'本季情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID and StatisticalDate between @quarterstartday and @quarterendday
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'本年情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID and StatisticalDate between @yearstartday and @yearendday
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				@jtGuid as ParentScopeId,
				bu.BUGUID                                                                                      AS ScopeId,
				bu.BUName,
				'累计情况'                                                                                      AS ObjectType,
				'公司'                                                                                            AS [维度],
				bu.HierarchyCode
		 FROM bu
				  left join ActualGetIn on bu.BUGUID = ActualGetIn.BUGUID
		 GROUP BY bu.BUGUID, bu.BUName,bu.HierarchyCode
				  --集团
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'昨日情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where Cast(StatisticalDate as Date) = @yesterday
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'本日情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where Cast(StatisticalDate as Date) = @now
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'本周情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where StatisticalDate between @weekstartday and @weekendday
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'本月情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where StatisticalDate between @monthstartday and @monthendday
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'本季情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where StatisticalDate between @quarterstartday and @quarterendday
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'本年情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
		 where StatisticalDate between @yearstartday and @yearendday
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				null as GrandParentScopeId,
				null as ParentScopeId,
				@jtGuid                                                                                        AS ScopeId,
				'集团',
				'累计情况'                                                                                      AS ObjectType,
				'集团'                                                                                            AS [维度],
				'' as HierarchyCode
		 FROM ActualGetIn
			  --项目
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'昨日情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @yesterday
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'本日情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @now
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'本周情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @weekstartday and @weekendday
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'本月情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @monthstartday and @monthendday
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'本季情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @quarterstartday and @quarterendday
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'本年情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @yearstartday and @yearendday
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.BUGUID as ParentScopeId,
				proj.parentGuid                                                                                  AS ScopeId,
				proj.ParentProjName,
				'累计情况'                                                                                      AS ObjectType,
				'项目'                                                                                            AS [维度],
				proj.ParentHierarchyCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid
		 GROUP BY proj.parentGuid, proj.ParentProjName,proj.BUGUID,proj.ParentHierarchyCode

				  --分期
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'昨日情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @yesterday
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'本日情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @now
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'本周情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @weekstartday and @weekendday
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID ,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'本月情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @monthstartday and @monthendday
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID ,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'本季情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @quarterstartday and @quarterendday
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID ,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'本年情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @yearstartday and @yearendday
		 GROUP BY proj.projGuid, proj.ProjShortName,proj.parentGuid,proj.BUGUID,proj.HierarchyCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				proj.BUGUID as GrandParentScopeId,
				proj.parentGuid as ParentScopeId,
				proj.projGuid                                                                                  AS ScopeId,
				proj.ProjShortName,
				'累计情况'                                                                                      AS ObjectType,
				'分期'                                                                                            AS [维度],
				proj.HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid
		 GROUP BY proj.projGuid,proj.ProjShortName,proj.parentGuid,proj.BUGUID,proj.HierarchyCode
				  -- 业态
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'昨日情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @yesterday
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'本日情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and Cast(StatisticalDate as Date) = @now
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'本周情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @weekstartday and @weekendday
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'本月情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @monthstartday and @monthendday
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'本季情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn
							on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @quarterstartday and @quarterendday
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'本年情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid and StatisticalDate between @yearstartday and @yearendday
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
		 union all
		 SELECT isnull(SUM(ISNULL(ActualGetIn.LoanHousingAmount, 0)), 0)            AS [贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.NonLoanHousingAmount, 0)), 0)         AS [非贷款类回款金额],
				isnull(SUM(ISNULL(ActualGetIn.SupplementaryAgreementAmount, 0)), 0) AS [补充协议款],
				isnull(SUM(ISNULL(ActualGetIn.HousingAmount, 0)), 0)                AS [回款金额],
				isnull(SUM(ISNULL(ActualGetIn.Report_BuildAmount, 0)), 0)           AS [楼款_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_FirstAmount, 0)), 0)           AS [首期_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_EarnestAmount, 0)), 0)         AS [定金_模糊匹配],
				isnull(SUM(ISNULL(ActualGetIn.Report_OtherAmount, 0)), 0)           AS [其他_模糊匹配],
				'00000000-0000-0000-0000-000000000000' as GrandParentScopeId,
				proj.projGuid as ParentScopeId,
				TopProductTypeGUID                                                                                AS ScopeId,
				TopProductTypeName,
				'累计情况'                                                                                      AS ObjectType,
				'业态'                                                                                            AS [维度],
				TopProductTypeCode as HierarchyCode
		 FROM proj
				  left join ActualGetIn on proj.projGuid = ActualGetIn.projGuid
		 where TopProductTypeName is not null
		 GROUP BY proj.projGuid,TopProductTypeName,TopProductTypeGUID,proj.parentGuid,TopProductTypeCode
	 )A
