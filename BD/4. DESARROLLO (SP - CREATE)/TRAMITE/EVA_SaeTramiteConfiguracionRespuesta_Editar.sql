IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteConfiguracionRespuesta_Editar') DROP PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Editar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (26.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Edita una configuración de respuesta de encargado en un trámite
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
EXEC EVA_SaeTramiteConfiguracionRespuesta_Editar 12, 'APR', 'MANUAL', 'Aprueba el trámite, escribe la respuesta correspondiente y finaliza el proceso.', NULL, NULL, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Editar
@IdTramite			INT,
@Respuesta			CHAR(3),
@Tipo				VARCHAR(8),
@TextoInformativo	VARCHAR(500),
@Texto1				VARCHAR(200),
@Texto2				VARCHAR(200),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE EVA_SAE_TramiteConfiguracionRespuesta
	SET
	Tipo = @Tipo,
	TextoInformativo = @TextoInformativo,
	Texto1 = @Texto1,
	Texto2 = @Texto2
	WHERE
	IdTramite = @IdTramite
	AND Respuesta = @Respuesta

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END