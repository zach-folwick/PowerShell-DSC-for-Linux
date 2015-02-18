IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetAllDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetAllDetails]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FileMasInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FileMasInsert]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[FnGetTeamName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FnGetTeamName]
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[File_Mas]') AND type in (N'U'))
BEGIN
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'File_Mas'and COLUMN_NAME = 'Scan_Type')
BEGIN
ALTER TABLE [File_Mas]
ADD Scan_Type int NULL DEFAULT '1' WITH VALUES
END
END
GO
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
SET ANSI_NULLS ON
GO
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

EXEC dbo.sp_executesql @statement = N'UPDATE [Hist_Mgmt]
		SET Context = REPLACE(Context, ''Resoutce ID:'', ''Resource ID:'')
		FROM [Hist_Mgmt]
		WHERE SUBSTRING(Context, 0, 13) = ''Resoutce ID:'''

END
GO
