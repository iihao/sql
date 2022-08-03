--查询结果临时表
CREATE TABLE [#tbTemp] ([SpecialBusinessUnitGUID] UNIQUEIDENTIFIER NOT NULL,
[SpecialBusinessUnitName] NVARCHAR(128) NULL,
[Amount] DECIMAL(18, 4) NULL,
[OccurredPlanningAmount] DECIMAL(18, 4) NULL,
[BalanceAmount] DECIMAL(18, 4) NULL);
INSERT INTO #tbTemp(SpecialBusinessUnitGUID, SpecialBusinessUnitName, Amount)
SELECT sbu.SpecialBusinessUnitGUID, sbu.SpecialBusinessUnitName, SUM(ISNULL(t.Amount, 0)) AS Amount
FROM dbo.fy_Cost c
	 JOIN dbo.fy_SpecialBusinessUnit2Cost sbu2c ON sbu2c.CostGUID = c.CostGUID
	 JOIN dbo.fy_SpecialBusinessUnit sbu ON sbu.SpecialBusinessUnitGUID = sbu2c.SpecialBusinessUnitGUID
											AND sbu.IsEnd = 1
											AND EXISTS (SELECT TOP(1)1
														FROM dbo.fy_SpecialBusinessUnit2Project sbu2p
														WHERE sbu2p.SpecialBusinessUnitGUID = sbu.SpecialBusinessUnitGUID
															  AND sbu2p.ProjGUID IN (@var_ProjGUID))
	 LEFT JOIN(SELECT b.ContractItemGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_ContractItemFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_ContractItem b WITH(NOLOCK)ON b.ContractItemGUID = a.ContractItemGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND b.IsAbort = 0 AND a.PlanAmount > 0
			   UNION ALL
			   --合同
			   SELECT b.ContractGUID AS BillGUID, a.FtAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_ContractFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_Contract b WITH(NOLOCK)ON b.ContractGUID = a.ContractGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND b.IsAbort = 0
			   UNION ALL
			   --合同预付
			   SELECT b.HTFKApplyGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_HTFKApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_HTFKApply b WITH(NOLOCK)ON b.HTFKApplyGUID = a.HTFKApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND b.IsPrepay = 1
			   UNION ALL
			   --补充合同
			   SELECT b.BcContractGUID AS BillGUID, a.FtAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_BcContractFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_BcContract b WITH(NOLOCK)ON b.BcContractGUID = a.BcContractGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
			   UNION ALL
			   --合同结算
			   SELECT b.ContractBalanceGUID AS BillGUID, a.FtAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_ContractBalanceFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_ContractBalance b WITH(NOLOCK)ON b.ContractBalanceGUID = a.ContractBalanceGUID
					LEFT JOIN dbo.fy_Contract c WITH(NOLOCK)ON b.MasterContractGUID = c.ContractGUID
					LEFT JOIN dbo.fy_BcContract bc WITH(NOLOCK)ON bc.MasterContractGUID = c.ContractGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
			   UNION ALL
			   --出差申请
			   SELECT b.BusinessTripApplyGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID,
				   a.SpecialBusinessUnitGUID
			   FROM dbo.fy_BusinessTripApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_BusinessTripApply b WITH(NOLOCK)ON b.BusinessTripApplyGUID = a.BusinessTripApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND a.PlanAmount > 0
			   UNION ALL
			   --出差申请
			   SELECT b.BusinessTripApplyGUID AS BillGUID, a.LoanAmount AS Amount, a.CostGUID,
				   a.SpecialBusinessUnitGUID
			   FROM dbo.fy_BusinessTripApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_BusinessTripApply b WITH(NOLOCK)ON b.BusinessTripApplyGUID = a.BusinessTripApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum = 2
					 AND b.IsApplyLoan = 1 AND a.IsCoerceFt = 0
			   UNION ALL
			   --费用申请
			   SELECT b.ExpenseApplyGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_ExpenseApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_ExpenseApply b WITH(NOLOCK)ON b.ExpenseApplyGUID = a.ExpenseApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND a.PlanAmount > 0
			   UNION ALL
			   --费用申请
			   SELECT b.ExpenseApplyGUID AS BillGUID, a.LoanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_ExpenseApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_ExpenseApply b WITH(NOLOCK)ON b.ExpenseApplyGUID = a.ExpenseApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum = 2
					 AND b.IsApplyLoan = 1 AND a.IsCoerceFt = 0
			   UNION ALL
			   --借款申请
			   SELECT b.LoanApplyGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_LoanApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_LoanApply b WITH(NOLOCK)ON b.LoanApplyGUID = a.LoanApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
					 AND a.PlanAmount > 0
			   UNION ALL
			   --日常报销
			   SELECT b.DailyExpenseGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_DailyExpenseFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_DailyExpense b WITH(NOLOCK)ON b.DailyExpenseGUID = a.DailyExpenseGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
			   UNION ALL
			   --差旅报销
			   SELECT b.BusTripExpenseGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_BusTripExpenseFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_BusTripExpense b WITH(NOLOCK)ON b.BusTripExpenseGUID = a.BusTripExpenseGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)
			   UNION ALL
			   --对公请款
			   SELECT b.CompanyPayApplyGUID AS BillGUID, a.PlanAmount AS Amount, a.CostGUID, a.SpecialBusinessUnitGUID
			   FROM dbo.fy_CompanyPayApplyFtDetail a WITH(NOLOCK)
					LEFT JOIN dbo.fy_CompanyPayApply b WITH(NOLOCK)ON b.CompanyPayApplyGUID = a.CompanyPayApplyGUID
			   WHERE a.SourceDate BETWEEN @var_StartDate AND @var_EndDate AND b.ApproveStateEnum IN (2, 3)) t ON t.CostGUID = c.CostGUID
																												 AND t.SpecialBusinessUnitGUID = sbu.SpecialBusinessUnitGUID
WHERE c.BUGUID = @var_BUGUID AND c.IsDisable = 0
GROUP BY sbu.SpecialBusinessUnitName, sbu.SpecialBusinessUnitGUID;

--更新预算，余额
UPDATE a
SET a.OccurredPlanningAmount = Budget.OccurredPlanningAmount,
	a.BalanceAmount = Budget.OccurredPlanningAmount - a.Amount
FROM #tbTemp a
	 LEFT JOIN(SELECT ybp.SpecialBusinessUnitGUID,
				   SUM(ybp.OccurredPlanningAmount + ybp.OccurredPlanningAdjustAmount) AS OccurredPlanningAmount
			   FROM dbo.fy_YearBudgetPoise ybp WITH(NOLOCK)
					JOIN dbo.fy_Cost c WITH(NOLOCK)ON c.CostGUID = ybp.CostGUID
			   WHERE ybp.YearMonth BETWEEN @var_StartDate AND @var_EndDate AND c.IsEnd = 1
			   GROUP BY ybp.SpecialBusinessUnitGUID) Budget ON Budget.SpecialBusinessUnitGUID = a.SpecialBusinessUnitGUID;

--查询结果
SELECT * FROM #tbTemp ORDER BY SpecialBusinessUnitGUID;
DROP TABLE #tbTemp;