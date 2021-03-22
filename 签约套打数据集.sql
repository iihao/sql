SELECT  buyer1.CstName AS 买方1姓名, buyer1.CardType AS 买方1证件类型, buyer1.CardID AS 买方1证件号码, cst1.Gender AS 买方1性别, cst1.PostCode AS 买方1邮政编码, buyer1.Tel AS 买方1联系电话, buyer1.Address AS 买方1地址, YEAR(cst1.BirthDate) 
  AS 买方1出生_年, MONTH(cst1.BirthDate) AS 买方1出生_月, DAY(cst1.BirthDate) AS 买方1出生_日, 
  buyer2.CstName AS 买方2姓名, buyer2.CardType AS 买方2证件类型, buyer2.CardID AS 买方2证件号码, cst2.Gender AS 买方2性别, 
  cst2.PostCode AS 买方2邮政编码, buyer2.Tel AS 买方2联系电话, buyer2.Address AS 买方2地址, YEAR(cst2.BirthDate) AS 买方2出生_年, MONTH(cst2.BirthDate) AS 买方2出生_月, DAY(cst2.BirthDate) AS 买方2出生_日, 
  buyer3.CstName AS 买方3姓名, buyer3.CardType AS 买方3证件类型, buyer3.CardID AS 买方3证件号码, cst3.Gender AS 买方3性别, 
  cst3.PostCode AS 买方3邮政编码, buyer3.Tel AS 买方3联系电话, buyer3.Address AS 买方3地址, YEAR(cst3.BirthDate) AS 买方3出生_年, MONTH(cst3.BirthDate) AS 买方3出生_月, DAY(cst3.BirthDate) AS 买方3出生_日, 
  CAST(sale.BldArea AS decimal(18, 2)) AS 建筑面积, CAST(sale.TnArea AS decimal(18, 2)) AS 套内面积, CONVERT(nvarchar, CAST(sale.CjTnPrice AS money), 1) AS 套内成交单价, CONVERT(nvarchar, CAST(sale.CjBldPrice AS money), 1) AS 折后单价, 
  CONVERT(nvarchar, CAST(sale.DiscntValue AS money), 1) AS 折扣, sale.DiscntRemark AS 折扣体系, CONVERT(nvarchar, CAST(sale.CjRoomTotal AS money), 1) AS 折后总价, CONVERT(nvarchar, CAST(sale.RoomBldPrice AS money), 1) AS 原单价, 
  CONVERT(nvarchar, CAST(sale.RoomTotal AS money), 1) AS 原总价, CONVERT(nvarchar, CAST(sale.AjTotal AS money), 1) AS 按揭金额, CONVERT(nvarchar, CAST(sale.CjRoomTotal - sale.AjTotal - sale.GjjTotal AS money), 1) AS 交款合计, 
  CONVERT(nvarchar, CAST(sale.CjRoomTotal - sale.AjTotal-(select ISNULL(SUM(RmbAmount), 0) AS Expr1 from  dbo.s_Fee AS f where ItemName='借款' and (TradeGUID = sale.TradeGUID) AND (sale.Status = '激活') ) AS money), 1) AS 瑞府交款合计, 

  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(round(sale.BldArea*1906,0) AS money), 1) else CONVERT(nvarchar, CAST(round(sale.BldArea*1914,0) AS money), 1) end AS 丰城春江悦装修总价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(1906 AS money), 1) else CONVERT(nvarchar, CAST(1914 AS money), 1) end AS 丰城春江悦装修单价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(round(sale.RoomTotal-sale.BldArea*1906,0) AS money), 1) else CONVERT(nvarchar, CAST(round(sale.RoomTotal-sale.BldArea*1914,0) AS money), 1) end AS 丰城春江悦原毛坯总价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(sale.RoomBldPrice-1906 AS money), 1) else CONVERT(nvarchar, CAST(sale.RoomBldPrice-1914 AS money), 1) end AS 丰城春江悦原毛坯单价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(round(sale.CjRmbTotal-sale.BldArea*1906,0) AS money), 1) else CONVERT(nvarchar, CAST(round(sale.CjRmbTotal-sale.BldArea*1914,0) AS money), 1) end AS 丰城春江悦成交毛坯总价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(sale.CjBldPrice-1906 AS money), 1) else CONVERT(nvarchar, CAST(sale.CjBldPrice-1914 AS money), 1) end AS 丰城春江悦成交毛坯单价, 
  CASE WHEN sale.BldArea >= 110 then CONVERT(nvarchar, CAST(round((sale.CjRmbTotal-sale.BldArea*1906)*0.015,0) AS money), 0) else CONVERT(nvarchar, CAST(round((sale.CjRmbTotal-sale.BldArea*1914)*0.015,0) AS money), 0) end AS 丰城春江悦维修基金, 

		   case when PayFormName like '%一次性%' then
	  CONVERT(nvarchar, CAST(
	  (SELECT  ISNULL(SUM(RmbAmount), 0) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金','楼款')) AND (TradeGUID = sale.TradeGUID))-(SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE  (ItemName in ( '首期','定金')) and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1)
	 else 
	 CONVERT(nvarchar, CAST(
	  (SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID))-(SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
WHERE   (ItemName in ( '首期','定金')) and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1)
	 end
	  AS '瑞府-今日交款',

CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') AND datediff(dd, G.GetDate,getdate())=0) AS money), 1) AS 今日交款金额,

SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_十万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_千,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_百,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_十,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款') AND datediff(dd, G.GetDate,getdate())=0) AS money),0), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 今日已交款金额_元,


	CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') AND ItemName in ( '定金')) AS money), 1) AS 已交定金金额,

SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_十万, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_万, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT,RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_千, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_百, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_十, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST(sale.CjRoomTotal - sale.AjTotal AS money), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 交款合计_元, 


SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_十万, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_万, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT,RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_千, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_百, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_十, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府交款合计_元, 



SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_十万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_千,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE  itemtype in ('贷款类房款','非贷款类房款')  and  (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_百,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_十,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money),0), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 已交款金额_元,

CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money), 1) AS 瑞府已交款金额, 
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_十万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_千,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_百,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_十,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST
((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') and ItemType in ('非贷款类房款','贷款类房款')) AS money),0), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府已交款金额_元,

  CASE WHEN CAST(((
	  (SELECT  SUM(isnull(RmbAmount, 0))
	FROM     s_fee f
	WHERE   f.ItemName in  ('首期','定金','楼款','车位款') AND f.TradeGUID = sale.TradeGUID)) / sale.CjRoomTotal * 100) AS decimal(18, 0)) IS NULL THEN 0 ELSE CAST(((              (SELECT  SUM(isnull(RmbAmount, 0))
	FROM     s_fee f
	WHERE   f.ItemName in  ('首期','定金','楼款','车位款') AND f.TradeGUID = sale.TradeGUID)) / sale.CjRoomTotal * 100) AS decimal(18, 0)) END AS 首付比例, 
	
	ISNULL(ys.应收金额, 0) AS 应收金额, ISNULL(ys.实收金额, 0) AS 实收金额, ISNULL(ys.欠款金额, 0) AS 欠款金额, 
  CONVERT(nvarchar, CAST(ys.实收金额 AS money), 1) AS 实收金额1,proj.ProjectName AS 分期名称, proj.ProjectFullName AS 项目全称, bt.BldName AS 楼栋名称, room.Unit AS 单元名称, room.FloorName AS 楼层, room.Room AS 房号, room.RoomInfo AS 房间全称, room.RoomGUID, 
  sale.PayFormName AS 付款方式, sale.AgreementNo AS 合同编号, CONVERT(nvarchar, CAST(sale.Earnest AS money), 1) AS 定金, CONVERT(nvarchar, CAST(ISNULL(sale.Earnest, 0) +
	  (SELECT  ISNULL(SUM(RmbAmount), 0) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName = '首期') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 首期定金, 

CONVERT(nvarchar, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 红星九颂首期定金, 	
	
CONVERT(nvarchar, CAST((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金','车位款')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 车位首付, 			
	
	CONVERT(nvarchar, CAST(- ISNULL(sale.Earnest, 0) +
	  (SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName = '首期') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 今日首付金额,
	
	CONVERT(nvarchar, CAST(- ISNULL(sale.Earnest, 0) +
	  (SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 今日首付金额新,

				CONVERT(nvarchar, CAST( ISNULL(sale.Earnest, 0) +
	  (SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ( '首期','定金')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 今日首付金额新bak,


				CONVERT(nvarchar, CAST(
	  (SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	FROM     dbo.s_Fee AS f
	WHERE   (ItemName in ('定金','首期')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 首付金额新修水,
	
	CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)*0.006) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemType in( '非贷款类房款','贷款类房款')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 维修基金新,
	

	CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 借款,

	 CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName = '首期') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 首期, CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName = '契税') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 契税, CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName like '%维修基金%') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 维修基金, 
	 
	 --CONVERT(nvarchar, CAST
	 -- ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 --FROM     dbo.s_Fee AS f
	 --WHERE   (ItemName = '办证费') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 办证费,

	 CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName = '制证费') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 办证费,

	 CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName = '工本费') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 工本费,
	 
	 
	 CONVERT(nvarchar, CAST
	  ((SELECT  SUM(ISNULL(RmbAmount, 0)) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemType = '代收费用') AND (TradeGUID = sale.TradeGUID)) AS money), 1) AS 代收费用总和, 

CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('贷款类房款','非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1) AS 已交款金额, 


CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1) AS 已交非贷款金额, 
CONVERT(nvarchar, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')  and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1) AS 应交非贷款金额, 
CONVERT(nvarchar, CAST
	  (((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')  and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活'))) AS money), 1) AS 今日应交非贷款金额,
	 
  CONVERT(nvarchar, CAST
	  (((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money), 1) AS 瑞府今日应交非贷款金额,

SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 1000000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_百万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 100000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_十万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 10000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_万,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 1000) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_千,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 100) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_百,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 10) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_十,
SUBSTRING('零壹贰叁肆伍陆柒捌玖', CONVERT(INT, RIGHT(CAST(CAST(FLOOR(CONVERT(INT, isnull (CAST(((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Fee AS G
	 WHERE   itemtype in ('非贷款类房款')   and ( TradeGUID= sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   itemtype in ('非贷款类房款')  and (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) - (SELECT  ISNULL(SUM(RmbAmount), 0)             AS Expr1 FROM     dbo.s_Fee AS f
	 WHERE   (ItemName in( '借款')) AND (TradeGUID = sale.TradeGUID))) AS money),0), 1) / 1) AS BIGINT) AS VARCHAR(30)), 1)) + 1, 1) AS 瑞府今日应交非贷款金额_元,

						   
	 CASE WHEN (CONVERT(float, CAST(isnull(sale.Earnest, 0) +
	  (SELECT  SUM(isnull(RmbAmount, 0))
	FROM     s_fee f
	WHERE   f.ItemName = '首期' AND f.TradeGUID = sale.TradeGUID) AS money), 1) - CONVERT(float, CAST
	  ((SELECT  SUM(G.Amount)
	 FROM     s_Getin G
	 WHERE   G.SaleGUID = sale.TradeGUID AND sale.Status = '激活') AS money), 1)) = '0' THEN '       ' ELSE (CONVERT(float, CAST(isnull(sale.Earnest, 0) +
	  (SELECT  SUM(isnull(RmbAmount, 0))
	FROM     s_fee f
	WHERE   f.ItemName = '首期' AND f.TradeGUID = sale.TradeGUID) AS money), 1) - CONVERT(float, CAST
	  ((SELECT  SUM(G.Amount)
	 FROM     s_Getin G
	 WHERE   G.SaleGUID = sale.TradeGUID AND sale.Status = '激活') AS money), 1)) END AS 当日应交, CONVERT(float, CAST(sale.Earnest AS money), 1) - CONVERT(float, CAST
	  ((SELECT  SUM(Amount) AS Expr1
	 FROM     dbo.s_Getin AS G
	 WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活')) AS money), 1) AS 当日应交1, YEAR(sale.QSDate) AS 签署日期_年, MONTH(sale.QSDate) AS 签署日期_月, DAY(sale.QSDate) AS 签署日期_日, CONVERT(varchar(100), 
  sale.QSDate, 23) AS 签约日期, CONVERT(varchar(100), t.RGOrderQsDate, 23) AS 认购日期, sale.CalMode AS 计价方式, sale.AjBank AS 按揭银行, sale.AjYear AS 按揭年限, sale.GjjBank AS 公积金银行, CONVERT(nvarchar, 
  CAST(sale.AjTotal + sale.GjjTotal AS money), 1) AS 贷款金额, CONVERT(nvarchar, CAST(sale.GjjTotal AS money), 1) AS 公积金金额,

	case when sale.PayFormName like '%一次性%' then '130' else '210' end AS 制证费_丰城珑园,
	ys.产证代办,
	 CONVERT(nvarchar, CAST
	  ((SELECT  round(SUM(ISNULL(RmbAmount, 0)*0.015) ,0)AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemType in( '非贷款类房款','贷款类房款')) AND (TradeGUID = sale.TradeGUID)) AS INT), 1) AS 维修基金_丰城珑园,

	 CONVERT(nvarchar, CAST
	  ((SELECT  round(SUM(ISNULL(RmbAmount, 0)*0.015),0)+(case when sale.PayFormName like '%一次性%' then '130' else '210' end) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemType in( '非贷款类房款','贷款类房款')) AND (TradeGUID = sale.TradeGUID)) AS INT), 1) AS 代收费用总和_丰城珑园,	
				  CONVERT(nvarchar, CAST
	  ((SELECT  round(SUM(ISNULL(RmbAmount, 0)*0.015),0)+(ys.产证代办) AS Expr1
	 FROM     dbo.s_Fee AS f
	 WHERE   (ItemType in( '非贷款类房款','贷款类房款')) AND (TradeGUID = sale.TradeGUID)) AS INT), 1) AS 代收费用总和_丰城珑园_new,	  
   sale.ContractGUID AS oid
FROM    dbo.s_Contract AS sale LEFT OUTER JOIN
  dbo.s_Buyer AS buyer1 ON sale.ContractGUID = buyer1.SaleGUID AND buyer1.CstNum = 1 LEFT OUTER JOIN
  dbo.s_Buyer AS buyer2 ON sale.ContractGUID = buyer2.SaleGUID AND buyer2.CstNum = 2 LEFT OUTER JOIN
  dbo.s_Buyer AS buyer3 ON sale.ContractGUID = buyer3.SaleGUID AND buyer3.CstNum = 3 LEFT OUTER JOIN
  dbo.s_OCAttachRoom AS fs1 ON sale.ContractGUID = fs1.SaleGUID AND fs1.Sequence = 1 LEFT OUTER JOIN
  dbo.s_room AS fs1_Room ON fs1.RoomGUID = fs1_Room.RoomGUID LEFT OUTER JOIN
  dbo.s_Building AS fs1_bld ON fs1_bld.BldGUID = fs1_Room.BldGUID LEFT OUTER JOIN
  dbo.s_OCAttachRoom AS fs2 ON sale.ContractGUID = fs2.SaleGUID AND fs2.Sequence = 2 LEFT OUTER JOIN
  dbo.s_room AS fs2_Room ON fs2.RoomGUID = fs2_Room.RoomGUID LEFT OUTER JOIN
  dbo.s_Building AS fs2_bld ON fs2_bld.BldGUID = fs2_Room.BldGUID LEFT OUTER JOIN
  dbo.p_Customer AS cst1 ON buyer1.CstGUID = cst1.CstGUID LEFT OUTER JOIN
  dbo.p_Customer AS cst2 ON buyer2.CstGUID = cst2.CstGUID LEFT OUTER JOIN
  dbo.p_Customer AS cst3 ON buyer3.CstGUID = cst3.CstGUID LEFT OUTER JOIN
  dbo.s_room AS room ON sale.RoomGuid = room.RoomGUID LEFT OUTER JOIN
  dbo.s_Trade AS t ON sale.TradeGUID = t.TradeGUID LEFT OUTER JOIN
  dbo.s_Building AS bt ON bt.BldGUID = room.BldGUID LEFT OUTER JOIN
  dbo.vp_interface_businessunit AS unit ON sale.BUGUID = unit.BUGUID LEFT OUTER JOIN
  dbo.vp_interface_project AS proj ON sale.ProjGUID = proj.ProjectId LEFT OUTER JOIN
  dbo.vp_interface_project AS fs1_proj ON fs1.ProjGUID = fs1_proj.ProjectId LEFT OUTER JOIN
  dbo.vp_interface_project AS fs2_proj ON fs2.ProjGUID = fs2_proj.ProjectId LEFT OUTER JOIN
	  (SELECT  TradeGUID, MAX(CASE WHEN ItemType IN ('贷款类房款') AND rmbye > 0 THEN lastdate ELSE NULL END) AS 按揭类付款期限, SUM(CASE WHEN ItemType IN ('贷款类房款') THEN f.RmbYe ELSE 0 END) AS 按揭类欠款金额, 
			   MAX(CASE WHEN ItemName IN ('首期', '楼款', '车位款') AND rmbye > 0 THEN lastdate ELSE NULL END) AS 首期类付款期限, SUM(CASE WHEN ItemName IN ('首期', '楼款', '车位款') THEN f.RmbYe ELSE 0 END) AS 首期类欠款金额, 
			   MAX(CASE WHEN ItemName IN ('借款') AND rmbye > 0 THEN lastdate ELSE NULL END) AS 借款类付款期限, SUM(CASE WHEN ItemName IN ('借款') THEN f.RmbYe ELSE 0 END) AS 借款类欠款金额, 
			   SUM(CASE WHEN ItemType IN ('贷款类房款', '非贷款类房款') THEN f.RmbAmount ELSE 0 END) AS 应收金额, SUM(CASE WHEN ItemType IN ('贷款类房款', '非贷款类房款') THEN f.RmbAmount - f.RmbYe ELSE 0 END) AS 实收金额, 
			   SUM(CASE WHEN ItemName IN ('产证代办') THEN f.RmbAmount ELSE 0 END) AS 产证代办,
			   SUM(CASE WHEN ItemType IN ('贷款类房款', '非贷款类房款') THEN f.RmbYe ELSE 0 END) AS 欠款金额
	FROM     dbo.s_Fee AS f
	GROUP BY TradeGUID) AS ys ON ys.TradeGUID = sale.TradeGUID









