IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteCaso_Agregar') DROP PROCEDURE EVA_SaeTramiteCaso_Agregar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (25.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Agrega la configuración de casos en un trámite
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
EXEC EVA_SaeTramiteCaso_Agregar 'Carrera', null, null, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteCaso_Agregar
@NombreCaso			VARCHAR(100),
@IdPlantillaAdjunto	INT,
@IdArchivoEjemplo	INT,
@IdTramite			INT,
@EsActivo			BIT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO EVA_SAE_TramiteCaso
	(NombreCaso, IdPlantillaAdjunto, IdArchivoEjemplo, IdTramite, EsActivo)
	VALUES
	(@NombreCaso, @IdPlantillaAdjunto, @IdArchivoEjemplo, @IdTramite, @EsActivo)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, SCOPE_IDENTITY())
END