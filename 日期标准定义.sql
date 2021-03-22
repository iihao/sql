
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
