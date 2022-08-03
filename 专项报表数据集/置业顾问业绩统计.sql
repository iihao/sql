SELECT 
ROW_NUMBER()OVER(ORDER BY Q.累计签约金额 DESC) AS 排名,
CASE WHEN ISNULL(Q.渠道,'')='' THEN '非渠道' ELSE Q.渠道 END AS 渠道,
Q.本期住宅认购套数,
Q.本期住宅认购金额,
Q.本期住宅签约套数,
Q.本期住宅签约金额,
CASE WHEN ISNULL(Q.累计认购套数,0)=0 THEN 0 ELSE
CAST(Q.累计签约套数 AS decimal(18,2))/CAST(Q.累计认购套数 AS decimal(18,2)) END AS 累计签约完成率,
Q.本期车位签约套数,
Q.本期车位签约金额,
Q.本期商业签约套数,
Q.本期商业签约金额,
Q.本期累计签约金额,
Q.累计签约金额,
Q.总退房套数,
CASE WHEN ISNULL(Q.累计认购套数,0)=0 THEN 0 ELSE 
CAST(Q.总退房套数 AS decimal(18,2))/CAST(Q.累计认购套数 AS decimal(18,2)) END AS 累计退房率	
FROM
(
SELECT 
	CASE WHEN ISNULL(T.qudao,'')='' THEN t.Oqudao else t.qudao END AS 渠道,
	SUM(CASE WHEN T.OStatus='激活' OR T.CStatus='激活' THEN 1 ELSE 0 END) AS 累计认购套数,
	SUM(CASE WHEN T.OStatus='激活' OR T.CStatus='激活' THEN T.OCjRoomTotal ELSE 0 END) AS 累计认购金额,
	SUM(CASE WHEN (T.OStatus='激活' OR T.CStatus='激活') AND TopProductTypeName='住宅'  AND OQsDate BETWEEN @bgndate AND @enddate THEN 1 ELSE 0 END) AS 本期住宅认购套数,
	SUM(CASE WHEN (T.OStatus='激活' OR T.CStatus='激活') AND TopProductTypeName='住宅'  AND OQsDate BETWEEN @bgndate AND @enddate THEN T.OCjRoomTotal ELSE 0 END) AS 本期住宅认购金额,
	SUM(CASE WHEN T.CStatus='激活' THEN 1 ELSE 0 END) AS 累计签约套数,
	SUM(CASE WHEN T.CStatus='激活' AND CQsDate BETWEEN @bgndate AND @enddate THEN T.CCjRoomTotal ELSE 0 END) AS 本期累计签约金额,
	SUM(CASE WHEN T.CStatus='激活' THEN T.CCjRoomTotal ELSE 0 END) AS 累计签约金额,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='住宅' AND CQsDate BETWEEN @bgndate AND @enddate THEN 1 ELSE 0 END) AS 本期住宅签约套数,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='住宅' AND CQsDate BETWEEN @bgndate AND @enddate THEN T.CCjRoomTotal ELSE 0 END) AS 本期住宅签约金额,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='商业' AND CQsDate BETWEEN @bgndate AND @enddate THEN 1 ELSE 0 END) AS 本期商业签约套数,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='商业' AND CQsDate BETWEEN @bgndate AND @enddate THEN T.CCjRoomTotal ELSE 0 END) AS 本期商业签约金额,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='车位' AND CQsDate BETWEEN @bgndate AND @enddate THEN 1 ELSE 0 END) AS 本期车位签约套数,
	SUM(CASE WHEN (T.CStatus='激活') AND TopProductTypeName='车位' AND CQsDate BETWEEN @bgndate AND @enddate THEN T.CCjRoomTotal ELSE 0 END) AS 本期车位签约金额,
	SUM(CASE WHEN T.OCloseReason='退房' OR T.CCloseReason='退房' THEN 1 ELSE 0 END) AS 总退房套数
FROM data_wide_s_Trade T
WHERE T.ProjGUID IN (@PROJGUID)
GROUP BY CASE WHEN ISNULL(T.qudao,'')='' THEN t.Oqudao else t.qudao END
)Q
ORDER BY Q.累计签约金额 DESC



