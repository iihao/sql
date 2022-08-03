USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[vs_Voucher2GetinDetail_rpt]    Script Date: 04/29/2021 15:02:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[vs_Voucher2GetinDetail_rpt] 
AS 
SELECT
	v.VouchGUID, 
	v.VouchType,
	v.VouchTypeEnum,
	v.SaleType, 
	v.VouchStatus, 
	v.Invotype,
	v.InvoTypeEnum,
	v.InvoNO, 
	v.Jkr, 
	v.Kpr, 
	KpDate, 
	case when v.VouchType='放款单' then v.KpDate else v.SkDate end as SkDate, 
	v.AuditName, 
	v.AuditDate, 
	v.LoanBank, 
	v.BuGUID, 
	g.ProjGUID, 
	g.GetinGUID, 
	case when v.VouchType='退款单' then v.SkDate else g.GetDate end as GetDate, 
	g.SaleGUID,
	g.InSequence, 
	g.ItemType, 
	g.ItemName, 
	g.Amount, 
	g.Bz, 
	g.ExRate, 
	g.RmbAmount, 
	g.Status, 
	g.PreGetinGUID, 
	g.GetForm, 
	
	g.BeforeYe, 
	g.BeforeRmbYe, 
	g.AfterYe, 
	g.AfterRmbYe,
	v.Remark,
	g.RzBank as RzBank ,
	g.PosAmount,
	g.TaxAmount,
	g.TaxRate,
	v.RmbAmount as VouchRmbAmount,
	v.CreatedTime,
	v.RoomGUID
FROM 
	s_Voucher v
	left outer join s_Getin g ON g.VouchGUID = v.VouchGUID 
GO





USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[vs_Trade_rpt]    Script Date: 04/29/2021 15:03:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		CREATE   VIEW [dbo].[vs_Trade_rpt] 
		AS   
		SELECT
			ProjGUID,
			OrderType AS SaleStatus,
			OrderGUID AS SaleGUID ,
			TradeGUID ,
			Status,
			QSDate ,
			QSDate as RgDate,
			null as QyDate,
			RoomGUID ,
			RoomInfo ,
			CjRmbTotal,
			CjBldPrice,
			BldArea,
			DiscntValue,
			DiscntRemark,
			PayFormName,
			CstName,
			CardID,
			CstTel,
			CstAddr,
			ZygwAllGUID,
			Zygw,
			AjBank,
			AjTotal,
			AjYear,
			GjjBank,
			GjjTotal,
			GjjYear,
			CloseReason,
			CloseDate
		FROM dbo.es_Order_rpt
		UNION ALL
		SELECT  
			ProjGUID,
			'签约' AS SaleStatus,
			ContractGUID AS SaleGUID ,
			es_Contract_rpt.TradeGUID ,
			Status,
			es_Contract_rpt.QSDate ,
			o.QSDate as RgDate,
			es_Contract_rpt.QSDate as QyDate,
			RoomGUID ,
			RoomInfo ,
			CjRmbTotal,
			CjBldPrice,
			BldArea,
			DiscntValue,
			DiscntRemark,
			PayFormName,
			CstName,
			CardID,
			CstTel,
			CstAddr,
			ZygwAllGUID,
			Zygw,
			AjBank,
			AjTotal,
			AjYear,
			GjjBank,
			GjjTotal,
			GjjYear,
			CloseReason,
			CloseDate
		FROM dbo.es_Contract_rpt
			left outer join (select TradeGUID,QSDate from s_Order where Status='关闭' and CloseReason='转签约') o on es_Contract_rpt.TradeGUID=o.TradeGUID
GO


USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[vs_rpt_order]    Script Date: 04/29/2021 15:04:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vs_rpt_order]
AS
	SELECT  [OrderGUID] ,
			[CreatedTime] ,
			[CreatedGUID] ,
			[ModifiedTime] ,
			[ModifiedGUID] ,
			[AgreementNo] ,
			[Remark] ,
			[AuditGUID] ,
			[CalModeEnum] ,
			[BldArea] ,
			[CjRmbTotal] ,
			[CjRoomTotal] ,
			[AuditDate] ,
			[CloseDate] ,
			[AuditStatusEnum] ,
			[CjBldPrice] ,
			[ZxTotal] ,
			[IsST] ,
			[AjBank] ,
			[IsZxkbrht] ,
			[GjjTotal] ,
			[AjTotal] ,
			[DiscntValue] ,
			[GjjBank] ,
			[QSDate] ,
			[RoomGUID] ,
			[FsTotal] ,
			[RoomBldPrice] ,
			[StatusEnum] ,
			[CjTnPrice] ,
			[YqyDate] ,
			[DjBldPrice] ,
			[ProjGUID] ,
			[RoomTnPrice] ,
			[RoomTotal] ,
			[TnArea] ,
			[TradeGUID] ,
			[DjTotal] ,
			[DjTnPrice] ,
			[Earnest] ,
			[LastSaleGUID] ,
			[LastSaleType] ,
			[PayFormGUID] ,
			[YwgsDate] ,
			FaceDiscntRemark,
			BcxyDiscntRemark,
			case
		   when BcxyDiscntRemark = '' then FaceDiscntRemark
		   else '面价折扣说明：' + FaceDiscntRemark + ';' + '补充协议折扣说明：' + BcxyDiscntRemark end as [DiscntRemark],
			[IsLockDisount] ,
			[Addition] ,
			[JbrGUID] ,
			[Zygw] ,
			[OrderBarcode] ,
			[CloseReason] ,
			[OrderTypeEnum] ,
			[AreaStatusEnum] ,
			[ZxBz] ,
			[ZxPrice] ,
			[GjjYear] ,
			[AjYear] ,
			[Status] ,
			[BUGUID] ,
			[AuditName] ,
			[LastSaleTypeEnum] ,
			[CalMode] ,
			[OrderType] ,
			[AreaStatus] ,
			[PayFormName] ,
			[JbrName] ,
			[CreatedName] ,
			[ModifiedName] ,
			[AuditStatus] ,
			[CloseReasonEnum] ,
			[IdCode] ,
			[BaTotal]  ,
			[s_Order].[RoomBzTotal] ,
			[s_Order].[RoomBzBldPrice] ,
			[s_Order].[RoomBzTnPrice] ,
			[s_Order].[IsEnableBcxy]
	FROM    [s_Order] WITH ( NOLOCK )
	WHERE   OrderTypeEnum = 0
			AND IsPreOrder <> 1
			AND StatusEnum = 1

GO
USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[es_Order_rpt]    Script Date: 04/29/2021 15:05:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[es_Order_rpt]   
AS   
SELECT 
	o.OrderGUID, 
	o.BUGUID, 
	o.ProjGUID, 
	o.TradeGUID, 
	o.RoomGUID,   
	o.LastSaleGUID, 
	o.LastSaleType, 
	o.AgreementNo, 
	o.OrderBarcode,
	o.QSDate, 
	o.YwgsDate,
	o.BldArea, 
	o.TnArea, 
	o.CjRmbTotal,
	o.CjBldPrice,
	o.CalMode,
	o.PayFormGUID,
	o.PayformName, 
	o.DiscntValue, 
	o.DiscntRemark,
	o.Earnest, 
	o.AjBank, 
	o.AjTotal, 
	o.AjYear,   
	o.GjjBank, 
	o.GjjTotal,
	o.GjjYear, 
	o.OrderType, 
	o.Status,
	o.Zygw,
	o.ZygwAllGUID, 
	o.CloseDate, 
	o.CloseReason,  
	o.ReMark, 
	o.AreaStatus, 
	cst1.cstGUID AS cstguid1, 
	cst2.cstGUID AS cstguid2,  
	cst3.cstGUID AS cstguid3, 
	cst4.cstGUID AS cstguid4,    
	p1.CstName+(CASE WHEN isnull(p2.CstName,'')='' THEN '' ELSE ';'+p2.CstName END)+(CASE WHEN isnull(p3.CstName,'')='' THEN '' ELSE ';'+p3.CstName END)+(CASE WHEN isnull(p4.CstName,'')='' THEN '' ELSE ';'+p4.CstName END) AS CstName, 
	p1.Tel+(CASE WHEN isnull(p2.Tel,'')='' THEN '' ELSE ';'+p2.Tel END)+(CASE WHEN isnull(p3.Tel,'')='' THEN '' ELSE ';'+p3.Tel END)+(CASE WHEN isnull(p4.Tel,'')='' THEN '' ELSE ';'+p4.Tel END) AS CstTel, 
	p1.CardID+(CASE WHEN isnull(p2.CardID,'')='' THEN '' ELSE ';'+p2.CardID END)+(CASE WHEN isnull(p3.CardID,'')='' THEN '' ELSE ';'+p3.CardID END)+(CASE WHEN isnull(p4.CardID,'')='' THEN '' ELSE ';'+p4.CardID END) AS CardID, 
	cst1.Address as CstAddr,
	(b.BldFullName+(CASE WHEN r.Unit<>'' THEN '-'+r.Unit+'-'+r.Room ELSE +'-'+r.Room END )) as RoomInfo            
