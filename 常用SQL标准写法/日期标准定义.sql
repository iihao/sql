
SET DATEFIRST 1
DECLARE @now Date =GetDate()
declare @yesterday Date =DATEADD(day, -1, @now)
declare @weekstartday Date =DATEADD(day, 1 - datepart(weekday, @now), @now)
declare @weekendday Date =DATEADD(day, -1, DATEADD(week, 1, @weekstartday))
declare @monthstartday Date =DATEADD(day, 1 - day(@now), @now)
declare @monthendday Date =DATEADD(day, -1, DATEADD(month, 1, @monthstartday))
declare @yearstartday Date =cast(year(@now) as varchar(4)) + '-01-01';
declare @yearendday Date =DATEADD(day, -1, DATEADD(year, 1, @yearstartday))
declare @quarterstartday Date =DATEADD(month, (datepart(quarter, @now) - 1) * 3, @yearstartday)
declare @quarterendday Date =DATEADD(day, -1, DATEADD(quarter, 1, @quarterstartday))









 Public Function divide(x As Double, y As Double) As Double
		If y = 0.0 Then
			Return 0.0
		Else
			Return x / y
		End If
	End Function
 
 使用：  =Code.divide(Sum(Fields!OverCost.Value),Sum(Fields!TargetCost.Value))
 

 
 
 http://192.168.10.1:56800/service/XChangeServlet?account=U8cloud&receiver=10205
 
 
 14312101040034125	凯达-一般户-农业银行南昌东湖支行14312101040034125	14312101040034125	人民币		中国农业银行	收支
 1502212019300308105	凯达-一般户-中国工商银行南昌苏圃支行1502212019300308105	1502212019300308105	人民币		中国工商银行	收支
 193247088225	赣电-贷款户中国银行193247088225	193247088225	人民币		中国银行	收支
 20000044805400037031946	江西凯达房地产开发有限公司-一般-北京银行南昌高新支行20000044805400037031946	20000044805400037031946	人民币		北京银行	收支
 200749619679	中国银行南昌市青云谱支行营业部	200749619679	人民币		中国银行	收支
 36050110345500000650	江西凯达房地产开发有限公司-中国建设银行南昌江铜支行36050110345500000650	36050110345500000650	人民币		中国建设银行	收支
 361899991011000275701	凯达-一般户-交通银行南昌省府大院支行361899991011000275701	361899991011000275701	人民币		交通银行	收支
 791914823400019	江西凯达房地产开发有限公司-江西银行南昌永叔路支行791914823400019	791914823400019	人民币		江西银行	收支