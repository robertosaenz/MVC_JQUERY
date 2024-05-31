IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitudSpring_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_Obtener
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (04.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene una solicitud de trámite pendiente de pago
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_SaeTramiteSolicitudSpring_Obtener 11
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitudSpring_Obtener
@IdTramiteSolicitud INT
AS
BEGIN
	SELECT 20 AS Monto
	FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	INNER JOIN EVA_SAE_TramiteEstados TE WITH (NOLOCK)
	ON TS.IdEstado = TE.IdEstado
	INNER JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH (NOLOCK)
	ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
	WHERE
	TS.IdTramiteSolicitud = @IdTramiteSolicitud
	AND TE.NombreEstado = 'Pendiente de pago'
END