fn_ChnMoney

SELECT 
fs1_Room.RoomInfo as 附属1_房间全称,
cast(fs1.BldArea as decimal(18,4)) as 附属1_建筑面积,
cast(fs1.TnArea as decimal(18,4)) as 附属1_套内面积,
convert(nvarchar,cast(fs1.CjBldPrice as money),1) as 附属1_建筑成交单价,
convert(nvarchar,cast(fs1.CjTnPrice as money),1) as 附属1_套内成交单价,
convert(nvarchar,cast(fs1.Discount as money),1) as 附属1_折扣,
convert(nvarchar,cast(fs1.CjTotal as money),1)  as 附属1_成交总价,
fs1_proj.ProjectFullName as 附属1_项目全称,
fs1_bld.BldName as 附属1_楼栋名称,
fs1_Room.Unit as 附属1_单元名称,
fs1_Room.FloorName as 附属1_楼层,
fs1_Room.Room as 附属1_房号,
fs2_Room.RoomInfo as 附属2_房间全称,
cast(fs2.BldArea as decimal(18,4)) as 附属2_建筑面积,
cast(fs2.TnArea as decimal(18,4)) as 附属2_套内面积,
convert(nvarchar,cast(fs2.CjBldPrice as money),1) as 附属2_建筑成交单价,
convert(nvarchar,cast(fs2.CjTnPrice as money),1) as 附属2_套内成交单价,
convert(nvarchar,cast(fs2.Discount as money),1) as 附属2_折扣,
convert(nvarchar,cast(fs2.CjTotal as money),1)  as 附属2_成交总价,
fs2_proj.ProjectFullName as 附属2_项目全称,
fs2_bld.BldName as 附属2_楼栋名称,
fs2_Room.Unit as 附属2_单元名称,
fs2_Room.FloorName as 附属2_楼层,
fs2_Room.Room as 附属2_房号,
buyer1.AlternativePhone as 备选电话,
buyer1.CstName as 买方1姓名,
buyer1.CardType as 买方1证件类型,
buyer1.CardID as 买方1证件号码,
cst1.Gender as 买方1性别,
buyer1.Tel as 买方1联系电话,
buyer1.Address as 买方1地址,
buyer1.HjAddress as 买方1户籍地址,
YEAR(cst1.BirthDate) as 买方1出生_年,
MONTH(cst1.BirthDate) as 买方1出生_月,
DAY(cst1.BirthDate) as 买方1出生_日,
buyer2.CstName as 买方2姓名,
buyer2.CardType as 买方2证件类型,
buyer2.CardID as 买方2证件号码,
cst2.Gender as 买方2性别,
buyer2.Tel as 买方2联系电话,
buyer2.Address as 买方2地址,
buyer2.HjAddress as 买方2户籍地址,
YEAR(cst2.BirthDate) as 买方2出生_年,
MONTH(cst2.BirthDate) as 买方2出生_月,
DAY(cst2.BirthDate) as 买方2出生_日,
sale.IdCode AS 二维码 ,
cast(sale.BldArea as decimal(18,4)) as 建筑面积,
cast(sale.TnArea as decimal(18,4)) as 套内面积,
cast(sale.BldArea-sale.TnArea  as decimal(18,4)) as 公摊面积,
sale.RoomBldPrice 表单价 ,
sale.Roomtotal 表价,
convert(nvarchar,cast(sale.CjTnPrice  as money),1) as 套内成交单价,
convert(nvarchar,cast(sale.CjBldPrice  as money),1)  as 建筑成交单价,
convert(nvarchar,cast(sale.DiscntValue  as money),1)  as 折扣,
convert(nvarchar,cast(sale.CjRmbTotal  as money),1)  as 成交总价,
proj.ProjectFullName as 项目全称,
bt.BldName as 楼栋名称,
room.Unit as 单元名称,
room.FloorName as 楼层,
room.Room as 房号,
room.RoomInfo as 房间全称,
sale.PayFormName as 付款方式,
convert(nvarchar,cast(sale.Earnest  as money),1) as 定金,
YEAR(sale.QSDate) as 签署日期_年,
MONTH(sale.QSDate) as 签署日期_月,
DAY(sale.QSDate) as 签署日期_日,
sale.CalMode as 计价方式,
sale.AjBank as 按揭银行,
sale.GjjBank as 公积金银行,
CONVERT(nvarchar, CAST
((SELECT  SUM(Amount) AS Expr1
FROM     dbo.s_Getin AS G
WHERE   (SaleGUID = sale.TradeGUID) AND (sale.Status = '激活') ) AS money), 1) AS 已交款金额,
convert(nvarchar,cast(sale.AjTotal  as money),1) as 按揭金额,
convert(nvarchar,cast(sale.GjjTotal  as money),1) as 公积金金额,
convert(nvarchar,cast(isnull(sale.CjRmbTotal,0)-isnull(sale.AjTotal,0)-isnull(sale.GjjTotal,0)  as money),1) as 首期或楼款含定,
convert(nvarchar,cast(isnull(sale.AjTotal,0)+isnull(sale.GjjTotal,0)  as money),1) as 贷款金额,
cast(((isnull(sale.AjTotal,0)+isnull(sale.GjjTotal,0))/isnull(sale.CjRmbTotal,0))*100 as decimal(18,0)) as 贷款比例,
cast(round((round((isnull(sale.CjRmbTotal,0)-isnull(sale.AjTotal,0)-isnull(sale.GjjTotal,0))/10000,2)/round((isnull(sale.CjRmbTotal,0)/10000),2))*100,0) as decimal(18,0)) as 首付比例,
sale.ContractGUID as oid,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 100000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_十万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 10000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 1000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_千 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 100) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_百 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 10) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_十 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.Earnest / 1) AS BIGINT) AS VARCHAR(30)),1))+1,1) 定金_元 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 10000000000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_百亿 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 1000000000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_十亿 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 100000000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_亿 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 10000000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_千万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 1000000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_百万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 100000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_十万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 10000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_万 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 1000) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_千 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 100) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_百 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 10) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_十 ,
SUBSTRING('零壹贰叁肆伍陆柒捌玖',CONVERT(INT,RIGHT(CAST(CAST(FLOOR(sale.CjRmbTotal / 1) AS BIGINT) AS VARCHAR(30)),1))+1,1) 成交价_元 
FROM    dbo.s_Contract sale
LEFT JOIN dbo.s_Buyer buyer1 ON sale.ContractGUID = buyer1.SaleGUID
								AND buyer1.CstNum = 1
