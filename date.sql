drop table #temp_table

declare @year int
declare @day int
declare @daytostart int
declare @date datetime
declare @daydiff int
declare @datetostart datetime


create table #temp_table
(
	startdate datetime,
	enddate datetime
)


-- 1 Sunday, 2 Monday, 3 Tuesday, 4 Wednesday, 5 Thursday, 6 Friday, 7 Saturday
select @daytostart= 6
select @date='2/1/2012'

select datepart(dw,@date)

select @daydiff=0

while ((@daytostart != datepart(dw,dateadd(day,@daydiff,@date))) and @daydiff < 8 )
begin
 select @daydiff=@daydiff+1
end


select @datetostart=dateadd(day,@daydiff,@date)

select @datetostart
select @daydiff=0
while ( datepart(year,dateadd(day,@daydiff,@datetostart)) <= datepart(year,@datetostart) )
begin

	insert into #temp_table
	(startdate, enddate)
	select dateadd(day,@daydiff,@datetostart), dateadd(day,@daydiff+2,@datetostart)


	select @daydiff=@daydiff+7
	
	
end


select * from #temp_table