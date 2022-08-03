SELECT *                   /*回溯*/
 
FROM
(
	SELECT
		/*主外键*/
		s_Contract.WideGUID AS WideGUID,                                                           --业务GUID
		s_Contract.ContractGUID,
		sm.ReasonType AS CCloseReasonType,                                                         --签约关闭原因分类
																								   /*签约信息*/
		s_Contract.QSDate AS CQSDate,                                                              --签约日期（草签）
		s_Contract.NetContractDate AS CNetQSDate,                                                  --网签日期
		s_Contract.YwgsDate AS CYjgsDate,                                                          --签约业绩归属日期
		s_Contract.BaNo AS CBaNo,                                                                  --签约业绩归属日期
		s_Contract.BaDate AS CBaDate,                                                              --签约业绩归属日期
		s_Contract.JbrName AS CJbrName,                                                            --签约经办人
		s_Contract.ContractType AS ContractType,                                                   --合同类别
		s_Contract.CloseDate AS CCloseDate,                                                        --签约关闭日期
		s_Contract.CloseReason AS CCloseReason,                                                    --签约关闭原因
		CASE
			WHEN s_Contract.CloseDate IS NOT NULL THEN
				s_Contract.ModifiedName
			ELSE
				''
		END AS CCloser,                                                                            --关闭人
		s_Contract.Status AS CStatus,                                                              --签约状态
		s_Contract.DjTotal AS CDjTotal ,														   --签约底价总价
		s_Contract.Zygw AS CZygw,                                                                  --签约置业顾问
		s_Contract.ZygwAllGUID AS CZygwAllGUID,                                                    --签约置业顾问GUID
		CASE WHEN EXISTS(SELECT 1 FROM s_ProjectTeam team WHERE team.ProjGUID = dbo.s_Contract.ProjGUID   ) 
					THEN 
					STUFF((
									SELECT
											DISTINCT '、'+team.Name
											FROM s_OC2Sale             oc2sale1

											JOIN s_ProjectTeamUser teamUser ON  teamUser.UserGUID = oc2sale1.UserGUID 
															   JOIN s_ProjectTeam team
																   ON team.ProjTeamGUID = teamUser.ProjTeamGUID
											WHERE oc2sale1.SaleTypeEnum = 2
												  AND oc2sale1.SaleGUID =s_Contract.ContractGUID
												  AND team.ProjGUID = oc2sale1.ProjGUID
												FOR XML PATH('')
												)
											,1,1,'')
					ELSE 
					STUFF((
											SELECT
											DISTINCT '、'+team.Name
											FROM s_OC2Sale             oc2sale1

											JOIN s_ProjectTeamUser teamUser ON  teamUser.UserGUID = oc2sale1.UserGUID 
											JOIN dbo.vp_interface_project project ON project.ProjGUID = oc2sale1.ProjGUID
											JOIN s_ProjectTeam team ON team.ProjTeamGUID = teamUser.ProjTeamGUID 
											WHERE oc2sale1.SaleTypeEnum = 2
												  AND oc2sale1.SaleGUID =dbo.s_Contract.ContractGUID
												  AND project.ParentGuid = team.ProjGUID
												FOR XML PATH('')
												)
											,1,1,'')

					END  AS CProjectTeam,                                                                       --签约销售团队
		STUFF(
		(
			SELECT ';' + CONVERT(NVARCHAR(100), CONVERT(DECIMAL(8, 2), oc2sale.FTRate))
			FROM s_OC2Sale oc2sale
			WHERE oc2sale.SaleTypeEnum = 2
				  AND oc2sale.SaleGUID = s_Contract.ContractGUID
			ORDER BY oc2sale.SaleNo
			FOR XML PATH('')
		),
		1,
		1,
		''
			 ) AS CZygwRate,                                                                       --签约置业顾问比例
		s_Contract.BldArea AS CCjBldArea,                                                          --签约成交建筑面积
		s_Contract.TnArea AS CCjTnArea,                                                            --签约成交套内面积
		s_Contract.AreaStatus AS CCjAreaStatus,                                                    --签约成交面积状态
		s_Contract.RoomBzBldPrice AS CRoomBldPrice,                                                --签约房间标准建筑单价
		s_Contract.RoomBzTnPrice AS CRoomTnPrice,                                                  --签约房间标准套内单价
		s_Contract.RoomBzTotal AS CRoomTotal,                                                      --签约房间标准总价
		s_Contract.CjBldPrice AS CCjRoomBldPrice,                                                  --签约成交房间建筑单价
		s_Contract.CjTnPrice AS CCjRoomTnPrice,                                                    --签约成交房间套内单价
		s_Contract.CjRoomTotal AS CCjRoomTotal,                                                    --签约成交房间总价
		s_OCAttachRoom.CAttachRoomInfo,                                                            --签约附属房间信息
		ISNULL(s_OCAttachRoom.Count, 0) AS CCjFsCount,                                             --签约附属套数
		ISNULL(s_OCAttachRoom.SumBldArea, 0) AS CCjFsBldArea,                                      --签约附属建筑面积合计
		ISNULL(s_OCAttachRoom.SumTnArea, 0) AS CCjFsTnArea,                                        --签约附属套内面积合计
		s_Contract.FsTotal AS CCjFsTotal,                                                          --签约附属总价合计
		s_Contract.ZxTotal AS CCjZxTotal,                                                          --签约装修总价
		s_Contract.IsZxkbrht AS CIsZxkbrht,                                                        --签约装修款并入合同
		s_Contract.CjRmbTotal AS CCjTotal,                                                         --签约成交总价(含补充协议)
		ISNULL(s_Contract.TaxAmount, 0) AS CTaxAmount,                                             --签约税额
		ISNULL(s_Contract.Rate, 0) AS CTaxRate,                                                    --签约税率
		s_Contract.DiscntValue AS CDiscount,                                                       --签约折扣
		s_Contract.PayFormName AS CPayForm,                                                        --签约付款方式
		s_Contract.FaceDiscntRemark as CFaceDiscountRemark,
		  s_Contract.BcxyDiscntRemark as CBcxyDiscountRemark,
		  case
			  when [s_Contract].BcxyDiscntRemark = '' then [s_Contract].FaceDiscntRemark
			  else '面价折扣说明：' + [s_Contract].FaceDiscntRemark + ';' + '补充协议折扣说明：' +
				   [s_Contract].BcxyDiscntRemark end                                                              AS CDiscountRemark,  --认购折扣说明
		s_Contract.AjBank AS CAjBank,                                                              --签约-按揭银行
		s_Contract.AjYear AS CAjYear,                                                              --签约-按揭年限
		s_Contract.AjTotal AS CAjTotal,                                                            --签约-按揭金额
		s_Contract.GjjBank AS CGjjBank,                                                            --签约-公积金银行
		s_Contract.GjjYear AS CGjjYear,                                                            --签约-公积金年限
		s_Contract.GjjTotal AS CGjjTotal,                                                          --签约-公积金金额
		ISNULL(s_Bcxy.CjTotal, 0) AS CBcxyTotal,                                                   --签约-补充协议总价
		ISNULL(s_Bcxy.Rate, 0) AS CBcxyTaxRate,                                                    --合同补充协议税率
		s_Contract.JFDate AS YjfDate,                                                              --应交房日期
		s_Contract.AuditStatus AS CAuditStatus,                                                    --签约审核状态
		s_Contract.AgreementNo AS CAgreementNo                                                     --签约合同编号
	FROM s_Contract
		LEFT JOIN s_Bcxy
			ON s_Bcxy.SaleGUID = s_Contract.ContractGUID /*附属房间信息*/
		LEFT JOIN
		 (
			 SELECT  SUM(A.TnArea) SumTnArea ,
										SUM(A.BldArea) SumBldArea ,
										COUNT(1) Count ,
										STUFF((SELECT ';'+ShortRoomInfo FROM dbo.s_OCAttachRoom  
											  INNER JOIN s_room ON  s_OCAttachRoom.roomGuid = s_room.RoomGUID 
											  WHERE A.SaleGUID = s_OCAttachRoom.SaleGUID 
											  FOR XML PATH('')),1,1,'') CAttachRoomInfo,
										SaleGUID
								FROM    s_OCAttachRoom A
			 GROUP BY SaleGUID
		 ) s_OCAttachRoom
			ON s_OCAttachRoom.SaleGUID = s_Contract.ContractGUID /*关闭原因*/
		LEFT JOIN
		 (
			 SELECT ROW_NUMBER() OVER (PARTITION BY SaleGUID ORDER BY ExecDate DESC) RowNum,
					ReasonType,
					CONVERT(NVARCHAR(50),apply.ExecDate,23) NewQsDate,
					apply.SaleGUID
			 FROM
				 (
					 SELECT SaleGUID,
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
					 WHERE c.StatusEnum = 0 /*关闭*/
						   AND c.CloseReasonEnum = 8 /*撤销签约*/
				 ) apply
				 INNER JOIN s_Contract
					 ON s_Contract.ContractGUID = apply.NewSaleGUID
		 ) sm
			ON sm.SaleGUID = s_Contract.ContractGUID
			   AND sm.RowNum = 1
		--产生新单
		LEFT JOIN
		 (
			 SELECT ROW_NUMBER() OVER (PARTITION BY NewSaleGUID ORDER BY ExecDate DESC) RowNum,
					apply.NewSaleGUID
			 FROM
				 (
					 SELECT NewSaleGUID AS NewSaleGUID,
							ExecDate
					 FROM s_SaleModiApply
					 WHERE ExecDate IS NOT NULL
						   AND ApplyTypeEnum IN ( 1, /*价格变更*/ 4 /*换房*/ )
				 ) apply
				 INNER JOIN s_Contract
					 ON s_Contract.ContractGUID = apply.NewSaleGUID
		 ) smNew
			ON smNew.NewSaleGUID = s_Contract.ContractGUID
			   AND smNew.RowNum = 1
) t