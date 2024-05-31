IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_ObtenerInformacion') DROP PROCEDURE EVA_SaeTramite_ObtenerInformacion
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.21)
--Revisado por		: SCAYCHO
--Funcionalidad		: Muestra la configuración actual de un trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC [EVA_SaeTramite_ObtenerInformacion] 23, 1569679, 13, 1,'00002700',384264
EXEC [EVA_SaeTramite_ObtenerInformacion] 2, 1, '00002700', 1427776
*/

CREATE PROCEDURE [dbo].EVA_SaeTramite_ObtenerInformacion
@IdTramite			INT,
@IdActor			INT,
@IdCaso				INT,
@EntornoDePrueba	BIT,
@CompaniaSocio		CHAR(8),
@IdMatricula		INT
AS
BEGIN
	SET NOCOUNT ON
	-- CONFIGURATION FILE SERVER
	DECLARE @Ruta VARCHAR(200)
	DECLARE @Servidor VARCHAR(200)

	SELECT @Servidor = ISNULL(P.Valor,'') FROM Parametro P WITH (NOLOCK) WHERE P.Nombre='RutaEva'

	-- SETTING VALUES 
	IF(@EntornoDePrueba = 1)
	BEGIN

		SET @Ruta=@Servidor+'test\tramites\constancias\plantillas\'
	END
	ELSE
	BEGIN
		SET @Ruta=@Servidor+'tramites\constancias\plantillas\'
	END

	-- CONFIGURATION SPRING
	DECLARE @Serie CHAR(4)
	DECLARE @IdSede INT
	DECLARE @IdPeriodo INT
	DECLARE @Sucursal CHAR(4)

	SELECT TOP 1 
	@IdSede = S.IdSede,
	@Serie = S.Serie,
	@IdPeriodo = M.IdPeriodo,
	@Sucursal = S.Sucursal 
	FROM [Matricula] AS M WITH(NOLOCK)
	INNER JOIN [Sede] S WITH(NOLOCK) ON M.IdSede = S.IdSede
	WHERE M.IdActor = @IdActor
	and IdMatricula=@IdMatricula

	DECLARE @IdPlantillaAdjunto INT

	SELECT
	@IdPlantillaAdjunto = IdPlantillaAdjunto
	FROM EVA_SAE_TramiteCaso
	WHERE
	IdCaso = @IdCaso
	AND IdTramite = @IdTramite
	AND EsActivo = 1

	IF(@IdSede = 4)
		BEGIN
			SELECT DISTINCT 
			T.EsAutomatico,
			T.EsManual,
			T.TieneCosto,
			T.GeneraAdjunto,
			@IdPlantillaAdjunto AS IdPlantillaAdjunto,
			CONCAT(@Ruta,AE.NombreCDN,'.',AE.Extension) AS NombrePlantilla,
			T.IdServicioClasificacion_IQ as IdServicioClasificacion,
			CP.ItemCodigo,
			TRIM(T.CodigoPublico) AS CodigoPublico,
			TC.CodigoPublico AS CodigoPublicoCategoria,
			T.MinimoAdjunto,
			T.MaximoAdjunto,
			T.IdSolicitante
			FROM [EVA_SAE_Tramite] T WITH(NOLOCK)
			LEFT JOIN [EVA_SAE_TramiteCategoria]	TC WITH(NOLOCK) ON TC.IdCategoria = T.IdCategoria
			LEFT JOIN [ArchivoEVA]					AE WITH(NOLOCK) ON AE.IdArchivo	 = @IdPlantillaAdjunto
			LEFT JOIN [CO_Precio_ASOC]				CP WITH(NOLOCK) ON CP.ItemCodigo  = T.IdServicioClasificacion_IQ AND CP.UnidadNegocio = @Sucursal AND CP.CompaniaSocio = @CompaniaSocio
			WHERE T.IdTramite = @IdTramite
		END
	ELSE
		BEGIN
			SELECT DISTINCT 
			T.EsAutomatico,
			T.EsManual,
			T.TieneCosto,
			T.GeneraAdjunto,
			@IdPlantillaAdjunto AS IdPlantillaAdjunto,
			CONCAT(@Ruta,AE.NombreCDN,'.',AE.Extension) AS NombrePlantilla,
			T.IdServicioClasificacion,
			CP.ItemCodigo,
			TRIM(T.CodigoPublico) AS CodigoPublico,
			TC.CodigoPublico AS CodigoPublicoCategoria,
			T.MinimoAdjunto,
			T.MaximoAdjunto,
			T.IdSolicitante
			FROM [EVA_SAE_Tramite] T WITH(NOLOCK)
			LEFT JOIN [EVA_SAE_TramiteCategoria]	TC WITH(NOLOCK) ON TC.IdCategoria = T.IdCategoria
			LEFT JOIN [ArchivoEVA]					AE WITH(NOLOCK) ON AE.IdArchivo   = @IdPlantillaAdjunto
			LEFT JOIN [CO_Precio]					CP WITH(NOLOCK) ON CP.ItemCodigo  = T.IdServicioClasificacion AND CP.UnidadNegocio = @Sucursal AND CP.CompaniaSocio = @CompaniaSocio
			WHERE T.IdTramite = @IdTramite
		END
END