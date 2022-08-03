SELECT  A.BUGUID,
A.PROJGUID,
--房源信息
p.PROJNAME AS 项目名称,
sb.BldName AS 楼栋,
a.Floorno 楼层,
a.unit 单元号,
a.Room 房号,
--case when pmpt.Name like '%商铺%' or pmpt.Name like '%车库%' then '' else
--convert(varchar(2),replace(sb.BldName,'#',''))+'-'+left(case when isnull(a.Unit,'')='' then '1' else a.unit end,1)
--+'-'+right('0'+convert(varchar(2),left(case when isnull(a.Unit,'')='' then '1' else a.unit end,1)),2)+
--right('0'+convert(varchar(2),a.FloorName),2)+RIGHT(a.room, 1) end AS 测绘房号,
--case when a.unit LIKE '%一%'then '1' when a.unit LIKE '%二%'then '2' when a.unit LIKE '%三%'then '3' when a.unit LIKE '%四%'then '4' else a.unit   end  as 单元号处理,
--sb.BldName +'-'+ case when a.unit LIKE '%一%'then '1' when a.unit LIKE '%二%'then '2' when a.unit LIKE '%三%'then '3' when a.unit LIKE '%四%'then '4' else a.unit   end +'-'+a.Room as 房号合并,
replace(a.roominfo,' ','') AS 房间全称, 
pmpt.Name AS 业态 ,
pmpt.ParentName AS 业态大类,
A.STATUS AS 交易状态,
CASE WHEN a.status = '认购' then  so.zygw
	WHEN a.Status = '签约' then  sc.zygw
	ELSE '' end   AS 置业顾问 ,
CONVERT(VARCHAR(10), so.QSDate, 121) AS 认购日期 ,

--客户信息
t.BuyerAllNames AS 客户姓名 ,
t.BuyerAllCardIds 身份证号码,
CASE WHEN a.status = '认购' then case when  ISNULL(sber1.Tel,'')='' THEN sber1.AlternativePhone
			  WHEN  ISNULL(sber1.AlternativePhone,'')='' THEN sber1.Tel
			  ELSE sber1.Tel + ';' + sber1.AlternativePhone end 
	  WHEN a.Status = '签约' then case when  ISNULL(sber2.Tel,'')='' THEN sber1.AlternativePhone
			  WHEN  ISNULL(sber2.AlternativePhone,'')='' THEN sber2.Tel
			  ELSE sber2.Tel + ';' + sber2.AlternativePhone end
	  ELSE '' end  	  AS 联系电话 , 
CASE WHEN a.status = '认购' then  sber1.Address
	   WHEN a.Status = '签约' then  sber2.Address
	   ELSE '' end  	  AS 联系地址 ,
ys.首付定金金额 AS 定金,
CONVERT(VARCHAR(10), sc.QSDate, 121) AS 签约日期 ,
CASE WHEN a.status = '认购' then  so.PayFormName
	   WHEN a.Status = '签约' then  sc.PayFormName
	   ELSE '' end  	  AS 付款方式 , 

cast(round(sc.DiscntValue,2) as decimal(18,2)) as 折扣,
cast(sc.CjRmbTotal*(100-sc.DiscntValue)/100 as decimal(18,2)) as 折扣金额,
CASE WHEN a.status = '认购' then  so.DiscntRemark
	   WHEN a.Status = '签约' then  sc.DiscntRemark
	   ELSE '' end  	  AS 折扣说明 ,
a.BldArea 建筑面积,
a.BldPrice 建筑单价,
a.Total 房间总价, 
so.CjRmbTotal 认购总价,
sc.CjBldPrice 签约单价,
sc.CjRmbTotal 签约总价,
sc.JFDate 应交房日期,
a.ScBldArea 实测建筑面积 ,
bck.RmbBcTotal 补差金额,

isnull(首付房款金额,0) as 首期款,
isnull(ssk.累计收款,0) 累计收款,
isnull(sc.CjRmbTotal,so.CjRmbTotal) - isnull(ssk.累计收款,0) as 累计未收,
isnull(ssk.开收据金额,0) 累开收据,
isnull(ssk.开发票金额,0) 累开发票,
isnull(ssk.开正式金额,0) 累开正式发票,
isnull(ssk.不含税金额,0) 不含税金额,
isnull(ssk.开票总金额,0) 开票小计,
isnull(ssk.未开票金额,0) 未开票,