FROM s_Order o
	inner join s_Trade t ON o.TradeGUID=t.TradeGUID             
	inner join s_Room r ON t.RoomGUID=r.RoomGUID             
	inner join s_Building b on r.BldGUID=b.BldGUID
	left outer join s_Buyer cst1 ON o.OrderGUID=cst1.SaleGUID AND cst1.cstNum=1  
	left outer join p_Customer p1 ON cst1.cstGUID=p1.cstGUID  
	left outer join s_Buyer cst2 ON o.OrderGUID=cst2.SaleGUID AND cst2.cstNum=2  
	left outer join p_Customer p2 ON cst2.cstGUID=p2.cstGUID  
	left outer join s_Buyer cst3 ON o.OrderGUID=cst3.SaleGUID AND cst3.cstNum=3  
	left outer join p_Customer p3 ON cst3.cstGUID=p3.cstGUID  
	left outer join s_Buyer cst4 ON o.OrderGUID=cst4.SaleGUID AND cst4.cstNum=4  
	left outer join p_Customer p4 ON cst4.cstGUID=p4.cstGUID  
GO

USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[es_Contract_rpt]    Script Date: 04/29/2021 15:06:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[es_Contract_rpt]   
AS   
SELECT 
	c.ContractGUID, 
	c.BUGUID, 
	c.ProjGUID, 
	c.TradeGUID, 
	c.RoomGUID,   
	c.LastSaleGUID, 
	c.LastSaleType, 
	c.AgreementNo, 
	c.ContractBarcode,
	c.QSDate, 
	c.YwgsDate,
	c.BldArea, 
	c.TnArea, 
	c.CjRmbTotal,
	c.CjBldPrice,
	c.CalMode,
	c.PayFormGUID,
	c.PayformName, 
	c.DiscntValue, 
	c.DiscntRemark,
	c.Earnest, 
	c.AjBank, 
	c.AjTotal, 
	c.AjYear,   
	c.GjjBank, 
	c.GjjTotal,
	c.GjjYear, 
	c.ContractType, 
	c.Status,
	c.Zygw,
	c.ZygwAllGUID, 
	c.CloseDate, 
	c.CloseReason,  
	c.ReMark, 
	c.AreaStatus, 
	cst1.cstGUID AS cstguid1, 
	cst2.cstGUID AS cstguid2,  
	cst3.cstGUID AS cstguid3, 
	cst4.cstGUID AS cstguid4,    
	p1.CstName+(CASE WHEN isnull(p2.CstName,'')='' THEN '' ELSE ';'+p2.CstName END)+(CASE WHEN isnull(p3.CstName,'')='' THEN '' ELSE ';'+p3.CstName END)+(CASE WHEN isnull(p4.CstName,'')='' THEN '' ELSE ';'+p4.CstName END) AS CstName, 
	p1.Tel+(CASE WHEN isnull(p2.Tel,'')='' THEN '' ELSE ';'+p2.Tel END)+(CASE WHEN isnull(p3.Tel,'')='' THEN '' ELSE ';'+p3.Tel END)+(CASE WHEN isnull(p4.Tel,'')='' THEN '' ELSE ';'+p4.Tel END) AS CstTel, 
	p1.CardID+(CASE WHEN isnull(p2.CardID,'')='' THEN '' ELSE ';'+p2.CardID END)+(CASE WHEN isnull(p3.CardID,'')='' THEN '' ELSE ';'+p3.CardID END)+(CASE WHEN isnull(p4.CardID,'')='' THEN '' ELSE ';'+p4.CardID END) AS CardID, 
	cst1.Address as CstAddr,
	(b.BldFullName+(CASE WHEN r.Unit<>'' THEN '-'+r.Unit+'-'+r.Room ELSE +'-'+r.Room END )) as RoomInfo            
