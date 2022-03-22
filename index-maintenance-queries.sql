/*
 ** CHECK To see what Indexes are Missing
 **
 ** run the query uncommented below
 **

 OPTIONAL:  
	These two sprocs analyze EXISTING Indexes to see if they are being used or not

	sp_IndexAnalysis
	EXEC dbo.sp_BlitzIndex @DatabaseName='firstchoicedb-NIGHTLY', @SchemaName='dbo', @TableName='CRM_MessageQueue';

*/

SET TRANSACTION ISOLATION LEVEL 
                        READ UNCOMMITTED


select *
from (
	select Rank() over (partition by dbname  order by  totalcost desc, create_statement) as rnk, DBName, TotalCost, TableName, Equality_columns as EqualityColumns, Inequality_Columns as InequalityColumns, Included_Columns as IncludedColumns, Create_Statement as CreateStatement
	from (
	SELECT 
	 ROUND(s.avg_total_user_cost *
		   s.avg_user_impact
			* (s.user_seeks + s.user_scans),0)
					 AS [TotalCost]
	 ,d.[statement] AS [TableName]
	 ,equality_columns
	 ,inequality_columns
	 ,included_columns
	 , DB_NAME(d.database_id) as DBName
	 ,'CREATE INDEX [IX_' + OBJECT_NAME(d.OBJECT_ID,d.database_id) + '_'
		+ REPLACE(REPLACE(REPLACE(ISNULL(d.equality_columns,''),', ','_'),'[',''),']','') +
		CASE
		WHEN d.equality_columns IS NOT NULL AND d.inequality_columns IS NOT NULL THEN '_'
		ELSE ''
		END
		+ REPLACE(REPLACE(REPLACE(ISNULL(d.inequality_columns,''),', ','_'),'[',''),']','')
		+ ']'
		+ ' ON ' + d.statement
		+ ' (' + ISNULL (d.equality_columns,'')
		+ CASE WHEN d.equality_columns IS NOT NULL AND d.inequality_columns IS NOT NULL THEN ',' ELSE
		'' END
		+ ISNULL (d.inequality_columns, '')
		+ ')'
		+ ISNULL (' INCLUDE (' + d.included_columns + ')', '') AS Create_Statement
	FROM sys.dm_db_missing_index_groups g
	INNER JOIN sys.dm_db_missing_index_group_stats s
	  ON s.group_handle = g.index_group_handle
	INNER JOIN sys.dm_db_missing_index_details d
	  ON d.index_handle = g.index_handle
	) aa
) final
where final.rnk <=10