a.TnArea 套内面积,
a.TnPrice 套内单价,
sc.CjTnPrice 套内成交单价,
sc.AjBank AS 按揭银行 , 
sc.AjTotal 按揭金额,
sc.AjYear 按揭年限,
SC.GjjBank as 公积金银行,
sc.gjjTotal 公积金金额,
sc.GjjYear 公积金年限,

a.HxName 户型,
a.RoomStru 房间结构,
pmpt.Name 产品类型,
sc.BaNo 备案号,
sc.AgreementNo 合同编号,
fs1_Room.RoomInfo 附属房间房号1,
fs1_Room.BldArea 附属房间面积1,
fs1.CjTotal 附属房间成交价1,

fs2_Room.RoomInfo 附属房间房号2,
fs2_Room.BldArea 附属房间面积2,
fs2.CjTotal 附属房间成交价2,

fs3_Room.RoomInfo 附属房间房号3,
fs3_Room.BldArea 附属房间面积3,
fs3.CjTotal 附属房间成交价3,


fs4_Room.RoomInfo 附属房间房号4,
fs4_Room.BldArea 附属房间面积4,
fs4.CjTotal 附属房间成交价4


----认购签约信息
--CONVERT(VARCHAR(10),sc.NetContractDate, 121) AS 网签日期,
-- ,
--ssp2.CompleteDate AS 按揭放款日期,
--ssp3.CompleteDate AS 公积金放款日期,
--isnull(按揭金额,0) as 按揭金额,
--case when pmpt.ParentName='住宅' then isnull(按揭金额,0)*0.05
--	when pmpt.ParentName='商业' then isnull(按揭金额,0)*0.1
--	else 0 end AS 保证金,
----回款信息
--(select amount from (select sum(amount) AS amount,RoomGUID from s_Getin where ItemName='定金' and ISNULL(Status,'') <> '作废'  group by RoomGUID) g
--where g.RoomGUID=a.roomguid
--) AS 实收定金,
--ISNULL(首付定金实收,0) AS 已收定金,
--ISNULL(首付房款实收,0) AS 已收首付款,
--isnull(首付实收,0) as 已收非贷款类房款,
--ISNULL(银行按揭实收,0) AS 已收商业贷款,
--ISNULL(公积金实收,0) AS 已收公积金贷款,
--isnull(按揭实收,0) as 已收贷款类房款,
--ISNULL(代收费用实收,0) as 已收代收款,
----未回款信息
--ISNULL(首付定金未收,0) AS 未收定金,
--ISNULL(首付房款未收,0) AS 未收首付款,
--isnull(首付未收,0) as 未收非贷款类房款,
--ISNULL(银行按揭未收,0) AS 未收商业贷款,
--ISNULL(公积金未收,0) AS 未收公积金贷款,
--isnull(按揭未收,0) as 未收贷款类房款,
--ISNULL(代收费用未收,0) as 未收代收款,
--sc.CjRoomTotal as 一房一价,
--sc.AgreementNo 合同编号, 
--a.YsBldArea 预售建筑面积,
--a.YsTnArea 预售套内面积, 
--a.ScTnArea  实测套内面积,
--a.AreaStatus 面积状态,
--a.DjTotal 房间底价,
--sog.Fax as 渠道人员姓名,
--so.YqyDate 预签约日期,
--sc.BaDate 备案日期, 
--CONVERT(VARCHAR(10), GetDate, 121) AS 最后回款时间 ,
--isnull(so.remark,'') + isnull(sc.Remark,'')  备注,
--CASE WHEN a.status = '认购' then  so.Earnest
--WHEN a.Status = '签约' then  sc.Earnest
--ELSE '' end   AS 应收定金 ,
---- CASE WHEN a.status = '认购' then  spt1.Name 
----WHEN a.Status = '签约' then  spt2.Name
----   ELSE '' end   AS 置业顾问团队 ,

--(case when sc.PayFormName like '%公积金%'  then ssp3.CompleteDate else ssp2.CompleteDate end)  as 放款日期,
--sg.MainMediaName 媒体大类
FROM s_room a 
INNER JOIN s_Building sb WITH ( NOLOCK ) ON a.BldGUID = sb.BldGUID
INNER JOIN p_MasterDataProductType pmpt WITH ( NOLOCK ) ON pmpt.p_MasterDataProductTypeId = sb.ProductTypeGUID
INNER JOIN P_PROJECT p ON A.PROJGUID = p.p_projectId
INNER JOIN s_Trade T on A.RoomGUID = t.RoomGUID and TradeStatus = '激活'
LEFT JOIN s_Order so ON t.RGOrderGUID = so.OrderGUID
LEFT JOIN s_Buyer AS sber1 ON sber1.SaleGUID = so.OrderGUID
							   AND sber1.CstNum = 1
