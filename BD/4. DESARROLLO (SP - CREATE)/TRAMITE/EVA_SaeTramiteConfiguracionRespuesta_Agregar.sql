IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteConfiguracionRespuesta_Agregar') DROP PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Agregar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (26.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Agrega una configuración de respuesta de encargado en un trámite
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
EXEC EVA_SaeTramiteConfiguracionRespuesta_Agregar 12, 'APR', 'MANUAL', 'Aprueba el trámite, escribe la respuesta correspondiente y finaliza el proceso.', NULL, NULL, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteConfiguracionRespuesta_Agregar
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

	INSERT EVA_SAE_TramiteConfiguracionRespuesta
	(IdTramite, Respuesta, Tipo, TextoInformativo, Texto1, Texto2)
	VALUES
	(@IdTramite, @Respuesta, @Tipo, @TextoInformativo, @Texto1, @Texto2)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END