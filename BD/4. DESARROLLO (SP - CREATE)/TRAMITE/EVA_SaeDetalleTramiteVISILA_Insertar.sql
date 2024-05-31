IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeDetalleTramiteVISILA_Insertar') DROP PROCEDURE EVA_SaeDetalleTramiteVISILA_Insertar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (21.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Inserta información complementaria para el trámite Visado de sílabos
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
@1		15.07.22	scaycho			Se eliminó la columna "Codigo" y se agregó la columna "IdCurso"
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeDetalleTramiteVISILA_Insertar 1, 1, 9817, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteVISILA_Insertar
@IdTramiteSolicitud	INT,
@IdModulo			INT,
@IdCurso			INT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT EVA_SAE_DetalleTramite_VISILA
	(IdTramiteSolicitud, IdModulo, IdCurso)
	VALUES
	(@IdTramiteSolicitud, @IdModulo, @IdCurso)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END