LEFT JOIN s_Contract sc ON t.ContractGUID = sc.ContractGUID
LEFT JOIN s_BcWork bck ON sc.ContractGUID=bck.ContractId
LEFT JOIN s_SaleService SS2 on ss2.SaleGUID = sc.ContractGUID and ss2.ServiceItem = '按揭服务'
LEFT JOIN s_SaleServiceProc sSP2 ON ss2.s_SaleServiceGUID = sSP2.SaleServiceGUID and sSP2.ServiceProc like '%已放款%'
LEFT JOIN s_SaleService SS3 on ss3.SaleGUID = sc.ContractGUID and ss3.ServiceItem = '公积金服务'
LEFT JOIN s_SaleServiceProc sSP3 ON SS3.s_SaleServiceGUID = sSP3.SaleServiceGUID and  sSP3.ServiceProc like  '%已放款%'
LEFT JOIN s_Buyer AS sber2 ON sber2.SaleGUID = sc.ContractGUID
							   AND sber2.CstNum = 1


LEFT JOIN dbo.s_OCAttachRoom fs1 ON (case when a.status = '签约' then sc.ContractGUID  when 
a.status = '认购' then so.OrderGUID end  = fs1.SaleGUID 
								) AND fs1.Sequence = 1
LEFT JOIN dbo.s_Room fs1_Room ON fs1.RoomGUID = fs1_Room.RoomGUID
LEFT JOIN dbo.s_Building fs1_bld ON fs1_bld.BldGUID = fs1_Room.BldGUID

LEFT JOIN dbo.s_OCAttachRoom fs2 ON (case when a.status = '签约' then sc.ContractGUID  when 
a.status = '认购' then so.OrderGUID end  = fs2.SaleGUID 
								) AND fs2.Sequence = 2
LEFT JOIN dbo.s_Room fs2_Room ON fs2.RoomGUID = fs2_Room.RoomGUID
LEFT JOIN dbo.s_Building fs2_bld ON fs2_bld.BldGUID = fs2_Room.BldGUID

	 LEFT JOIN dbo.s_OCAttachRoom fs3 ON (case when a.status = '签约' then sc.ContractGUID  when 
a.status = '认购' then so.OrderGUID end  = fs3.SaleGUID 
								) AND fs3.Sequence = 3
LEFT JOIN dbo.s_Room fs3_Room ON fs3.RoomGUID = fs3_Room.RoomGUID
LEFT JOIN dbo.s_Building fs3_bld ON fs3_bld.BldGUID = fs3_Room.BldGUID

   LEFT JOIN dbo.s_OCAttachRoom fs4 ON  (case when a.status = '签约' then sc.ContractGUID  when 
a.status = '认购' then so.OrderGUID end  = fs4.SaleGUID 
								) AND fs4.Sequence = 4
LEFT JOIN dbo.s_Room fs4_Room ON fs4.RoomGUID = fs4_Room.RoomGUID
LEFT JOIN dbo.s_Building fs4_bld ON fs4_bld.BldGUID = fs4_Room.BldGUID


   LEFT JOIN dbo.s_OCAttachRoom fs5 ON (case when a.status = '签约' then sc.ContractGUID  when 
a.status = '认购' then so.OrderGUID end  = fs5.SaleGUID 
								) AND fs5.Sequence = 5
LEFT JOIN dbo.s_Room fs5_Room ON fs5.RoomGUID = fs5_Room.RoomGUID
LEFT JOIN dbo.s_Building fs5_bld ON fs5_bld.BldGUID = fs5_Room.BldGUID

