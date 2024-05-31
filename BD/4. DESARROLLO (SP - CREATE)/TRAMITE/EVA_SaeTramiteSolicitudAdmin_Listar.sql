IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeTramiteSolicitudAdmin_Listar')
  DROP PROCEDURE EVA_SaeTramiteSolicitudAdmin_Listar
GO
--------------------------------------------------------------------------------
--Creado por    	: SCAYCHO (05.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista las solicitudes de trámite, además permite visualizar el estado actual
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramiteSolicitudAdmin_Listar 1, '', 1, 10, 'sla', 'desc',NULL,'',1296171,NULL,NULL,NULL,3
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitudAdmin_Listar @EsFinalizado bit,
@Busqueda varchar(255) = '',
@Pagina int = 1,
@TamanoPagina int = 5,
@SortColumn varchar(20) = 'fecha',
@SortOrder varchar(4) = 'desc',
@IdSede int = NULL,
@EstadoFiltro varchar(5) = '',
@IdActor int,
@IdProducto int = NULL,
@IdSubcategoria int = NULL,
@Fecha bigint = NULL,
@TipoUsuario int
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @SubQuery varchar(max) = STUFF((SELECT
    CONCAT('U.Nombre LIKE ''%', Items, '%''', ' OR ')
  FROM dbo.udf_Split(@Busqueda, ' ')
  FOR xml PATH (''))
  , 1, 0, '')
  DECLARE @FechaCreacion varchar(20) = (CONVERT(date, (SELECT
    [dbo].[toDatetime](@Fecha))
  , 103))

  DECLARE @Data AS TABLE (
    IdTramiteSolicitud int,
    Nombre varchar(200),
    Nombres varchar(200),
    Apellidos varchar(200),
    FechaCreacion bigint,
    NombreEstado varchar(30),
    NombreEstadoUsuario varchar(30),
    FechaActualizacion bigint,
    Grupo varchar(50),
    UltimoEstadoRespuesta varchar(10),
    SLA int,
    FechaVencimiento datetime,
    TotalFilas int
  )

  IF (@SortColumn NOT IN ('fecha', 'sla'))
  BEGIN
    SET @SortColumn = 'TS.FechaCreacion'
  END
  ELSE
  BEGIN
    IF (@SortColumn = 'fecha')
    BEGIN
      SET @SortColumn = 'TS.FechaCreacion'
    END
    IF (@SortColumn = 'sla')
    BEGIN
      SET @SortColumn = 'FechaVencimiento'
    END
  END

  IF (@SortOrder NOT IN ('asc', 'desc'))
  BEGIN
    SET @SortOrder = 'DESC'
  END

  DECLARE @Query varchar(max) = '
	SELECT
	TS.IdTramiteSolicitud,
	T.NombreInterno,
	U.Nombres,
	CONCAT(U.ApellidoPaterno, '' '', U.ApellidoMaterno) AS Apellidos,
	dbo.toMiliseconds(TS.FechaPGA) AS FechaCreacion,
	TE.NombreEstado,
	TEU.NombreEstado AS NombreEstadoUsuario,
	dbo.toMiliseconds(TS.FechaActualizacion) AS FechaActualizacion,
	NULL AS Grupo,
	TS.UltimoEstadoRespuesta, ' +IIF(@EsFinalizado=0,'[dbo].[EVA_FN_RestarDiasHabiles](TS.FechaPGA,T.DiasAtencion,default) AS SLA, ','TS.SLA, ')+
   'DATEADD(DAY, T.DiasAtencion, TS.FechaPGA) AS FechaVencimiento,
	COUNT(*) OVER() AS TotalFilas
	FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	INNER JOIN EVA_SAE_Tramite T WITH (NOLOCK) ON TS.IdTramite = T.IdTramite
	INNER JOIN Usuario U WITH (NOLOCK) ON TS.IdActorSolicitante = U.IdActor
	INNER JOIN EVA_SAE_TramiteEstados TE WITH (NOLOCK) ON TS.IdEstado = TE.IdEstado
	INNER JOIN EVA_SAE_TramiteSolicitudHistorialEstados TSEH ON TSEH.IdTramiteSolicitud = TS.IdTramiteSolicitud and TSEH.IdEstado = TS.IdEstado
	INNER JOIN EVA_SAE_TramiteEstados TEU WITH (NOLOCK) ON TS.IdEstadoUsuario = TEU.IdEstado ' +
	IIF(@TipoUsuario = 2, '', 'INNER JOIN EVA_SAE_TramiteEncargado EN WITH (NOLOCK) ON EN.IdTramite=T.IdTramite') + '
	WHERE
	T.EsActivo = 1
	AND U.IdTipoUsuario=1
	AND TS.EsAutomatico = 0 AND TS.EsRespuestaMaquinal=0 AND ' +
  IIF(@TipoUsuario = 2, 'TS.IdActorEncargado=', 'EN.IdActor=')
  + CONVERT(varchar(500), @IdActor) +
  ' AND (' + @SubQuery + 'TS.IdTramiteSolicitud LIKE ''%'' + ''' + @Busqueda + ''' + ''%''' + 'OR T.Nombre LIKE ''%'' + ''' + @Busqueda + ''' + ''%'')'
  
  IF (@IdSede IS NOT NULL)
  BEGIN
    DECLARE @SubQuerySedes varchar(100) = CONCAT(' AND TS.IdSede=', @IdSede)
    SET @Query = @Query + @SubQuerySedes
  END

  DECLARE @SubqueryEstados varchar(100)
  IF (@EsFinalizado = 0)
  BEGIN
    IF (@EstadoFiltro <> '')
    BEGIN

      SELECT
        @SubqueryEstados = (CASE @EstadoFiltro
          WHEN 'REG' THEN 'AND TS.EstadoSolicitud in (''PGA'') and UltimoEstadoRespuesta is null'
          WHEN 'OBS' THEN 'AND TS.EstadoSolicitud in (''PGA'') and UltimoEstadoRespuesta is NOT null'
          ELSE ''
        END)

      SET @Query = @Query + @SubqueryEstados
    END
    ELSE
    BEGIN
      SET @SubqueryEstados = 'AND TS.EstadoSolicitud in (''PGA'')'
      SET @Query = @Query + @SubqueryEstados
    END
  END
  ELSE
  BEGIN
    IF (@EstadoFiltro <> '')
    BEGIN

      SELECT
        @SubqueryEstados = (CASE @EstadoFiltro
          WHEN 'APR' THEN 'AND TS.EstadoSolicitud in (''FIN'') and UltimoEstadoRespuesta =''APR'''
          WHEN 'DES' THEN 'AND TS.EstadoSolicitud in (''FIN'') and UltimoEstadoRespuesta =''REC'''
          ELSE ''
        END)

      SET @Query = @Query + @SubqueryEstados
    END
    ELSE
    BEGIN
      SET @SubqueryEstados = 'AND TS.EstadoSolicitud in (''FIN'')'
      SET @Query = @Query + @SubqueryEstados
    END
  END


  IF (@IdProducto IS NOT NULL)
  BEGIN
    DECLARE @SubqueryProducto varchar(100) = CONCAT(' AND TS.IdProducto = ', @IdProducto)
    SET @Query = @Query + @SubqueryProducto
  END

  IF (@IdSubCategoria IS NOT NULL)
  BEGIN
    DECLARE @SubQuerySubCategoria varchar(100) = CONCAT(' AND T.IdTramite = ', @IdSubCategoria)
    SET @Query = @Query + @SubQuerySubCategoria
  END

  IF (@Fecha IS NOT NULL)
  BEGIN
    DECLARE @SubqueryFecha varchar(100) = ' AND convert(date,TS.FechaCreacion,103) = ''' + @FechaCreacion + ''''
    SET @Query = @Query + @SubqueryFecha

  END
  PRINT @Query
  DECLARE @ConPaginacion varchar(max) = @Query + ' ORDER BY ' + @SortColumn + ' ' + @SortOrder + ' ' +
  'OFFSET (' + CONVERT(varchar(max), @Pagina) + ' - 1) * ' + CONVERT(varchar(max), @TamanoPagina) + '' +
  'ROWS FETCH NEXT ' + CONVERT(varchar(max), @TamanoPagina) + '' +
  'ROWS ONLY'

  INSERT INTO @Data
  EXECUTE (@Query)

  EXECUTE (@ConPaginacion)
  SELECT
    ISNULL((SELECT TOP 1
      TotalFilas
    FROM @Data)
    , 0) AS Docs

END