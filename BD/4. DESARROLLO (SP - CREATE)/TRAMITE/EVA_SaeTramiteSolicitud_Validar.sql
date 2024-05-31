IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_Validar') DROP PROCEDURE EVA_SaeTramiteSolicitud_Validar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Retorna la información básica del trámite, adicionalmente realiza validaciones según el flujo de documentos de pago
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
@1		11.03.22	scaycho			Se agregó nuevas columnas a retornar
*/

/*  
Ejemplo:

EXEC EVA_SaeTramiteSolicitud_Validar 23, 1

*/

CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitud_Validar]
@IdTramiteSolicitud INT,
@EntornoDePrueba BIT
AS
BEGIN
	SET NOCOUNT ON

	-- CONFIGURATION FILE SERVER
	DECLARE @Ruta VARCHAR(200)
	DECLARE @Servidor VARCHAR(200)

	SELECT 
	@Servidor=ISNULL(P.Valor,'')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre='RutaEva'

	IF(@EntornoDePrueba = 1)
	BEGIN
		SET @Ruta=@Servidor+'test\tramites\constancias\plantillas\'
	END
	ELSE
	BEGIN
		SET @Ruta=@Servidor+'tramites\constancias\plantillas\'
	END

	SELECT 
	TS.IdTramiteSolicitud,
	TS.IdEstado,
	ISNULL(TS.EsAutomatico, 0) AS EsAutomatico,
	ISNULL(T.TieneCosto, 0) AS TieneCosto,
	TC.IdPlantillaAdjunto,
	--TRIM(T.CodigoPublico) AS CodigoPublico,
	T.GeneraAdjunto,
	--CONCAT(@Ruta, AE.NombreCDN, '.', AE.Extension) AS NombrePlantilla,
    TRIM(TCAT.CodigoPublico) AS CodigoPublicoCategoria,
	ISNULL(TSS.EsPagado, 0) AS EsPagado,
	T.PermiteDescargarPlantilla,
	TS.IdCaso,
	T.CodigoPublico,
	T.IdEncargado
	FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
	LEFT JOIN EVA_SAE_TramiteCaso TC WITH (NOLOCK)
	ON TS.IdCaso = TC.IdCaso
	LEFT JOIN EVA_SAE_Tramite T WITH(NOLOCK) ON TS.IdTramite = T.IdTramite
	LEFT JOIN ArchivoEVA AE	WITH(NOLOCK) ON AE.IdArchivo = TC.IdPlantillaAdjunto
	LEFT JOIN EVA_SAE_TramiteCategoria TCAT WITH(NOLOCK) ON TCAT.IdCategoria = T.IdCategoria
	LEFT JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK) ON TSS.IdTramiteSolicitud = TS.IdTramiteSolicitud
	WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud AND TS.EsAnulado = 0
END