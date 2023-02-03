 

T-SQL Patterns and Practices Review

BNPP - System

Prepared by: Anders Uhl Pedersen
anuhlped@microsoft.com


Date: 2022-07-18



 

		
	The information contained in this document represents the current view of Microsoft Corporation on the issues discussed as of the date of publication. Because Microsoft must respond to changing market conditions, it should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication.
MICROSOFT MAKES NO WARRANTIES, EXPRESS, IMPLIED OR STATUTORY, AS TO THE INFORMATION IN THIS DOCUMENT.
Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.
Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.
The descriptions of other companies’ products in this document, if any, are provided only as a convenience to you. Any such references should not be considered an endorsement or support by Microsoft. Microsoft cannot guarantee their accuracy, and the products may change over time. Also, the descriptions are intended as brief highlights to aid understanding, rather than as thorough coverage. For authoritative descriptions of these products, please consult their respective manufacturers.
© 2013 Microsoft Corporation. All rights reserved. Any use or distribution of these materials without express authorization of Microsoft Corp. is strictly prohibited.
Microsoft and Windows are either registered trademarks of Microsoft Corporation in the United States and/or other countries.
The names of actual companies and products mentioned herein may be the trademarks of their respective owners.
	
		

 


Table of Contents
Table of Contents	3
1. Executive Summary	6
2. Summary of Findings	7
2.1 Scope of the engagement	7
2.2 Issue Severity	8
3. Detailed Findings	13
Concurrency	13
WAITFOR DELAY TIME usage	13
Cursors	14
List all instances of cursor usage	14
Database Design	15
Avoid using types of variable length that are size 1 or 2	15
Check for VARCHAR, NVARCHAR of length MAX	16
Deprecation	18
Avoid using a string literal to alias a column	18
Database options ANSI_NULLS, ANSI_PADDING and CONCAT_NULLS_YIELDS_NULL will always be set to ON	20
Deprecated data types TEXT, IMAGE or NTEXT	21
Use parentheses when specifying TOP in SELECT statements	22
Remove references to undocumented system tables	23
Column aliases in ORDER BY clause cannot be prefixed by table alias	24
ORDER BY specifies integer ordinal	25
Unqualified Joins	26
FOR XML AUTO queries return derived table references in 90 or later compatibility modes	27
Inventory	28
List all instances of table variable usage	28
List all cross database object references	30
List all instances of WHILE statement usage	31
List all input parameters of type XML	33
Logical Expressions	34
DELETE statement without a WHERE clause	34
ORDER BY has no guarantees in the context of an INSERT	36
COUNT will exclude NULL values	37
Nesting a subquery within another is not recommended	38
Statements using <> or != syntax	39
Statements using NOT IN syntax	41
Statements using NOT LIKE syntax	43
Procedure or Function without exception handling	44
ORDER BY has no guarantees in a SELECT INTO context	45
Usage of SELECT * observed	46
SELECT TOP (1) statement without ORDER BY could cause wrong results	47
SELECT used to assign to a variable	48
SELECT or SET used to assign value to a variable from a subquery	49
SELECT statement without a WHERE clause	50
UPDATE statement without a WHERE clause	51
Naming	52
Keywords used as column names	52
Single character object names are not recommended	53
Performance	54
EXECUTE statements should specify schema identifier	54
Input parameter is modified inside a procedure	56
Intrinsic function usage on columns in predicate	57
Intrinsic function usage on columns in JOIN predicate	59
LIKE predicate with leading wildcard	60
INSERT can execute in parallel if TABLOCK is specified	61
CTEs are not always efficient when the SELECT relies on the DISTINCT of all the columns	62
Distinct within aggregate Function	63
UDF without table access should specify SCHEMABINDING	64
UDF usage in the output list	65
Row goal issue	66
Wildcard pattern usage	67
Readability	68
Review the usage of the 'columnAlias = columnName' syntax	68
IF statements should have a BEGIN...END for readability	69
INSERT should specify the list of columns	70
Zero-length schema identifier	71
Review the use of PRINT statements	72
Avoid mixing named parameters with un-named parameters in EXECUTE procedure references	74
Security	75
EXECUTE used with string variable	75
DROP TABLE statement usage	77
Stability	78
Consider using SCOPE_IDENTITY instead of @@IDENTITY	78
Columns with IDENTITY property set may see 'jumps' in SQL 2012 and above	79
Issue described in KB2662301	80
VARCHAR or NVARCHAR declared without size specification	82
Table Hints	83
Table aliased with a reserved word	83
4. Conclusion	84
5. Appendix	85
5.1 Methodology	85





 

		
	1. Executive Summary
	
		
BNPP requested Microsoft to review the database design and code for System and identify suboptimal T-SQL query patterns and practices. The overall goals defined for this exercise are:
·        Identify practices impacting the performance of T-SQL queries
·        Identify code impacting the concurrency and scalability of the system
·        Identify code which may be an upgrade blocker or would be affected by breaking changes
·        Identify code which might give undesired results
·        Knowledge Transfer on T-SQL Code Best Practices

This report presents the findings grouped by categories and each issue is graded in severity. The issues can be prioritized for remediation in the order of their severity. It is also recommended that the findings from this report be shared with all the developer teams in BNPP, with the aim of avoiding these issues in future development work.

		

 

				
2. Summary of Findings
	
				
	2.1 Scope of the engagement

We have covered 1 databases in the scope of this exercise:

				
Schema Statistics
The table below summarizes the different types of objects analyzed per database.		
	Count	Lines
workspace111118	604	22,483
Batch	104	119
DefaultConstraint	36	36
ForeignKeyConstraint	51	102
Function	14	792
Index	57	290
Procedure	150	17,538
Table	140	2,901
Trigger	5	345
UniqueConstraint	43	205
View	4	155

				
	 		 


		
2.2 Issue Severity

The issues which follow are graded as per their ‘severity’. Icons are used to indicate the severity. Given below is the legend for the same.

		
	 
	
		


	
Affected Object Counts by Impact
The table below lists the various issues discovered, grouped by impact. For each level we present the count of affected objects identified.
 	Critical	17
EXECUTE used with string variable	13
Wildcard pattern usage	4
	
 	High	51
Remove references to undocumented system tables	1
ORDER BY has no guarantees in the context of an INSERT	8
LIKE predicate with leading wildcard	3
Keywords used as column names	15
ORDER BY specifies integer ordinal	8
UDF usage in the output list	2
ORDER BY has no guarantees in a SELECT INTO context	2
Table aliased with a reserved word	11
WAITFOR DELAY TIME usage	1
	
 	Medium	344
DELETE statement without a WHERE clause	10
Avoid using a string literal to alias a column	12
Database options ANSI_NULLS, ANSI_PADDING and CONCAT_NULLS_YIELDS_NULL will always be set to ON	3
Deprecated data types TEXT, IMAGE or NTEXT	7
Input parameter is modified inside a procedure	13
INSERT should specify the list of columns	36
Intrinsic function usage on columns in predicate	14
Intrinsic function usage on columns in JOIN predicate	5
COUNT will exclude NULL values	2
Zero-length schema identifier	16
Nesting a subquery within another is not recommended	9
Column aliases in ORDER BY clause cannot be prefixed by table alias	5
CTEs are not always efficient when the SELECT relies on the DISTINCT of all the columns	1
Distinct within aggregate Function	3
UDF without table access should specify SCHEMABINDING	6
Row goal issue	4
Consider using SCOPE_IDENTITY instead of @@IDENTITY	7
DROP TABLE statement usage	25
Usage of SELECT * observed	19
SELECT used to assign to a variable	28
SELECT or SET used to assign value to a variable from a subquery	21
Columns with IDENTITY property set may see 'jumps' in SQL 2012 and above	40
Issue described in KB2662301	13
VARCHAR or NVARCHAR declared without size specification	40
UPDATE statement without a WHERE clause	5
	
 	Low	138
Use parentheses when specifying TOP in SELECT statements	10
EXECUTE statements should specify schema identifier	12
Statements using <> or != syntax	25
Statements using NOT IN syntax	18
Statements using NOT LIKE syntax	3
INSERT can execute in parallel if TABLOCK is specified	42
Review the use of PRINT statements	10
Avoid mixing named parameters with un-named parameters in EXECUTE procedure references	6
SELECT TOP (1) statement without ORDER BY could cause wrong results	4
SELECT statement without a WHERE clause	5
Avoid using types of variable length that are size 1 or 2	2
FOR XML AUTO queries return derived table references in 90 or later compatibility modes	1
	
 	Informational	341
Review the usage of the 'columnAlias = columnName' syntax	4
IF statements should have a BEGIN...END for readability	32
List all instances of cursor usage	20
List all instances of table variable usage	9
List all cross database object references	44
List all instances of WHILE statement usage	21
List all input parameters of type XML	2
Single character object names are not recommended	7
Procedure or Function without exception handling	150
Unqualified Joins	1
Check for VARCHAR, NVARCHAR of length MAX	51
	

	
Issue Categories and Affected Object Counts
The table below lists the various categories of issues discovered along with the count of affected objects identified under each issue.
		workspace111118
Concurrency	1
 	WAITFOR DELAY TIME usage	1
		
Cursors	20
 	List all instances of cursor usage	20
		
Database Design	53
 	Avoid using types of variable length that are size 1 or 2	2
 	Check for VARCHAR, NVARCHAR of length MAX	51
		
Deprecation	48
 	Avoid using a string literal to alias a column	12
 	Database options ANSI_NULLS, ANSI_PADDING and CONCAT_NULLS_YIELDS_NULL will always be set to ON	3
 	Deprecated data types TEXT, IMAGE or NTEXT	7
 	Use parentheses when specifying TOP in SELECT statements	10
 	Remove references to undocumented system tables	1
 	Column aliases in ORDER BY clause cannot be prefixed by table alias	5
 	ORDER BY specifies integer ordinal	8
 	Unqualified Joins	1
 	FOR XML AUTO queries return derived table references in 90 or later compatibility modes	1
		
Inventory	76
 	List all instances of table variable usage	9
 	List all cross database object references	44
 	List all instances of WHILE statement usage	21
 	List all input parameters of type XML	2
		
Logical Expressions	309
 	DELETE statement without a WHERE clause	10
 	ORDER BY has no guarantees in the context of an INSERT	8
 	COUNT will exclude NULL values	2
 	Nesting a subquery within another is not recommended	9
 	Statements using <> or != syntax	25
 	Statements using NOT IN syntax	18
 	Statements using NOT LIKE syntax	3
 	Procedure or Function without exception handling	150
 	ORDER BY has no guarantees in a SELECT INTO context	2
 	Usage of SELECT * observed	19
 	SELECT TOP (1) statement without ORDER BY could cause wrong results	4
 	SELECT used to assign to a variable	28
 	SELECT or SET used to assign value to a variable from a subquery	21
 	SELECT statement without a WHERE clause	5
 	UPDATE statement without a WHERE clause	5
		
Naming	22
 	Keywords used as column names	15
 	Single character object names are not recommended	7
		
Performance	109
 	EXECUTE statements should specify schema identifier	12
 	Input parameter is modified inside a procedure	13
 	Intrinsic function usage on columns in predicate	14
 	Intrinsic function usage on columns in JOIN predicate	5
 	LIKE predicate with leading wildcard	3
 	INSERT can execute in parallel if TABLOCK is specified	42
 	CTEs are not always efficient when the SELECT relies on the DISTINCT of all the columns	1
 	Distinct within aggregate Function	3
 	UDF without table access should specify SCHEMABINDING	6
 	UDF usage in the output list	2
 	Row goal issue	4
 	Wildcard pattern usage	4
		
Readability	104
 	Review the usage of the 'columnAlias = columnName' syntax	4
 	IF statements should have a BEGIN...END for readability	32
 	INSERT should specify the list of columns	36
 	Zero-length schema identifier	16
 	Review the use of PRINT statements	10
 	Avoid mixing named parameters with un-named parameters in EXECUTE procedure references	6
		
Security	38
 	EXECUTE used with string variable	13
 	DROP TABLE statement usage	25
		
Stability	100
 	Consider using SCOPE_IDENTITY instead of @@IDENTITY	7
 	Columns with IDENTITY property set may see 'jumps' in SQL 2012 and above	40
 	Issue described in KB2662301	13
 	VARCHAR or NVARCHAR declared without size specification	40
		
Table Hints	11
 	Table aliased with a reserved word	11
		
	

 


3. Detailed Findings


Concurrency
	
 	WAITFOR DELAY TIME usage
Description
Each WAITFOR statement has a thread associated with it. If many WAITFOR statements are specified on the same server, many threads can be tied up waiting for these statements to run. SQL Server monitors the number of threads associated with WAITFOR statements, and randomly selects some of these threads to exit if the server starts to experience thread starvation. You can create a deadlock by running a query with WAITFOR within a transaction that also holds locks preventing changes to the rowset that the WAITFOR statement is trying to access. SQL Server identifies these scenarios and returns an empty result set if the chance of such a deadlock exists.
Recommendation
Ensure that the statement which uses WAITFOR specifies the minimum wait interval possible. Also avoid using this statement during a long-running transaction.
References
·	WAITFOR (Transact-SQL) | Microsoft Docs


workspace111118 (1 occurrences)
Procedure ssis SSIS_ExecutePackage
WAITFOR DELAY '00:00:1' @ line 51, col 3
		


 
Cursors
	
 	List all instances of cursor usage
Description
Cursor usage can be impactful on performance, as it induces a row-by-row processing instead of the preferred relational processing.
Recommendation
Carefully review the use of cursors. In many cases the use of modern T-SQL constructs like Common Table Expressions, the OUTPUT clause and others can mitigate the need to use cursors.
References
·	sys.dm_exec_cursors (Transact-SQL) | Microsoft Docs
·	DECLARE CURSOR (Transact-SQL) | Microsoft Docs
·	Types of Cursors


workspace111118 (20 occurrences)
Procedure dbo CRDF_GetConvertedAcatDatas
OPEN lstFilters @ line 342, col 5
OPEN col_list @ line 392, col 8
Procedure dbo CreateFreeAnalysisReporting
OPEN DB_CURSOR_ENTT @ line 87, col 1
OPEN DB_CURSOR_ENTTGROUP @ line 109, col 1
OPEN DB_CURSOR @ line 172, col 1
OPEN DB_CURSOR_ENTTGROUP @ line 183, col 1
OPEN DB_CURSOR_ENTT @ line 231, col 1
Procedure dbo FreeAnalysis_GetDatasByRow
OPEN columnsName @ line 41, col 2
Procedure dbo GetIsDeletableQualidocs
OPEN cursor_qualidoc @ line 35, col 1
Procedure dbo GetListEntityCharacteristicsData
OPEN var_list @ line 50, col 2
Procedure dbo GetListRefData
OPEN var_list @ line 88, col 2
OPEN var_list @ line 262, col 2
Procedure dbo Struct_CreateAllViews
OPEN structs @ line 23, col 2
Procedure dbo Struct_CreateView
OPEN var_list @ line 63, col 2
Procedure dbo Workflow_Initialization_IsUpToDate
OPEN listScope @ line 59, col 2
Procedure dbo Workflow_UpdateChildren
OPEN children @ line 105, col 3
		


 
Database Design
	
 	Avoid using types of variable length that are size 1 or 2
