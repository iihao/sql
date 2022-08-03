SELECT  ( vouchguid ) AS 票据GUID ,
( SELECT    b1.projname
  FROM      p_Project b
  LEFT JOIN p_Project b1 on b.ParentGUID=b1.p_projectId
  WHERE     a.ProjGUID = b.p_projectId
) AS 项目名称 ,
	   ( SELECT    b.projname
  FROM      p_Project b
  LEFT JOIN p_Project b1 on b.ParentGUID=b1.p_projectId
  WHERE     a.ProjGUID = b.p_projectId
) AS 分期名称 ,
invono AS '发票号' ,
RzBank as 入账银行,
remark AS '备注' ,
( SELECT TOP 1
			RoomInfo
  FROM      s_room b2
  WHERE     b2.RoomGuid = a.RoomGuid
) AS 分期_房间编码 ,
( SELECT TOP 1
			ShortRoomInfo
  FROM      s_room b2
  WHERE     b2.RoomGuid = a.RoomGuid
) AS 房间编码 ,
( jkr ) AS 交款人 ,
kpr AS 收款人 ,
(select top 1 CardID from p_Customer where CstName=jkr) AS 身份证号,
CONVERT(varchar(100), kpdate, 23) AS 开票日期 ,
 CONVERT(VARCHAR(20),CAST(RmbAmount AS money),1) AS 总金额小写 ,
dbo.fn_ChnMoney_New(CAST(RmbAmount AS NUMERIC(20, 2))) AS 总金额大写 ,
STUFF(( SELECT  DISTINCT
				',' + g.ItemName
		FROM    dbo.s_Getin g WITH ( NOLOCK )
		WHERE   g.VouchGUID = a.VouchGUID
				AND g.IsSysCx = 0/*非系统冲销的*/
	  FOR
		XML PATH('')
	  ), 1, 1, '') AS 款项名称,
	STUFF(( SELECT  DISTINCT
				',' + g.GetForm
		FROM    dbo.s_Getin g WITH ( NOLOCK )
		WHERE   g.VouchGUID = a.VouchGUID
				AND g.IsSysCx = 0/*非系统冲销的*/
	  FOR
		XML PATH('')
	  ), 1, 1, '') AS 付款方式,
dbo.cqfn_VauchPrint_tom_1(vouchguid, a.VouchType) AS 款项名称_金额说明 ,
dbo.cqfn_VauchPrint_tom_2(vouchguid, a.VouchType) AS 交款方式_金额说明 ,
dbo.cqfn_VauchPrint_tom_3(vouchguid) AS 款项类别_说明
FROM    s_voucher a
INNER JOIN dbo.fn_Split(@oid, ',') voucherIdList ON voucherIdList.Value = a.VouchGUID



战略

天际 

建模平台
集成开放平台 提升国企 打通各种系统，构建数据资产，生态链！
数据分析平台





