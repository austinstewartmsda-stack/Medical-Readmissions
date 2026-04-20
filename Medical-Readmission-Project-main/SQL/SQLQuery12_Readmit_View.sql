USE [readmit_data]
GO

/****** Object:  View [dbo].[average_readmit_rate_per_month]    Script Date: 1/27/2026 1:14:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[average_readmit_rate_per_month] AS
SELECT
    AVG(Readmission_Rate) AS average_readmit_rate
FROM [dbo].[ffs-medicare-30-day-readmission-rate-puf];
GO