Description
When you use data types of variable length such as VARCHAR, NVARCHAR, and VARBINARY, you incur an additional storage cost to track the length of the value stored in the data type. In addition, columns of variable length are stored after all columns of fixed length, which can have performance implications.
Recommendation
If the length of the type will be very small (size 1 or 2) and consistent, declare them as a type of fixed length, such as CHAR, NCHAR, and BINARY.
References
·	nchar and nvarchar (Transact-SQL) | Microsoft Docs
·	Using char and varchar Data


workspace111118 (2 occurrences)
Table dbo APP_TEMPLATEMODELE
[FAMILY] [nvarchar](1) CO...AS NULL @ line 18, col 2
Table dbo LNK_INHERITANCE
[DEPTH_OPERATION] [nvarch...OT NULL @ line 12, col 2
		


 
 	Check for VARCHAR, NVARCHAR of length MAX
Description
The large object data types like varchar(max), nvarchar(max), varbinary(max), text, ntext, image, and xml can be up to 2 GB in size and can be used as variables or parameters in stored procedures. Parameters and variables that are defined as a LOB data type use main memory as storage if the values are small. However, large values are stored in TEMPDB. Therefore, they are prone to potential physical and logical bottlenecks in TEMPDB.
Recommendation
Use the appropriate data type as per the anticipated sizes of data. If you are using SQL 2008 and above, consider these to pass in larger (delimited) strings to a stored procedure, like new Table Valued Parameter feature.
References
·	Capacity Planning for tempdb
·	How It Works: Gotcha: *VARCHAR(MAX) caused my queries to be slower – CSS SQL Server Engineers
·	nchar and nvarchar (Transact-SQL) | Microsoft Docs


workspace111118 (51 occurrences)
Table dbo APP_TRANSCO_QUERY
[STR_QUERY] [varchar](max..._AS NULL @ line 5, col 2
Procedure dbo CRDF_GetConvertedsourceScopes
@LstScopes varchar(Max) @ line 18, col 9
@query varchar(max) @ line 23, col 11
Procedure dbo CRDF_GetFilingTypes
@qrtIdsCSV  varchar(max) @ line 20, col 2
@entitiesIdsCSV varchar(max) @ line 21, col 2
Procedure dbo CRDF_Struct_GetData
@SQL VARCHAR(MAX) @ line 24, col 6
Procedure dbo CRDF_Workflow_GetTemplateDependencies
convert(nvarchar(max), l....y_type) @ line 45, col 4
convert(nvarchar(max), l....entity) @ line 46, col 4
convert(nvarchar(max), l....OUNTRY) @ line 47, col 4
convert(nvarchar(max), l....RTMENT) @ line 48, col 4
convert(nvarchar(max), l...._type) @ line 161, col 4
 ... (note: only 5 of 8 findings shown)
Procedure dbo Scope_GetChildrenId
@entities   varchar(max) @ line 49, col 10
Procedure dbo Transco_InitFILTERS
@Final_Where nvarchar(max) @ line 48, col 10
@sql nvarchar(MAX) =' sel...ect ' @ line 191, col 13
Procedure idr GetInputFormNonLockedRows
[SQL] nvarchar(max) @ line 87, col 3
@query as nvarchar(max) @ line 108, col 10
@centralWhere as nvarchar...(max) @ line 109, col 10
@sensibilityWhere as nvar...(max) @ line 110, col 10
@PERangeStatement nvarcha... = '' @ line 131, col 10
Procedure ssis Matrix_InsertData
convert (nvarchar(max),@L...RROR) @ line 324, col 60
Table ssis TMP_LOGS
[Descr] [nvarchar](max) C..._AS NULL @ line 5, col 2
		


Deprecation

	
 	Avoid using a string literal to alias a column
Description
We detected the usage of column alias syntax of one of the types:
 'colAlias' = someColName 
 
 or 
 
 someColName 'colAlias'. 

The usage of string literal values as column aliases has been deprecated since SQL Server 2005 and may cause issues in specific scenarios such as BACPAC export. In addition, the support for this language feature may be removed in future releases of SQL Server. It still works in SQL Server 2016.
Recommendation
Avoid the usage of string literals as column aliases and instead use the AS syntax as recommended in the reading links below.
References
·	Deprecated Database Engine Features in SQL Server 2016 | Microsoft Docs
·	Aaron Bertrand : Bad Habits to Kick : Using AS instead of = for column aliases
·	No longer able to create a bacpac: SQL70015: Deprecated feature 'String literals as column aliases' is not supported on SQL Azure - Stack Overflow

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (12 occurrences)
Batch  Adhoc batch @ line 1 (CREATE DATABASE [workspace11
N'workspace111118' @ line 4, col 10
N'workspace111118_log' @ line 6, col 10
Procedure dbo CRDF_Process_GetRelativesInformation
'UsedByRef' @ line 21, col 76
'UsedByTemplates' @ line 22, col 78
Procedure dbo CRDF_Scope_GetTemplatesProperties
'Count' @ line 26, col 23
Procedure dbo CRDF_Workspace_GetSteeringToolsData
'UPLOAD_DATE' @ line 34, col 26
'Type' @ line 36, col 21
Procedure dbo GetInputFormsSensiLockRules
'data()' @ line 95, col 60
Procedure dbo GetIsDeletableQualidocs
'QUALIDOC_ID' @ line 100, col 26
'ISTODELETE' @ line 100, col 58
Procedure dbo GetValueFromTransco
'ROW_ID' @ line 673, col 23
'COLUMN_ID' @ line 673, col 50
'VALEURVAL' @ line 673, col 79
'VALEURPARAM' @ line 673, col 120
'VARIABLETYPE' @ line 673, col 153
Procedure idr CreateFeed
'Feed Id Created' @ line 103, col 25
Procedure idr CreateFeedProtection
'Feed Id Created' @ line 124, col 25
Procedure idr WS_LoadIdrData
'RowCount' @ line 23, col 24
'ColumnCount' @ line 23, col 53
		


 
 	Database options ANSI_NULLS, ANSI_PADDING and CONCAT_NULLS_YIELDS_NULL will always be set to ON
Description
In a future version of SQL Server, ANSI_NULLS, ANSI_PADDING and CONCAT_NULLS_YIELDS_NULL will always be set to ON, regardless of the ALTER DATABASE option turning it off.
Recommendation
There is no remedial action other than awareness. If this change impacts code, you will need to handle that accordingly in the future before migrating to a new version of SQL Server. This behavior did not change yet in SQL Server 2016.
References
·	Deprecated Database Engine Features in SQL Server 2016 | Microsoft Docs
·	SET ANSI_NULLS (Transact-SQL) | Microsoft Docs
·	SET ANSI_PADDING (Transact-SQL) | Microsoft Docs
·	SET CONCAT_NULL_YIELDS_NULL (Transact-SQL) | Microsoft Docs
·	ALTER DATABASE SET Options (Transact-SQL) | Microsoft Docs


workspace111118 (3 occurrences)
Batch  Alter Database workspace111118
ALTER DATABASE [workspace...NULL OFF @ line 1, col 1
Batch  Alter Database workspace111118
ALTER DATABASE [workspace...ULLS OFF @ line 1, col 1
Batch  Alter Database workspace111118
ALTER DATABASE [workspace...DING OFF @ line 1, col 1
		


 
 	Deprecated data types TEXT, IMAGE or NTEXT
Description
In some cases, using TEXT, IMAGE or NTEXT might harm performance. These data types are checked as deprecated. Still works in SQL Server 2016.
Recommendation
Deprecated data types are marked to be discontinued on next versions of SQL Server, should use new data types such as: (varchar(max), nvarchar(max), varbinary(max) and etc.)
References
·	ntext, text, and image (Transact-SQL) | Microsoft Docs
·	Deprecated Database Engine Features in SQL Server 2016 | Microsoft Docs


workspace111118 (7 occurrences)
Table dbo APP_ASYNCHRONOUSPROCESS
[ASYNCPROC_MESSAGE] [ntex...NOT NULL @ line 5, col 2
Table dbo APP_USERMESSAGE
[USERMESSAGE] [ntext] COL..._AS NULL @ line 8, col 2
Table dbo LNK_INHERITANCE
[ENTITY_TYPE] [ntext] COL..._AS NULL @ line 7, col 2
[COUNTRY] [ntext] COLLATE..._AS NULL @ line 8, col 2
[ENTITY] [ntext] COLLATE ..._AS NULL @ line 9, col 2
[DEPARTMENT] [ntext] COLL...AS NULL @ line 10, col 2
Procedure dbo LockWorkflowElements
convert(text, TM.VERSION_...sage) @ line 177, col 72
Procedure dbo UnlockWorkflowElements
convert(text, TM.VERSION_...sage) @ line 127, col 74
Procedure idr InsertUploadErrorFile
@ErrorFile text @ line 23, col 2
Table idr UploadErrorFile
[ErrorFile] [text] COLLAT...NOT NULL @ line 5, col 2
		


 
 	Use parentheses when specifying TOP in SELECT statements
Description
For backward compatibility, the parentheses are optional in SELECT statements. However, in cases where a variable or a scalar subquery is used to specify the value of the TOP filter, parentheses are mandatory.
Recommendation
We recommend that you always use parentheses for TOP in SELECT statements for consistency with the otherwise required use of parentheses in INSERT, UPDATE, MERGE and DELETE statements.
References
·	TOP (Transact-SQL) | Microsoft Docs
·	SELECT Clause (Transact-SQL) | Microsoft Docs


workspace111118 (10 occurrences)
Procedure dbo CRDF_GetConvertedAcatDatas
TOP 1 @ line 235, col 49
Procedure dbo CRDF_Template_Delete
TOP 1000000 @ line 140, col 12
Procedure dbo CRDF_Workflow_GetAllScopeChildren
TOP 1 @ line 72, col 11
TOP 1 @ line 185, col 11
TOP 1 @ line 256, col 11
TOP 1 @ line 325, col 11
Procedure dbo DuplicateWorkspace_Custom_Struct
TOP 1 @ line 161, col 49
Procedure dbo FreeAnalysis_CreateDatas
TOP 1 @ line 130, col 9
TOP 1 @ line 215, col 42
TOP 1 @ line 216, col 46
Procedure dbo GetConvertedDatas
TOP 1 @ line 105, col 49
TOP 1 @ line 116, col 41
top 1 @ line 185, col 53
Procedure dbo GetInputFormsLockedData
TOP 1 @ line 144, col 46
Procedure dbo GetIsDeletableQualidocs
TOP 1 @ line 46, col 8
Procedure dbo GetListRefData
TOP 1 @ line 81, col 36
TOP 1 @ line 86, col 36
TOP 1 @ line 255, col 33
TOP 1 @ line 260, col 33
Procedure dbo Workflow_GetChainLink
TOP 1 @ line 95, col 10
		


 
 	Remove references to undocumented system tables
Description
Many system tables that were undocumented in prior releases have changed or no longer exists, therefore, using these tables may cause errors after upgrading to SQL Server 2008 or above.
Recommendation
SQL Server Upgrade Advisor and SQL Books Online may contain documentation for equivalent tables.
References
·	Deprecated Database Engine Features in SQL Server 2016 | Microsoft Docs
·	Breaking Changes to Database Engine Features in SQL Server 2012


workspace111118 (1 occurrences)
Procedure dbo Struct_CreateView
sysobjects @ line 33, col 19
		


 
 	Column aliases in ORDER BY clause cannot be prefixed by table alias
Description
In SQL Server 2005 or later, column aliases in the ORDER BY clause cannot be prefixed by the table alias. For example, the following query executes in SQL Server 2000, but returns an error in SQL Server 2008:

SELECT FirstName AS f, LastName AS l
FROM Person.Contact p
ORDER BY p.l

The SQL Server 2008 Database Engine does not match p.l in the ORDER BY clause to a valid column in the table.
Recommendation
Modify queries that use column aliases prefixed by table aliases in the ORDER BY clause in either of the following ways:

- Do not prefix the column alias in the ORDER BY clause, if possible.
- Replace the column alias with the column name(s).
References
·	Column aliases in ORDER BY clause cannot be prefixed by table alias
·	Tibor Karaszi : Why can't we have column alias in ORDER BY?

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (5 occurrences)
Procedure dbo GetIsDeletableQualidocs
V1.QUALIDOC_ID @ line 100, col 106
Procedure dbo GetTemplateListCalculation
R1.Country @ line 102, col 11
R1.Entity @ line 102, col 23
Procedure dbo GetTemplateListControl
R1.Country @ line 81, col 11
Procedure dbo GetTemplateListInputForm
R1.Country @ line 121, col 11
R1.Department @ line 121, col 23
Procedure dbo GetTemplateListReporting
R1.Country @ line 114, col 11
R1.Entity @ line 114, col 23
R1.SubProcess @ line 114, col 34
		


 
 	ORDER BY specifies integer ordinal
Description
This rule checks stored procedures, functions, views and triggers for use of ORDER BY clause specifying ordinal column numbers as sort columns. A sort column can be specified as a nonnegative integer representing the position of the name or alias in the select list, but this is not recommended. An integer cannot be specified when the order_by_expression appears in a ranking function. A sort column can include an expression, but when the database is in SQL 90 compatibility mode or higher, the expression cannot resolve to a constant.
Recommendation
Specify the sort column as a name or column alias rather than hard coding the ordinal.
References
·	Aaron Bertrand : Bad habits to kick : ORDER BY ordinal

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (8 occurrences)
Procedure dbo CRDF_Entity_GetColumnData
order by 2 @ line 24, col 56
Function dbo CRDF_Struct_Column
order by 2 @ line 25, col 56
Procedure dbo CRDF_Workflow_GetExpandedWorkflow
order by 1 @ line 31, col 3
Procedure dbo CRDF_Workflow_GetItems
order by 1,3,5 @ line 44, col 3
Procedure dbo CRDF_Workflow_GetTargetTemplates
order by 2 @ line 47, col 2
Procedure dbo CRDF_Workflow_GetTemplateDependencies
order by 1,3,5 @ line 144, col 3
order by 1,3,5 @ line 255, col 2
Procedure dbo GetInputFormsData
ORDER BY 3 DESC, 2 ASC,1 ASC @ line 244, col 3
Procedure dbo GetInputFormsDataWithPivot
ORDER BY 3 DESC, 2 ASC,1 ASC @ line 257, col 3
		


 
 	Unqualified Joins
Description
SQL Server normally handles 'old-style' join syntax quite well in most cases. However, in certain rare conditions, the use of an 'unqualified' join syntax can cause SQL Server to get confused. In some cases, this can lead to the infamous 'missing join predicate' warning in Profiler. More importantly, in those cases, it can cause extremely poor query performance. Some 'old-style' join syntax does not work on SQL Server 2005 and above.
Recommendation
The usage of explicit JOIN syntax is recommended in all cases with the JOIN predicates as well.
References
·	Missing Join Predicate Event Class | Microsoft Docs
·	Deprecation of "Old Style" JOIN Syntax: Only A Partial Thing – Ward Pond's SQL Server blog
·	The old INNER JOIN syntax vs. the new INNER JOIN syntax - SQLServerCentral
·	No Join Predicate - Grant Fritchey
·	SQL Server Upgrade Advisor: Considerations when upgrading from SQL 2000 to SQL 2012 – Premier Field Engineering Developer Blog
·	Discontinued Database Engine Functionality in SQL Server 2005
·	FROM (Transact-SQL) | Microsoft Docs
·	Visual Representation of SQL Joins - CodeProject

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (1 occurrences)
Procedure dbo GetEntitySensibilityByCountry
from #temp, [dbo].[InputF...iew] vw @ line 49, col 1
		


 
 	FOR XML AUTO queries return derived table references in 90 or later compatibility modes
Description
When the database compatibility level is set to 90 or later, FOR XML queries that execute in AUTO mode return references to derived table aliases. When the compatibility level is set to 80, FOR XML AUTO queries return references to the base tables that define a derived table. For example, the following query, which includes a derived table, produces different results under compatibility levels 80, 90, or later:

SELECT * FROM 
   (SELECT a.id AS a, b.id AS b 
    FROM Test a JOIN Test b ON a.id=b.id) AS DerivedTest FOR XML AUTO;

Under compatibility level 80, the query returns the following results. The results reference the base table aliases a and b of the derived table instead of the derived table alias.

 <a a="1"><b b="1"/></a></li><a a="2"><b b="2"/></a></li>

Under compatibility level 90 or later, the query returns references to the derived table alias DerivedTest instead of to the derived table's base tables.

 <DerivedTest a="1" b="1"/><DerivedTest a="2" b="2"/>
Recommendation
Modify your application as required to account for the changes in results of FOR XML AUTO queries that include derived tables and that run under compatibility level 90 or later.
References
·	FOR XML AUTO queries return derived table references in 90 or later compatibility modes


workspace111118 (1 occurrences)
Procedure dbo GetInputFormsDataWithPivot
AUTO @ line 268, col 145
		


Inventory

	
 	List all instances of table variable usage
Description
Table variables are not supported in the SQL Server optimizer's cost-based reasoning model. Therefore, they should not be used when cost-based choices are required to achieve an efficient query plan. Plan choices may not be optimal or stable when a table variable contains a large amount of data. Also, queries that modify table variables do not generate parallel query execution plans. Finally, Indexes cannot be created explicitly on table variables, and no statistics are kept on table variables.
Recommendation
Do not use table variables to store large amounts of data (more than 100 rows). Consider rewriting such queries to use temporary tables or use the USE PLAN query hint to ensure the optimizer uses an existing query plan that works well for your scenario.
References
·	table (Transact-SQL) | Microsoft Docs
·	11.0 Temporary Tables, Table Variables and Recompiles – SQL Programmability & API Development Team Blog
·	DECLARE @local_variable (Transact-SQL) | Microsoft Docs


workspace111118 (9 occurrences)
Procedure dbo CRDF_GetQRT
DECLARE @PHY_DEP TABLE (...ULL
 ) @ line 71, col 2
Procedure dbo CRDF_SwitchQRTVersionSIX
DECLARE @SIXTABLE TABLE( ...R(100)) @ line 51, col 2
DECLARE @SHEETTABLE TABLE...(100)) @ line 169, col 4
Function dbo GetAllSensibilitiesFiltersByInputFormScope
DECLARE  @Sensibilities T...r(200)) @ line 43, col 2
DECLARE @AllFilters TABLE...r(200)) @ line 54, col 2
Procedure dbo GetInputFormsSensiLockRules
DECLARE @TEMPTABLE TABLE ...]) 
 ) @ line 45, col 2
DECLARE @TEMPRULE TABLE (... ) 
 ) @ line 66, col 2
Procedure dbo GetValueFromTransco
DECLARE  @TMP_LST_VAR TAB...)
   ) @ line 53, col 2
