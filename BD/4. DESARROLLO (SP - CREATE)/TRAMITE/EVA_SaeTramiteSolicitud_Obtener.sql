IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitud_Obtener
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (07.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Retorna el estado actual de una solicitud de trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramiteSolicitud_Obtener 1
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitud_Obtener
@IdTramiteSolicitud INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT TS.EstadoSolicitud
	FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud
END