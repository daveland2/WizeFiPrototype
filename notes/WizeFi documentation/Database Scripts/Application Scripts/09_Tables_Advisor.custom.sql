SET QUOTED_IDENTIFIER,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    ANSI_PADDING,
    ANSI_NULLS,
    ANSI_WARNINGS ON
GO



/*
	Currently dont have a way to specify a binary data field so this one is manual 
	(but not required in the application either (used in report).
*/

ALTER TABLE Advisor.Company
ADD 
	[Logo] [varbinary](MAX) NULL
GO