DECLARE  @TMP_ENTITY TABL...
    ) @ line 78, col 2
Procedure dbo Transco_InitFILTERS
DECLARE  @Tmp_LST_VAR TAB...c
   ) @ line 31, col 2
Procedure dbo Transco_Lnk_Val_Update
DECLARE  @RELATE_TEMPLATE...)
  ) @ line 108, col 3
Procedure idr CreateFeedProtection
DECLARE @MyTableEntityVar... NULL); @ line 76, col 2
Procedure idr GetInputFormNonLockedRows
DECLARE @MyTableVar TABLE...NT
 ); @ line 33, col 2
		


 
 	List all cross database object references
Description
Inventory all instances of three-part naming in table / executable procedure references which indicate cross-database or even cross-server object usage. This pattern can represent a blocker to use some High Availability features. Also, makes migration more complex.
Recommendation
Use this pattern only when is really necessary.

workspace111118 (44 occurrences)
Batch  Adhoc batch @ line 9 (IF (1 = FULLTEXTSERVICEPROPE
[workspace111118].[dbo].[...atabase] @ line 3, col 6
Procedure dbo CRDF_StructTableFixedForSSRS
MASTERWIND..LST_VARFORMAT @ line 35, col 15
MASTERWIND..LST_TEMPLATETYPE @ line 40, col 15
Procedure dbo CRDF_Workflow_GetTemplateDependencies
masterwind.dbo.LST_TREATM...NTTYPE @ line 60, col 14
masterwind.dbo.LST_TREATM...TTYPE @ line 176, col 14
Procedure dbo GetAdminTemplates
masterwind.dbo.LST_TEMPLA...TETYPE @ line 43, col 13
masterwind.dbo.LST_TEMPLA...TETYPE @ line 76, col 13
Procedure dbo GetDataSummary
masterwind.dbo.LNK_USERWO...KSPACE @ line 45, col 14
masterwind.dbo.LST_USER @ line 46, col 14
Procedure dbo GetIsDeletableQualidocs
masterwind..LNK_SCOPEACTION @ line 53, col 13
masterwind..LNK_SCOPEACTION @ line 63, col 13
masterwind..LNK_SCOPEACTION @ line 72, col 13
Procedure dbo GetTemplateListReporting
masterwind.dbo.LNK_SCOPEACTION @ line 77, col 14
MASTERWIND.DBO.LNK_SCOPEA...CTION @ line 107, col 14
Trigger dbo switchTemplateVersion
MASTERWIND..LST_VARFORMAT @ line 104, col 15
MASTERWIND..LST_VARFORMAT @ line 105, col 15
Procedure idr CreateFeed
[masterwind]..LST_USER @ line 63, col 7
Procedure idr CreateFeedProtection
[masterwind]..LST_USER @ line 67, col 7
		


 
 	List all instances of WHILE statement usage
Description
WHILE loops which contain statements accessing tables can potentially lead to cursor-like performance semantics.
Recommendation
Carefully review the use of such loops.
References
·	WHILE (Transact-SQL) | Microsoft Docs


workspace111118 (21 occurrences)
Procedure dbo CRDF_Struct_GetData
WHILE @INDEX<@COUNTCOLUMN... 
 END @ line 33, col 2
Procedure dbo CRDF_SwitchQRTVersionSIX
WHILE @INDEXSIX<=@MAXINDE...    END @ line 81, col 6
WHILE @INDEX<=@MAXINDEX
...   END @ line 182, col 6
Procedure dbo CreateFreeAnalysisReporting
WHILE @@FETCH_STATUS = 0 ...ID
END @ line 90, col 1
WHILE @@FETCH_STATUS = 0 ...D
END @ line 112, col 1
WHILE @@FETCH_STATUS = 0 ... 
END @ line 174, col 1
WHILE @@FETCH_STATUS = 0 ...D
END @ line 185, col 1
WHILE @@FETCH_STATUS = 0 ...D
END @ line 233, col 1
Procedure dbo FreeAnalysis_CreateDatas
WHILE @@FETCH_STATUS = 0...
 END @ line 332, col 2
Procedure dbo GetIsDeletableQualidocs
WHILE @@FETCH_STATUS = 0...BL
END @ line 42, col 1
Procedure dbo GetValueFromTransco
WHILE @CPTEUR_TOUR <=  @N...
 END @ line 332, col 2
WHILE @COUNTER_ENTITEFILL...
  END @ line 394, col 3
WHILE @@FETCH_STATUS = 0...   END @ line 474, col 8
Procedure dbo Scope_GetChildrenId
WHILE @@FETCH_STATUS = 0... 
 END @ line 84, col 2
Procedure dbo Transco_InitFILTERS
WHILE @Cpteur_tour <=  @N...
  END @ line 80, col 3
WHILE @Counter_Filter <= ...   END @ line 137, col 4
while @@FETCH_STATUS = 0 ...   end @ line 187, col 4
while @@FETCH_STATUS = 0 ...   end @ line 208, col 4
Trigger dbo UpdatingRowValue
WHILE (@INDEX<=@ROWCOUT)...
   END @ line 43, col 4
Procedure dbo Workflow_UpdateChildren
WHILE @@FETCH_STATUS = 0...
  END @ line 110, col 3
		


 
 	List all input parameters of type XML
Description
Usually, XML can contain a large rowset. Using this type as a parameter can lead to performance problems.
Recommendation
Evaluate if it is necessary to use the XML as a parameter, since sometimes you just need some part of that information and not all of it. If it is required, pass it in multiple rows, in the form of a XML input parameter. You can also evaluate the usage of table valued parameters, which are supported in SQL Server 2008 and above.
References
·	Specifying XML Values as Parameters
·	Table-Valued Parameters (Database Engine)
·	Use Table-Valued Parameters (Database Engine) | Microsoft Docs
·	Table-Valued Parameters


workspace111118 (2 occurrences)
Procedure dbo GetInputFormsData
xml @ line 48, col 24
Procedure dbo GetInputFormsDataWithPivot
xml @ line 47, col 24
		


Logical Expressions

	
 	DELETE statement without a WHERE clause
Description
A missing WHERE clause on a large or frequently executed, mid-sized result set can lead to query performance issues and excessive table scanning.
Recommendation
Check if this is intentional or an accidental construct. In some cases, DELETE without WHERE clauses can be replaced with a TRUNCATE TABLE statement for improved performance.
References
·	DELETE (Transact-SQL)
·	TRUNCATE TABLE (Transact-SQL) | Microsoft Docs


workspace111118 (10 occurrences)
Procedure dbo CRDF_Template_Delete
DELETE Q FROM APP_QRT Q I...HEET_ID @ line 77, col 3
DELETE PD FROM APP_PHYSIC...heetSrc @ line 80, col 3
DELETE PD FROM APP_PHYSIC...heetDep @ line 83, col 3
DELETE P FROM LNK_PERIMET...OPE_ID] @ line 98, col 3
DELETE VH FROM LNK_VAL_HI...EET_ID @ line 126, col 4
 ... (note: only 5 of 17 findings shown)
Procedure dbo CRDF_Template_DeleteReporting_ManageKo
DELETE C FROM LNK_CELLULE...HEET_ID @ line 31, col 3
DELETE S FROM APP_SHEET S...EET_ID] @ line 39, col 3
Procedure dbo CRDF_Workflow_GetAllScopeChildren
WITH  q AS
        (
  ...OM    q @ line 76, col 2
DELETE FROM #TMP_SCOPE @ line 135, col 6
WITH  q AS
        (
  ...M    q @ line 190, col 2
WITH  q AS
        (
  ...M    q @ line 261, col 2
WITH  q AS
        (
  ...M    q @ line 330, col 2
Procedure dbo GetValueFromTransco
delete  from #GenerateFilter @ line 335, col 2
DELETE FROM #TMP_ENTITETE...ILE_ID @ line 377, col 3
Procedure dbo Scope_GetChildrenId
DELETE FROM #TMP_SCOPE @ line 99, col 6
Procedure dbo Transco_Lnk_Val_Update
DELETE  [dbo].TRANSCO_LNK...VAL tlv @ line 50, col 4
Procedure dbo UnlockWorkflowElements
DELETE LS
 FROM LNK_LOCK...KED_ID @ line 107, col 2
Procedure dbo Workflow_UpdateChildren
DELETE FROM #TMP_SCOPE @ line 128, col 7
Procedure ssis CRDF_Transco_Insert_Transco
delete from [LNK_TRANSCOSOURCE] @ line 59, col 2
delete from [LNK_TRANSCOF...ILTER] @ line 151, col 2
Procedure ssis War_Insert_Data
delete from Ssis.[War_Par...ontext] @ line 93, col 2
DELETE FROM SSIS.[WAR_NAM...NTION] @ line 177, col 2
delete from [dbo].[APP_PH...ENCE]; @ line 241, col 1
		


 
 	ORDER BY has no guarantees in the context of an INSERT
Description
When used together with an INSERT statement to insert rows from another source, the ORDER BY clause does not guarantee the rows are inserted in the specified order. Potential to have higher cost plan with no logical guarantees on insert order.

Also note that in SQL Server 2000, the presence of ORDER BY along with an IDENTITY function does not guarantee that the identity values will be in the desired sequence.

Note: this issue will not be triggered if a TOP is specified in the corresponding SELECT query for the INSERT.
Recommendation
Reevaluate why the ORDER BY is used.
References
·	ORDER BY Clause (Transact-SQL) | Microsoft Docs


workspace111118 (8 occurrences)
Function dbo CRDF_Struct_Column
select  distinct v.BASICV...er by 2 @ line 24, col 2
Procedure dbo CreateInputFormCompositionAndClosePEFeeds
SELECT
  @uploadId, -- a...ROW ASC @ line 48, col 2
Function dbo GetInputFormColumnMappingBetweenTemplateVersions
SELECT   
  otherVersion...NBR ASC @ line 42, col 2
Procedure dbo GetInputFormsData
SELECT rowNumber, 'dbo', ...D] ASC @ line 168, col 2
SELECT DISTINCT V.ROW_NB,...y] ASC @ line 177, col 2
SELECT DISTINCT V.ROW_NB,...ROW_NB @ line 190, col 3
SELECT DISTINCT val.ROW_N...ROW_NB @ line 201, col 3
Procedure dbo GetInputFormsDataWithPivot
SELECT rowNumber, 'dbo', ...D] ASC @ line 164, col 2
SELECT DISTINCT V.ROW_NB,...y] ASC @ line 172, col 2
SELECT DISTINCT V.ROW_NB,...ROW_NB @ line 185, col 3
SELECT DISTINCT val.ROW_N...ROW_NB @ line 196, col 3
Procedure dbo GetValueFromTransco
select VARIABLE_ID,SOURCE...ROW_NB @ line 172, col 2
SELECT @Itemsheetid,COL_O...ER_NBR @ line 431, col 4
Procedure dbo Transco_InitFILTERS
SELECT  val.BASICVAL_LBL ...sPivot @ line 109, col 4
Procedure ssis Matrix_InsertData
SELECT ag.GROUP_ID, lf.FU...ion_ID @ line 268, col 3
		


 
 	COUNT will exclude NULL values
Description
The usage of COUNT(ColumnName) when ColumnName is a NULLable column could return an unexpected value, since aggregate functions exclude NULLs. Also, this can hurt performance if the optimizer cannot use the smallest (non-filtered index) to get a row count.
Recommendation
Verify if the logic is correct and that the application is returning the expected value.
References
·	SQL Tip: COUNTing NULL values – Benjamin's blog
·	COUNT (Transact-SQL) | Microsoft Docs