LEFT JOIN dbo.s_Buyer buyer2 ON sale.ContractGUID = buyer2.SaleGUID
								AND buyer2.CstNum = 2
LEFT JOIN dbo.s_OCAttachRoom fs1 ON sale.ContractGUID = fs1.SaleGUID
								AND fs1.Sequence = 1
LEFT JOIN dbo.s_Room fs1_Room ON fs1.RoomGUID = fs1_Room.RoomGUID
LEFT JOIN dbo.s_Building fs1_bld ON fs1_bld.BldGUID = fs1_Room.BldGUID
LEFT JOIN dbo.s_OCAttachRoom fs2 ON sale.ContractGUID = fs2.SaleGUID
								AND fs2.Sequence = 2
LEFT JOIN dbo.s_Room fs2_Room ON fs2.RoomGUID = fs2_Room.RoomGUID
LEFT JOIN dbo.s_Building fs2_bld ON fs2_bld.BldGUID = fs2_Room.BldGUID
LEFT JOIN dbo.p_Customer cst1 ON buyer1.CstGUID = cst1.CstGUID
LEFT JOIN dbo.p_Customer cst2 ON buyer2.CstGUID = cst2.CstGUID
LEFT JOIN dbo.s_Room room ON sale.RoomGUID = room.RoomGUID
LEFT JOIN dbo.s_Trade t ON sale.TradeGUID = t.TradeGUID
LEFT JOIN dbo.s_Building bt ON bt.BldGUID = room.BldGUID
LEFT JOIN dbo.vp_interface_businessunit unit ON sale.BUGUID = unit.BUGUID
LEFT JOIN vp_interface_project proj ON sale.ProjGUID = proj.ProjectId
LEFT JOIN vp_interface_project fs1_proj ON fs1.ProjGUID = fs1_proj.ProjectId
LEFT JOIN vp_interface_project fs2_proj ON fs2.ProjGUID = fs2_proj.ProjectId
