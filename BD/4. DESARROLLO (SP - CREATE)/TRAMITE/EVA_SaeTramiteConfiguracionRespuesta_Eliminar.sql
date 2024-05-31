IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteConfiguracionRespuesta_Eliminar') DROP PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Eliminar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (26.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Elimina una configuración de respuesta de encargado en un trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeTramiteConfiguracionRespuesta_Eliminar 1, 'OBS', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Eliminar
@IdTramite	INT,
@Respuesta	CHAR(3),
@RetVal		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM EVA_SAE_TramiteConfiguracionRespuesta
	WHERE
	IdTramite = @IdTramite
	AND Respuesta = @Respuesta

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END