workspace111118 (2 occurrences)
View dbo ScopeLockStatusView
C.[sensibility test] @ line 47, col 30
Procedure idr CreateFeedProtection
[Name of Entity_ID] @ line 86, col 33
		


 
 	Nesting a subquery within another is not recommended
Description
Nested subqueries can cause performance degradation and complexity of maintainability.
Recommendation
Instead, replace by using JOIN statement.
References
·	The "Nested WHERE-IN" SQL Anti-Pattern

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (9 occurrences)
Procedure dbo CRDF_GetQRT
(
        SELECT [VERSIO...     ) @ line 120, col 8
(
      SELECT [VERSION_...
   ) @ line 232, col 13
Procedure dbo CRDF_SwitchQRTVersionSIX
(SELECT SHEET_ID FROM APP...BLE)) @ line 200, col 31
(SELECT SHEET_ID FROM APP...BLE)) @ line 201, col 27
Procedure dbo CRDF_Workflow_GetScopeParentReporting
( --select the id sheets ...le
  ) @ line 73, col 2
(
       --select all va...      ) @ line 76, col 7
Procedure dbo CRDF_Workflow_GetTemplateDependencies
( --select the id sheets ...e
  ) @ line 126, col 2
(
       --select all va...     ) @ line 129, col 7
Procedure dbo CRDF_Workspace_GetSteeringToolsData
(select isnull(usr.firstN..._ID)  ) @ line 35, col 2
Procedure dbo Transco_InitFILTERS
(select  STRUCT_LBL from ...ID) ) @ line 192, col 34
Procedure ssis Matrix_InsertData
(SELECT LU.[USER_ID] --,A...
   ) @ line 135, col 23
(SELECT AG.GROUP_ID
    ...     ) @ line 252, col 9
Procedure ssis ProfilsMatrix_InsertData
(select SCOPE_ID from LNK...   )) @ line 102, col 30
Procedure ssis War_InsertErrorLogs
(SELECT '#!' + LTRIM(RTRI...('')) @ line 193, col 49
(SELECT '#!' + LTRIM(RTRI...('')) @ line 205, col 51
(SELECT '#!'+ 'Row '+ LTR...('')) @ line 219, col 50
(select distinct [SIX_LBL...    ) @ line 221, col 47
(SELECT '#!' + LTRIM(RTRI...('')) @ line 241, col 46
		


 
 	Statements using <> or != syntax
Description
"NOT" logic can limit overall query performance. Furthermore, it introduces additional contention because it often results in evaluation of each row (index scans) in order to determine if a search condition is met for the query.
Recommendation
Avoid using "<>" in search expressions. Instead, elect to use inclusive "equals" and range queries. In addition, construct your WHERE clause to reference high-cardinality, indexed columns. It is not always possible to rewrite this type of logical expression. However, if you are experiencing excessive scanning and I/O issues, rewriting the search conditions can help improve query performance significantly. Try to find more inclusive conditions for filtering the result set. The key objective is to reduce the number of rows that must be evaluated by SQL Server. Focus on search conditions that affect as few rows as possible and evaluate the query execution plan to ensure that SQL Server is using index seeks whenever possible.
References
·	Predicates | Microsoft Docs
·	Search Condition (Transact-SQL) | Microsoft Docs
·	Inequality predicates do not trigger scans – Mohamed Sharaf's Blog


workspace111118 (25 occurrences)
Procedure dbo CRDF_GetConvertedAcatDatas
[SENSIBILITY TEST]!=@SENS...CTION @ line 334, col 11
Procedure dbo CRDF_SwitchQRTVersionSIX
TEMPLATE_ID <> @CORRESPON...TE_ID @ line 108, col 13
SHEET_LBL!='DATA_SUMMARY' @ line 174, col 10
Procedure dbo CRDF_Workflow_GetScopeParentReporting
APt.TEMPLATETYPE_ID<>1 @ line 46, col 45
Apt.TEMPLATEMODELE_ID<>@i...emplate @ line 90, col 6
Function dbo GetAllSensibilitiesFiltersByInputFormScope
[SENSIBILITY TEST]!=S.Sen...ibility @ line 60, col 8
Procedure dbo GetArchivedTemplateFile
templatefile.UPLOAD_DATE ...  )
 ) @ line 37, col 8
Procedure dbo GetInputFormsData
@currentVersionOfTheTempl...N_LBL @ line 116, col 65
Procedure dbo GetInputFormsLockedData
TM.VERSION_LBL <> TF.VERS...ON_LBL @ line 56, col 65
Field <> '' @ line 160, col 63
f.Field <> '' @ line 175, col 87
Procedure idr SetFeedAsValid
OldFeeds.FEED_ID <> @FeedId @ line 50, col 8
Procedure ssis Matrix_CleanTempData
Valeur !='' @ line 43, col 12
Valeur !='' @ line 70, col 11
Procedure ssis Matrix_InsertData
TDS1.LINE<>1 @ line 125, col 11
LINE <>1 @ line 153, col 10
Line <>1 @ line 180, col 9
Line <> 1 @ line 208, col 9
PROFIL_ID <> ap.PROFIL_ID @ line 216, col 15
 ... (note: only 5 of 7 findings shown)
		


 
 	Statements using NOT IN syntax
Description
"NOT" logic can limit overall query performance. Furthermore, it introduces additional contention because it often results in evaluation of each row (index scans) in order to determine if a search condition is met for the query.
Recommendation
Avoid using such conditions in search expressions. Instead, elect to use inclusive "equals" and range queries. In addition, construct your WHERE clause to reference high-cardinality, indexed columns. It is not always possible to rewrite this type of logical expression. However, if you are experiencing excessive scanning and I/O issues, rewriting the search conditions can help improve query performance significantly. Try to find more inclusive conditions for filtering the result set. The key objective is to reduce the number of rows that must be evaluated by SQL Server. Focus on search conditions that affect as few rows as possible and evaluate the query execution plan to ensure that SQL Server is using index seeks whenever possible.
References
·	Predicates | Microsoft Docs
·	Search Condition (Transact-SQL) | Microsoft Docs
·	Inequality predicates do not trigger scans – Mohamed Sharaf's Blog


workspace111118 (18 occurrences)
Procedure dbo CRDF_SwitchQRTVersionSIX
SHEET_LBL NOT IN (SELECT ...ABLE) @ line 200, col 98
SHEET_LBL NOT IN (SELECT ...ABLE) @ line 201, col 94
Procedure dbo CRDF_Workflow_GetAllScopeChildren
SCOPE_ID not in (SELECT S...ESSED) @ line 168, col 8
SCOPE_ID not in (SELECT S...ESSED) @ line 175, col 8
SCOPE_ID not in (SELECT S...ESSED) @ line 248, col 8
lncHeritage.VARIABLE_ID n...RCE] ) @ line 293, col 9
SCOPE_ID not in (SELECT S...ESSED) @ line 311, col 8
 ... (note: only 5 of 6 findings shown)
Procedure dbo CRDF_Workflow_GetScopeChildrenReporting
lncHeritage.VARIABLE_ID n...RCE] ) @ line 79, col 32
Procedure dbo CRDF_Workflow_GetScopeParentReporting
lnc.VARIABLE_ID not in (s...RCE] ) @ line 85, col 13
Procedure dbo CRDF_Workflow_GetTargetTemplates
lnc.VARIABLE_ID not in (s...URCE] ) @ line 37, col 9
Procedure dbo CRDF_Workflow_GetTemplateDependencies
lnc.VARIABLE_ID not in (s...CE] ) @ line 138, col 13
lncHeritage.VARIABLE_ID n...RCE] ) @ line 242, col 9
Procedure dbo FreeAnalysis_GetDatasByRow
COLUMN_NAME NOT IN ('ROW_...Apply') @ line 38, col 7
Trigger dbo GrantAdminRights
FUNCTION_ID NOT IN (SELEC...roupId) @ line 25, col 8
Procedure ssis Matrix_CleanTempData
Colonne NOT IN (SELECT co...      ) @ line 39, col 6
Colonne NOT IN (SELECT Co...      ) @ line 66, col 6
Procedure ssis Matrix_InsertData
[UID] NOT IN (SELECT UID ...USER]) @ line 100, col 8
TDS.COLONNE NOT IN ('F1',...'F2') @ line 111, col 13
VALEUR NOT IN (SELECT GRO...ROUP) @ line 112, col 13
COLONNE NOT IN ('F1','F2') @ line 259, col 16
Colonne NOT IN ('F1', 'F2') @ line 274, col 13
 ... (note: only 5 of 6 findings shown)
		


 
 	Statements using NOT LIKE syntax
Description
"NOT" logic can limit overall query performance. Furthermore, it introduces additional contention because it often results in evaluation of each row (index scans) in order to determine if a search condition is met for the query.
Recommendation
Avoid using such conditions in search expressions. Instead, elect to use inclusive "equals" and range queries. In addition, construct your WHERE clause to reference high-cardinality, indexed columns. It is not always possible to rewrite this type of logical expression. However, if you are experiencing excessive scanning and I/O issues, rewriting the search conditions can help improve query performance significantly. Try to find more inclusive conditions for filtering the result set. The key objective is to reduce the number of rows that must be evaluated by SQL Server. Focus on search conditions that affect as few rows as possible and evaluate the query execution plan to ensure that SQL Server is using index seeks whenever possible.
References
·	Predicates | Microsoft Docs
·	Search Condition (Transact-SQL) | Microsoft Docs
·	Inequality predicates do not trigger scans – Mohamed Sharaf's Blog
·	LIKE (Transact-SQL) | Microsoft Docs


workspace111118 (3 occurrences)
Procedure dbo CRDF_Scope_Get_TreeViewElement
APP_T.TEMPLATEMODELE_LBL ...'%ALL%' @ line 65, col 9
DEPARTMENT_LBL  NOT LIKE ...%ALL%' @ line 76, col 84
DEPARTMENT_LBL  NOT LIKE ....R.%' @ line 76, col 121
APP_T.TEMPLATEMODELE_LBL ...%ALL%' @ line 81, col 35
APP_T.TEMPLATEMODELE_LBL ...%ALL%' @ line 93, col 35
Procedure dbo GetListRefData
@filtre NOT Like '%n.r%' @ line 282, col 12
@filtre NOT Like '%n.r%' @ line 289, col 12
Procedure ssis Matrix_InsertError
F4 NOT LIKE '%@%.%' @ line 110, col 9
		


 
 	Procedure or Function without exception handling
Description
Coding standardization.
Recommendation
Follow your organization's coding standards for error handling. In SQL 2005 and above, TRY...CATCH constructs are the preferred way to do this.
References
·	TRY...CATCH (Transact-SQL) | Microsoft Docs