FROM s_Contract c
	inner join s_Trade t ON c.TradeGUID=t.TradeGUID             
	inner join s_Room r ON t.RoomGUID=r.RoomGUID             
	inner join s_Building b on r.BldGUID=b.BldGUID
	left outer join s_Buyer cst1 ON c.ContractGUID=cst1.SaleGUID AND cst1.cstNum=1  
	left outer join p_Customer p1 ON cst1.cstGUID=p1.cstGUID  
	left outer join s_Buyer cst2 ON c.ContractGUID=cst2.SaleGUID AND cst2.cstNum=2  
	left outer join p_Customer p2 ON cst2.cstGUID=p2.cstGUID  
	left outer join s_Buyer cst3 ON c.ContractGUID=cst3.SaleGUID AND cst3.cstNum=3  
	left outer join p_Customer p3 ON cst3.cstGUID=p3.cstGUID  
	left outer join s_Buyer cst4 ON c.ContractGUID=cst4.SaleGUID AND cst4.cstNum=4  
	left outer join p_Customer p4 ON cst4.cstGUID=p4.cstGUID
GO

USE [dotnet_erp60]
GO
/****** Object:  View [dbo].[es_Booking_rpt]    Script Date: 04/29/2021 15:08:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[es_Booking_rpt] 
AS 
SELECT 
	bk.BookingGUID,
	bk.ProjGUID,
	bk.BgnDate,
	bk.EndDate,
	bk.ProjNum,
	bk.SjNum,
	bk.FullProjNum,
	bk.Bz,
	bk.YsAmount,
	bk.Remark,
	bk.Status,
	bk.CloseTime,
	bk.ClosePreson,
	bk.CloseReason,
	bk.CloseRemark,
	p1.cstGUID AS cstguid1, 
	p2.cstGUID AS cstguid2,
	p3.cstGUID AS cstguid3, 
	p4.cstGUID AS cstguid4,  
	p1.CstName+(CASE WHEN isnull(p2.CstName,'')='' THEN '' ELSE ';'+p2.CstName END)+(CASE WHEN isnull(p3.CstName,'')='' THEN '' ELSE ';'+p3.CstName END)+(CASE WHEN isnull(p4.CstName,'')='' THEN '' ELSE ';'+p4.CstName END) AS CstName, 
	p1.Tel+(CASE WHEN isnull(p2.Tel,'')='' THEN '' ELSE ';'+p2.Tel END)+(CASE WHEN isnull(p3.Tel,'')='' THEN '' ELSE ';'+p3.Tel END)+(CASE WHEN isnull(p4.Tel,'')='' THEN '' ELSE ';'+p4.Tel END) AS CstTel, 
	p1.CardID+(CASE WHEN isnull(p2.CardID,'')='' THEN '' ELSE ';'+p2.CardID END)+(CASE WHEN isnull(p3.CardID,'')='' THEN '' ELSE ';'+p3.CardID END)+(CASE WHEN isnull(p4.CardID,'')='' THEN '' ELSE ';'+p4.CardID END) AS CardID, 
	p1.Address as CstAddr,
	bk.RoomGUIDs,
	bk.RoomNames,
	bk.Zygw,
	bk.ZygwGUID
FROM 
	s_Booking bk
	left outer join s_Booking2CSt bc1 ON bk.BookingGUID=bc1.BookingGUID AND bc1.Sequence=1  
	left outer join p_Customer p1 ON bc1.CstGUID=p1.CstGUID  
	left outer join s_Booking2CSt bc2 ON bk.BookingGUID=bc2.BookingGUID AND bc2.Sequence=2  
	left outer join p_Customer p2 ON bc2.CstGUID=p2.CstGUID  
	left outer join s_Booking2CSt bc3 ON bk.BookingGUID=bc3.BookingGUID AND bc3.Sequence=3  
	left outer join p_Customer p3 ON bc3.CstGUID=p3.CstGUID  
	left outer join s_Booking2CSt bc4 ON bk.BookingGUID=bc4.BookingGUID AND bc4.Sequence=4  
	left outer join p_Customer p4 ON bc4.CstGUID=p4.CstGUID  
GO










