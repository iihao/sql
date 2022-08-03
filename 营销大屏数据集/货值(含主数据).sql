with hz as (
	select b.BUGUID,b.BUName,b.ProjectGuid,b.ProjectName,b.XxCode,
	b.SetNum as 目标套数,
	isnull(b.UpSaleArea,0.00)+ isnull(b.DownSaleArea,0.00) as 目标面积,
	(isnull(b.TargetUnitPrice,0.0)*(isnull(b.UpCarNum,0)+isnull(b.DownCarNum,0))
	+(isnull(b.UpSaleArea,0.00)+ isnull(b.DownSaleArea,0.00))*isnull(b.TargetUnitPrice,0.00))/100000000  as 目标货值,
	r.* 
	from 
	data_wide_mdm_building b
	left join (
	select --分期维度
	r.BldGUID,
	r.MasterBldGUID,
	sum(1) as 房源总套数,
	sum(r.BldArea) as 房源总面积,
	sum(case when r.Status='签约' or r.Status='认购'  then R.CjRmbTotal else  CASE WHEN isnull(r.djTotal,0)<>0 
	then r.djTotal else 0  end END)/100000000 as 房源总货值,
	sum(case when r.Status='签约' or r.Status='认购'  then 1 else 0 end) as 已售套数,
	sum(case when r.Status='签约' or r.Status='认购'  then r.BldArea else 0 end) as 已售面积,
	sum(case when r.Status='签约' or r.Status='认购'  then R.CjRmbTotal else 0 end)/100000000 as 已售货值,
	sum(case when r.Status='签约' or r.Status='认购'  then 0 else 1 end)  as 未售套数,
	sum(case when r.Status='签约' or r.Status='认购'  then 0 else r.BldArea end) as 未售面积,
	sum(case when r.Status='签约' or r.Status='认购'  then 0 else (CASE WHEN isnull(r.djTotal,0)<>0 
	then r.djTotal else 0  end ) END)/100000000 as 未售货值
	from
	data_wide_s_Room r
	group by r.MasterBldGUID,r.BldGUID) r on r.MasterBldGUID=b.BuildingGUID)
	
	select 
	'集团' as wd,
	BUGUID,
	BUName,
	sum(case when isnull(XxCode,'')='' then 目标套数 else 房源总套数 end) as 总套数,
	sum(case when isnull(XxCode,'')='' then 目标面积 else 房源总面积 end) as 总面积,
	sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end) as 总货值,
	sum(目标货值) as 目标货值,
	sum(房源总货值) as 房源总货值,
	sum(已售套数) as 已售套数,
	sum(已售面积) as 已售面积,
	sum(已售货值) as 已售货值,
	sum(未售套数) as 未售套数,
	sum(未售面积) as 未售面积,
	sum(未售货值) as 未售货值,
	case when isnull(sum(房源总货值),0)=0 then 0 else
	sum(已售货值)/sum(房源总货值) end as 房源去化率,
	case when isnull(sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end),0)=0 then 0 else
	sum(已售货值)/sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end) end as 房源去化率
	from hz
	group by 
	BUGUID,
	BUName
	
	union all 
	
	select 
	'项目' as wd,
	ProjectGuid,
	ProjectName,
	sum(case when isnull(XxCode,'')='' then 目标套数 else 房源总套数 end) as 总套数,
	sum(case when isnull(XxCode,'')='' then 目标面积 else 房源总面积 end) as 总面积,
	sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end) as 总货值,
	sum(目标货值) as 目标货值,
	sum(房源总货值) as 房源总货值,
	sum(已售套数) as 已售套数,
	sum(已售面积) as 已售面积,
	sum(已售货值) as 已售货值,
	sum(未售套数) as 未售套数,
	sum(未售面积) as 未售面积,
	sum(未售货值) as 未售货值,
	case when isnull(sum(房源总货值),0)=0 then 0 else
	sum(已售货值)/sum(房源总货值) end as 房源去化率,
	case when isnull(sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end),0)=0 then 0 else
	sum(已售货值)/sum(case when isnull(XxCode,'')='' then 目标货值 else 房源总货值 end) end as 全盘去化率
	from hz
	group by 
	ProjectGuid,
	ProjectName
	
	
	
	