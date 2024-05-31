IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeDetalleTramiteCONSNOT_Insertar') DROP PROCEDURE EVA_SaeDetalleTramiteCONSNOT_Insertar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (20.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Inserta información complementaria para el trámite Constancia de notas
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
@1		15.07.22	scaycho			Se eliminó la columna "Codigo"
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeDetalleTramiteCONSNOT_Insertar 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteCONSNOT_Insertar
@IdTramiteSolicitud	INT,
@IdModulo			INT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT EVA_SAE_DetalleTramite_CONSNOT
	(IdTramiteSolicitud, IdModulo)
	VALUES
	(@IdTramiteSolicitud, @IdModulo)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END