declare @year int=2021;
WITH budget
		 AS (
			SELECT 
			sum(case when BudgetType='计划认购金额'  then a.BudgetAmount else 0 end) as BudgetOrderAmount,
			sum(case when BudgetType='计划签约金额'  then a.BudgetAmount else 0 end) as BudgetContractAmount,
			sum(case when BudgetType='计划回款金额'  then a.BudgetAmount else 0 end) as BudgetGetinAmount,
			ProjGUID
			FROM (select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,1 as month,x_Month1 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,2 as month,x_Month2 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,3 as month,x_Month3 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,4 as month,x_Month4 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,5 as month,x_Month5 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,6 as month,x_Month6 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,7 as month,x_Month7 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,8 as month,x_Month8 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,9 as month,x_Month9 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,10 as month,x_Month10 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,11 as month,x_Month11 as BudgetAmount,x_year as year from x_s_SalesBudget union all
			select x_ProjGUID as ProjGUID,x_BudgetType as BudgetType,12 as month,x_Month12 as BudgetAmount,x_year as year from x_s_SalesBudget)
			a LEFT JOIN  (select *,case when isnull(ParentCode,'')='' then ProjCode else ParentCode end AS NewParentCode from p_Project)p on a.ProjGUID=p.p_projectId
			LEFT JOIN  p_project p1 on p.NewParentCode = p1.ProjCode
			 WHERE  Year=@year
			 GROUP BY ProjGUID
	),

	 /*实际签约*/
	 actualContract
		 AS (SELECT ISNULL(SUM(RmbAmount), 0) / 100000000 AS Amount, --实际签约金额(亿元)
		 ProjGUID
		  FROM s_SaleHsData  a WITH (NOLOCK)
		  WHERE year(a.QsDate) = @year AND TradeType='签约'
		GROUP BY a.ProjGUID
				  
	 ),
	
	 /*实际认购*/
	 actualOrder
		 AS (SELECT ISNULL(SUM(RmbAmount), 0) / 100000000 AS Amount, --实际签约金额(亿元)
		 ProjGUID
		  FROM s_SaleHsData  a WITH (NOLOCK)
		  WHERE year(a.QsDate) = @year 
		GROUP BY a.ProjGUID
				  
	 ),
	 /*实际回款*/
	 actualGetin
		 AS (     SELECT ISNULL(SUM(a.RmbAmount), 0) / 100000000    AS Amount,
							 a.ProjGUID
				 from s_Getin a left join s_Voucher b ON a.VouchGUID =b.VouchGUID
				INNER JOIN dbo.s_Trade c ON a.SaleGUID = c.TradeGUID and (c.TradeStatus='激活' or c.CloseReason='退房') and RoomStatus='签约'
				INNER JOIN s_Room sr ON c.RoomGUID = sr.RoomGUID  
				INNER JOIN s_Building  sb ON sr.BldGUID = sb.BldGUID    
				where isnull(a.Status,'') <> '作废' and b.VouchType in ('收款单','退款单','放款单','转账单')    	       
				and ItemType in ( '非贷款类房款' , '贷款类房款') 
				and year(case when c.ContractQsDate>a.GetDate and isnull(c.ContractQsDate,'')<>''  then c.ContractQsDate else a.GetDate end)=@year
				group by a.ProjGUID 
				  
	 )

SELECT *,@year as year,
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
		 SELECT SUM(ISNULL(budget.BudgetContractAmount, 0) ) AS 签约目标,
				SUM(ISNULL(budget.BudgetOrderAmount, 0) )    AS 认购目标,
				SUM(ISNULL(budget.BudgetGetinAmount, 0) )    AS 回款目标,
				SUM(ISNULL(actualContract.Amount, 0) )       AS 实际签约,
				SUM(ISNULL(actualOrder.Amount, 0) )          AS 实际认购,
				SUM(ISNULL(actualGetin.Amount, 0) )          AS 实际回款,
				'集团' BuName
		 FROM ( 
		 select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p 
		-- LEFT JOIN p_Project P1 ON P.ParentGUID=P1.p_projectId
				  LEFT JOIN budget
							ON budget.ProjGUID = p.p_projectId         
				  LEFT JOIN actualContract
							ON  actualContract.ProjGUID = p.p_projectId     
				  LEFT JOIN actualOrder
							 ON actualOrder.ProjGUID = p.p_projectId     
				  LEFT JOIN actualGetin
							 ON actualGetin.ProjGUID = p.p_projectId     	
	 ) t
	 
	UNION ALL 

	SELECT *,@year as year,
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
		 SELECT SUM(ISNULL(budget.BudgetContractAmount, 0) ) AS 签约目标,
				SUM(ISNULL(budget.BudgetOrderAmount, 0) )    AS 认购目标,
				SUM(ISNULL(budget.BudgetGetinAmount, 0) )    AS 回款目标,
				SUM(ISNULL(actualContract.Amount, 0) )       AS 实际签约,
				SUM(ISNULL(actualOrder.Amount, 0) )          AS 实际认购,
				SUM(ISNULL(actualGetin.Amount, 0) )          AS 实际回款,
				P1.ProjName AS BuName
		 FROM ( 
		 select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p 
		LEFT JOIN p_Project P1 ON P.ParentGUID=P1.p_projectId
				  LEFT JOIN budget
							ON budget.ProjGUID = p.p_projectId         
				  LEFT JOIN actualContract
							ON  actualContract.ProjGUID = p.p_projectId     
				  LEFT JOIN actualOrder
							 ON actualOrder.ProjGUID = p.p_projectId     
				  LEFT JOIN actualGetin
							 ON actualGetin.ProjGUID = p.p_projectId 
		GROUP BY P1.ProjName    	
	 ) t
