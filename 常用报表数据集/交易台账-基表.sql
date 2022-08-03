select --集团维度
'集团维度' as WD,
'集团' as BUName ,
'EE4ACEEB-C4AF-EA11-80CA-000C2964F145' as BUGUID ,

sum(1) as 总套数,
sum(r.BldArea) as 总面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END)/100000000 as 总货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 1 else 0 end) as 已售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then r.BldArea else 0 end) as 已售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0.00 end)/100000000 as 已售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else 1 end)  as 未售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else r.BldArea end) as 未售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0.00 else (CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end ) END)/100000000 as 未售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0 end)
/sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END) as 去化率
from
s_Room r
left join s_Trade t on r.RoomGUID=t.RoomGuid and t.TradeStatus='激活'
left join s_Contract c on t.TradeGUID=c.TradeGUID and c.Status='激活'
left join (select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p on r.ProjGUID=p.p_projectId
left join p_Project p1 on p.ParentGUID=p1.p_projectId
left join  myBusinessUnit bu on r.BUGUID = bu.BUGUID

union all 
select --公司维度
'公司维度' as WD,
bu.BUName as BUName ,
p1.BUGUID as BUGUID ,

sum(1) as 总套数,
sum(r.BldArea) as 总面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END)/100000000 as 总货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 1 else 0 end) as 已售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then r.BldArea else 0 end) as 已售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0.00 end)/100000000 as 已售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else 1 end)  as 未售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else r.BldArea end) as 未售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0.00 else (CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end ) END)/100000000 as 未售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0 end)
/sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END) as 去化率
from
s_Room r
left join s_Trade t on r.RoomGUID=t.RoomGuid and t.TradeStatus='激活'
left join s_Contract c on t.TradeGUID=c.TradeGUID and c.Status='激活'
left join (select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p on r.ProjGUID=p.p_projectId
left join p_Project p1 on p.ParentGUID=p1.p_projectId
left join  myBusinessUnit bu on r.BUGUID = bu.BUGUID
group by p1.BUGUID,bu.BUName

union all
select --项目维度
'项目维度' as WD,
p1.ProjName  ,
p1.p_projectId  ,

sum(1) as 总套数,
sum(r.BldArea) as 总面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END)/100000000 as 总货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 1 else 0 end) as 已售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then r.BldArea else 0 end) as 已售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0.00 end)/100000000 as 已售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else 1 end)  as 未售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else r.BldArea end) as 未售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0.00 else (CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end ) END)/100000000 as 未售货值,

	sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0 end)
/sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END) as 去化率
from
s_Room r
left join s_Trade t on r.RoomGUID=t.RoomGuid and t.TradeStatus='激活'
left join s_Contract c on t.TradeGUID=c.TradeGUID and c.Status='激活'
left join (select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p on r.ProjGUID=p.p_projectId
left join p_Project p1 on p.ParentGUID=p1.p_projectId
left join  myBusinessUnit bu on r.BUGUID = bu.BUGUID
group by p1.ProjName ,
p1.p_projectId 

union all
select --项目维度
'业态维度' as WD,
prod.Name  ,
prod.p_MasterDataProductTypeId ,

sum(1) as 总套数,
sum(r.BldArea) as 总面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END)/100000000 as 总货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 1 else 0 end) as 已售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then r.BldArea else 0 end) as 已售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0.00 end)/100000000 as 已售货值,

sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else 1 end)  as 未售套数,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0 else r.BldArea end) as 未售面积,
sum(case when r.Status='签约'/* or r.Status='认购' */ then 0.00 else (CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end ) END)/100000000 as 未售货值,

	sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else 0 end)
/sum(case when r.Status='签约'/* or r.Status='认购' */ then c.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 then r.djTotal else 0  end END) as 去化率
from
s_Room r
left join s_Trade t on r.RoomGUID=t.RoomGuid and t.TradeStatus='激活'
left join s_Contract c on t.TradeGUID=c.TradeGUID and c.Status='激活'
left join (select p_projectId,case when ParentGUID is not null then ParentGUID else p_projectId end as ParentGUID from p_Project) p on r.ProjGUID=p.p_projectId
left join p_Project p1 on p.ParentGUID=p1.p_projectId
left join  myBusinessUnit bu on r.BUGUID = bu.BUGUID
left join s_Building  bld on bld.BldGUID = r.BldGUID
left join vp_interface_MasterDataProductType Prod on bld.ProductTypeGUID = Prod.p_MasterDataProductTypeId
group by prod.Name  ,
prod.p_MasterDataProductTypeId 
