IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteCaso_Editar') DROP PROCEDURE EVA_SaeTramiteCaso_Editar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (25.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Edita la configuración de casos en un trámite
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
EXEC EVA_SaeTramiteCaso_Editar 1, 'Carrera', null, null, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteCaso_Editar
@IdCaso				INT,
@NombreCaso			VARCHAR(100),
@IdPlantillaAdjunto	INT,
@IdArchivoEjemplo	INT,
@IdTramite			INT,
@EsActivo			BIT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE EVA_SAE_TramiteCaso
	SET
	NombreCaso = @NombreCaso,
	IdPlantillaAdjunto = @IdPlantillaAdjunto,
	IdArchivoEjemplo = @IdArchivoEjemplo,
	EsActivo = @EsActivo
	WHERE
	IdCaso = @IdCaso
	AND IdTramite = @IdTramite

	SET @RetVal = IIF(@@ROWCOUNT = 0, -51, -1)
END