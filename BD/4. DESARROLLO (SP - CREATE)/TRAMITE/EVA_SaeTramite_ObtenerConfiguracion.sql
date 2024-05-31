IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_ObtenerConfiguracion') DROP PROCEDURE EVA_SaeTramite_ObtenerConfiguracion
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (06.12.21)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene la configuración de un trámite a partir de su id
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramite_ObtenerConfiguracion 11, '00002500'
*/

CREATE PROCEDURE [EVA_SaeTramite_ObtenerConfiguracion]
@IdTramite		INT,
@CompaniaSocio	CHAR(8)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Ruta varchar(100)

	SELECT @Ruta = P.Valor2
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre = 'RutaEva'

	DECLARE
	@IdTramiteT INT,
	@Nombre VARCHAR(100),
	@NombreInterno VARCHAR(150),
	@Descripcion VARCHAR(max),
	@DescripcionGrupo VARCHAR(max),
	@CodigoPublico CHAR(9),
	@EsAutomatico BIT,
	@EsManual BIT,
	@EsActivo BIT,
	@TieneCosto BIT,
	@GeneraAdjunto VARCHAR(5),
	@IdSolicitante INT,
	@IdEncargado INT,
	@IdCategoria INT,
	@IdServicioClasificacion CHAR(20),
	@IdServicioClasificacion_IQ CHAR(20),
	@HoraVencimiento INT,
	@DiasAtencion INT,
	@DiasHabilesResponderObservacion INT,
	@NombreCategoria varchar(100),
	@ServicioClasificacion CHAR(100),
	@ServicioClasificacion_IQ CHAR(100),
	@TieneRespuestaSolicitante	BIT,
	@PermiteDescargarPlantilla	BIT,
	@MinimoAdjunto INT,
	@MaximoAdjunto INT,
	@PesoKbAdjunto FLOAT,
	@FormatoAdjunto VARCHAR(500),
	@MinimoAdjuntoEncargado INT,
	@MaximoAdjuntoEncargado INT,
	@PesoKbAdjuntoEncargado FLOAT,
	@FormatoAdjuntoEncargado VARCHAR(500),
	@TituloDetalle VARCHAR(1000),
	@TituloAdjunto VARCHAR(1000),
	@TextoDetalle VARCHAR(1000),
	@TextoAdjunto VARCHAR(1000),
	@MostrarCursoDiplomado BIT

	SELECT
	@IdTramiteT = T.IdTramite,
	@Nombre = T.Nombre,
	@NombreInterno = T.NombreInterno,
	@Descripcion = T.Descripcion,
	@DescripcionGrupo = T.DescripcionGrupo,
	@CodigoPublico = T.CodigoPublico,
	@EsAutomatico = T.EsAutomatico,
	@EsManual = T.EsManual,
	@EsActivo = T.EsActivo,
	@TieneCosto = T.TieneCosto,
	@GeneraAdjunto = T.GeneraAdjunto,
	@IdSolicitante = T.IdSolicitante,
	@IdEncargado = T.IdEncargado,
	@IdCategoria = T.IdCategoria,
	@IdServicioClasificacion = T.IdServicioClasificacion,
	@IdServicioClasificacion_IQ = T.IdServicioClasificacion_IQ,
	@HoraVencimiento = T.HoraVencimiento,
	@DiasAtencion = T.DiasAtencion,
	@DiasHabilesResponderObservacion = DiasHabilesResponderObservacion,
	@NombreCategoria = TC.Nombre,
	@TieneRespuestaSolicitante = T.TieneRespuestaSolicitante,
	@PermiteDescargarPlantilla = T.PermiteDescargarPlantilla,
	@MinimoAdjunto = T.MinimoAdjunto,
	@MaximoAdjunto = T.MaximoAdjunto,
	@PesoKbAdjunto = T.PesoKbAdjunto,
	@FormatoAdjunto = T.FormatoAdjunto,
	@MinimoAdjuntoEncargado = T.MinimoAdjuntoEncargado,
	@MaximoAdjuntoEncargado = T.MaximoAdjuntoEncargado,
	@PesoKbAdjuntoEncargado = T.PesoKbAdjuntoEncargado,
	@FormatoAdjuntoEncargado = T.FormatoAdjuntoEncargado,
	@TituloDetalle = T.TituloDetalle,
	@TituloAdjunto = T.TituloAdjunto,
	@TextoDetalle = T.TextoDetalle,
	@TextoAdjunto = T.TextoAdjunto,
	@MostrarCursoDiplomado = T.MostrarCursoDiplomado
	FROM [EVA_SAE_tramite] T WITH (NOLOCK)
	INNER JOIN [EVA_SAE_TramiteCategoria] TC WITH (NOLOCK)
	  ON T.IdCategoria = TC.IdCategoria
	WHERE T.IdTramite = @IdTramite

	IF (@IdServicioClasificacion IS NOT NULL)
	BEGIN
	  DECLARE @SpringProducts TABLE (
		ServicioClasificacion char(20),
		DescripcionLocal char(100),
		Sede char(20)
	  )
	  INSERT INTO @SpringProducts
	  EXEC EVA_SaeTramiteProducto_Listar @CompaniaSocio, 0
	  SELECT
		@ServicioClasificacion = DescripcionLocal
	  FROM @SpringProducts
	  WHERE ServicioClasificacion = @IdServicioClasificacion
	END

	IF (@IdServicioClasificacion_IQ IS NOT NULL)
	BEGIN
	  DECLARE @SpringProducts_IQ TABLE (
		ServicioClasificacion char(20),
		DescripcionLocal char(100),
		Sede char(20)
	  )
	  INSERT INTO @SpringProducts_IQ
	  EXEC EVA_SaeTramiteProducto_Listar @CompaniaSocio, 1
	  SELECT
		@ServicioClasificacion_IQ = DescripcionLocal
	  FROM @SpringProducts_IQ
	  WHERE ServicioClasificacion = @IdServicioClasificacion_IQ
	END

	SELECT
	@IdTramiteT AS IdTramite,
	@Nombre AS Nombre,
	@NombreInterno AS NombreInterno,
	@Descripcion AS Descripcion,
	@DescripcionGrupo AS DescripcionGrupo,
	@CodigoPublico AS CodigoPublico,
	@EsAutomatico AS EsAutomatico,
	@EsManual AS EsManual,
	@EsActivo AS EsActivo,
	@TieneCosto AS TieneCosto,
	@GeneraAdjunto AS GeneraAdjunto,
	@IdSolicitante AS IdSolicitante,
	@IdEncargado AS IdEncargado,
	@IdCategoria AS IdCategoria,
	@IdServicioClasificacion AS IdServicioClasificacion,
	@IdServicioClasificacion_IQ AS IdServicioClasificacion_IQ,
	@HoraVencimiento AS HoraVencimiento,
	@DiasAtencion AS DiasAtencion,
	@DiasHabilesResponderObservacion AS DiasHabilesResponderObservacion,
	@NombreCategoria AS NombreCategoria,
	@ServicioClasificacion AS ServicioClasificacion,
	@ServicioClasificacion_IQ AS ServicioClasificacion_IQ,
	@TieneRespuestaSolicitante AS TieneRespuestaSolicitante,
	@PermiteDescargarPlantilla AS PermiteDescargarPlantilla,
	@MinimoAdjunto AS MinimoAdjunto,
	@MaximoAdjunto AS MaximoAdjunto,
	@PesoKbAdjunto AS PesoKbAdjunto,
	@FormatoAdjunto AS FormatoAdjunto,
	@MinimoAdjuntoEncargado AS MinimoAdjuntoEncargado,
	@MaximoAdjuntoEncargado AS MaximoAdjuntoEncargado,
	@PesoKbAdjuntoEncargado AS PesoKbAdjuntoEncargado,
	@FormatoAdjuntoEncargado AS FormatoAdjuntoEncargado,
	@TituloDetalle AS TituloDetalle,
	@TituloAdjunto AS TituloAdjunto,
	@TextoDetalle AS TextoDetalle,
	@TextoAdjunto AS TextoAdjunto,
	@MostrarCursoDiplomado As MostrarCursoDiplomado

	SELECT
	  IdCategoria,
	  IIF(TC.EsActivo = 1, TC.Nombre, TC.Nombre+' ('+'Inactivo)') AS Nombre,
	  RTRIM(CodigoPublico) as CodigoPublico
	FROM [EVA_SAE_TramiteCategoria] TC WITH (NOLOCK)

	SELECT
	  TR.IdRequisito,
	  IIF(TR.IdCaso IS NOT NULL,CONCAT(R.Nombre, ' ', '(',TC.NombreCaso, ')'),R.Nombre) Nombre,
	  R.Detalle,
	  TR.EsActivo,
	  TR.IdCaso,
	  TR.Orden
	FROM [EVA_SAE_TramiteRequisito] TR WITH (NOLOCK)
	INNER JOIN [EVA_SAE_Requisito] R WITH (NOLOCK)
	  ON TR.IdRequisito = R.IdRequisito
	LEFT JOIN EVA_SAE_TramiteCaso TC WITH (NOLOCK)
	  ON TC.IdCaso=TR.IdCaso
	WHERE TR.IdTramite = @IdTramite
	ORDER BY TR.Orden

	SELECT
	  AE.IdArchivo,
	  AE.Nombre,
	  AE.Extension
	FROM [EVA_SAE_TramiteAdjunto] TA WITH (NOLOCK)
	INNER JOIN [ArchivoEVA] AE WITH (NOLOCK)
	  ON TA.IdArchivo = AE.IdArchivo

	SELECT IdEstado, NombreEstado
	FROM EVA_SAE_TramiteEstados WITH (NOLOCK)
	WHERE EsActivo = 1

	SELECT IdEstado, Orden, FlujoNormal, FlujoComplementario, FlujoNegativo, CorreoSolicitante, CorreoEncargado, EstadoSolicitud
	FROM EVA_SAE_TramiteEventoEstado WITH (NOLOCK)
	WHERE IdTramite = @IdTramite
	ORDER BY Orden ASC

	SELECT Codigo, Descripcion
	FROM EVA_PlantillasCorreos WITH (NOLOCK)
	WHERE EsActivo = 1

	SELECT TCR.Respuesta, TCR.Tipo, TCR.TextoInformativo, TCR.Texto1, TCR.Texto2
	FROM EVA_SAE_TramiteConfiguracionRespuesta TCR WITH (NOLOCK)
	WHERE TCR.IdTramite = @IdTramite

	SELECT IdCaso, NombreCaso, IdPlantillaAdjunto, IdArchivoEjemplo, EsActivo
	FROM EVA_SAE_TramiteCaso TC WITH (NOLOCK)
	WHERE TC.IdTramite = @IdTramite
	ORDER BY IdCaso DESC

	SELECT DISTINCT 
		UN.IdUnidadAcademica, 
		UN.Nombre, 
		UN.TienePrecio,
		UN.BloqueoDeuda
	FROM UnidadAcademica UN WITH (NOLOCK)
	LEFT JOIN EVA_SAE_UnidadAcademicaAgrupacion UAA WITH (NOLOCK)
	ON UN.IdUnidadAcademica = UAA.idUnidadAcademica
	WHERE UN.Activo = 1 
	  AND UAA.IdAgrupacion in ( 
		SELECT MTR.IdMaestroRegistro FROM MaestroTablaRegistro MTR
			INNER JOIN MaestroTabla MT
			ON MTR.IdMaestroTabla = MT.IdMaestroTabla
		WHERE MT.Codigo = 'EvaSaeUniAcaAgr' )
		Select '' as x
	--SELECT IdTramite, IdUnidadAcademica
	--FROM EVA_SAE_Tramite_UnidadAcademica
	--WHERE IdTramite = @IdTramite
END