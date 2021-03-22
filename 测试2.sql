SELECT * /*回溯*/
  FROM (   SELECT
			   /*主外键*/
						s_Contract.WideGUID AS WideGUID, --业务GUID
						s_Contract.ContractGUID,
						sm.ReasonType AS CCloseReasonType, --签约关闭原因分类
						/*签约信息*/
						s_Contract.QSDate AS CQSDate, --签约日期（草签）
						s_Contract.NetContractDate AS CNetQSDate, --网签日期
						s_Contract.YwgsDate AS CYjgsDate, --签约业绩归属日期
						s_Contract.BaNo AS CBaNo, --签约业绩归属日期
						s_Contract.BaDate AS CBaDate, --签约业绩归属日期
						s_Contract.JbrName AS CJbrName, --签约经办人
						s_Contract.ContractType AS ContractType, --合同类别
						s_Contract.CloseDate AS CCloseDate, --签约关闭日期
						s_Contract.CloseReason AS CCloseReason, --签约关闭原因
						CASE
							 WHEN s_Contract.CloseDate IS NOT NULL THEN s_Contract.ModifiedName
							 ELSE '' END AS CCloser, --关闭人
						s_Contract.Status AS CStatus, --签约状态
						s_Contract.DjTotal AS CDjTotal, --签约底价总价
						s_Contract.BldArea AS CCjBldArea, --签约成交建筑面积
						s_Contract.TnArea AS CCjTnArea, --签约成交套内面积
						s_Contract.AreaStatus AS CCjAreaStatus, --签约成交面积状态
						s_Contract.RoomBzBldPrice AS CRoomBldPrice, --签约房间标准建筑单价
						s_Contract.RoomBzTnPrice AS CRoomTnPrice, --签约房间标准套内单价
						s_Contract.RoomBzTotal AS CRoomTotal, --签约房间标准总价
						s_Contract.CjBldPrice AS CCjRoomBldPrice, --签约成交房间建筑单价
						s_Contract.CjTnPrice AS CCjRoomTnPrice, --签约成交房间套内单价
						s_Contract.CjRoomTotal AS CCjRoomTotal, --签约成交房间总价
						s_Contract.FsTotal AS CCjFsTotal, --签约附属总价合计
						s_Contract.ZxTotal AS CCjZxTotal, --签约装修总价
						s_Contract.IsZxkbrht AS CIsZxkbrht, --签约装修款并入合同
						s_Contract.CjRmbTotal AS CCjTotal, --签约成交总价(含补充协议)
						ISNULL(s_Contract.TaxAmount, 0) AS CTaxAmount, --签约税额
						ISNULL(s_Contract.Rate, 0) AS CTaxRate, --签约税率
						s_Contract.DiscntValue AS CDiscount, --签约折扣
						s_Contract.PayFormName AS CPayForm, --签约付款方式
						s_Contract.FaceDiscntRemark AS CFaceDiscountRemark,
						s_Contract.BcxyDiscntRemark AS CBcxyDiscountRemark,
						CASE
							 WHEN [s_Contract].BcxyDiscntRemark = '' THEN [s_Contract].FaceDiscntRemark
							 ELSE '面价折扣说明：' + [s_Contract].FaceDiscntRemark + ';' + '补充协议折扣说明：' + [s_Contract].BcxyDiscntRemark END AS CDiscountRemark, --认购折扣说明
						s_Contract.AjBank AS CAjBank, --签约-按揭银行
						s_Contract.AjYear AS CAjYear, --签约-按揭年限
						s_Contract.AjTotal AS CAjTotal, --签约-按揭金额
						s_Contract.GjjBank AS CGjjBank, --签约-公积金银行
						s_Contract.GjjYear AS CGjjYear, --签约-公积金年限
						s_Contract.GjjTotal AS CGjjTotal, --签约-公积金金额
						ISNULL(s_Bcxy.CjTotal, 0) AS CBcxyTotal, --签约-补充协议总价
						ISNULL(s_Bcxy.Rate, 0) AS CBcxyTaxRate, --合同补充协议税率
						s_Contract.JFDate AS YjfDate, --应交房日期
						s_Contract.AuditStatus AS CAuditStatus, --签约审核状态
						s_Contract.AgreementNo AS CAgreementNo --签约合同编号
			 FROM       s_Contract
			 LEFT JOIN  s_Bcxy
			   ON s_Bcxy.SaleGUID = s_Contract.ContractGUID
			OUTER APPLY (   SELECT TOP 1 apply.ReasonType
							  FROM (   SELECT SaleGUID,
											  SaleGUID AS NewSaleGUID,
											  ExecDate,
											  ReasonType
										 FROM s_SaleModiApply
										WHERE ExecDate IS NOT NULL
										  AND ApplyTypeEnum IN ( 1, /*价格变更*/ 3, /*退房*/ 4 /*换房*/ )
									   UNION
									   /*撤销签约*/
									   SELECT c.ContractGUID,
											  c.ContractGUID AS NewSaleGUID,
											  c.CloseDate,
											  c.CloseReason
										 FROM s_Contract AS c
										WHERE c.StatusEnum      = 0 /*关闭*/
										  AND c.CloseReasonEnum = 8 /*撤销签约*/
							  ) apply
							 WHERE apply.SaleGUID = s_Contract.ContractGUID
							 ORDER BY apply.ExecDate DESC) sm ) t