--      LEFT JOIN s_ProjectTeamUserRelation SP2 ON sc.ZygwAllGUID = SP2.UserGUID
--   LEFT JOIN s_ProjectTeamUserRelation SP1 ON so.ZygwAllGUID = SP1.UserGUID
--LEFT JOIN s_ProjectTeam spt1 ON SP1.ProjTeamGUID = spt1.ProjTeamGUID
--LEFT JOIN s_ProjectTeam spt2 ON SP2.ProjTeamGUID = spt2.ProjTeamGUID
LEFT JOIN (SELECT SaleGUID , max(GetDate) as GetDate
FROM s_Getin where ItemType in ('贷款类房款','非贷款类房款') and ISNULL(Status,'') <> '作废'
group by SaleGUID) bc ON t.TradeGUID = bc.SaleGUID
LEFT JOIN 
(  select f.TradeGUID, 
sum(case when ItemType = '非贷款类房款' then RmbAmount else 0 end ) 首付金额 ,
sum(case when ItemType = '非贷款类房款' then RmbAmount - RmbYe + RmbDsAmount else 0 end) 首付实收 ,
sum(case when ItemType = '非贷款类房款' then RmbYe  else 0 end) 首付未收 ,

sum(case when ItemType = '非贷款类房款' and ItemName = '定金'  then RmbAmount else 0 end ) 首付定金金额 ,
sum(case when ItemType = '非贷款类房款' and ItemName = '定金' then RmbAmount - RmbYe + RmbDsAmount else 0 end) 首付定金实收,
sum(case when ItemType = '非贷款类房款' and ItemName = '定金' then RmbYe else 0 end) 首付定金未收,

sum(case when ItemType = '非贷款类房款' and ItemName <> '定金'  then RmbAmount else 0 end ) 首付房款金额 ,
sum(case when ItemType = '非贷款类房款' and ItemName <> '定金' then RmbAmount - RmbYe + RmbDsAmount else 0 end) 首付房款实收,
sum(case when ItemType = '非贷款类房款' and ItemName <> '定金' then  RmbYe  else 0 end) 首付房款未收,

sum(case when ItemType = '贷款类房款' then RmbAmount else 0 end) 按揭金额 ,
sum(case when ItemType = '贷款类房款' then RmbAmount - RmbYe +RmbDsAmount else 0 end) 按揭实收 ,
sum(case when ItemType = '贷款类房款' then  RmbYe else 0 end) 按揭未收 ,

sum(case when ItemType = '贷款类房款' and ItemName='银行按揭' then RmbAmount else 0 end) 银行按揭应收 ,
sum(case when ItemType = '贷款类房款' and ItemName='银行按揭' then RmbAmount - RmbYe +RmbDsAmount else 0 end) 银行按揭实收 ,
sum(case when ItemType = '贷款类房款' and ItemName='银行按揭' then RmbYe else 0 end) 银行按揭未收 ,

sum(case when ItemType = '贷款类房款' and ItemName='公积金' then RmbAmount else 0 end) 公积金应收 ,
sum(case when ItemType = '贷款类房款' and ItemName='公积金' then RmbAmount - RmbYe +RmbDsAmount else 0 end) 公积金实收,
sum(case when ItemType = '贷款类房款' and ItemName='公积金' then  RmbYe else 0 end) 公积金未收,

sum(case when ItemType = '代收费用' then RmbAmount else 0 end ) 代收费用应收 ,
sum(case when ItemType = '代收费用' then RmbAmount - RmbYe +RmbDsAmount else 0 end ) 代收费用实收, 
sum(case when ItemType = '代收费用' then RmbYe else 0 end ) 代收费用未收
 
from s_Fee f
group by f.TradeGUID
		)ys ON ys.TradeGUID=t.TradeGUID
left join (select 
v.SaleGUID,
sum(g.Amount) as 累计收款,
sum(case when v.Invotype='收据' then g.Amount else 0 end) as 开收据金额,
sum(case when v.Invotype='发票' then g.Amount else 0 end) as 开发票金额,
sum(case when v.Invotype like '增值税' then g.Amount else 0 end) as 开正式金额,
sum(case when v.Invotype <>'无票据' then g.Amount else 0 end) as 开票总金额,
sum(case when v.Invotype ='无票据' then g.Amount else 0 end) as 未开票金额,
sum(g.RmbAmount-g.TaxAmount ) as 不含税金额
 from s_Voucher v
inner join s_Getin g on v.VouchGUID=g.VouchGUID
where isnull(v.VouchStatus,'')<>'作废' and (g.ItemType='非贷款类房款' OR g.ItemType='贷款类房款')
group by v.SaleGUID) ssk on ssk.SaleGUID=t.TradeGUID

left join s_Opp2Sale ss ON so.OrderGUID = ss.SaleGUID 
left join  s_Opportunity  sg ON sg.OppGUID = ss.OppGUID
left join  s_OppCustomer  sog ON sg.OppCstGUID = sog.OppCstGUID  
WHERE A.PROJGUID in (@Projguid) and 
a.Status in ('认购','签约')
and CONVERT(VARCHAR(10), so.QSDate, 121) between CONVERT(VARCHAR(10),@BeginDate, 121)  and CONVERT(VARCHAR(10),@EndDate, 121)

ORDER BY 交易状态,项目名称,楼栋,楼层,房号






