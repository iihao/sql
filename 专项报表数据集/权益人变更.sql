USE [dotnet_erp60]
GO

/****** Object:  View [dbo].[vs_rpt_changename]    Script Date: 2021/11/5 17:33:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vs_rpt_changename]  
AS  
  SELECT  s_SaleModiApply.SaleGUID ,  
	s_SaleModiApply.SaleModiApplyGUID,
		s_SaleModiApply.ExecDate ,  
		s_SaleModiApply.ExecGUID ,  
		s_SaleModiApply.ExecName ,  
		s_SaleModiApply.Reason ,  
		s_SaleModiApply.ReasonType,
		s_SaleModiApply.ApplyName,
		s_SaleModiApply.ApplyDate,
		s_SaleModiApply.Buyer CstNames, 
		s_SaleModiApply.AuditDate AS MAuditDate,
		s_SaleModiApply.AuditName AS MAuditName,
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BldArea  
			 ELSE s_Contract.BldArea  
		END AS BldArea ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.TnArea  
			 ELSE s_Contract.TnArea  
		END AS TnArea ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.TradeGUID  
			 ELSE s_Contract.TradeGUID  
		END AS TradeGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CjBldPrice  
			 ELSE s_Contract.CjBldPrice  
		END AS CjBldPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.RoomGuid  
			 ELSE s_Contract.RoomGuid  
		END AS RoomGuid ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.IsST  
			 ELSE s_Contract.IsST  
		END AS IsST ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.ProjGUID  
			 ELSE s_Contract.ProjGUID  
		END AS ProjGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CreatedTime  
			 ELSE s_Contract.CreatedTime  
		END AS CreatedTime ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CreatedGUID  
			 ELSE s_Contract.CreatedGUID  
		END AS CreatedGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.ModifiedTime  
			 ELSE s_Contract.ModifiedTime  
		END AS ModifiedTime ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.ModifiedGUID  
			 ELSE s_Contract.ModifiedGUID  
		END AS ModifiedGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CjTnPrice  
			 ELSE s_Contract.CjTnPrice  
		END AS CjTnPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CalModeEnum  
			 ELSE s_Contract.CalModeEnum  
		END AS CalModeEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AjBank  
			 ELSE s_Contract.AjBank  
		END AS AjBank ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.GjjBank  
			 ELSE s_Contract.GjjBank  
		END AS GjjBank ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.DjTotal  
			 ELSE s_Contract.DjTotal  
		END AS DjTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.DiscntValue  
			 ELSE s_Contract.DiscntValue  
		END AS DiscntValue ,  
		--当前是签约状态，则为转签约前认购的签署日期  
		CASE WHEN LastOrder.QSDate IS NULL THEN   
	(CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.QSDate  
	 ELSE NULL  
	END)   
   ELSE LastOrder.QSDate   
		END AS OrderQSDate ,  
		s_Contract.QSDate AS ContractQSDate ,  
		s_Contract.NetContractDate AS NetContractDate ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.QSDate  
			 ELSE s_Contract.QSDate  
		END AS QSDate ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CjRoomTotal  
			 ELSE s_Contract.CjRoomTotal  
		END AS CjRoomTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.ZxTotal  
			 ELSE s_Contract.ZxTotal  
		END AS ZxTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CjRmbTotal  
			 ELSE s_Contract.CjRmbTotal  
		END AS CjRmbTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.RoomBldPrice  
			 ELSE s_Contract.RoomBldPrice  
		END AS RoomBldPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.FsTotal  
			 ELSE s_Contract.FsTotal  
		END AS FsTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.IsZxkbrht  
			 ELSE s_Contract.IsZxkbrht  
		END AS IsZxkbrht ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.DjTnPrice  
			 ELSE s_Contract.DjTnPrice  
	 END AS DjTnPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.Remark  
			 ELSE s_Contract.Remark  
		END AS Remark ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.GjjTotal  
			 ELSE s_Contract.GjjTotal  
		END AS GjjTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AgreementNo  
			 ELSE s_Contract.AgreementNo  
		END AS AgreementNo ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.RoomTnPrice  
			 ELSE s_Contract.RoomTnPrice  
		END AS RoomTnPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.RoomTotal  
			 ELSE s_Contract.RoomTotal  
		END AS RoomTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.DjBldPrice  
			 ELSE s_Contract.DjBldPrice  
		END AS DjBldPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AjTotal  
			 ELSE s_Contract.AjTotal  
		END AS AjTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.StatusEnum  
			 ELSE s_Contract.StatusEnum  
		END AS StatusEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AuditDate  
			 ELSE s_Contract.AuditDate  
		END AS AuditDate ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CloseDate  
			 ELSE s_Contract.CloseDate  
		END AS CloseDate ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AuditGUID  
			 ELSE s_Contract.AuditGUID  
		END AS AuditGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AuditStatusEnum  
			 ELSE s_Contract.AuditStatusEnum  
		END AS AuditStatusEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.LastSaleGUID  
			 ELSE s_Contract.LastSaleGUID  
		END AS LastSaleGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.LastSaleType  
			 ELSE s_Contract.LastSaleType  
		END AS LastSaleType ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.Earnest  
			 ELSE s_Contract.Earnest  
		END AS Earnest ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.PayFormGUID  
			 ELSE s_Contract.PayFormGUID  
		END AS PayFormGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.YwgsDate  
			 ELSE s_Contract.YwgsDate  
		END AS YwgsDate ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.IsLockFee  
			 ELSE s_Contract.IsLockFee  
		END AS IsLockFee ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaseRoomTotal  
			 ELSE s_Contract.BaseRoomTotal  
		END AS BaseRoomTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BcBaseTotal  
			 ELSE s_Contract.BcBaseTotal  
		END AS BcBaseTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaseCjTotal  
			 ELSE s_Contract.BaseCjTotal  
		END AS BaseCjTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.DiscntRemark  
			 ELSE s_Contract.DiscntRemark  
		END AS DiscntRemark ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.IsLockDisount  
			 ELSE s_Contract.IsLockDisount  
		END AS IsLockDisount ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.Addition  
			 ELSE s_Contract.Addition  
		END AS Addition ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.JbrGUID  
			 ELSE s_Contract.JbrGUID  
		END AS JbrGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.Zygw  
			 ELSE s_Contract.Zygw  
		END AS Zygw ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.OrderBarcode  
			 ELSE s_Contract.ContractBarcode  
		END AS Barcode ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CloseReason  
			 ELSE s_Contract.CloseReason  
		END AS CloseReason ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AjYear  
			 ELSE s_Contract.AjYear  
		END AS AjYear ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.GjjYear  
			 ELSE s_Contract.GjjYear  
		END AS GjjYear ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaseCjBldPrice  
			 ELSE s_Contract.BaseCjBldPrice  
		END AS BaseCjBldPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaseCjTnPrice  
			 ELSE s_Contract.BaseCjTnPrice  
		END AS BaseCjTnPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BUGUID  
			 ELSE s_Contract.BUGUID  
		END AS BUGUID ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.LastSaleTypeEnum  
			 ELSE s_Contract.LastSaleTypeEnum  
		END AS LastSaleTypeEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CalMode  
			 ELSE s_Contract.CalMode  
		END AS CalMode ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.Status  
			 ELSE s_Contract.Status  
		END AS Status ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.PayFormName  
			 ELSE s_Contract.PayFormName  
		END AS PayFormName ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AreaStatusEnum  
			 ELSE s_Contract.AreaStatusEnum  
		END AS AreaStatusEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.JbrName  
			 ELSE s_Contract.JbrName  
		END AS JbrName ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CreatedName  
			 ELSE s_Contract.CreatedName  
		END AS CreatedName ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.ModifiedName  
			 ELSE s_Contract.ModifiedName  
		END AS ModifiedName ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AuditStatus  
			 ELSE s_Contract.AuditStatus  
		END AS AuditStatus ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AreaStatus  
			 ELSE s_Contract.AreaStatus  
		END AS AreaStatus ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.AuditName  
			 ELSE s_Contract.AuditName  
		END AS AuditName ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.CloseReasonEnum  
			 ELSE s_Contract.CloseReasonEnum  
		END AS CloseReasonEnum ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.IdCode  
			 ELSE s_Contract.IdCode  
		END AS IdCode ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaTotal  
			 ELSE s_Contract.BaTotal  
		END AS BaTotal ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaBldPrice  
			 ELSE s_Contract.BaBldPrice  
		END AS BaBldPrice ,  
		CASE WHEN s_Order.OrderGUID IS NOT NULL THEN s_Order.BaTnPrice  
			 ELSE s_Contract.BaTnPrice  
		END AS BaTnPrice  
FROM    s_SaleModiApply WITH (NOLOCK)  
		LEFT JOIN s_Order WITH (NOLOCK) ON s_Order.OrderGUID = s_SaleModiApply.SaleGUID  
		LEFT JOIN s_Contract WITH (NOLOCK) ON s_Contract.ContractGUID = s_SaleModiApply.SaleGUID  
		LEFT JOIN s_Order LastOrder WITH (NOLOCK) ON LastOrder.OrderGuid=s_Contract.LastSaleGuid  
WHERE   s_SaleModiApply.ApplyTypeEnum = 2 
		AND s_SaleModiApply.ExecDate IS NOT NULL  

GO












