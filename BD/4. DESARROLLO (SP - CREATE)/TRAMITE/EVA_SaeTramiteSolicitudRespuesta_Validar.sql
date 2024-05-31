IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudRespuesta_Validar') DROP PROCEDURE EVA_SaeTramiteSolicitudRespuesta_Validar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Valida si la solicitud existe antes de seguir con el proceso de registrar respuesta
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudRespuesta_Validar] 1
*/ 

CREATE PROCEDURE [EVA_SaeTramiteSolicitudRespuesta_Validar]
	@IdTramiteSolicitud				INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
	TS.IdTramiteSolicitud,
	TS.IdActorSolicitante,
	TS.IdActorEncargado,
	TS.EsAnulado,
	TS.EstadoSolicitud,
	T.TieneRespuestaSolicitante
	FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
	INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK) ON T.IdTramite = TS.IdTramite
	WHERE 
	TS.IdTramiteSolicitud = @IdTramiteSolicitud
END