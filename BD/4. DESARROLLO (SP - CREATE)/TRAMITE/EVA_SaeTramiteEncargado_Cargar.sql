IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEncargado_Cargar') DROP PROCEDURE EVA_SaeTramiteEncargado_Cargar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (13.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista los encargados del trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_SaeTramiteEncargado_Cargar 1
*/

CREATE PROCEDURE EVA_SaeTramiteEncargado_Cargar
@IdTramite INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
	IdTramite,
	IdActor
	FROM EVA_SAE_TramiteEncargado WITH (NOLOCK)
	WHERE IdTramite = @IdTramite
END
