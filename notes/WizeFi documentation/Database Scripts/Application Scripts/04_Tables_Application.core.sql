SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO

IF SCHEMA_ID('Application') IS NULL
	EXEC('CREATE SCHEMA Application') 
GO


PRINT 'Add [Log] table' 
IF OBJECT_ID(N'[Application].[Log]') IS NOT NULL 
	DROP TABLE [Application].[Log] 
GO
CREATE TABLE [Application].[Log](
    [LogId] [int] IDENTITY(1,1) NOT NULL,
    [LogDate] [datetime] NOT NULL,
    [Thread] [varchar](255) NOT NULL,
    [Level] [varchar](50) NOT NULL,
    [Logger] [varchar](255) NOT NULL,
    [MethodName] [varchar](255) NULL,
    [Message] [varchar](4000) NOT NULL,
    [Exception] [varchar](8000) NULL
) ON [PRIMARY]
 

GO