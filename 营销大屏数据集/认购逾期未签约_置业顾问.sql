select 
ParentProjGUID,
ParentProjName,
OZygw,
sum(case when datediff(dd,YqyDate,GETDATE())>0 then 1 else 0 end) as 逾期未签套数, 
sum(case when datediff(dd,YqyDate,GETDATE())>0 then OCjBldArea else 0 end) as 逾期未签面积, 
sum(case when datediff(dd,YqyDate,GETDATE())>0 then OCjTotal else 0 end)/10000 as 逾期未签金额 
from data_wide_s_Trade
where isnull(ozygw,'')<>'' and ostatus='激活'
group by
ParentProjGUID,
ParentProjName,
OZygw
order by sum(case when datediff(dd,YqyDate,GETDATE())>0 then 1 else 0 end) desc

