select 
ParentProjGUID,
ParentProjName,
BldGUID,
BldName,
max(最大逾期天数) as 最大逾期天数,
sum(case when 逾期未回套数>=1 then 1 else 0 end) as 逾期未回套数,
sum(逾期未回金额) as 逾期未回金额
from(
select 
f.ParentProjGUID,
f.ParentProjName,
f.BldGUID,
f.BldName,
f.RoomGUID,
max(case when DATEDIFF(dd,LastDate,GETDATE())>0 then DATEDIFF(dd,LastDate,GETDATE()) else 0 end) as 最大逾期天数,
sum(case when DATEDIFF(dd,LastDate,GETDATE())>0 then 1 else 0 end) as 逾期未回套数,
sum(case when DATEDIFF(dd,LastDate,GETDATE())>0 then RmbYe else 0 end)/10000 as 逾期未回金额
from
data_wide_s_Fee f
INNER JOIN dbo.data_wide_s_Trade trade WITH (NOLOCK)
		ON f.TradeGUID = trade.TradeGUID
		   AND trade.CStatus = '激活'
		   AND trade.TradeStatus = '激活'
where f.RmbYe > 0 --and f.isfk=1 
AND (f.ItemType='非贷款类房款' OR f.ItemName='公积金' OR f.itemName='银行按揭')
group by
f.ParentProjGUID,
f.ParentProjName,
f.BldGUID,
f.BldName,
f.RoomGUID)t
where 最大逾期天数>0
group by 
ParentProjGUID,
ParentProjName,
BldGUID,
BldName
order by sum(逾期未回金额) desc 