IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteFiltro_Eliminar') DROP PROCEDURE EVA_SaeTramiteFiltro_Eliminar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (19.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Elimina la configuración de filtros de un caso en un trámite
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
EXEC EVA_SaeTramiteFiltro_Eliminar 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteFiltro_Eliminar
@IdTramite		INT,
@IdCaso			INT,
@RetVal			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM EVA_SAE_TramiteFiltro
	WHERE
	IdTramite = @IdTramite
	AND IdCaso = @IdCaso

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END