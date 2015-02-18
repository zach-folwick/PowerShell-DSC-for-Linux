SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Version]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Version](
	[Version_ID] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[Version] [nchar](20) NULL
) ON [PRIMARY]
END
Go
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM Version)
BEGIN 
INSERT INTO Version values('1.1')
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Task_Mas]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Task_Mas](
	[Task_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Task_Name] [nvarchar](500) NULL,
	[Task_Local_Name] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_Task_Mas] PRIMARY KEY NONCLUSTERED 
(
	[Task_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Team_Mas]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Team_Mas](
	[Team_Id] [numeric](10, 0) IDENTITY(1,1) NOT NULL,
	[Team_Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_Team_Mas] PRIMARY KEY NONCLUSTERED 
(
	[Team_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetHisFileId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[FnGetHisFileId] 
(
	-- Add the parameters for the function here
	@File_Name NVARCHAR(450),
	@Task_Id bigint
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
DECLARE @File_Id INT
IF NOT EXISTS (SELECT [File_Id] FROM dbo.Hist_File_Mas  WHERE  File_Name = @File_Name AND Task_Id = @Task_Id)
	SET @File_Id = -9999
ELSE
	SELECT @File_Id = [File_Id] FROM dbo.Hist_File_Mas  WHERE  File_Name = @File_Name AND Task_Id = @Task_Id
	RETURN @File_Id
END


' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetEmpName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[FnGetEmpName] 
(
	-- Add the parameters for the function here
	@EmpId BIGINT
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
DECLARE @Emp_Name nvarchar(100)

IF NOT EXISTS (SELECT Emp_Name FROM Emp_Mas WHERE Emp_Id = @EmpId)
	SET @Emp_Name = ''''
ELSE
	SELECT @Emp_Name = Emp_Name FROM Emp_Mas WHERE Emp_Id = @EmpId
	RETURN @Emp_Name
END
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Emp_Mas]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Emp_Mas](
	[Emp_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Emp_Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_Emp_Mas] PRIMARY KEY NONCLUSTERED 
(
	[Emp_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Hist_Mgmt]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Hist_Mgmt](
	[File_Id] [bigint] NOT NULL,
	[Task_Id] [bigint] NULL,
	[Term] [nvarchar](100) NOT NULL,
	[Class] [nvarchar](100) NOT NULL,
	[Severity] [numeric](2, 0) NOT NULL,
	[Context] [nvarchar](400) NOT NULL,
	[Context_Info] [nvarchar](4000) NOT NULL,
	[IssueType] [nvarchar](2) NOT NULL,
	[Invest_Id] [bigint] NULL,
	[version] [int] NOT NULL,
	[Bug_No] [bigint] NULL,
	[IsSourceComment] [bit] NULL,
	[IsMigrated] [bit] NULL CONSTRAINT [DF_Hist_Mgmt_IsMigrated]  DEFAULT ((0))
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[Hist_File_Mas]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Hist_File_Mas](
	[File_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[File_Name] [nvarchar](450) NOT NULL,
	[FOTFile_Id] [bigint] NULL,
	[Task_Id] [bigint] NOT NULL,
 CONSTRAINT [PK_Hist_File_mas] PRIMARY KEY NONCLUSTERED 
(
	[File_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[File_Mas]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[File_Mas](
	[File_Id] [bigint] IDENTITY(1,1) NOT NULL,
	[File_Name] [nvarchar](450) NOT NULL,
	[Owner_Id] [bigint] NOT NULL,
	[Team_Id] [numeric](10, 0) NOT NULL,
	[Scan_Type] [int] NULL  DEFAULT ((1)),
 CONSTRAINT [PK_File_mas] PRIMARY KEY NONCLUSTERED 
(
	[File_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetTaskId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[FnGetTaskId] 
(
	-- Add the parameters for the function here
	 @Task_Name NVARCHAR(500),
	 @Task_Local_Name NVARCHAR(500)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
DECLARE @Task_Id INT
IF NOT EXISTS (SELECT [Task_Id] FROM dbo.Task_Mas WHERE  Task_Local_Name = @Task_Local_Name and Task_Name =@Task_Name)
	SET @Task_Id = -9999
ELSE
	SELECT @Task_Id = [Task_Id] FROM dbo.Task_Mas WHERE  Task_Local_Name = @Task_Local_Name and Task_Name =@Task_Name
	RETURN @Task_Id
END
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetFileId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Shweta>
-- =============================================
CREATE FUNCTION [dbo].[FnGetFileId]
(
	-- Add the parameters for the function here
	@File_Name NVARCHAR(500)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @File_Id INT 
IF NOT EXISTS (SELECT File_Name FROM File_Mas WHERE File_Name = @File_Name)
	SET @File_Id = -9999 
ELSE
	-- Add the T-SQL statements to compute the return value here
	SELECT @File_Id = File_Id FROM File_Mas WHERE File_Name = @File_Name

	-- Return the result of the function
	RETURN @File_Id

END
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetFileOwner]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[FnGetFileOwner] 
(
	-- Add the parameters for the function here
	@File_Id BIGINT --its not FOTFile_Id
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
DECLARE @Owner_Name  nvarchar(100)

SELECT     @Owner_Name = [Emp_Mas].[Emp_Name]
FROM         [Emp_Mas] INNER JOIN
                      [File_Mas] ON [Emp_Mas].[Emp_Id] = [File_Mas].[Owner_Id] INNER JOIN
                      [Hist_File_Mas] ON [File_Mas].[File_Id] = [Hist_File_Mas].[FOTFile_Id]
		 WHERE [Hist_File_Mas].[File_Id] = @File_Id 
	SELECT @Owner_Name = ISNULL(@Owner_Name,'''')
	RETURN @Owner_Name
END
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_FetchFOTO]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_FetchFOTO] 
	@File_Name	nvarchar(500),
	@Owner	    nvarchar(100) OUTPUT,
	@Team_Name	nvarchar(100) OUTPUT,
	@FOTFile_Id BIGINT OUTPUT
AS
BEGIN

	SELECT		@FOTFile_Id  = [File_Id], 
				@Owner = [Emp_Mas].[Emp_Name], 
				@Team_Name = [Team_Mas].[Team_Name]
		FROM         [File_Mas] INNER JOIN
                      [Emp_Mas] ON [File_Mas].[Owner_Id] = [Emp_Mas].[Emp_Id] INNER JOIN
                      [Team_Mas] ON [File_Mas].[Team_Id] = [Team_Mas].[Team_Id]
		where [File_Mas].[File_Name]=@File_Name
END







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetFOTOs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFOTOs] 
	@File_Name	nvarchar(500)
AS
BEGIN

	SELECT		[File_Id] as FOTOID, 
				[File_Mas].[File_Name] as ''File_Name'',
				[Emp_Mas].[Emp_Name] as Owner  , 
				[Team_Mas].[Team_Name] as Team_name
		FROM         [File_Mas] INNER JOIN
                      [Emp_Mas] ON [File_Mas].[Owner_Id] = [Emp_Mas].[Emp_Id] INNER JOIN
                      [Team_Mas] ON [File_Mas].[Team_Id] = [Team_Mas].[Team_Id]
		where [File_Mas].[File_Name] like  @File_Name + ''%''
		order by [File_Mas].[File_Name] desc
END








' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetTeamName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'Create FUNCTION [dbo].[FnGetTeamName] 
(
	-- Add the parameters for the function here
	@File_Id BIGINT --its not FOTFile_Id
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
DECLARE @Team_Name  nvarchar(100)


		SELECT    @Team_Name = [Team_Mas].[Team_Name]
		FROM         [File_Mas] INNER JOIN
							  [Team_Mas] ON [File_Mas].[Team_Id] = [Team_Mas].[Team_Id] INNER JOIN
							  [Hist_File_Mas] ON [File_Mas].[File_Id] = [Hist_File_Mas].[FOTFile_Id]
		WHERE [Hist_File_Mas].[File_Id] = @File_Id 

	SELECT @Team_Name = ISNULL(@Team_Name,'''')
	RETURN @Team_Name
END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetAllDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllDetails]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT     File_Mas.File_Id, File_Mas.File_Name, File_Mas.Owner_Id, File_Mas.Team_Id,File_Mas.Scan_Type, Team_Mas.Team_Name, Emp_Mas.Emp_Name
FROM         File_Mas INNER JOIN
                      Team_Mas ON File_Mas.Team_Id = Team_Mas.Team_Id INNER JOIN
                      Emp_Mas ON File_Mas.Owner_Id = Emp_Mas.Emp_Id

End
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetTeamId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Shweta>
-- =============================================
Create FUNCTION [dbo].[FnGetTeamId]
(
	-- Add the parameters for the function here
	@Team_Name NVARCHAR(500)
	
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Team_Id INT 
	
	IF NOT EXISTS (SELECT Team_Id FROM Team_Mas WHERE Team_Name = @Team_Name)
	SET @Team_Id = -9999
ELSE
	SELECT @Team_Id = Team_Id FROM Team_Mas WHERE Team_Name = @Team_Name
	
	-- Return the result of the function
	RETURN @Team_Id

END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetEmpId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[FnGetEmpId] 
(
	-- Add the parameters for the function here
	@Emp_Name NVARCHAR(400)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
DECLARE @Emp_Id INT
IF NOT EXISTS (SELECT Emp_Id FROM Emp_Mas WHERE Emp_Name = @Emp_Name)
	SET @Emp_Id = -9999
ELSE
	SELECT @Emp_Id = Emp_Id FROM Emp_Mas WHERE Emp_Name = @Emp_Name
	RETURN @Emp_Id
END
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_HistmgtInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistmgtInsert] 
	@File_Name nvarchar(450),
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@Term nvarchar(100) ,
	@Class nvarchar(100),
	@Severity numeric(2, 0),
	@Context nvarchar(400) ,
	@Context_Info nvarchar(4000),
	@IssueType nvarchar(2) ,
	@Invest_Name nvarchar(100),
	@version int,
	@Bug_No BIGINT,
	@IsSourceComment bit ,
	@FOTFile_Id bigint
AS
BEGIN

	DECLARE @Invest_Id	BIGINT 
	DECLARE @File_Id	BIGINT 
	DECLARE @Task_Id	BIGINT 


-- Get Task ID 
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)
-- DEBUG: SELECT 1, @Task_Id 

IF ( @Task_Id <= 0) 
	BEGIN 
		INSERT INTO [Task_Mas]
				   ([Task_Name]
				   ,[Task_Local_Name])
			 VALUES
				   (@Task_Name,
					@Task_Local_Name)	
		SELECT @Task_Id = SCOPE_IDENTITY()	
	END 
-- DEBUG: SELECT 11, @Task_Id 

-- Get File ID
SELECT @File_Id = dbo.FnGetHisFileId(@File_Name,@Task_Id)
-- DEBUG: SELECT 2, @File_Id 



IF ( @File_Id <= 0) 
	BEGIN 
		INSERT INTO [Hist_File_Mas]
				   ([File_Name],
					[FOTFile_Id],
					[Task_Id])
			 VALUES(@File_Name,isnull(@FOTFile_Id,0),@Task_Id)
		SELECT @File_Id = SCOPE_IDENTITY()	

	END 
-- DEBUG: SELECT 22, @File_Id 
update  Hist_File_Mas 
		set FOTFile_Id = @FOTFile_Id
where @File_Id = [File_Id]  and Task_Id = @Task_Id

-- Get Investigator ID 

SELECT @Invest_Id = dbo.FnGetEmpId(@Invest_Name)
-- DEBUG: SELECT 3, @Invest_Id  
IF ( @Invest_Id <= 0) 
	BEGIN 
		INSERT INTO [dbo].[Emp_Mas]
				   ([Emp_Name])
			 VALUES
				   (@Invest_Name)
		SELECT @Invest_Id = SCOPE_IDENTITY()	
	END 


		DECLARE @IsMigrated bit 
		SET @IsMigrated  = 0
		SELECT  @IsMigrated = IsMigrated
					FROM 	[Hist_Mgmt]
						WHERE 
							[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
							AND [Severity] = @Severity 
							AND [Context_Info] = @Context_Info
							AND [IsSourceComment] =@IsSourceComment
							AND version<=@version



IF (@IsMigrated=1) 
	BEGIN 
	   UPDATE [Hist_Mgmt]
		   SET 
			  [IssueType] = @IssueType,
			  [Invest_Id] = @Invest_Id,
			  [version] = @version,
			  [Bug_No] = @Bug_No,
			  [IsMigrated] = 0,
			  [Context] = @Context ,
			  @IsMigrated =0 
			WHERE [File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
				AND [Severity] = @Severity  AND [Context_Info] = @Context_Info
				AND [IsSourceComment] =@IsSourceComment and @version = version

	END
ELSE
	BEGIN


		-- DEBUG: SELECT 33, @Invest_Id  
		IF NOT EXISTS(
		SELECT [Term] FROM Hist_Mgmt WHERE 
		[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
		AND [Severity] = @Severity AND [Context] = @Context AND [Context_Info] = @Context_Info
		AND [IsSourceComment] =@IsSourceComment  and @version = version
		)
				BEGIN 
						-- DEBUG: SELECT 4

						--Insert into History Management 
						INSERT INTO [Hist_Mgmt]
								   (
									   [File_Id],
									   [Task_Id],
									   [Term],
									   [Class],
									   [Severity],
									   [Context],
									   [Context_Info],
									   [IssueType],
									   [Invest_Id],
									   [version],
									   [Bug_No],
									   [IsSourceComment]
									)
							 VALUES
									( 
									   @File_Id,
									   @Task_Id,
									   @Term,
									   @Class,
									   @Severity,
									   @Context,
									   @Context_Info,
									   @IssueType,
									   @Invest_Id,
									   @version,
									   @Bug_No,
									   @IsSourceComment
									)
				END 
		ELSE
			BEGIN 
				

					-- DEBUG: SELECT 5
					UPDATE [Hist_Mgmt]
					   SET 
						  [IssueType] = @IssueType,
						  [Invest_Id] = @Invest_Id,
						  [version] = @version,
						  [Bug_No] = @Bug_No,
						  [IsMigrated] = 0
						WHERE [File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
							AND [Severity] = @Severity AND [Context] = @Context AND [Context_Info] = @Context_Info
							AND [IsSourceComment] =@IsSourceComment and @version = version
			END 
	END

END


















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_HistmgtMigrate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistmgtMigrate] 
	@File_Name nvarchar(450),
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@Term nvarchar(100) ,
	@Class nvarchar(100),
	@Severity numeric(2, 0),
	@Context nvarchar(400) ,
	@Context_Info nvarchar(4000),
	@IssueType nvarchar(2) ,
	@Invest_Name nvarchar(100),
	@version int,
	@Bug_No BIGINT,
	@IsSourceComment bit ,
	@FOTFile_Id bigint
AS
BEGIN

	DECLARE @Invest_Id	BIGINT 
	DECLARE @File_Id	BIGINT 
	DECLARE @Task_Id	BIGINT 


-- Get Task ID 
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)
-- DEBUG: SELECT 1, @Task_Id 

IF ( @Task_Id <= 0) 
	BEGIN 
		INSERT INTO [Task_Mas]
				   ([Task_Name]
				   ,[Task_Local_Name])
			 VALUES
				   (@Task_Name,
					@Task_Local_Name)	
		SELECT @Task_Id = SCOPE_IDENTITY()	
	END 
-- DEBUG: SELECT 11, @Task_Id 

-- Get File ID
SELECT @File_Id = dbo.FnGetHisFileId(@File_Name,@Task_Id)
-- DEBUG: SELECT 2, @File_Id 



IF ( @File_Id <= 0) 
	BEGIN 
		INSERT INTO [Hist_File_Mas]
				   ([File_Name],
					[FOTFile_Id],
					[Task_Id])
			 VALUES(@File_Name,isnull(@FOTFile_Id,0),@Task_Id)
		SELECT @File_Id = SCOPE_IDENTITY()	

	END 
-- DEBUG: SELECT 22, @File_Id 
update  Hist_File_Mas 
		set FOTFile_Id = @FOTFile_Id
where @File_Id = [File_Id]  and Task_Id = @Task_Id

-- Get Investigator ID 

SELECT @Invest_Id = dbo.FnGetEmpId(@Invest_Name)
-- DEBUG: SELECT 3, @Invest_Id  
IF ( @Invest_Id <= 0) 
	BEGIN 
		INSERT INTO [dbo].[Emp_Mas]
				   ([Emp_Name])
			 VALUES
				   (@Invest_Name)
		SELECT @Invest_Id = SCOPE_IDENTITY()	
	END 

-- DEBUG: SELECT 33, @Invest_Id  
IF NOT EXISTS(
SELECT [Term] FROM Hist_Mgmt WHERE 
[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
AND [Severity] = @Severity AND [Context_Info] = @Context_Info
AND [IsSourceComment] =@IsSourceComment  and @version = version
)
		BEGIN 
				-- DEBUG: SELECT 4

				--Insert into History Management 
				INSERT INTO [Hist_Mgmt]
						   (
							   [File_Id],
							   [Task_Id],
							   [Term],
							   [Class],
							   [Severity],
							   [Context],
							   [Context_Info],
							   [IssueType],
							   [Invest_Id],
							   [version],
							   [Bug_No],
							   [IsSourceComment],
							   [IsMigrated]
							)
					 VALUES
							( 
							   @File_Id,
							   @Task_Id,
							   @Term,
							   @Class,
							   @Severity,
							   @Context,
							   @Context_Info,
							   @IssueType,
							   @Invest_Id,
							   @version,
							   @Bug_No,
							   @IsSourceComment,
							   1
							)
		END 
ELSE
	BEGIN 

			-- DEBUG: SELECT 5
			UPDATE [Hist_Mgmt]
			   SET 
				  [IssueType] = @IssueType,
				  [Invest_Id] = @Invest_Id,
				  [version] = @version,
				  [Bug_No] = @Bug_No,
				  [IsMigrated] =1
				WHERE [File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
					AND [Severity] = @Severity AND [Context] = @Context AND [Context_Info] = @Context_Info
					AND [IsSourceComment] =@IsSourceComment and @version = version
	END 

END


















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_HistmgtDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistmgtDelete] 
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500)
AS
BEGIN

	DECLARE @Task_Id	BIGINT 

-- Get Task ID 
		SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)

		IF ( @Task_Id >= 0) 
			BEGIN 

		--Delete [dbo.Hist_Mgmt]
				DELETE FROM [Hist_Mgmt]
					WHERE Task_Id = @Task_Id

		--Delete [Hist_File_Mas]
				DELETE FROM [Hist_File_Mas] 
					WHERE Task_Id = @Task_Id

		--Delete [Task_Mas]
				DELETE FROM [Task_Mas]
					WHERE Task_Id = @Task_Id

		END 

END






' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FileMasInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[FileMasInsert]
	@File_Name nvarchar(500),
	@Team_Name nvarchar(500),
	@Owner_Name nvarchar(500),
	@File_ID bigint ,
	@Scan_Type int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @Owner_Id	BIGINT 
	DECLARE @Team_Id	BIGINT 
	SET NOCOUNT ON;

--Get TeamID
SELECT @Team_Id =dbo.FnGetTeamId(@Team_Name)

IF ( @Team_Id <= 0) 
	BEGIN 
		INSERT INTO Team_Mas
				   (Team_Name)
			 VALUES
				   (@Team_Name)	
		SELECT @Team_Id = SCOPE_IDENTITY()	
	END 

--Get OwnerID
SELECT @Owner_Id = dbo.FnGetEmpId(@Owner_Name)

IF ( @Owner_Id <= 0) 
	BEGIN 
		INSERT INTO Emp_Mas
				   ([Emp_Name])
			 VALUES
				   (@Owner_Name)	
		SELECT @Owner_Id = SCOPE_IDENTITY()	
	END 
--Insert Sp
--if (isnull(@File_ID))

if (isnull(@File_ID,0) = 0)
begin 
		select @File_ID = File_ID  from [File_Mas]
		where [File_Name] = @File_Name
end 

if (isnull(@File_ID,0) = 0)
begin

INSERT INTO [File_Mas]
           ([File_Name]
           ,[Owner_Id]
           ,[Team_Id]
           ,[Scan_Type])
     VALUES
           (@File_Name,
            @Owner_Id,
            @Team_Id,
            @Scan_Type)
end 
else
begin
Update File_Mas 
	Set [File_Name] = @File_Name,
		[Owner_Id] = @Owner_Id,
		Team_Id = @Team_Id,
		Scan_Type = @Scan_Type
where  [File_Id] = @File_Id
end 
    
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FileMasDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[FileMasDelete]
	@File_Name nvarchar(500),
	@Team_Name nvarchar(500),
	@Owner_Name nvarchar(500),
	@IsHistRecPresent BIT OUTPUT 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @Owner_Id	BIGINT 
	DECLARE @Team_Id	BIGINT 
	
	
	SET NOCOUNT ON;

set @IsHistRecPresent = 0;


--Get TeamID
SELECT @Team_Id = dbo.FnGetTeamId(@Team_Name)


--IF ( @Team_Id <= 0) 
--	BEGIN 
--		Delete  From File_Mas
--				   ([Team_Name])
--			 VALUES
--				   (@Team_Name)	
--		SELECT @Team_Id = SCOPE_IDENTITY()	
--	END 


--Get OwnerID
SELECT @Owner_Id = dbo.FnGetEmpId(@Owner_Name)

--IF ( @Owner_Id <= 0) 
--	BEGIN 
--		Delete  From Emp_Mas
--				   ([Emp_Name])
--			 VALUES
--				   (@Owner_Name)	
--		SELECT @Owner_Id = SCOPE_IDENTITY()	
--	END 
--Delete Sp

--IF NOT EXISTS ( select File_Mas.File_Id from Hist_File_Mas INNER JOIN File_Mas
--				ON File_Mas.File_Id = Hist_File_Mas.FOTFile_Id where @File_Name = File_Mas.[File_Name]) 
BEGIN 
		DELETE FROM [File_Mas]
				WHERE @Team_ID = Team_Id and @Owner_ID = Owner_ID and @File_Name = [File_Name]
END 
--ELSE 
 BEGIN 
	SET @IsHistRecPresent =1
 END 

END 





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[CheckRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[CheckRecord]
	@File_Name nvarchar(500),
	@Team_Name nvarchar(500),
	@Owner_Name nvarchar(500),
	@IsHistRecPresent BIT OUTPUT 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @Owner_Id	BIGINT 
	DECLARE @Team_Id	BIGINT 
	
	
	SET NOCOUNT ON;

set @IsHistRecPresent = 1;


--Get TeamID
SELECT @Team_Id = dbo.FnGetTeamId(@Team_Name)


--IF ( @Team_Id <= 0) 
--	BEGIN 
--		Delete  From File_Mas
--				   ([Team_Name])
--			 VALUES
--				   (@Team_Name)	
--		SELECT @Team_Id = SCOPE_IDENTITY()	
--	END 


--Get OwnerID
SELECT @Owner_Id = dbo.FnGetEmpId(@Owner_Name)

--IF ( @Owner_Id <= 0) 
--	BEGIN 
--		Delete  From Emp_Mas
--				   ([Emp_Name])
--			 VALUES
--				   (@Owner_Name)	
--		SELECT @Owner_Id = SCOPE_IDENTITY()	
--	END 
--Delete Sp

IF EXISTS ( select File_Mas.File_Id from Hist_File_Mas INNER JOIN File_Mas
				ON File_Mas.File_Id = Hist_File_Mas.FOTFile_Id where @File_Name = File_Mas.[File_Name]) 
BEGIN 
	SET @IsHistRecPresent = 1
 END  
ELSE 
 BEGIN 
	SET @IsHistRecPresent = 0
 END 

END 





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_FOTOMigrate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_FOTOMigrate]
	@File_Name nvarchar(500),
	@Team_Name nvarchar(500),
	@Owner_Name nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @Owner_Id	BIGINT 
	DECLARE @Team_Id	BIGINT 
	DECLARE @File_ID	BIGINT
	SET @File_ID =0
	SET NOCOUNT ON;

--Get TeamID
SELECT @Team_Id =dbo.FnGetTeamId(@Team_Name)

IF ( @Team_Id <= 0) 
	BEGIN 
		INSERT INTO Team_Mas
				   (Team_Name)
			 VALUES
				   (@Team_Name)	
		SELECT @Team_Id = SCOPE_IDENTITY()	
	END 

--Get OwnerID
SELECT @Owner_Id = dbo.FnGetEmpId(@Owner_Name)

IF ( @Owner_Id <= 0) 
	BEGIN 
		INSERT INTO Emp_Mas
				   ([Emp_Name])
			 VALUES
				   (@Owner_Name)	
		SELECT @Owner_Id = SCOPE_IDENTITY()	
	END 
--Insert Sp
--if (isnull(@File_ID))

if (isnull(@File_ID,0) = 0)
begin 
		select @File_ID = File_ID  from [File_Mas]
		where [File_Name] = @File_Name
end 

if (isnull(@File_ID,0) = 0)
begin

INSERT INTO [File_Mas]
           ([File_Name]
           ,[Owner_Id]
           ,[Team_Id])
     VALUES
           (@File_Name,
            @Owner_Id,
            @Team_Id)
end 
else
begin
Update File_Mas 
	Set [File_Name] = @File_Name,
		[Owner_Id] = @Owner_Id,
		Team_Id = @Team_Id
where  [File_Id] = @File_Id
end 
    
END





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteHistmgtversion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_deleteHistmgtversion] 
	
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@version int
	
AS
BEGIN

	DECLARE @Task_Id	BIGINT 

-- Get Task ID 
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)
DELETE FROM [Hist_Mgmt]
   	WHERE [Task_Id] = @Task_Id  AND version = @version

END







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetHistmgtDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt Insert
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHistmgtDetail] 
	@File_Name nvarchar(450),
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@Term nvarchar(100) ,
	@Class nvarchar(100),
	@Severity numeric(2, 0),
	@Context nvarchar(400) ,
	@Context_Info nvarchar(4000),
	@version int,
	@IsSourceComment bit ,

	@IssueType nvarchar(2) OUTPUT,
	@Invest_Name nvarchar(100) OUTPUT,
	@Bug_No BigInt OUTPUT,
	@IsDataExists bit OUTPUT
AS
BEGIN

	DECLARE @File_Id	BIGINT 
	DECLARE @Task_Id	BIGINT 
	DECLARE @IsMigrated bit 

	DECLARE @PC4ContextCheck int

	set @IsDataExists = 0
	SET @PC4ContextCheck =1
	SET @IsMigrated = 0





-- Get Task ID 
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)

-- Get File ID
SELECT @File_Id = dbo.FnGetHisFileId(@File_Name,@Task_Id)

SELECT Top 1 @IsMigrated = IsMigrated
			FROM 	[Hist_Mgmt]
				WHERE 
					[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
					AND [Severity] = @Severity 
					AND [Context_Info] = substring(@Context_Info,0,LEN(@Context_Info)) 
					AND [IsSourceComment] =@IsSourceComment
					AND version<=@version order by version desc,IssueType DESC

if (@IsMigrated =0 )
	BEGIN 
		set @PC4ContextCheck = 2
		SELECT Top 1 @IsMigrated = IsMigrated
			FROM 	[Hist_Mgmt]
				WHERE 
					[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
					AND [Severity] = @Severity 
					AND [Context_Info] = @Context_Info
					AND [IsSourceComment] =@IsSourceComment
					AND version<=@version order by version desc,IssueType DESC
	END 

IF (@IsMigrated=1) 
	BEGIN 
		IF (@PC4ContextCheck = 1)
			BEGIN 
				SELECT  Top 1
									  
										  @IssueType = [IssueType] ,
										  @Invest_Name = [dbo].[FnGetEmpName]([Invest_Id]) ,
										  @Bug_No= isnull([Bug_No],0),
										  @IsDataExists = 1
									FROM 	[Hist_Mgmt]
										WHERE 
											[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
											AND [Severity] = @Severity 
											AND [Context_Info] = substring(@Context_Info,0,LEN(@Context_Info)) 
											AND [IsSourceComment] =@IsSourceComment
											AND version<=@version 
									order by version desc,IssueType DESC
			END 
	   ELSE
			BEGIN
				SELECT  Top 1
									  
										  @IssueType = [IssueType] ,
										  @Invest_Name = [dbo].[FnGetEmpName]([Invest_Id]) ,
										  @Bug_No= isnull([Bug_No],0),
										  @IsDataExists = 1
									FROM 	[Hist_Mgmt]
										WHERE 
											[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
											AND [Severity] = @Severity 
											AND [Context_Info] = @Context_Info 
											AND [IsSourceComment] =@IsSourceComment
											AND version<=@version 
									order by version desc,IssueType DESC
			END 
	
	END 
ELSE
BEGIN 
		if EXISTS(SELECT
						   [Task_Id]
						  
					FROM 	[Hist_Mgmt]
						WHERE 
							[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
							AND [Severity] = @Severity AND [Context] = @Context 
							AND [Context_Info] = @Context_Info
							AND [IsSourceComment] =@IsSourceComment
							AND version<=@version )
				BEGIN 		

						SELECT  Top 1
							  
								  @IssueType = [IssueType] ,
								  @Invest_Name = [dbo].[FnGetEmpName]([Invest_Id]) ,
								  @Bug_No= isnull([Bug_No],0),
								  @IsDataExists = 1
							FROM 	[Hist_Mgmt]
								WHERE 
									[File_Id] = @File_Id AND [Task_Id] = @Task_Id AND [Term] = @Term 
									AND [Severity] = @Severity AND [Context] = @Context 
									AND [Context_Info] = @Context_Info
									AND [IsSourceComment] =@IsSourceComment
									AND version<=@version 
							order by version desc
				END
		ELSE
			BEGIN 
				set @IsDataExists = 0
			END
END 

END
















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetLatestHist]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt History Data
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLatestHist] 
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500)
AS
BEGIN
	DECLARE @Task_Id BIGINT 
	DECLARE @maxversion INT 
	SELECT @maxversion =-1
	
	
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)

if (@Task_Id is null)
begin 
	SET @maxversion =-1
end 
else
begin 
	
	select @maxversion = max(version) from Hist_Mgmt WHERE Hist_Mgmt.Task_Id = @Task_Id  

IF (@maxversion IS NULL )
BEGIN 
SET @maxversion =-1
END 
 
SELECT			IDENTITY(INT,1,1)as SR_NO,
				Hist_File_Mas.File_Name AS ''File'',
				Hist_Mgmt.Context AS Location, 
				Hist_Mgmt.Term AS Term, 
				Hist_Mgmt.Severity, 
                Hist_Mgmt.Class AS Class, 
				Hist_Mgmt.IssueType as ''FP/TP'',  
				Hist_Mgmt.IsSourceComment, 
				Hist_Mgmt.Context_Info as Context, 
				Hist_Mgmt.version as version, 
				[dbo].[FnGetTeamName](Hist_File_Mas.File_Id) AS ''Team Name'', 
				[dbo].[FnGetFileOwner](Hist_File_Mas.File_Id) AS Owner,
				dbo.FnGetEmpName(Hist_Mgmt.Invest_Id) AS Investigator,
                Hist_Mgmt.Bug_No as ''Bug No.'' ,
				Hist_File_Mas.FOTFile_Id INTO #TEMP
		FROM        
		Hist_Mgmt INNER JOIN dbo.Hist_File_Mas ON dbo.Hist_File_Mas.File_Id = Hist_Mgmt.File_Id 
		WHERE Hist_Mgmt.Task_Id =  @Task_Id  AND Hist_Mgmt.version = @maxversion 

SELECT * FROM #TEMP

end 

END 












' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllHist]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		V-wagava
-- Create date: 05-16-2007
-- Description:	His mgt History Data
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAllHist] 
	@Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@maxversion INT OUTPUT
AS
BEGIN
	DECLARE @Task_Id BIGINT 
	SELECT @maxversion =-1
	
	
SELECT @Task_Id = dbo.FnGetTaskId(@Task_Name,@Task_Local_Name)

if (@Task_Id is null)
begin 
	SET @maxversion =-1
end 
else
begin 
	
	select @maxversion = max(version) from Hist_Mgmt WHERE Hist_Mgmt.Task_Id = @Task_Id  

IF (@maxversion IS NULL )
BEGIN 
SET @maxversion =-1
END 
 
SELECT			IDENTITY(INT,1,1)as SR_NO,
				Hist_File_Mas.File_Name AS ''File'',
				Hist_Mgmt.Context AS Location, 
				Hist_Mgmt.Term AS Term, 
				CASE Hist_Mgmt.Severity
						WHEN 1 THEN 1
						WHEN 2 THEN 2
						WHEN 3 THEN 3
						WHEN 4 THEN 4
						WHEN 15 THEN ''''
						ELSE ''Invalid Severity''
				END as Severity,
                Hist_Mgmt.Class AS Class, 
				Hist_Mgmt.IssueType as ''FP/TP'',  
				Hist_Mgmt.IsSourceComment, 
				Hist_Mgmt.Context_Info as Context, 
				Hist_Mgmt.version as version, 
				[dbo].[FnGetTeamName](Hist_File_Mas.File_Id) AS ''Team Name'', 
				[dbo].[FnGetFileOwner](Hist_File_Mas.File_Id) AS Owner,
				dbo.FnGetEmpName(Hist_Mgmt.Invest_Id) AS Investigator,
                Hist_Mgmt.Bug_No as ''Bug No.'' ,
				Hist_File_Mas.FOTFile_Id INTO #TEMP
		FROM        
		Hist_Mgmt INNER JOIN dbo.Hist_File_Mas ON dbo.Hist_File_Mas.File_Id = Hist_Mgmt.File_Id 
		WHERE Hist_Mgmt.Task_Id =  @Task_Id  

SELECT * FROM #TEMP

end 

END 













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_updateHistmgt]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		v-ragho
-- Create date: 07-09-2007
-- Description:	Upadte task details.
--EXEC [dbo].[usp_updateHistmgt] ''HM Test1'', ''HM Test1'', ''V-RAGHO_v-ragho_E:\Rakesh\PolicheckTestData\poli-hang Small.txt'', ''V-RAGHO_v-ragho_E:\Rakesh\PolicheckTestData\poli-hang Med.txt''
-- =============================================
CREATE PROCEDURE [dbo].[usp_updateHistmgt] 
	@Task_Name nvarchar(500),
	@Prev_Task_Name nvarchar(500),
	@Task_Local_Name nvarchar(500),
	@Prev_Task_Local_Name nvarchar(500)
AS
BEGIN
	IF NOT EXISTS (	SELECT	''x'' 
				FROM	task_mas 
				WHERE	task_name = @Prev_Task_Name
				AND		task_local_name = @Prev_Task_Local_Name)
	BEGIN
		RETURN;
	END	
				

	
	IF (@Task_Local_Name != @Prev_Task_Local_Name)
	BEGIN
		--Delete task details
		  EXEC dbo.usp_histmgtDelete @Prev_Task_Name, @Prev_Task_Local_Name	
	END
	ELSE
	BEGIN
		--Update task name and task local Name
		Update	task_mas
		set		task_name = @Task_Name,
				task_local_name = @Task_Local_Name
		WHERE	task_name = @Prev_Task_Name
		AND		task_local_name = @Prev_Task_Local_Name
			
	END
END







' 
END
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_Hist_Mgmt_File_Mas]') AND fkeyid = OBJECT_ID(N'[dbo].[Hist_Mgmt]'))
ALTER TABLE [dbo].[Hist_Mgmt]  WITH CHECK ADD  CONSTRAINT [FK_Hist_Mgmt_File_Mas] FOREIGN KEY([File_Id])
REFERENCES [dbo].[Hist_File_Mas] ([File_Id])
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_Hist_Mgmt_Task_Mas]') AND fkeyid = OBJECT_ID(N'[dbo].[Hist_Mgmt]'))
ALTER TABLE [dbo].[Hist_Mgmt]  WITH CHECK ADD  CONSTRAINT [FK_Hist_Mgmt_Task_Mas] FOREIGN KEY([Task_Id])
REFERENCES [dbo].[Task_Mas] ([Task_Id])
GO

IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_Task_Mas_Hist_File_Mas]') AND fkeyid = OBJECT_ID(N'[dbo].[Hist_File_Mas]'))
ALTER TABLE [dbo].[Hist_File_Mas]  WITH CHECK ADD  CONSTRAINT [FK_Task_Mas_Hist_File_Mas] FOREIGN KEY([Task_Id])
REFERENCES [dbo].[Task_Mas] ([Task_Id])
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_File_Mas_Emp_Mas]') AND fkeyid = OBJECT_ID(N'[dbo].[File_Mas]'))
ALTER TABLE [dbo].[File_Mas]  WITH CHECK ADD  CONSTRAINT [FK_File_Mas_Emp_Mas] FOREIGN KEY([Owner_Id])
REFERENCES [dbo].[Emp_Mas] ([Emp_Id])
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_File_Mas_Team_Mas]') AND fkeyid = OBJECT_ID(N'[dbo].[File_Mas]'))
ALTER TABLE [dbo].[File_Mas]  WITH CHECK ADD  CONSTRAINT [FK_File_Mas_Team_Mas] FOREIGN KEY([Team_Id])
REFERENCES [dbo].[Team_Mas] ([Team_Id])

