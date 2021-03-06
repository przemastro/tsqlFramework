USE [master]
GO
/****** Object:  Database [Astro]    Script Date: 2016-06-04 14:56:36 ******/
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
/****** Object:  Schema [bi]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [bi]
GO
/****** Object:  Schema [data]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [data]
GO
/****** Object:  Schema [log]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [log]
GO
/****** Object:  Schema [stg]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [stg]
GO
/****** Object:  Schema [test]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [test]
GO
/****** Object:  Schema [util]    Script Date: 2016-06-04 14:56:36 ******/
CREATE SCHEMA [util]
GO
/****** Object:  StoredProcedure [bi].[observationsDelta]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [bi].[observationsDelta]
  
   @observationId varchar(50) = NULL
  
AS
BEGIN

   SET NOCOUNT ON;


--set id
   Declare @i int
   Declare @query nvarchar(max)
   Declare @deltaColumn varchar(50)
   Declare @stagingColumn varchar(50)
   Declare @photometryTable varchar (100)
   Declare @deltaColumnId nvarchar(max)
   Declare @ProcName varchar(100) = '[bi].[observationsDelta]'
   Declare @ProcMessage varchar(100)



   set @ProcMessage = 'EXEC ' + @ProcName + ' ,@observationId=' + coalesce(convert(varchar(50),@observationId),'NULL')
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.BEGIN', @ProcName, @ProcMessage, @observationId)
   



--uPhotometry table
 set @ProcMessage = 'Populate bi.uPhotometry table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=1)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=1)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @uPhotometry varchar(50)
 DECLARE insert_cursor CURSOR FOR (select uPhotometry from stg.stagingObservations where Active=1 except select uPhotometry from bi.uPhotometry)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @uPhotometry

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.uPhotometry (uPhotometryId, uPhotometry) SELECT @i, @uPhotometry
   FETCH NEXT FROM insert_cursor into @uPhotometry
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor
 

--vPhotometry table
 set @ProcMessage = 'Populate bi.vPhotometry table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=2)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=2)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @vPhotometry varchar(50)
 DECLARE insert_cursor CURSOR FOR (select vPhotometry from stg.stagingObservations where Active=1 except select vPhotometry from bi.vPhotometry)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @vPhotometry

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.vPhotometry (vPhotometryId, vPhotometry) SELECT @i, @vPhotometry
   FETCH NEXT FROM insert_cursor into @vPhotometry
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor



 --bPhotometry table
 set @ProcMessage = 'Populate bi.bPhotometry table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=3)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=3)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @bPhotometry varchar(50)
 DECLARE insert_cursor CURSOR FOR (select bPhotometry from stg.stagingObservations where Active=1 except select bPhotometry from bi.bPhotometry)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @bPhotometry

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.bPhotometry (bPhotometryId, bPhotometry) SELECT @i, @bPhotometry
   FETCH NEXT FROM insert_cursor into @bPhotometry
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor


 
--uPhotometryTime table
 set @ProcMessage = 'Populate bi.uPhotometryTime table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   

 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=4)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=4)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @uPhotometryTime varchar(50)
 DECLARE insert_cursor CURSOR FOR (select uPhotometryTime from stg.stagingObservations where Active=1 except select uPhotometryTime from bi.uPhotometryTime)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @uPhotometryTime

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.uPhotometryTime (uPhotometryTimeId, uPhotometryTime) SELECT @i, @uPhotometryTime
   FETCH NEXT FROM insert_cursor into @uPhotometryTime
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor


 --vPhotometryTime table
 set @ProcMessage = 'Populate bi.vPhotometryTime table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=5)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=5)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @vPhotometryTime varchar(50)
 DECLARE insert_cursor CURSOR FOR (select vPhotometryTime from stg.stagingObservations where Active=1 except select vPhotometryTime from bi.vPhotometryTime)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @vPhotometryTime

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.vPhotometryTime (vPhotometryTimeId, vPhotometryTime) SELECT @i, @vPhotometryTime
   FETCH NEXT FROM insert_cursor into @vPhotometryTime
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor



 --bPhotometryTime table
 set @ProcMessage = 'Populate bi.bPhotometryTime table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 set @deltaColumn = (select DeltaColumnId from util.metadataComparison where id=6)
 set @photometryTable = (select PhotometryTable from util.metadataComparison where id=6)
 set @query = ('select top 1 @deltaColumnId='+@deltaColumn +' from '+@photometryTable+' alias order by '+ @deltaColumn +' desc')
 
 print @query
 
 exec sp_executesql @query, @Params = N'@deltaColumnId varchar(50) output', @deltaColumnId = @deltaColumnId output
 
 if ((@deltaColumnId) = null)
   begin
   set @i = 1
   end
 else
   begin
   set @i = (@deltaColumnId) + 1
   end


 Declare @bPhotometryTime varchar(50)
 DECLARE insert_cursor CURSOR FOR (select bPhotometryTime from stg.stagingObservations where Active=1 except select bPhotometryTime from bi.bPhotometryTime)

 OPEN insert_cursor
 FETCH NEXT FROM insert_cursor into @bPhotometryTime

 WHILE @@FETCH_STATUS=0
   BEGIN
   Insert into bi.bPhotometryTime (bPhotometryTimeId, bPhotometryTime) SELECT @i, @bPhotometryTime
   FETCH NEXT FROM insert_cursor into @bPhotometryTime
   set @i=@i+1
   END
 close insert_cursor
 Deallocate insert_cursor

--bi.observations table
 set @ProcMessage = 'Populate bi.observations table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
   
 insert into bi.observations select so.id, so.RowId, so.StarName, so.StartDate, so.EndDate, uph.uPhotometryId, upht.uPhotometryTimeId,
                                     vph.vPhotometryId, vpht.vPhotometryTimeId, bph.bPhotometryId, bpht.bPhotometryTimeId
 from stg.stagingObservations so
                               join bi.uPhotometry uph on uph.uPhotometry=so.uPhotometry
                               join bi.vPhotometry vph on vph.vPhotometry=so.vPhotometry
                               join bi.bPhotometry bph on bph.bPhotometry=so.bPhotometry
                               join bi.uPhotometryTime upht on upht.uPhotometryTime=so.uPhotometryTime
                               join bi.vPhotometryTime vpht on vpht.vPhotometryTime=so.vPhotometryTime
                               join bi.bPhotometryTime bpht on bpht.bPhotometryTime=so.bPhotometryTime
                               where id=@observationId and status='new' and active=1



  delete tob from bi.observations tob
  inner join stg.stagingObservations tso on tso.RowId=tob.RowId
  where tso.id=@observationId and status='old' and active=0

 set @ProcMessage = 'Populate bi.uPhotometry table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)

--update stg.stagingObservations table
 set @ProcMessage = 'Update stg.stagingObservations table'
 Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), NULL, @ProcName, @ProcMessage, @observationId)
      
 update stg.stagingObservations set status='old'

 select * from stg.stagingObservations

 select * from bi.observations

   set @ProcMessage = 'Completed'
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.END', @ProcName, @ProcMessage, @observationId)
   
END


GO
/****** Object:  StoredProcedure [data].[insertTestData]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [data].[insertTestData]
  
   @observationId varchar(50) = NULL,
   @active bit = 1,
   @status varchar(20) = 'new', 
   @starName varchar(50) = NULL,
   @startDate varchar(50) = NULL,
   @endDate varchar(50) = NULL 

  
AS
BEGIN

   SET NOCOUNT ON;

   Declare @ProcName varchar(100) = '[data].[insertTestData]'
   Declare @ProcMessage varchar(100)



   set @ProcMessage = 'EXEC ' + @ProcName + ' ,@observationId=' + coalesce(convert(varchar(50),@observationId),'NULL') +
                                            ' ,@active=' + coalesce(convert(varchar(50),@active),'NULL') +
											' ,@status=' + coalesce(convert(varchar(50),@status),'NULL') +
											' ,@starName=' + coalesce(convert(varchar(50),@starName),'NULL') +
											' ,@startDate=' + coalesce(convert(varchar(50),@startDate),'NULL') +
											' ,@endDate=' + coalesce(convert(varchar(50),@endDate),'NULL')
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.BEGIN', @ProcName, @ProcMessage, @observationId)
   

   Declare @uPhotometryTime varchar(50), @uPhotometry varchar(50), @vPhotometryTime varchar(50), @vPhotometry varchar(50), @bPhotometryTime varchar(50), @bPhotometry varchar(50)
   Declare @rowId int = 1

   DECLARE insert_cursor CURSOR FOR
   SELECT [Column 0], [Column 1], [Column 2], [Column 3], [Column 4], [Column 5] from [data].[TestData]

   OPEN insert_cursor
   FETCH NEXT FROM insert_cursor into @uPhotometryTime,@uPhotometry,@vPhotometryTime,@vPhotometry,@bPhotometryTime,@bPhotometry

   WHILE @@FETCH_STATUS=0
      BEGIN

      Insert into stg.stagingObservations (id, RowId, StarName, StartDate, EndDate, uPhotometry, uPhotometryTime, vPhotometry, vPhotometryTime, bPhotometry, bPhotometryTime, Status, Active)
      SELECT @observationId, @rowId, @starName, @startDate, @endDate, @uPhotometry, @uPhotometryTime, @vPhotometry, @vPhotometryTime, @bPhotometry, @bPhotometryTime, @status, @active

      FETCH NEXT FROM insert_cursor into @uPhotometryTime, @uPhotometry, @vPhotometryTime, @vPhotometry, @bPhotometryTime, @bPhotometry
      set @rowId=@rowId+1
      END
   close insert_cursor
   Deallocate insert_cursor

   set @ProcMessage = 'Test Data insert completed'
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.END', @ProcName, @ProcMessage, @observationId)
   

END


GO
/****** Object:  StoredProcedure [test].[observationsComparison]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [test].[observationsComparison]

   @observationId varchar(50) = NULL,
   @reportMode varchar(10) = 'N',
   @stagingTable varchar(50) = NULL,
   @deltaTable varchar(50) = NULL
  
AS
BEGIN


   SET NOCOUNT ON;
  
   Declare @query nvarchar(max)
   Declare @ProcName varchar(100) = '[test].[observationsComparison]'
   Declare @ProcMessage varchar(100)

   Declare @xmlCountsReport nvarchar(max) = ''
   Declare @xmlResult nvarchar(max) = ''
   Declare @xmlVarTime nvarchar(max)
   Declare @xmlComparison nvarchar(max)
  
   --Start procedure and log
   set @ProcMessage = 'EXEC ' + @ProcName + ' ,@observationId=' + coalesce(convert(varchar(50),@observationId),'NULL') + 
                                            ' ,@stagingTable=' + coalesce(convert(varchar(50),@stagingTable),'NULL') +
											' ,@deltaTable=' + coalesce(convert(varchar(50),@deltaTable),'NULL')
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.BEGIN', @ProcName, @ProcMessage, @observationId)
  

      
    --create temp table with values from Metadata dor specific .stg Table
    IF OBJECT_ID(N'tempdb.dbo.#tableStgDelta') is NULL

       CREATE TABLE #tableStgDelta (
          Id INT IDENTITY(1,1),
          DeltaColumn varchar(255),
          PhotometryTable varchar(255),
          DeltaColumnId varchar(255),
          StagingColumn varchar(8000),
          DataTypeConversion varchar(1000),
          NullValuesConversion varchar(100),
		  JoinHint varchar(100)
          )   


       insert into #tableStgDelta(DeltaColumn, PhotometryTable, DeltaColumnId, StagingColumn, DataTypeConversion, NullValuesConversion, JoinHint)
       select mcom.DeltaColumn, mcom.PhotometryTable, DeltaColumnId, mcom.StagingColumn, mcom.DataTypeConversion, mcom.NullValuesConversion, mcom.JoinHint from util.metadataComparison mcom
	   join util.metadataCounts mcnt on mcom.MetadataCountsId=mcnt.id
       where StagingTable=@stagingTable


      
    if(@reportMode='N')
       begin
       select * from #tableStgDelta
       end     

    --create query for dynamic execution
    Declare @deltaQuery nvarchar(max) = ''  --FCT
    Declare @deltaQuery2 nvarchar(max) = '' --FCT
    Declare @STGQuery nvarchar(max) = ''      --STG
    Declare @i int; set @i=1;
    Declare @dataTypeConversionValue varchar(800)
    Declare @nullValuesConversion varchar(100)
	Declare @joinHint varchar(50)
   
   set @ProcMessage = 'Begin loop for observationId='+@observationId
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'LOOP.BEGIN', @ProcName, @ProcMessage, @observationId)

    while @i <= (select count(1) from #tableStgDelta)
       begin
       set @dataTypeConversionValue = (select DataTypeConversion from #tableStgDelta where id=@i)
       set @nullValuesConversion = (select nullValuesConversion from #tableStgDelta where id=@i)
	   set @joinHint = (select joinHint from #tableStgDelta where id=@i)

       if(@i>1)
          begin
             set @deltaQuery = 'alias'+(convert(varchar(2),@i,2))+'.'+ (select DeltaColumn from #tableStgDelta where id=@i) +', '+ @deltaQuery
             set @deltaQuery2 = ' '+@joinHint+' ' + (select PhotometryTable from #tableStgDelta where id=@i) + ' alias'+(convert(varchar(2),@i,2)) + ' on ' +
                                  'fct.' +(select DeltaColumnId from #tableStgDelta where id=@i) + '=' + 'alias'+(convert(varchar(2),@i,2))+'.'+(select DeltaColumnId from #tableStgDelta where id=@i)
                                  + @deltaQuery2                       
             set @STGQuery = '(case when ISNULL(ltrim(rtrim('+(select StagingColumn from #tableStgDelta where id=@i)+')), '''')='''' Then '+@nullValuesConversion+' else '+ (@dataTypeConversionValue)+ ' end) as '''+(select StagingColumn from #tableStgDelta where id=@i) +''', '+ @STGQuery
          set @i=@i+1         
          end
       else     
          begin
             set @deltaQuery = 'alias'+(convert(varchar(2),@i,2))+'.'+ (select DeltaColumn from #tableStgDelta where id=@i) + @deltaQuery
             set @deltaQuery2 = ' '+@joinHint+' ' + (select PhotometryTable from #tableStgDelta where id=@i) + ' alias'+(convert(varchar(2),@i,2)) + ' on ' +
                                  'fct.' +(select DeltaColumnId from #tableStgDelta where id=@i) + '=' + 'alias'+(convert(varchar(2),@i,2))+'.'+(select DeltaColumnId from #tableStgDelta where id=@i)
                                  + @deltaQuery2                       
             set @STGQuery = '(case when ISNULL(ltrim(rtrim('+(select StagingColumn from #tableStgDelta where id=@i)+')), '''')='''' Then '+@nullValuesConversion+' else '+ (@dataTypeConversionValue)+ ' end) as '''+(select StagingColumn from #tableStgDelta where id=@i) +''''+ @STGQuery
          set @i=@i+1         
          end
       end;

    --Final queries
    set @deltaQuery = 'select RowId,' + @deltaQuery + ' from ' + @deltaTable + ' fct with (NOLOCK)'
    set @STGQuery = 'select RowId,' + @STGQuery + ' from ' + @stagingTable + ' with (NOLOCK) where Id='+cast(@observationId as varchar(100));
    
    Declare @deltaQueryFinal nvarchar(max)
    set @deltaQueryFinal = @deltaQuery + ' ' + @deltaQuery2 + ' where Id='+cast(@observationId as varchar(100));
   

    print @STGQuery
    print @deltaQueryFinal
	
   
    Declare @deltaQueryLastFinal nvarchar(max)
    Declare @var int

    if(@reportMode = 'N')
       begin
       exec sp_executesql @STGQuery           
       exec sp_executesql @deltaQueryFinal  

       set @deltaQueryLastFinal = @STGQuery + ' except ' + @deltaQueryFinal

       exec sp_executesql @deltaQueryLastFinal
       end
    else
       begin
       set @deltaQueryFinal = 'select @var=count(1) from (' + @STGQuery + ' except ' + @deltaQueryFinal +') b'     
       exec sp_executesql @deltaQueryLastFinal, @Params = N'@var varchar(50) output', @var = @var output
       select @observationId as 'ObservationId', @var as 'Staging - Delta Difference'
	 
	   set @query = 'select @xmlVarTime=getDate()'
	   exec sp_executesql @query, @Params = N'@xmlVarTime varchar(50) output', @xmlVarTime = @xmlVarTime output 
	  
       set @xmlComparison = ISNULL(CONVERT(varchar(50),@var),'No Difference')
	   print @xmlComparison
	   --XML report
       set @xmlCountsReport =
	   '<Entry name="Counts">
	      <Log>
		     <LogLine>
			    <Rule>Comparison</Rule>
				<ExecutionResult>'+@xmlComparison+'</ExecutionResult>
				<ObservationId>'+@observationId+'</ObservationId>
				<Time>'+@xmlVarTime+'</Time>
             </LogLine>
          </Log>
	   </Entry>'  
       set @xmlResult = '<Result xmlns:xsi="http://www.w3.org/2001/SMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+@xmlCountsReport+'</Result>'


   	   if(@xmlComparison = 'No Difference')
	     begin
		 insert into [util].[testStatus](observationId, testType, CreateDate, PostLoadingStatus, PostLoadingDetail) values(@observationId, 'Comparison',  getdate(), 'PASS', @xmlResult)
		 end
       else
	     begin
		 insert into [util].[testStatus](observationId, testType, CreateDate, PostLoadingStatus, PostLoadingDetail) values(@observationId, 'Comparison',  getdate(), 'FAIL', @xmlResult)
		 end   
       end

	  set @ProcMessage = 'Loop ended for observationId='+@observationId
      Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'LOOP.END', @ProcName, @ProcMessage, @observationId)

   --End procedure and log
   set @ProcMessage = 'Testing of quality completed'
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'PROC.END', @ProcName, @ProcMessage, @observationId)
  
  IF OBJECT_ID(N'tempdb.dbo.#tableStgDelta') is not NULL drop table #tableStgDelta
      
END   
GO
/****** Object:  StoredProcedure [test].[observationsCounts]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [test].[observationsCounts]
  
   @observationId varchar(50) = NULL,
   @stagingTable varchar(50) = NULL,
   @deltaTable varchar(50) = NULL
  
AS
BEGIN

   SET NOCOUNT ON;

   Declare @ProcName varchar(100) = '[test].[observationsCounts]'
   Declare @ProcMessage varchar(100)
   Declare @query2 nvarchar(max) = ''
   Declare @query nvarchar(max)
   Declare @stg nvarchar(max)
   Declare @bi nvarchar(max)
   Declare @stgbi nvarchar(max)

   Declare @i int = 1
   Declare @length int

   Declare @xmlStg nvarchar(max)
   Declare @xmlBi nvarchar(max)
   Declare @xmlStgBi nvarchar(max)
   Declare @xmlStgTime nvarchar(max)
   Declare @xmlBiTime nvarchar(max)
   Declare @xmlStgBiTime nvarchar(max)

   Declare @xmlCountsReport nvarchar(max) = ''
   Declare @xmlResult nvarchar(max) = ''

   Declare @delimiter varchar(10) = ','

   --Start procedure and log
   set @ProcMessage = 'Start testing of counts'
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message) values(getDate(), 'PROC.BEGIN', @ProcName, @ProcMessage)

   --This is magic for splitting observationId's
   IF OBJECT_ID(N'#observationIds') IS NULL
      CREATE TABLE #observationIds (
	     Id INT IDENTITY(1, 1),
		 Observation varchar(255)
	  )

   ;with cte as
   (
      select 0 a, 1 b
	  union all
	  select b, CHARINDEX(@delimiter, @observationId, b) + len(@delimiter)
	  from cte where b>a
   )
   Insert into #observationIds select substring(@observationId, a,
      case when b>len(@delimiter)
	     Then b-a-len(@delimiter)
		 else len(@observationId)-a+1 end) value
   from cte where a>0

   --calculate number of records for while loop
   set @query = 'select @length=count(1) from #observationIds'
   exec sp_executesql @query, @Params = N'@length int output', @length = @length output




while @i<=@length
   begin

   --lets use @i run   
   set @query = 'select @observationId=Observation from #observationIds where id = '+cast(@i as varchar(20))
   exec sp_executesql @query, @Params = N'@observationId varchar(50) output', @observationId = @observationId output

   set @ProcMessage = 'EXEC ' + @ProcName + ' ,@observationId=' + coalesce(convert(varchar(50),@observationId),'NULL') + 
                                            ' ,@stagingTable=' + coalesce(convert(varchar(50),@stagingTable),'NULL') +
											' ,@deltaTable=' + coalesce(convert(varchar(50),@deltaTable),'NULL')
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'LOOP.BEGIN', @ProcName, @ProcMessage, @observationId)

   if(@observationId = NULL)
      begin
	  set @query2 = 'select NULL, '+@stagingTable+', ' +@deltaTable
	  end
   else
      begin
	  --select count for stg
	  set @query = 'select @stg=count(distinct rowId) from '+@stagingTable+' with (NOLOCK) where ID='+@observationId
	  exec sp_executesql @query, @Params = N'@stg varchar(50) output', @stg = @stg output  
	  
	  set @xmlStg = @stg
	  set @query = 'select @xmlStgTime=getDate()'
	  exec sp_executesql @query, @Params = N'@xmlStgTime varchar(50) output', @xmlStgTime = @xmlStgTime output  



	  --select count for bi
	  set @query = 'select @bi=count(distinct rowId) from '+@deltaTable+' with (NOLOCK) where ID='+@observationId
	  exec sp_executesql @query, @Params = N'@bi varchar(50) output', @bi = @bi output  

	  set @xmlBi = @bi
	  set @query = 'select @xmlBiTime=getDate()'
	  exec sp_executesql @query, @Params = N'@xmlBiTime varchar(50) output', @xmlBiTime = @xmlBiTime output 
      
	  --calculat Stg-Delta difference
	  if (@stg!=@bi)
	     begin
	     set @stgbi = cast((cast(@stg as int) - cast(@bi as int)) as varchar)

		 set @xmlStgBi = @stgbi
	     set @query = 'select @xmlStgBiTime=getDate()'
	     exec sp_executesql @query, @Params = N'@xmlStgBiTime varchar(50) output', @xmlStgBiTime = @xmlStgBiTime output 
		 end
      else
	     begin
		 set @stgbi = '''OK'''

		 set @xmlStgBi = '''OK'''
	     set @query = 'select @xmlStgBiTime=getDate()'
	     exec sp_executesql @query, @Params = N'@xmlStgBiTime varchar(50) output', @xmlStgBiTime = @xmlStgBiTime output 
		 end

	  --final population
	  if(@i=1)
	     begin
	     set @query2 = 'select cast('+@observationId+' as varchar) as ObservationId, cast('+@stg+' as varchar) as StagingCount, cast('+@bi+' as varchar) as DeltaCount, cast('+@stgbi+' as varchar) as StgDeltaDifference'
		 end
      else if (@i<=@length)
	     begin
		 set @query2 = 'select cast('+@observationId+' as varchar) as ObservationId, cast('+@stg+' as varchar) as StagingCount, cast('+@bi+' as varchar) as DeltaCount, cast('+@stgbi+' as varchar) as StgDeltaDifference union all '+@query2		 
		 end


	  --XML report
	  set @xmlCountsReport =
	  '<Entry name="Counts">
	      <Log>
		     <LogLine>
			    <Rule>Counts</Rule>
				<ExecutionResult>'+@xmlStg+'</ExecutionResult>
				<ObservationId>'+@observationId+'</ObservationId>
				<Time>'+@xmlStgTime+'</Time>
             </LogLine>
			 <LogLine>
			    <Rule>Counts</Rule>
				<ExecutionResult>'+@xmlBi+'</ExecutionResult>
				<ObservationId>'+@observationId+'</ObservationId>
				<Time>'+@xmlBiTime+'</Time>
             </LogLine>
	         <LogLine>
			    <Rule>Counts</Rule>
				<ExecutionResult>'+@xmlStgBi+'</ExecutionResult>
				<ObservationId>'+@observationId+'</ObservationId>
				<Time>'+@xmlStgBiTime+'</Time>
             </LogLine>
          </Log>
	  </Entry>'	     

	  set @xmlResult = '<Result xmlns:xsi="http://www.w3.org/2001/SMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+@xmlCountsReport+'</Result>'

	  print @xmlResult

	  if(@stgbi = '''OK''')
	     begin
		 insert into [util].[testStatus](observationId, testType, CreateDate, PostLoadingStatus, PostLoadingDetail) values(@observationId, 'Counts',  getdate(), 'PASS', @xmlResult)
		 end
      else
	     begin
		 insert into [util].[testStatus](observationId, testType, CreateDate, PostLoadingStatus, PostLoadingDetail) values(@observationId, 'Counts',  getdate(), 'FAIL', @xmlResult)
		 end

	  set @stg = '0'
	  set @bi = '0'
	  set @i=@i+1
	  end

	  
	  set @ProcMessage = 'EXEC ' + @ProcName + ' ,@observationId=' + coalesce(convert(varchar(50),@observationId),'NULL') + 
                                            ' ,@stagingTable=' + coalesce(convert(varchar(50),@stagingTable),'NULL') +
											' ,@deltaTable=' + coalesce(convert(varchar(50),@deltaTable),'NULL')
      Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message, ObservationId) values(getDate(), 'LOOP.END', @ProcName, @ProcMessage, @observationId)
   end


   exec sp_executesql @query2

   set @ProcMessage = 'Testing of counts completed'
   Insert INTO [log].[log](CreateDate, LogCategory, LogObject, Message) values(getDate(), 'PROC.END', @ProcName, @ProcMessage)

   IF OBJECT_ID(N'#observationIds') is not NULL drop table #observationIds

END



GO
/****** Object:  Table [bi].[bPhotometry]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[bPhotometry](
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
/****** Object:  Table [bi].[bPhotometryTime]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[bPhotometryTime](
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
/****** Object:  Table [bi].[observations]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[observations](
	[ID] [int] NOT NULL,
	[RowId] [bigint] NULL,
	[StarName] [varchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[uPhotometryId] [bigint] NULL,
	[uPhotometryTimeId] [bigint] NULL,
	[vPhotometryId] [bigint] NULL,
	[vPhotometryTimeId] [bigint] NULL,
	[bPhotometryId] [bigint] NULL,
	[bPhotometryTimeId] [bigint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [bi].[uPhotometry]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[uPhotometry](
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
/****** Object:  Table [bi].[uPhotometryTime]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[uPhotometryTime](
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
/****** Object:  Table [bi].[vPhotometry]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[vPhotometry](
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
/****** Object:  Table [bi].[vPhotometryTime]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [bi].[vPhotometryTime](
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
/****** Object:  Table [data].[TestData]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [data].[TestData](
	[Column 0] [varchar](50) NULL,
	[Column 1] [varchar](50) NULL,
	[Column 2] [varchar](50) NULL,
	[Column 3] [varchar](50) NULL,
	[Column 4] [varchar](50) NULL,
	[Column 5] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [log].[log]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [log].[log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[LogCategory] [varchar](50) NULL,
	[LogObject] [varchar](50) NULL,
	[Message] [varchar](200) NULL,
	[ObservationId] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [stg].[stagingObservations]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[stagingObservations](
	[ID] [bigint] NULL,
	[RowId] [bigint] NOT NULL,
	[StarName] [varchar](50) NULL,
	[StartDate] [varchar](50) NULL,
	[EndDate] [varchar](50) NULL,
	[uPhotometry] [varchar](50) NULL,
	[uPhotometryTime] [varchar](50) NULL,
	[vPhotometry] [varchar](50) NULL,
	[vPhotometryTime] [varchar](50) NULL,
	[bPhotometry] [varchar](50) NULL,
	[bPhotometryTime] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[metadataComparison]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[metadataComparison](
	[ID] [int] NOT NULL,
	[MetadataCountsId] [int] NOT NULL,
	[StagingColumn] [varchar](50) NULL,
	[DeltaColumn] [varchar](50) NULL,
	[DeltaColumnId] [varchar](50) NULL,
	[PhotometryTable] [varchar](50) NULL,
	[DataTypeConversion] [varchar](1000) NULL,
	[NullValuesConversion] [varchar](100) NULL,
	[JoinHint] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[metadataCounts]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[metadataCounts](
	[ID] [int] NOT NULL,
	[StagingTable] [varchar](50) NULL,
	[DeltaTable] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[testStatus]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[testStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ObservationId] [int] NULL,
	[TestType] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[PostLoadingStatus] [varchar](50) NULL,
	[PostLoadingDetail] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [bi].[bPhotometrySorted]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [bi].[bPhotometrySorted] as
SELECT        TOP (100) PERCENT bi.observations.ID, bi.observations.RowId, bi.observations.StarName, bi.observations.StartDate, bi.observations.EndDate, bi.bPhotometry.bPhotometry, 
                         bi.bPhotometryTime.bPhotometryTime
FROM            bi.bPhotometry INNER JOIN
                         bi.observations ON bi.bPhotometry.bPhotometryId = bi.observations.bPhotometryId INNER JOIN
                         bi.bPhotometryTime ON bi.observations.bPhotometryTimeId = bi.bPhotometryTime.bPhotometryTimeId
ORDER BY bi.observations.ID, bi.observations.RowId, bi.observations.StartDate



GO
/****** Object:  View [bi].[observationsSorted]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [bi].[observationsSorted] as (
SELECT        TOP (100) PERCENT ID, RowId, StarName, StartDate, EndDate
FROM            bi.observations
ORDER BY ID, RowId, StartDate)



GO
/****** Object:  View [bi].[uPhotometrySorted]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [bi].[uPhotometrySorted] as
SELECT        TOP (100) PERCENT bi.observations.ID, bi.observations.RowId, bi.observations.StarName, bi.observations.StartDate, bi.observations.EndDate, bi.uPhotometry.uPhotometry, 
                         bi.uPhotometryTime.uPhotometryTime
FROM            bi.uPhotometry INNER JOIN
                         bi.observations ON bi.uPhotometry.uPhotometryId = bi.observations.uPhotometryId INNER JOIN
                         bi.uPhotometryTime ON bi.observations.uPhotometryTimeId = bi.uPhotometryTime.uPhotometryTimeId
ORDER BY bi.observations.ID, bi.observations.RowId, bi.observations.StartDate



GO
/****** Object:  View [bi].[vPhotometrySorted]    Script Date: 2016-06-04 14:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [bi].[vPhotometrySorted] as
SELECT        TOP (100) PERCENT bi.observations.ID, bi.observations.RowId, bi.observations.StarName, bi.observations.StartDate, bi.observations.EndDate, bi.vPhotometry.vPhotometry, 
                         bi.vPhotometryTime.vPhotometryTime
FROM            bi.vPhotometry INNER JOIN
                         bi.observations ON bi.vPhotometry.vPhotometryId = bi.observations.vPhotometryId INNER JOIN
                         bi.vPhotometryTime ON bi.observations.vPhotometryTimeId = bi.vPhotometryTime.vPhotometryTimeId
ORDER BY bi.observations.ID, bi.observations.RowId, bi.observations.StartDate

GO
USE [master]
GO
ALTER DATABASE [Astro] SET  READ_WRITE 
GO
