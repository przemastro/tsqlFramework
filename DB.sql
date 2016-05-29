USE [master]
GO
/****** Object:  Database [Astro]    Script Date: 2016-05-29 16:05:15 ******/
CREATE DATABASE [Astro]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Astro', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Astro.mdf' , SIZE = 1024000KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Astro_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Astro_log.ldf' , SIZE = 10240KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Astro] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Astro].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Astro] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Astro] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Astro] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Astro] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Astro] SET ARITHABORT OFF 
GO
ALTER DATABASE [Astro] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Astro] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Astro] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Astro] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Astro] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Astro] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Astro] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Astro] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Astro] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Astro] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Astro] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Astro] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Astro] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Astro] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Astro] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Astro] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Astro] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Astro] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Astro] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Astro] SET  MULTI_USER 
GO
ALTER DATABASE [Astro] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Astro] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Astro] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Astro] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Astro]
GO
/****** Object:  StoredProcedure [dbo].[observationsDelta]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[observationsDelta]
   
AS
BEGIN
   
   create table #tempTable
(
	[StarName] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[UPhotometry] [bit] NULL,
	[VPhotometry] [bit] NULL,
	[BPhotometry] [bit] NULL,
)
   insert into #tempTable select StarName, StartDate, EndDate, UPhotometry, VPhotometry, BPhotometry from (
      select StarName, StartDate, EndDate, UPhotometry, VPhotometry, BPhotometry from dbo.StagingObservations
         except
      select StarName, StartDate, EndDate, UPhotometry, VPhotometry, BPhotometry from dbo.Observations) t

	  select * from #tempTable
	  drop table #tempTable
END
  




    
GO
/****** Object:  Table [dbo].[bPhotometry]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bPhotometry](
	[bPhotometryId] [bigint] NOT NULL,
	[bPhotometry] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[bPhotometryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[bPhotometryTime]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[bPhotometryTime](
	[bPhotometryTimeId] [bigint] NOT NULL,
	[bPhotometryTime] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[bPhotometryTimeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[log]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[log](
	[ID] [int] NOT NULL,
	[ProcName] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Message] [varchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[observations]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[observations](
	[ID] [int] NOT NULL,
	[StarName] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[uPhotometryId] [bigint] NULL,
	[uPhotometryTimeId] [bigint] NULL,
	[uPhotometryFlag] [bit] NULL,
	[vPhotometryId] [bigint] NULL,
	[vPhotometryTimeId] [bigint] NULL,
	[vPhotometryFlag] [bit] NULL,
	[bPhotometryId] [bigint] NULL,
	[bPhotometryTimeId] [bigint] NULL,
	[bPhotometryFlag] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[stagingObservations]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[stagingObservations](
	[ID] [int] NOT NULL,
	[StarName] [varchar](50) NULL,
	[StartDate] [varchar](1) NULL,
	[EndDate] [varchar](1) NULL,
	[uPhotometry] [varchar](1) NULL,
	[uPhotometryTime] [varchar](1) NULL,
	[vPhotometry] [varchar](1) NULL,
	[vPhotometryTime] [varchar](1) NULL,
	[bPhotometry] [varchar](1) NULL,
	[bPhotometryTime] [varchar](1) NULL,
	[Status] [varchar](1) NULL,
	[Active] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[uPhotometry]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[uPhotometry](
	[uPhotometryId] [bigint] NOT NULL,
	[uPhotometry] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[uPhotometryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[uPhotometryTime]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[uPhotometryTime](
	[uPhotometryTimeId] [bigint] NOT NULL,
	[uPhotometryTime] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[uPhotometryTimeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[vPhotometry]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[vPhotometry](
	[vPhotometryId] [bigint] NOT NULL,
	[vPhotometry] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[vPhotometryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[vPhotometryTime]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[vPhotometryTime](
	[vPhotometryTimeId] [bigint] NOT NULL,
	[vPhotometryTime] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[vPhotometryTimeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[bPhotometrySorted]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[bPhotometrySorted] as 
SELECT        TOP (100) PERCENT dbo.Observations.ID, dbo.Observations.StarName, dbo.Observations.StartDate, dbo.Observations.EndDate, 
                         dbo.bPhotometryTime.bPhotometryTime, dbo.bPhotometry.bPhotometry
FROM            dbo.bPhotometry INNER JOIN
                         dbo.Observations ON dbo.bPhotometry.bPhotometryId = dbo.Observations.bPhotometryId CROSS JOIN
                         dbo.bPhotometryTime
ORDER BY dbo.Observations.StartDate, dbo.bPhotometryTime.bPhotometryTime

GO
/****** Object:  View [dbo].[observationsSorted]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[observationsSorted] as 
  SELECT        TOP (100) PERCENT ID, StarName, StartDate, EndDate, uPhotometryFlag, vPhotometryFlag, bPhotometryFlag
FROM            dbo.Observations
ORDER BY StartDate
GO
/****** Object:  View [dbo].[uPhotometrySorted]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[uPhotometrySorted] as 
SELECT        TOP (100) PERCENT dbo.Observations.ID, dbo.Observations.StarName, dbo.Observations.StartDate, dbo.Observations.EndDate, 
                         dbo.uPhotometry.uPhotometry, dbo.uPhotometryTime.uPhotometryTime
FROM            dbo.uPhotometry INNER JOIN
                         dbo.Observations ON dbo.uPhotometry.uPhotometryId = dbo.Observations.uPhotometryId CROSS JOIN
                         dbo.uPhotometryTime
ORDER BY dbo.Observations.StartDate, dbo.uPhotometryTime.uPhotometryTime
GO
/****** Object:  View [dbo].[vPhotometrySorted]    Script Date: 2016-05-29 16:05:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vPhotometrySorted] as 
SELECT        TOP (100) PERCENT dbo.Observations.ID, dbo.Observations.StarName, dbo.Observations.StartDate, dbo.Observations.EndDate, 
                         dbo.vPhotometry.vPhotometry, dbo.vPhotometryTime.vPhotometryTime
FROM            dbo.Observations INNER JOIN
                         dbo.vPhotometry ON dbo.Observations.vPhotometryId = dbo.vPhotometry.vPhotometryId INNER JOIN
                         dbo.vPhotometryTime ON dbo.Observations.vPhotometryTimeId = dbo.vPhotometryTime.vPhotometryTimeId
ORDER BY dbo.Observations.StartDate, dbo.vPhotometryTime.vPhotometryTime

GO
USE [master]
GO
ALTER DATABASE [Astro] SET  READ_WRITE 
GO