workspace111118 (150 occurrences)
Procedure dbo Basic_GetStructReferentials
CREATE PROCEDURE [dbo].[B...Id)
END @ line 4, col 1
Procedure dbo CRDF_Scope_Insert
CREATE PROCEDURE [dbo].[C...1.0
END @ line 4, col 1
Procedure dbo DuplicateWorkspace_Custom_Struct
CREATE PROCEDURE [dbo].[D...;')
END @ line 4, col 1
Procedure dbo GetSensibility
CREATE PROCEDURE [dbo].[G...


END @ line 4, col 1
Procedure dbo GetSensibilityAction
CREATE PROCEDURE [dbo].[G...st)
END @ line 4, col 1
Procedure dbo GetSensibilityByEntity
CREATE PROCEDURE [dbo].[G...yId
END @ line 4, col 1
Procedure dbo GetSubHierarchicalEntities
CREATE PROCEDURE [dbo].[G... 

END @ line 4, col 1
Procedure dbo Struct_GetBasicReferentials
CREATE PROCEDURE [dbo].[S...Id)
END @ line 4, col 1
Procedure dbo Struct_GetTemplates
CREATE PROCEDURE [dbo].[S...Id)
END @ line 4, col 1
Procedure dbo Struct_GetVariableList
CREATE PROCEDURE [dbo].[S..._NB
END @ line 4, col 1
		


 
 	ORDER BY has no guarantees in a SELECT INTO context
Description
When used together with a SELECT...INTO statement to insert rows from another source, the ORDER BY clause does not guarantee the rows are inserted in the specified order. Potential to have higher cost plan with no logical guarantees on insert order.

Also note that in SQL Server 2000, the presence of ORDER BY along with an IDENTITY function does not guarantee that the identity values will be in the desired sequence.
Recommendation
Reevaluate why the ORDER BY is used.
References
·	ORDER BY Clause (Transact-SQL) | Microsoft Docs


workspace111118 (2 occurrences)
Procedure dbo CreateFreeAnalysisReporting
#TEMPENTTGROUP @ line 66, col 131
#TEMPENTT @ line 75, col 131
Procedure dbo FreeAnalysis_CreateDatas
#ExchangeRatesDimensions @ line 223, col 40
		


 
 	Usage of SELECT * observed
Description
The SELECT * syntax is impacted by schema changes or ordinal changes.
Recommendation
Please use explicit column list as far as possible.
References
·	SELECT (Transact-SQL) | Microsoft Docs


workspace111118 (19 occurrences)
Procedure dbo CRDF_EntityCharacteristics_Delete
* @ line 33, col 23
Procedure dbo CRDF_GetQRT
* @ line 92, col 30
Procedure dbo CRDF_Workflow_GetAllScopeChildren
* @ line 78, col 22
* @ line 192, col 22
* @ line 263, col 22
* @ line 332, col 22
Procedure dbo CRDF_Workflow_GetExpandedWorkflow
* @ line 37, col 10
* @ line 43, col 9
Procedure dbo CRDF_Workspace_GetSteeringToolsData
* @ line 54, col 10
Procedure dbo FreeAnalysis_CreateDatas
* @ line 163, col 22
* @ line 326, col 37
Procedure dbo GetEntitySensibilityByCountry
* @ line 52, col 8
Procedure dbo GetListRefData
* @ line 80, col 39
* @ line 85, col 39
* @ line 254, col 39
* @ line 259, col 39
Procedure dbo GetValueFromTransco
* @ line 298, col 25
* @ line 425, col 26
* @ line 448, col 26
Procedure idr CreateFeedProtection
* @ line 81, col 13
		


 
 	SELECT TOP (1) statement without ORDER BY could cause wrong results
Description
Using TOP (1) you should guarantee result order of lines to avoid wrong result set
Recommendation
Whenever possible use ORDER BY with TOP(1) avoiding undesirable result sets, or change query code to use EXISTS instead.
References
·	TOP (Transact-SQL) | Microsoft Docs
·	SELECT Clause (Transact-SQL) | Microsoft Docs
·	SQL: If Exists Update Else Insert – Jeremiah Clark's Blog


workspace111118 (4 occurrences)
Procedure dbo DuplicateWorkspace_Custom_Struct
SELECT TOP 1 TEMPLATEMODE...peALL @ line 161, col 42
Trigger dbo switchTemplateVersion
SELECT top(1) ISnull(S.TE...TIVE=1 @ line 49, col 21
Trigger dbo Trg_ExtFile_Transco_LNK_VAL_UPDATING_ROWS
SELECT top(1) @TypeTempla...File_Id @ line 47, col 3
Procedure dbo Workflow_GetChainLink
SELECT TOP 1 SC.SCOPE_ID ...MENT_ID @ line 95, col 3
		


 
 	SELECT used to assign to a variable
Description
If a SELECT statement from a base table is used to assign values to a variable and that statement happens to access multiple rows, then the results might be unpredictable.
Recommendation
Check @@ROWCOUNT after such statements to ensure a single value was returned.
References
·	@@ROWCOUNT (Transact-SQL) | Microsoft Docs
·	SELECT Clause (Transact-SQL) | Microsoft Docs


workspace111118 (28 occurrences)
Procedure dbo CRDF_EntityCharacteristics_Delete
@ENTITY=BASICVAL_ID @ line 23, col 9
Procedure dbo CRDF_GetLastExportVersion
@version=[VERSION_UPLOAD_...XPORT] @ line 34, col 17
Procedure dbo CRDF_Struct_GetData
@STRUCTNAME=STRUCT_LBL @ line 26, col 9
@COLUMN_NAME=COLUMN_NAME @ line 35, col 10
Procedure dbo CRDF_Workflow_GetTemplateDependencies
@templateModel=APT.TEMPLA...ELE_LBL @ line 25, col 8
Procedure dbo GetInputFormsLockedData
@uploadId = TF.TEMPLATEFILE_ID @ line 53, col 9
Procedure dbo RemoveProphetEnterpriseData
@uploadId = TF.TEMPLATEFILE_ID @ line 80, col 9
@peRangeFirst=RANGE_FIRST_ROW @ line 109, col 10
Trigger dbo switchTemplateVersion
@TEMPTTYPEID = TEMPLATETYPE_ID @ line 31, col 10
@ACTIVATED = IS_ACTIFTEMP...MODELE @ line 32, col 10
@TEMPLABEL = TEMPLATEMODE...LE_LBL @ line 33, col 10
@TEMPID = TEMPLATEMODELE_ID @ line 34, col 10
Trigger dbo Trg_ExtFile_Transco_LNK_VAL_UPDATING_ROWS
@str_UPLOAD_DATE = upLign...AD_DATE @ line 28, col 9
Trigger dbo UpdatingRowValue
@STRUCT_LBL=STRUCT_LBL @ line 45, col 12
Procedure idr WS_InsertPEDataToLNK_VAL
@Scenario = SCENARIO_LBL @ line 81, col 10
		


 
 	SELECT or SET used to assign value to a variable from a subquery
Description
A SELECT or SET statement is used to assign a value to a variable. If that value comes from a subquery which might return more than 1 row then Msg 512 (Subquery returned more than 1 value) will be returned by SQL Server.
Recommendation
Catch such errors using error handling (TRY...CATCH) and look at the logical design of the query to avoid this kind of issue.
References
·	TRY...CATCH (Transact-SQL) | Microsoft Docs
·	Technical: Microsoft – SQL Server – Error – “Auto Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, , >= or when the subquery is used as an expression.” – Msg 512, Level 16, State 1 | Learning in the Open

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).

workspace111118 (21 occurrences)
Procedure dbo CRDF_Entity_GetColumnData
set @idLBL=(select VARIAB...@Label) @ line 21, col 2
Procedure dbo CRDF_GetCodeCountryIso
set @codeIso=(SELECT 
  ...ntryId) @ line 21, col 2
Procedure dbo CRDF_Scope_Insert
set @templateType =(selec...ateLbl) @ line 22, col 2
Procedure dbo CRDF_SwitchQRTVersionSIX
SET @WINDID=(SELECT SHEET...ETWIND) @ line 91, col 9
Procedure dbo GetValueFromTransco
SET @COUNTER_ENTITEFILLE ...YCODE) @ line 389, col 3
SET @SENSIBILITYACTION= (..._TEST) @ line 419, col 7
set @sensiFilteredQuery=(...CTION) @ line 504, col 3
Procedure dbo OPTM_Shrinkfile
SET @dbName=
     (
   ...      ) @ line 27, col 6
Procedure dbo RemoveProphetEnterpriseData
@Wind_Locked_BeginIndex  ...taID) @ line 114, col 10
@Wind_Row_Count = (SELECT...taID) @ line 115, col 10
Procedure dbo Shrink_log_Workspace
set @dbName=
 (
   sele...G'
  ) @ line 28, col 2
Trigger dbo switchTemplateVersion
@OLDID = (SELECT DISTINCT...LABEL) @ line 37, col 10
@OLDID = (SELECT DISTINCT...LABEL) @ line 55, col 11
Procedure idr WS_InsertPEDataToLNK_VAL
SET @Wind_Locked_BeginInd...ataID) @ line 114, col 4
SET @Wind_Row_Count = (SE...ataID) @ line 115, col 4
		


 
 	SELECT statement without a WHERE clause
Description
A missing WHERE clause on a large or frequently executed, mid-sized result set can lead to query performance issues and excessive table scanning.
Recommendation
Evaluate how the query is used and look for opportunities to reduce the result set. Also consider adding a WHERE clause and associated search conditions. In addition, if a WHERE clause cannot be used, consider whether the TOP keyword or ROW_NUMBER can be used to restrict or page through the dataset.
References
·	ROW_NUMBER (Transact-SQL) | Microsoft Docs
·	TOP (Transact-SQL) | Microsoft Docs
·	SELECT Clause (Transact-SQL) | Microsoft Docs


workspace111118 (5 occurrences)
Function dbo CRDF_Action2ShortName_Table
Select Action_ID,Action_L..._ACTION @ line 33, col 3
View dbo CRDF_Variable_Desc
SELECT     vr.VARIABLE_ID...ROUP_ID @ line 18, col 1
Procedure dbo Struct_CreateAllViews
SELECT     APP_STRUCT.STR..._STRUCT @ line 20, col 2
Trigger dbo UPDATING_ROWS
SELECT @I=COUNT(*) FROM I...SERTED; @ line 22, col 2
SELECT @D=COUNT(*) FROM D...ELETED; @ line 23, col 2
SELECT @STRUCT_LBL=STRUCT...RUCT_ID @ line 29, col 3
SELECT @STRUCT_LBL=APS.ST...RUCT_ID @ line 33, col 3
SELECT @STRUCT_LBL=APS.ST...RUCT_ID @ line 38, col 3
Procedure dbo Workflow_GetChainLink
SELECT TOP 1 SC.SCOPE_ID ...MENT_ID @ line 95, col 3
		


 
 	UPDATE statement without a WHERE clause	
Description
A missing WHERE clause on a large or frequently executed, mid-sized result set can lead to query performance issues and excessive table scanning.		
Recommendation
Check if this is intentional or an accidental construct.		
References
·	UPDATE (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (5 occurrences)		
Procedure dbo GetInputFormsLockedData		
UPDATE SF
 SET [Field] =...Field] @ line 111, col 2
UPDATE #GroupedSensibilit... + ')' @ line 139, col 2		
Procedure dbo Workflow_Initialization_IsUpToDate		
UPDATE APP_TEMPLATEHEADER...ATE = 1 @ line 38, col 2		
Procedure idr GetInputFormNonLockedRows		
UPDATE SF
 SET [Field] =...[Field] @ line 79, col 2
UPDATE #GroupedSensibilit... + ')' @ line 104, col 2		
Procedure ssis Matrix_InsertData		
UPDATE [MASTERWIND].[dbo]...ATE.UID @ line 52, col 1		
Procedure ssis War_Insert_Data		
update APP_SHEET_SIX
  s...d=Null @ line 227, col 3		
		


 
Naming		
		
 	Keywords used as column names	
Description
SQL Server reserves certain keywords for its exclusive use. No user-defined objects or columns in the database should be given a name that matches a reserved keyword.		
Recommendation
Avoid using reserved keywords for user-defined objects and column names. If you identify objects or columns using reserved keywords, rename them to avoid issues with future versions of SQL Server. If you cannot modify the column name immediately, the column must always be referred using delimited identifiers. However, you should still plan to rename the column before updating to a new version of SQL Server.		
References
·	Reserved Keywords (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (15 occurrences)		
Table dbo GCL_Version		
[Date] [datetime] NOT NULL @ line 3, col 2		
Table dbo LNK_NAVIGATION		
[ORDER] [numeric](18, 0) ...NOT NULL @ line 4, col 2		
Table ssis IMPORT_SSIS_LOG		
[OPERATION] [nvarchar](50...NOT NULL @ line 5, col 2
[VALUE] [nvarchar](255) C..._AS NULL @ line 9, col 2		
Table ssis TMP_LOGS		
[order] [int] NOT NULL @ line 6, col 2		
Table ssis TMP_STRUCTSHEETS		
[Alias] [nvarchar](255) C..._AS NULL @ line 5, col 2		
Table ssis TMP_TRANSCO_REQUETE		
[VALUE] [nvarchar](255) C...NOT NULL @ line 6, col 2		
Table ssis TMP_TRANSCO_REQUETE_CTRL		
[VALUE] [nvarchar](255) C...NOT NULL @ line 4, col 2		
Table ssis TMP_TRANSCO_REQUETE_VARIABLE_CTRL		
[VALUE] [nvarchar](255) C...NOT NULL @ line 5, col 2		
Table ssis TMP_TRANSCO_VARIABLE		
[OPERATION] [nvarchar](25...NOT NULL @ line 8, col 2
[CONDITION] [nvarchar](25...NOT NULL @ line 9, col 2		
Table ssis TMP_WORKFLOW		
[operation] [nvarchar](25..._AS NULL @ line 8, col 2		
		


 
 	Single character object names are not recommended	
Description
Single character object names tend to be confusing, as they may cause confusion between object names and aliases.		
Recommendation
It should be named appropriately to clarify object type and its purpose.		
		
workspace111118 (7 occurrences)		
Procedure dbo CRDF_Template_Delete		
Q @ line 77, col 10
P @ line 98, col 10
I @ line 162, col 10
I @ line 163, col 10
C @ line 197, col 11
 ... (note: only 5 of 8 findings shown)		
Procedure dbo CRDF_Template_DeleteReporting_ManageKo		
C @ line 31, col 10
S @ line 39, col 10		
Procedure dbo CRDF_Workflow_GetAllScopeChildren		
q @ line 84, col 10
q @ line 198, col 10
q @ line 269, col 10
q @ line 338, col 10		
Procedure dbo CreateInputFormCompositionAndClosePEFeeds		
F @ line 86, col 9		
Function dbo GetAllSensibilitiesFiltersByInputFormScope		
F @ line 69, col 9		
Procedure idr SetFeedAsValid		
V @ line 46, col 9		
Procedure idr WS_InsertPEDataToLNK_VAL		
F @ line 199, col 10		
		


Performance
	
		
 	EXECUTE statements should specify schema identifier	
Description
The lack of owner-qualification forces SQL Server to perform a second cache lookup and obtain an exclusive compile lock before the program determines that the existing cached execution plan can be reused. Obtaining the lock and performing lookups and other work that is needed to reach this point can introduce a delay for the compile locks that leads to blocking. This is especially true if many users who are not the stored procedure's owner concurrently run the procedure without supplying the owner's name. Be aware that even if you do not see SPIDs waiting for compile locks, lack of owner-qualification can introduce delays in stored procedure execution and cause unnecessarily high CPU utilization.		
Recommendation
When executing a user-defined procedure, we recommend qualifying the procedure name with the schema name. This practice gives a small performance boost, because the Database Engine does not have to search multiple schemas. It also prevents executing the wrong procedure if a database has procedures with the same name in multiple schemas.		
References
·	Description of SQL Server blocking caused by compile locks
·	Execute a Stored Procedure | Microsoft Docs
	
		
workspace111118 (12 occurrences)		
Procedure dbo CRDF_Workflow_GetAllScopeChildren		
Scope_GetParentsId @ line 130, col 33		
Procedure dbo GetInputFormsData		
GetInputFormsLockedData @ line 156, col 7		
Procedure dbo GetInputFormsDataWithPivot		
GetInputFormsLockedData @ line 149, col 7		
Procedure dbo RemoveProphetEnterpriseData		
GetInputFormsData @ line 91, col 7		
Procedure dbo Struct_CreateAllViews		
Struct_CreateView @ line 28, col 8		
Trigger dbo UPDATING_ROWS		
Struct_CreateView @ line 40, col 11		
Trigger dbo UpdatingRowValue		
STRUCT_CREATEVIEW @ line 46, col 10		
Procedure dbo Workflow_Initialization_IsUpToDate		
Workflow_UpdateChildren @ line 66, col 8		
Procedure dbo Workflow_UpdateChildren		
Scope_GetParentsId @ line 120, col 34
Workflow_UpdateChildren @ line 166, col 11
Workflow_UpdateChildren @ line 176, col 11
Workflow_UpdateChildren @ line 185, col 11		
Procedure idr WS_InsertPEDataToLNK_VAL		
GetInputFormsData @ line 85, col 8		
		


 
 	Input parameter is modified inside a procedure	
Description
The execution plan is computed with the input parameter as a baseline. If the actual value of the parameter changes inside the stored procedure, then it may increase the risk of poor performance.		
Recommendation
For best query performance, in some situations you'll need to avoid assigning a new value to a parameter of a stored procedure within the procedure body, and then using the parameter value in a query. The stored procedure and all queries in it are initially compiled with the parameter value first passed in as a parameter to the query. This is sometimes called parameter sniffing. If really needed, consider OPTIMIZE FOR UNKNOWN		
References
·	Don’t change value of that parameter – CSS SQL Server Engineers
·	OPTIMIZE FOR UNKNOWN – a little known SQL Server 2008 feature – SQL Programmability & API Development Team Blog
	
		
workspace111118 (13 occurrences)		
Function dbo CRDF_GetActionScopeProfileTemplate		
@SCOPEACTION @ line 23, col 5
@SCOPEACTION @ line 28, col 10
@SCOPEACTION @ line 29, col 10
@SCOPEACTION @ line 30, col 10
@SCOPEACTION @ line 36, col 10
 ... (note: only 5 of 16 findings shown)		
Procedure dbo CRDF_GetConvertedAcatDatas		
@curentEntityId @ line 155, col 7
@ENTITIESSTRING @ line 180, col 6
@TEMPLATEFILELIST @ line 375, col 10
@entitiesString @ line 488, col 8
@entitiesString @ line 492, col 8		
Procedure dbo CRDF_GetConvertedsourceScopes		
@LstScopes @ line 25, col 7		
Function dbo CRDF_Hierarchy		
@lst_TypEnt @ line 59, col 6		
Procedure dbo DuplicateWorkspace_Active_Basic		
@beginningALL @ line 27, col 6		
Procedure dbo DuplicateWorkspace_Active_Basic_Custom_Countries		
@beginningALL @ line 30, col 6		
Procedure dbo DuplicateWorkspace_Active_Struct		
@beginningALL @ line 30, col 6		
Procedure dbo DuplicateWorkspace_Custom_Basic		
@beginningALL @ line 31, col 6		
Procedure dbo GetConvertedDatas		
@entitiesString @ line 379, col 8
@entitiesString @ line 383, col 8		
Procedure dbo Transco_Lnk_Val_Update		
@TemplateFile_Id @ line 40, col 7
@TemplateFile_Id @ line 101, col 87		
		


 
 	Intrinsic function usage on columns in predicate	
Description
When a column is wrapped around in a function call within a predicate, the processing can be extremely slow due to the potential resultant scan.		
Recommendation
Try minimizing this kind of construct. Using it on smaller result sets is less of an impact than when used on very large data sets. In unavoidable circumstances, persisted computed columns or indexed views might be an alternative.		
References
·	CREATE FUNCTION (Transact-SQL) | Microsoft Docs
·	Removing Function Calls for Better Performance in SQL Server

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (14 occurrences)		
Procedure dbo CRDF_Scope_CheckIsUploaded		
isnull @ line 26, col 11
isnull @ line 27, col 11		
Procedure dbo CRDF_Scope_Get_TreeViewElement		
ISNULL @ line 35, col 48
ISNULL @ line 35, col 99
ISNULL @ line 42, col 12
ISNULL @ line 42, col 61
ISNULL @ line 49, col 12
 ... (note: only 5 of 7 findings shown)		
Procedure dbo CRDF_Workspace_GetSteeringToolsData		
max @ line 35, col 277		
Function dbo Entity_GetChildrenAndParent		
REPLACE @ line 46, col 158		
Procedure dbo GetSensibilityAction		
Upper @ line 22, col 103		
Procedure dbo Template_CreateReporting		
DATEADD @ line 57, col 46		
Procedure ssis CRDF_Transco_Insert_Transco		
UPPER @ line 94, col 73
substring @ line 100, col 79
UPPER @ line 124, col 10
len @ line 191, col 7
len @ line 193, col 7
 ... (note: only 5 of 6 findings shown)		
Procedure ssis Matrix_CleanTempData		
rtrim @ line 51, col 6
rtrim @ line 52, col 6
rtrim @ line 58, col 6		
Procedure ssis Matrix_InsertData		
ISNULL @ line 69, col 11
ISNULL @ line 70, col 9
ISNULL @ line 71, col 9
ISNULL @ line 72, col 9
ISNULL @ line 101, col 6		
Procedure ssis Matrix_InsertError		
LEN @ line 111, col 8
RTRIM @ line 111, col 12
LTRIM @ line 111, col 18
LEN @ line 112, col 8
RTRIM @ line 112, col 12
 ... (note: only 5 of 12 findings shown)		
		


 
 	Intrinsic function usage on columns in JOIN predicate	
Description
When a column is wrapped around in a function call within a predicate, the processing can be extremely slow due to the potential resultant scan.		
Recommendation
Try minimizing this kind of construct. Using it on smaller result sets is less of an impact than when used on very large data sets. In unavoidable circumstances, persisted computed columns or indexed views might be an alternative.		
References
·	CREATE FUNCTION (Transact-SQL) | Microsoft Docs
·	Removing Function Calls for Better Performance in SQL Server

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (5 occurrences)		
Procedure dbo CreateFreeAnalysisReporting		
ISNULL @ line 254, col 46
ISNULL @ line 254, col 84		
Procedure dbo GetValueFromTransco		
ISNULL @ line 164, col 42
ISNULL @ line 164, col 80		
View dbo InputFormLockedPerimetersView		
REVERSE @ line 26, col 91
REVERSE @ line 26, col 106
CHARINDEX @ line 26, col 146
REVERSE @ line 26, col 161
LEN @ line 27, col 81
 ... (note: only 5 of 11 findings shown)		
Procedure ssis ProfilsMatrix_InsertData		
Isnull @ line 259, col 11
Isnull @ line 259, col 40
Isnull @ line 260, col 11
Isnull @ line 260, col 42		
Procedure ssis ProfilsMatrix_InsertError		
RTRIM @ line 163, col 93
LTRIM @ line 163, col 99		
		


 
 	LIKE predicate with leading wildcard	
Description
A LIKE predicate with a leading % wildcard can lead to non-usage of otherwise suitable indexes, thereby reducing performance.		
Recommendation
If LIKE is really necessary, try to use % at the end of the word, not the beginning LIKE name%. Also, if you want to look for words within large text fields, Full-Text Search might be more appropriate.		
References
·	LIKE (Transact-SQL) | Microsoft Docs
·	Full-Text Search | Microsoft Docs
·	Query with Full-Text Search | Microsoft Docs
	
		
workspace111118 (3 occurrences)		
Procedure dbo CRDF_Scope_Get_TreeViewElement		
'%ALL%' @ line 65, col 43
'%ALL%' @ line 76, col 109
'%N.R.%' @ line 76, col 146
'%ALL%' @ line 81, col 69
'%ALL%' @ line 93, col 69		
Procedure ssis GetlogsMessages		
'%Error' @ line 41, col 26		
Procedure ssis Matrix_InsertError		
'%@%.%' @ line 110, col 21		
		


 
 	INSERT can execute in parallel if TABLOCK is specified	
Description
In SQL Server 2016 with compatibility level 130, INSERT...SELECT operations into on-disk tables can utilize multiple threads for the INSERT only if the TABLOCK hint is specified for the target table (please review the Reading links for exceptions for local temp tables).		
Recommendation
Usage of TABLOCK can help in bulk data loading scenarios, but obviously at the cost of concurrency. Evaluate the application scenario and accordingly decide if this optimization should be leveraged.		
References
·	SQLSweet16!, Episode 3: Parallel INSERT … SELECT | SQL Server Customer Advisory Team
·	Real World Parallel INSERT…SELECT: What else you need to know! | SQL Server Customer Advisory Team
	
		
workspace111118 (42 occurrences)		
Procedure dbo CRDF_Scope_Insert		
INSERT INTO LNK_SCOPE(CNT...ELE = 1 @ line 27, col 3
INSERT INTO LNK_SCOPE(CNT...ELE = 1 @ line 33, col 3
INSERT INTO LNK_SCOPE(CNT...ELE = 1 @ line 39, col 3
INSERT INTO LNK_SCOPE(CNT...ELE = 1 @ line 45, col 3		
Function dbo CRDF_Struct_Column		
insert into @An
 select ...er by 2 @ line 23, col 2		
Function dbo CRDF_UserCountry		
insert into @An 
 select...Profile @ line 21, col 2		
Procedure dbo CRDF_Workflow_GetScopeChildrenReporting		
INSERT INTO #TempTable
 ...     ) @ line 41, col 14
INSERT INTO #TempTable
 ...OPE_ID @ line 66, col 21		
Procedure dbo CRDF_Workflow_GetScopeParentReporting		
INSERT INTO #TempTable
 ...
     ) @ line 39, col 4
INSERT INTO #TempTable
 ...dEntity @ line 66, col 2		
Function dbo GetAllSensibilitiesFiltersByInputFormScope		
INSERT INTO @Sensibilitie...MN_NB=1 @ line 45, col 2		
Function dbo GetInputFormColumnMappingBetweenTemplateVersions		
INSERT INTO @Result
 SEL...NBR ASC @ line 41, col 2		
Trigger dbo GrantAdminRights		
INSERT LNK_FUNC_GROUP (GR...roupId) @ line 22, col 2		
Trigger dbo switchTemplateVersion		
INSERT INTO LNK_COMPO_STR... @OLDID @ line 66, col 4		
Trigger dbo UpdatingRowValue		
INSERT INTO #LISTSTRUCTNA...CVAL_ID @ line 37, col 4		
		


 
 	CTEs are not always efficient when the SELECT relies on the DISTINCT of all the columns	
Description
Using CTEs is not the most efficient approach when the statement immediately following the CTE expression relies on the DISTINCT of all the columns. Essentially this implies that the recursive logic doesn't have a primary key in the anchor, and thereby allowing each recursive member to not be unique. This creates a scenario where a huge number of duplicate rows are generated.		
Recommendation
Recursive CTE queries do have a reliance on the unique parent/child keys in order to get the best performance. If this is not possible to achieve, then a WHILE loop is potentially a much more efficient approach to handling the recursive query.		
References
·	Optimize Recursive CTE Query | SQL Server Customer Advisory Team
·	Recursive Queries Using Common Table Expressions
	
		
workspace111118 (1 occurrences)		
Function dbo Entity_GetChildrenAndParent		
WITH Filtered_Entity_Char...cendant @ line 38, col 1		
		


 
 	Distinct within aggregate Function	
Description
Distinct within the aggregate function performs extra sort operation to remove duplicate values		
Recommendation
Remove distinct clause from the aggregate function and use appropriate join and filter condition to remove duplicate rows		
References
·	CREATE FUNCTION (Transact-SQL) | Microsoft Docs
·	SELECT Clause (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (3 occurrences)		
Procedure dbo RemoveProphetEnterpriseData		
COUNT(distinct(ROW)) @ line 115, col 36		
View dbo ScopeLockStatusView		
COUNT(DISTINCT C.[sensibi...test]) @ line 47, col 15		
Procedure idr WS_InsertPEDataToLNK_VAL		
COUNT(distinct(ROW)) @ line 115, col 34		
		


 
 	UDF without table access should specify SCHEMABINDING	
Description
There is small but distinct performance hit if you do not mark an UDF (which does not access any table data) as SCHEMABINDING.		
Recommendation
Use SCHEMABINDING when possible.		
References
·	Improving query plans with the SCHEMABINDING option on T-SQL UDFs – SQL Programmability & API Development Team Blog
·	Create User-defined Functions (Database Engine) | Microsoft Docs
	
		
workspace111118 (6 occurrences)		
Function dbo CRDF_GetActionScopeProfileTemplate		
CREATE FUNCTION [dbo].[CR...ION
END @ line 4, col 1		
Function dbo CRDF_Split		
CREATE FUNCTION [dbo].[CR...n  
END @ line 4, col 1		
Function dbo CRDF_TRANSCO_ColToAlpha		
CREATE FUNCTION [dbo].[CR...rs;
END @ line 4, col 1		
Function dbo CRDF_TRANSCO_VerifyOperation		
CREATE FUNCTION [dbo].[CR...our
END @ line 4, col 1		
Function dbo fnSplitString		
CREATE FUNCTION [dbo].[fn...RN 
END @ line 3, col 1		
Function dbo getViewName		
CREATE FUNCTION getViewNa...'')
END @ line 4, col 1		
		


 
 	UDF usage in the output list	
Description
The UDF will be evaluated once per output row. If the UDF is complex, processing can be extremely slow, almost like a cursor usage scenario		
Recommendation
Try minimizing this kind of construct. Using it on smaller result sets is less of an impact than when used on very large data sets. Also, consider using a TVF and CROSS APPLY.		
References
·	Use Table-Valued Parameters (Database Engine) | Microsoft Docs
·	Create User-defined Functions (Database Engine) | Microsoft Docs
·	Using APPLY
	
		
workspace111118 (2 occurrences)		
Procedure ssis Matrix_InsertError		
[CRDF_TRANSCO_COLTOALPHA] @ line 70, col 26
[CRDF_TRANSCO_COLTOALPHA] @ line 85, col 16
[CRDF_TRANSCO_COLTOALPHA] @ line 97, col 13
[CRDF_TRANSCO_COLTOALPHA] @ line 97, col 62		
Procedure ssis ProfilsMatrix_InsertError		
[CRDF_TRANSCO_COLTOALPHA] @ line 57, col 63
[CRDF_TRANSCO_COLTOALPHA] @ line 70, col 63
[CRDF_TRANSCO_COLTOALPHA] @ line 85, col 54
[CRDF_TRANSCO_COLTOALPHA] @ line 173, col 63
[CRDF_TRANSCO_COLTOALPHA] @ line 191, col 63
 ... (note: only 5 of 9 findings shown)		
		


 
 	Row goal issue	
Description
Suboptimal plans in some cases.		
Recommendation
Each case should be looked at by examining the query plan. In some cases, nothing has to be done.		
References
·	Row Goals in Action – Tips, Tricks, and Advice from the SQL Server Query Optimization Team
·	Row Goals Gone Rogue – Bart Duncan's SQL Weblog
·	Page Free Space : Inside the Optimizer: Row Goals In Depth

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (4 occurrences)		
Procedure dbo CRDF_GetQRT		
( SELECT DISTINCT * 
   ...
    ) @ line 92, col 12		
Trigger dbo switchTemplateVersion		
( select transco.[SHEET_I...ID  ) @ line 115, col 13		
Procedure dbo WS_HasUserUploadRightOnScope		
(
  SELECT 1
  FROM LNK...Id
 ) @ line 29, col 12		
Procedure ssis ProfilsMatrix_InsertError		
(SELECT 'X' 
        FRO...T.F5) @ line 201, col 20
(SELECT AT.ACTION_SHORTNA...    ) @ line 250, col 20		
		


 
 	Wildcard pattern usage	
Description
This kind of wildcard query pattern will cause a table scan, resulting in poor query performance.

This rule checks for the following varieties of this pattern:

 -- Pattern 1
 SELECT *
 FROM TabFoo
 WHERE ColBar = @someparam OR @someparam IS NULL

 -- Pattern 2
 SELECT *
 FROM TabFoo
 WHERE ColBar = ISNULL(@someparam, ColBar)

Known limitation for case 2: we do not detect this pattern if the column name is prefixed with a table name or table alias.		
Recommendation
In many cases, an OPTION (RECOMPILE) hint can be a quick workaround, but can also cause too many recompilations. From a design point of view, you can rewrite the code. Consider using separate IF clauses, separated stored procedures or (not recommended) use a dynamic SQL statement with sp_executesql, watching for the risk of sql injection.		
References
·	OPTION(RECOMPILE) redux (a.k.a. Parameter Embedding Optimization not working) – Esoteric
·	T-SQL Anti-pattern of the day: ‘all-in-one’ queries – Esoteric
	
		
workspace111118 (4 occurrences)		
Procedure dbo CRDF_Scope_CheckDependencies		
@idDepartment is null @ line 25, col 40
@idEntity is null @ line 26, col 39		
Procedure dbo CRDF_Scope_GetId		
@idDepartment is null @ line 23, col 40
@idEntity is null @ line 24, col 39		
Procedure dbo CRDF_Scope_GetTemplatesProperties		
@idType is null @ line 39, col 34
@idDepartment is null @ line 40, col 38
@idType is null @ line 40, col 63
@idEntity is null @ line 41, col 37
@idType is null @ line 41, col 58		
Procedure dbo CRDF_Workflow_GetExpandedWorkflow		
@idSource  is null @ line 30, col 79		
		


 
Readability		
		
 	Review the usage of the 'columnAlias = columnName' syntax	
Description
We detected the usage of column alias syntax similar to:

 colAlias = someColName 

The usage of the 'equals sign' (also known as the assignment operator) to associate the column alias with an expression might not be preferred in certain coding standards / styles. Currently, this syntax is not explicitly deprecated / removed. This issue is provided largely as information and the developer needs to consider the overall coding standard / style in remediating this.		
Recommendation
It is recommended to use the AS syntax as recommended in the reading links below.		
References
·	SELECT Clause (Transact-SQL) | Microsoft Docs
·	Assignment Operator (Transact-SQL) | Microsoft Docs
·	Bad Habits to Kick: Using AS instead of = for column aliases

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (4 occurrences)		
Batch  Adhoc batch @ line 1 (CREATE DATABASE [workspace11		
N'workspace111118' @ line 4, col 10
N'workspace111118_log' @ line 6, col 10		
Function dbo CRDF_Split		
Data @ line 30, col 10
Data @ line 37, col 8		
Procedure dbo GetInputFormsDataWithPivot		
'COL' @ line 125, col 10
'COL' @ line 244, col 15		
View dbo InputFormLockedPerimetersView		
[SCOPE_ID] @ line 20, col 2
[Name of Entity_ID] @ line 21, col 2
[Name of Entity] @ line 22, col 2
[Sensibility] @ line 23, col 2		
		


 
 	IF statements should have a BEGIN...END for readability	
Description
Having explicit BEGIN...END blocks can improve readability in cases. Also, avoid future logic issues during the maintenance of the code. This is a matter of coding style.		
Recommendation
Generally, use the explicit BEGIN...END block as a pattern.		
References
·	BEGIN...END (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (32 occurrences)		
Procedure dbo CRDF_GetConvertedsourceScopes		
IF LEN(ISNULL(@LstScopes,...= '-1'; @ line 24, col 4		
Procedure dbo CRDF_Struct_GetData		
IF @INDEX>3
     SET @Cl...mns+',' @ line 41, col 6
IF (LEN(@ClauseOrderByCol...r by 1' @ line 59, col 2		
Procedure dbo CRDF_Workflow_GetExpandedWorkflow		
if  OBJECT_ID('tempdb..#A...ble #An @ line 21, col 2		
Procedure dbo CRDF_Workflow_GetScopeChildrenReporting		
IF OBJECT_ID('TEMPDB..#Te...pTable; @ line 29, col 8		
Procedure dbo CRDF_Workflow_GetScopeParentReporting		
IF OBJECT_ID('TEMPDB..#Te...pTable; @ line 26, col 2		
Procedure dbo GetValueFromTransco		
IF OBJECT_ID('TEMPDB..#TM...ILE_ID; @ line 45, col 3
IF OBJECT_ID('TEMPDB..#TM...NTITY; @ line 249, col 4
IF OBJECT_ID('tempdb..#Co...lumns; @ line 306, col 3
IF OBJECT_ID('tempdb..#fi...lters; @ line 314, col 4
IF OBJECT_ID('tempdb..#Ge...ilter; @ line 322, col 6
 ... (note: only 5 of 12 findings shown)		
Procedure dbo Transco_InitFILTERS		
IF OBJECT_ID('tempdb..#Tm...Filter; @ line 92, col 4
IF (@Tmp_TargerId = @Tmp_...''' )' @ line 151, col 7		
Trigger dbo Trg_ExtFile_Transco_LNK_VAL_UPDATING_ROWS		
IF (@TypeTemplate_Id =1  ...File_Id @ line 57, col 3		
Trigger dbo UPDATING_ROWS		
IF @I>0 AND @D=0
  SELEC...RUCT_ID @ line 28, col 3
IF @I>0 AND @D>0
  SELEC...RUCT_ID @ line 32, col 3
IF @I=0 AND @D>0
  SELEC...RUCT_ID @ line 37, col 3		
Procedure idr GetInputFormNonLockedRows		
IF @centralWhere='()'
  ...lWhere @ line 116, col 2
IF @sensibilityWhere='()'...yWhere @ line 120, col 6
if @rowCount = 1--
  SET...W_NB)' @ line 142, col 2		
		


 
 	INSERT should specify the list of columns	
Description
Any change in schema or the column ordering for the underlying table might result in incorrect data insertion.		
Recommendation
Always specify the column names in the INSERT list.		
References
·	INSERT (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (36 occurrences)		
Function dbo CRDF_Action2ShortName_Table		
Insert @ReturnValue
  Se...eRights @ line 78, col 3		
Function dbo CRDF_Struct_Column		
insert into @An
 select ...er by 2 @ line 23, col 2		
Function dbo CRDF_UserCountry		
insert into @An 
 select...Profile @ line 21, col 2		
Procedure dbo CRDF_Workflow_GetScopeChildrenReporting		
INSERT INTO #TempTable
 ...     ) @ line 41, col 14
INSERT INTO #TempTable
 ...OPE_ID @ line 66, col 21		
Procedure dbo CRDF_Workflow_GetScopeParentReporting		
INSERT INTO #TempTable
 ...
     ) @ line 39, col 4
INSERT INTO #TempTable
 ...dEntity @ line 66, col 2		
Function dbo GetAllSensibilitiesFiltersByInputFormScope		
INSERT INTO @Sensibilitie...MN_NB=1 @ line 45, col 2
INSERT INTO @AllFilters
...ibility @ line 56, col 2
INSERT INTO @AllFilters
...bility) @ line 83, col 2
INSERT INTO @Result
  SE...lters f @ line 93, col 3
INSERT INTO @Result
  SE...ilters @ line 112, col 3		
Function dbo GetInputFormColumnMappingBetweenTemplateVersions		
INSERT INTO @Result
 SEL...NBR ASC @ line 41, col 2		
Procedure dbo Scope_GetParentsId		
INSERT INTO #ENTITIES SEL...Scope) @ line 111, col 5
INSERT INTO #ALLENTITIES ...ssAll) @ line 130, col 5		
Trigger dbo UpdatingRowValue		
INSERT INTO #LISTSTRUCTNA...CVAL_ID @ line 37, col 4		
Procedure idr WS_InsertPEDataToLNK_VAL		
INSERT INTO [LNK_INPUT_FO...wIndex @ line 108, col 3
INSERT  INTO [dbo].[LNK_V...NB ASC @ line 148, col 3
INSERT  INTO [dbo].[LNK_V...NB ASC @ line 164, col 3
INSERT INTO APP_USERMESSA...Error' @ line 206, col 3		
		


 
 	Zero-length schema identifier	
Description
This issue is flagged when we detect code with a blank schema identifier. It is not normal to have a blank schema name and it can confuse readers.		
Recommendation
Use the full schema name whenever you can.		
References
·	CREATE SCHEMA (Transact-SQL) | Microsoft Docs
·	SQL Server Best Practices – Implementation of Database Object Schemas
	
		
workspace111118 (16 occurrences)		
Procedure dbo CRDF_Scope_Get_TreeViewElement		
[MASTERWIND]..LST_TEMPLAT...E LSTT @ line 63, col 13
[MASTERWIND]..LST_TEMPLAT...E LSTT @ line 79, col 13
[MASTERWIND]..LST_TEMPLAT...E LSTT @ line 91, col 13		
Procedure dbo CRDF_StructTableFixedForSSRS		
MASTERWIND..LST_VARFORMAT LVF @ line 35, col 15
MASTERWIND..LST_TEMPLATET...YPE LT @ line 40, col 15		
Procedure dbo GetInputFormsDataWithPivot		
masterwind..LST_USER U @ line 103, col 8		
Procedure dbo GetIsDeletableQualidocs		
masterwind..LNK_SCOPEACTI...N  lsa @ line 53, col 13
masterwind..LNK_SCOPEACTI...N  lsa @ line 63, col 13
masterwind..LNK_SCOPEACTI...N  lsa @ line 72, col 13		
Procedure dbo LockWorkflowElements		
masterwind..LST_TEMPLATET...YPE TT @ line 57, col 60
masterwind..LST_LOCKEDPER...PE LPT @ line 59, col 69
masterwind..LST_LOCKEDPER...PE LPT @ line 60, col 75
masterwind..LST_ACTION @ line 62, col 40
masterwind..LNK_SCOPEACTI...ON SA @ line 117, col 13
 ... (note: only 5 of 6 findings shown)		
Procedure dbo RemoveProphetEnterpriseData		
[masterwind]..LST_MESSAGE...YPE MT @ line 213, col 7
[masterwind]..LST_ACTION A @ line 214, col 13		
Trigger dbo switchTemplateVersion		
MASTERWIND..LST_VARFORMAT... LSTV @ line 104, col 15
MASTERWIND..LST_VARFORMAT...LSTV2 @ line 105, col 15		
Procedure idr CreateFeed		
[masterwind]..LST_USER U @ line 63, col 7		
Procedure idr WS_InsertPEDataToLNK_VAL		
[masterwind]..LST_MESSAGE...YPE MT @ line 208, col 8
[masterwind]..LST_ACTION A @ line 209, col 14		
Procedure ssis CRDF_Transco_Insert_Transco		
masterwind..LST_TEMPLATET...E lstt @ line 81, col 17
masterwind..LST_TEMPLATET...E lstt @ line 91, col 18		
		


 
 	Review the use of PRINT statements	
Description
For the ODBC 3.5x compliant SQL Server driver, messages from consecutive PRINT, RAISERROR, DBCC, or similar statements, as in a batch or stored procedure, are returned in a separate result set for each statement.

Failure to process these messages completely might result in open transactions on the server side.

In many cases such PRINT statements may be 'left over' from debugging or development time tracing. Such 'debugging' statements should be removed from the code before it enters production.

Lastly, all such PRINT messages are sent over the network to the client, so it is not a good idea from a performance or security point of view to send debugging-level messages to the client.		
Recommendation
If the PRINT statements are used for debugging purposes, please consider removing them from production code. Tools such as SQL Profiler can be used for similar purposes.		
References
·	PRINT (Transact-SQL) | Microsoft Docs
·	RAISERROR (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (10 occurrences)		
Procedure dbo CRDF_Template_Delete		
print 'Remove SIX Depende...P_QRT)' @ line 76, col 3
print 'Remove SIX Depende...ource)' @ line 79, col 3
print 'Remove SIX Depende...encie)' @ line 82, col 3
print 'Remove SIX Sheets ...T_SIX)' @ line 85, col 3
print 'set WIND_SHEET_ID ...reproc' @ line 88, col 3
 ... (note: only 5 of 24 findings shown)		
Procedure dbo CRDF_Template_DeleteReporting_ManageKo		
print 'Remove user messag...LLULE)' @ line 30, col 3
print 'Remove SIX Sheets ...T_SIX)' @ line 34, col 3
print 'Remove sheets (APP...SHEET)' @ line 38, col 3
print 'Remove scopes (APP...ODELE)' @ line 42, col 3
print @@ERROR @ line 46, col 3		
Procedure dbo GetIsDeletableQualidocs		
print @istodelete @ line 80, col 2		
Procedure dbo GetValueFromTransco		
print 'operation null' @ line 540, col 9
PRINT 'IF ===' @ line 590, col 6
PRINT 'CALC ===' @ line 629, col 6		
Procedure dbo LockWorkflowElements		
PRINT 'No cascade lock ha...t Form' @ line 75, col 3
PRINT 'End of process..' @ line 76, col 3
PRINT 'Done!' @ line 188, col 2		
Procedure dbo Transco_InitFILTERS		
print @@ERROR @ line 245, col 3		
Procedure dbo Transco_Lnk_Val_Update		
print @@ERROR @ line 202, col 3		
Procedure dbo UnlockWorkflowElements		
PRINT 'Done!' @ line 136, col 2		
Procedure idr CreateFeed		
PRINT 'CreateFeed - Feed ...ated!' @ line 101, col 2		
Procedure idr CreateFeedProtection		
PRINT 'CreateFeed - Feed ...ated!' @ line 122, col 2		
		


 
 	Avoid mixing named parameters with un-named parameters in EXECUTE procedure references	
Description
Readability of code would be better if a consistent parameter passing style is used.		
Recommendation
Either use all named parameters or all un-named parameters. In some cases, such as calling native compiled procedures, the un-named parameter scheme is preferred.		
References
·	Specifying a Parameter Name
·	CREATE PROCEDURE (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (6 occurrences)		
Procedure dbo CRDF_GetConvertedAcatDatas		
sp_executesql @propShareQ...output @ line 245, col 8
SP_EXECUTESQL @SQLTEMPLAT...UTPUT @ line 374, col 12		
Procedure dbo DuplicateWorkspace_Data		
sp_executesql @SQL, @Para...UTPUT @ line 117, col 11		
Procedure dbo DuplicateWorkspace_Data_All_Countries		
sp_executesql @SQL, @Para...UTPUT @ line 101, col 10		
Procedure dbo GetValueFromTransco		
SP_EXECUTESQL @SQL_STATEM...UTPUT @ line 551, col 13
SP_EXECUTESQL @SQL_STATEM...UTPUT @ line 621, col 12
SP_EXECUTESQL @SQL_STATEM...UTPUT @ line 650, col 12		
Procedure idr GetInputFormNonLockedRows		
sp_executesql @query, @Pa...UTPUT @ line 155, col 10		
Procedure ssis SSIS_ExecutePackage		
[SSISDB].[catalog].[set_e...e=@var0 @ line 32, col 7
[SSISDB].[catalog].[set_e...e=@var1 @ line 34, col 7
[SSISDB].[catalog].[set_e...e=@var2 @ line 36, col 7
[SSISDB].[catalog].[set_e...e=@var3 @ line 38, col 7
[SSISDB].[catalog].[set_e...e=@var4 @ line 40, col 7
 ... (note: only 5 of 7 findings shown)		
		


Security
	
		
 	EXECUTE used with string variable	
Description
The usage of unchecked variables in an EXECUTE statement can lead to SQL Injection attacks.		
Recommendation
Before you call EXECUTE with a character string, validate the character string. Never execute a command constructed from user input that has not been validated. Use sp_executesql instead.		
References
·	sp_executesql (Transact-SQL)
·	SQL Injection
·	Using sp_executesql
·	EXECUTE (Transact-SQL) | Microsoft Docs
·	How to configure URLScan 3.0 to mitigate SQL Injection Attacks – IIS troubleshooting, administration, and concepts.
·	Nazim's Security Blog - Filtering SQL injection from Classic ASP
·	Dynamic SQL & SQL injection – Raul Garcia's blog
·	SQL injection: Dynamic SQL within stored procedures – Varun Sharma's security blog
·	Do Stored Procedures Protect Against SQL Injection? – Brian Swan

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (13 occurrences)		
Procedure dbo CRDF_GetFilingTypes		
@qrtIdsCSV @ line 28, col 36
@entitiesIdsCSV @ line 29, col 26		
Procedure dbo CRDF_Scope_DeleteScopes		
@lstIdScope @ line 21, col 61
@lstIdScope @ line 23, col 59
@lstIdScope @ line 25, col 55		
Procedure dbo DuplicateWorkspace_Active_Struct		
@structFamilyDefault @ line 37, col 50
@SourceWorkspaceId @ line 49, col 63
@SourceWorkspaceId @ line 53, col 63
@processALL @ line 103, col 39
@templateModeleALL @ line 119, col 57
 ... (note: only 5 of 8 findings shown)		
Procedure dbo DuplicateWorkspace_Custom_Basic		
@basicFamilyDefault @ line 51, col 55
@BasicReferentialList @ line 56, col 44
@templateModeleALL @ line 72, col 56
@beginningALL @ line 73, col 59
@StructReferentialList @ line 81, col 40
 ... (note: only 5 of 17 findings shown)		
Procedure dbo DuplicateWorkspace_Custom_Struct		
@structFamilyDefault @ line 41, col 50
@StructReferentialList @ line 46, col 46
@SourceWorkspaceId @ line 54, col 63
@StructReferentialList @ line 56, col 46
@TemplateList @ line 79, col 54
 ... (note: only 5 of 16 findings shown)		
Procedure dbo DuplicateWorkspace_Transverse		
@DuplicatedWorkspaceId @ line 64, col 25
@ApplicationOwner @ line 68, col 26
@SelectedProfiles @ line 115, col 32
@ApplicationOwner @ line 139, col 73
@ApplicationOwner @ line 162, col 77		
Procedure dbo DuplicateWorkspace_Transverse_All_Countries		
@selectedCountries @ line 56, col 39
@ApplicationOwner @ line 65, col 66
@ApplicationOwner @ line 75, col 78
@selectedCountries @ line 88, col 34
@selectedCountries @ line 100, col 40
 ... (note: only 5 of 7 findings shown)		
Procedure dbo DuplicateWorkspace_UpdateSP		
@Query @ line 35, col 7		
Procedure dbo DuplicateWorkspace_UpdateTemplatePath		
@SourceWorkspaceName @ line 26, col 74
@DuplicatedWorkspaceName @ line 26, col 108		
Procedure dbo GetEntitiesTargetWorkspace		
@curentEntityLabel @ line 32, col 33		
		


 
 	DROP TABLE statement usage	
Description
DROP TABLE if used wrongly can cause permanent data loss. In addition, DROP TABLE, when applied to a temporary table, can affect the caching behavior for temp table metadata.		
Recommendation
Review the usage of DROP TABLE and avoid it for temporary tables.		
References
·	Is Tempdb Affecting Your Day-to-Day SQL Server Performance? | SQL Server content from SQL Server Pro

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (25 occurrences)		
Procedure dbo CRDF_GetQRT		
DROP TABLE #LASTUPLOADDATE1 @ line 57, col 3		
Procedure dbo CRDF_Workflow_GetScopeChildrenReporting		
DROP TABLE #TempTable; @ line 29, col 59		
Procedure dbo CRDF_Workflow_GetScopeParentReporting		
DROP TABLE #TempTable; @ line 26, col 53		
Procedure dbo GetConvertedDatas		
DROP TABLE #columns; @ line 52, col 57
DROP TABLE #shares; @ line 53, col 51
DROP TABLE #entityCurrency; @ line 54, col 59
DROP TABLE #centralFilters; @ line 55, col 59
DROP TABLE #filters; @ line 56, col 52		
Procedure dbo GetInputFormsLockedData		
DROP TABLE #columnsMapping @ line 80, col 3
DROP TABLE #Sensibilities...Filters @ line 97, col 3
DROP TABLE #GroupedSensib...ilters @ line 118, col 3
DROP TABLE #pivotedRawData @ line 147, col 3
DROP TABLE #rowsMapping @ line 259, col 3		
Procedure dbo GETPARAMETRAGECONTEXT		
DROP TABLE #CONTEXT @ line 48, col 1		
Procedure dbo LockWorkflowElements		
DROP TABLE #sensibilities @ line 83, col 3
DROP TABLE #impactedEntities @ line 93, col 3
DROP TABLE #scopeToLockOn...yLabel @ line 105, col 3
DROP TABLE #scopeToLockOn...yLabel @ line 128, col 3		
Procedure dbo Transco_InitFILTERS		
DROP TABLE #Tmp_Tr_curs_F...ilter; @ line 92, col 64
drop table #Tmp_Tr_curs_Filter @ line 162, col 4		
Procedure dbo UnlockWorkflowElements		
DROP TABLE #sensibilities @ line 74, col 3
DROP TABLE #scopeToUnlock...tyLabel @ line 84, col 3		
Procedure idr GetInputFormNonLockedRows		
DROP TABLE #columnsMapping @ line 126, col 2
DROP TABLE #Sensibilities...ilters @ line 127, col 2
DROP TABLE #GroupedSensib...ilters @ line 128, col 2		
		


 
Stability		
		
 	Consider using SCOPE_IDENTITY instead of @@IDENTITY	
Description
Because @@IDENTITY is a global identity value, it might have been updated outside the current scope and obtained an unexpected value. Triggers, including nested triggers used by replication, can update @@IDENTITY outside your current scope.		
Recommendation
To resolve this issue you must replace references to @@IDENTITY with SCOPE_IDENTITY, which returns the most recent identity value in the scope of the user statement. 

Note: There is an open issue with very specific cases involving parallel query plans, where neither @@IDENTITY nor SCOPE_IDENTITY returns the 'correct' value. Please refer to the KB article mentioned below for more details.		
References
·	You may receive incorrect values when using SCOPE_IDENTITY() and @@IDENTITY
	
		
workspace111118 (7 occurrences)		
Procedure dbo RemoveProphetEnterpriseData		
@@IDENTITY @ line 99, col 21		
Procedure dbo Transco_InitFILTERS		
@@IDENTITY @ line 26, col 14		
Procedure dbo Transco_Lnk_Val_Update		
@@IDENTITY @ line 46, col 15		
Trigger dbo Trg_ExtFile_Transco_LNK_VAL_UPDATING_ROWS		
@@IDENTITY @ line 40, col 15		
Procedure idr CreateFeed		
@@IDENTITY @ line 99, col 24		
Procedure idr CreateFeedProtection		
@@IDENTITY @ line 120, col 24		
Procedure idr WS_InsertPEDataToLNK_VAL		
@@IDENTITY @ line 101, col 25		
		


 
 	Columns with IDENTITY property set may see 'jumps' in SQL 2012 and above	
Description
Starting in SQL 2012 the implementation of the IDENTITY property is shared with the SEQUENCE object, with a default behavior to pre-allocate values for performance reasons. The side effect of this is that anytime there is a restart of the instance for example, the identity value obtained 'jumps' by a sometimes considerable number. This may impact applications which rely on a contiguous sequence of numbers.		
Recommendation
Be aware of this behavior change in SQL 2012 and above. Based on your application requirements, you can decide how severe (or not) this change is for your application. To revert to the older behavior, you can consider using trace flag 272 as documented on links below. Also, you can use the new data type sequence (SQL Server 2012 and above)		
References
·	Identity(1,1) jumped from 32 to 1023 with no table definition change
·	CREATE SEQUENCE (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (40 occurrences)		
Table dbo APP_GROUP		
[GROUP_ID] [numeric](18, ...NOT NULL @ line 2, col 2		
Table dbo APP_PROCESS		
[PROCESS_ID] [numeric](18...NOT NULL @ line 2, col 2		
Table dbo APP_SHEET		
[SHEET_ID] [numeric](18, ...NOT NULL @ line 2, col 2		
Table dbo APP_SHEET_SIX		
[SIX_SHEET_ID] [numeric](...NOT NULL @ line 2, col 2		
Table dbo APP_TRANSCO_QUERY		
[QUERY_ID] [numeric](18, ...NOT NULL @ line 2, col 2		
Table dbo APP_VARGROUP		
[VARGROUP_ID] [numeric](1...NOT NULL @ line 2, col 2		
Table dbo LNK_INPUT_FORM_COMPOSITION		
[COMPOSITION_ID] [numeric...NOT NULL @ line 2, col 2		
Table dbo LNK_TRANSCOSOURCE		
[TRANSCOSOURCE_ID] [numer...NOT NULL @ line 2, col 2		
Table dbo LNK_VAL		
[VAL_ID] [bigint] IDENTIT...NOT NULL @ line 2, col 2		
Table idr APP_FEED		
[FEED_ID] [numeric](18, 0...NOT NULL @ line 2, col 2		
		


 
 	Issue described in KB2662301	
Description
If a concurrent statements that resemble the following are executed in the instance:

CREATE PROC p AS RETURN (
 ...query...
); EXEC p;

OR

IF EXISTS(
 ...subquery...
);

Then in these cases, slow performance can occurs in SQL Server 2008 R2 or in SQL Server 2012. This behavior is generally co-related if high CPU usage is observed with contention over the QUERY_EXEC_STATS spinlock		
Recommendation
Run cumulative update package 5 for SQL Server 2008 R2 SP1 or cumulative update package 1 for SQL Server 2012 to fix this issue.		
References
·	FIX: Slow performance occurs in SQL Server 2008 R2 or in SQL Server 2012 if high CPU usage is observed with contention over the QUERY_EXEC_STATS spinlock
	
		
workspace111118 (13 occurrences)		
Procedure dbo GetInputFormsData		
(SELECT 1 FROM LNK_INPUT_...IDR') @ line 123, col 11		
Procedure dbo GetInputFormsLockedData		
(SELECT 1 FROM LNK_INPUT_...IDR') @ line 166, col 12		
Procedure dbo RemoveProphetEnterpriseData		
(SELECT 1 FROM [idr].[TMP...taID) @ line 112, col 12		
Procedure dbo Scope_GetChildrenId		
(SELECT SCOPE_ID FROM #TM...Scope) @ line 96, col 15		
Procedure dbo Struct_CreateView		
(select 1
            fr...= 'U') @ line 32, col 12		
Procedure dbo Workflow_UpdateChildren		
(SELECT SCOPE_ID FROM #TM...cope) @ line 122, col 16		
Procedure dbo WS_HasUserUploadRightOnScope		
(
  SELECT 1
  FROM LNK...Id
 ) @ line 29, col 12		
Procedure idr GetInputFormNonLockedRows		
(SELECT 1 FROM LNK_INPUT_...IDR') @ line 132, col 12		
Procedure idr SetFeedAsValid		
(SELECT 1 FROM APP_FEED  ... = 1 ) @ line 34, col 11		
Procedure idr WS_InsertPEDataToLNK_VAL		
(SELECT 1 FROM [idr].[TMP...taID) @ line 112, col 13		
		


 
 	VARCHAR or NVARCHAR declared without size specification	
Description
When you use data types of variable length such as VARCHAR, NVARCHAR, it is always recommended to explicitly specify the size. Failure to do so means that SQL will select the size for you, either 1 (when declaring parameters) or 30 (when converting) characters.		
Recommendation
Explicitly specify the size in all conditions.		
References
·	Deprecate (n)varchar with out length specifcation | Microsoft Connect
·	Make size of VARCHAR (no length) consistent | Microsoft Connect
·	Aaron Bertrand : Bad habits to kick : declaring VARCHAR without (length)

DISCLAIMER: Third-party link(s) are provided on an 'as-is' basis. Microsoft does not offer any guarantees or warranties regarding the content on the third-party site(s).		
		
workspace111118 (40 occurrences)		
Procedure dbo CRDF_Struct_GetData		
CONVERT(VARCHAR,@INEXCOLUMNS) @ line 39, col 68
CONVERT(VARCHAR,@INDEX) @ line 55, col 55		
Procedure dbo CRDF_Template_Delete		
convert(varchar, @IdTempl...ate) @ line 112, col 127		
Procedure dbo CreateFreeAnalysisReporting		
CAST(@VALUEGROUP AS VARCHAR) @ line 214, col 78		
Procedure dbo DuplicateWorkspace_Custom_Basic		
CONVERT(VARCHAR, @SourceW...aceId) @ line 29, col 48
CONVERT(VARCHAR, @Duplica...aceId) @ line 30, col 52		
Procedure dbo DuplicateWorkspace_Custom_Struct		
CONVERT(VARCHAR, @SourceW...aceId) @ line 31, col 48
CONVERT(VARCHAR, @Duplica...aceId) @ line 32, col 52
CONVERT(VARCHAR, @UserId) @ line 33, col 38
CONVERT(VARCHAR, @SourceW...aceId) @ line 34, col 39		
Procedure dbo Shrink_log_Workspace		
CONVERT(VARCHAR, @SourceW...aceId) @ line 26, col 49		
Procedure idr CreateFeed		
convert(varchar, @returnV...alue) @ line 101, col 31		
Procedure idr CreateFeedProtection		
convert(varchar, @returnV...alue) @ line 122, col 31		
Procedure idr GetInputFormNonLockedRows		
convert(varchar, ISNULL(C...ndex)) @ line 80, col 16
CONVERT(nvarchar, MIN(C.R...ROW)) @ line 134, col 55
CONVERT(nvarchar, MAX(C.R...ROW)) @ line 135, col 75
CONVERT(nvarchar, @uploadId) @ line 146, col 54
CONVERT(nvarchar, @scopeId) @ line 147, col 64
 ... (note: only 5 of 8 findings shown)		
Procedure ssis Matrix_InsertData		
cast (@LNK_USERS_Inserted...char) @ line 295, col 43
cast (@LNK_GROUPS_Inserte...char) @ line 298, col 43
cast (@LNK_USERS_Inserted...char) @ line 313, col 63
cast (@LNK_GROUPS_Inserte...char) @ line 316, col 63		
		


 
Table Hints		
		
 	Table aliased with a reserved word	
Description
In some cases, this issue is flagged due to using NOLOCK without a WITH clause and braces. This mean that the NOLOCK hint is treated as a table alias.

The issue is also flagged if a table alias is a reserved word.		
Recommendation
For the NOLOCK case, review these highlighted instances as the 'hint' is actually not effective in these cases. In the more generic case avoid using reserved words for table aliases.		
References
·	Difference nolock with braces and without braces
·	FROM (Transact-SQL) - Table Aliases
·	Reserved Keywords (Transact-SQL) | Microsoft Docs
	
		
workspace111118 (11 occurrences)		
Procedure dbo CRDF_GetQRT		
AT @ line 65, col 32
RESULT @ line 86, col 42		
Procedure dbo CRDF_StructTableFixedForSSRS		
AT @ line 39, col 32		
Procedure dbo CRDF_SwitchQRTVersionSIX		
AT @ line 229, col 41
AT @ line 221, col 41
AT @ line 260, col 41
AT @ line 250, col 41		
Function dbo GetAllSensibilitiesFiltersByInputFormScope		
VALUE @ line 49, col 34		
Procedure dbo GetDataSummary		
Scope @ line 27, col 17
Scope @ line 43, col 13		
Procedure dbo GetSensibility		
VALUE @ line 23, col 36		
Procedure dbo GetTemplateListControl		
SCOPE @ line 60, col 20		
Procedure dbo GetTemplateListReporting		
SCOPE @ line 86, col 19		
Procedure ssis CRDF_Transco_Insert_Transco		
at @ line 113, col 34
at @ line 121, col 28		
Procedure ssis CRDF_Transco_InsertError_Into_TranscoLog		
at @ line 390, col 34
at @ line 410, col 39
at @ line 423, col 39		
		


 

	
4. Conclusion
	
	
We request that the issues be taken up for remediation in the order of priority. A follow up check can be later scheduled with Microsoft to validate the remediation.
	
	

 

		
5. Appendix
		
		
	5.1 Methodology

We utilize a parser to analyze the T-SQL code submitted. The parser produces an abstract syntax tree of the T-SQL code. The parser is closely aligned with the actual SQL Server engine code, so we can be assured of very accurate support for the T-SQL language grammar. The code is then examined by a set of automated rules. The output of the rule is primarily the affected object: a line of code, a table name or stored procedure name which uniquely identifies the problem area.
The code is then examined by a set of automated rules. The output of the rule is primarily the affected object: a line of code, a table name or stored procedure name which uniquely identifies the problem area.
	


