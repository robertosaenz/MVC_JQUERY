IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudRespuesta_Registrar') DROP PROCEDURE EVA_SaeTramiteSolicitudRespuesta_Registrar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Registra las respuesta a las solicitudes de trámite y los archivos adjuntados.
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudRespuesta_Registrar] 1,763701,362141,1,'Mensaje',1, '1,2,3'
*/ 

CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudRespuesta_Registrar]
@IdTramiteSolicitud	INT,
@IdActor			INT,
@IdUsuario			INT,
@TipoParticipante   CHAR(3),
@Mensaje		    VARCHAR(1000),
@EntornoDePrueba	BIT,
@IdsArchivos		VARCHAR(MAX),
@Estado				CHAR(3),
@Sla				INT = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IdTramiteSolicitudRespuesta	INT
	DECLARE @Ruta	VARCHAR(100)

	SELECT @Ruta=Valor2 FROM Parametro where nombre = 'RutaEva'

	INSERT INTO EVA_SAE_TramiteSolicitudRespuesta
	(IdTramiteSolicitud,IdActor,TipoParticipante,Mensaje,Estado,UsuarioCreacion,FechaCreacion)
	VALUES
	(@IdTramiteSolicitud,@IdActor,TRIM(@TipoParticipante),@Mensaje,TRIM(@Estado),@IdUsuario,GETDATE())
	SET @IdTramiteSolicitudRespuesta = SCOPE_IDENTITY()

	IF(@IdsArchivos <> '')
	BEGIN
		INSERT INTO EVA_SAE_TramiteSolicitudRespuestaAdjunto
	(IdTramiteSolicitudRespuesta,IdArchivo,UsuarioCreacion,FechaCreacion)
	SELECT @IdTramiteSolicitudRespuesta,Items,@IdUsuario,GETDATE() FROM dbo.udf_Split(@IdsArchivos,',')
	END

	UPDATE EVA_SAE_TramiteSolicitud
	SET UltimoEstadoRespuesta = @Estado, SLA=@Sla
	WHERE IdTramiteSolicitud = @IdTramiteSolicitud
	
	SELECT 
	TSRA.IdTramiteSolicitudRespuesta,
	dbo.toMiliseconds(TSRA.FechaCreacion) AS FechaCreacion,
	CONCAT(U.Nombres,' ',U.ApellidoPaterno,' ',U.ApellidoMaterno) AS NombreActor
	FROM EVA_SAE_TramiteSolicitudRespuesta TSRA WITH(NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitudRespuesta TSR WITH(NOLOCK) ON TSRA.IdTramiteSolicitudRespuesta = TSR.IdTramiteSolicitudRespuesta
	INNER JOIN EVA_SAE_TramiteSolicitud TS WITH(NOLOCK) ON TSR.IdTramiteSolicitud = TS.IdTramiteSolicitud
	INNER JOIN Usuario U WITH(NOLOCK) ON TS.IdActorSolicitante = U.IdActor AND U.IdTipoUsuario=1
	WHERE TSRA.IdTramiteSolicitudRespuesta = @IdTramiteSolicitudRespuesta AND TS.EsAnulado = 0

	SELECT 
	AE.Nombre, 
	AE.Extension,
	IIF(@EntornoDePrueba=1,CONCAT(@Ruta,'test/sae/',AE.NombreCDN,'.',AE.Extension),CONCAT(@Ruta,'sae/',AE.NombreCDN,'.',AE.Extension)) as NombreCDN
	FROM EVA_SAE_TramiteSolicitudRespuestaAdjunto TSRA WITH(NOLOCK)
	INNER JOIN ArchivoEVA AE WITH(NOLOCK) ON TSRA.IdArchivo = AE.IdArchivo
	WHERE TSRA.IdTramiteSolicitudRespuesta = @IdTramiteSolicitudRespuesta
END


