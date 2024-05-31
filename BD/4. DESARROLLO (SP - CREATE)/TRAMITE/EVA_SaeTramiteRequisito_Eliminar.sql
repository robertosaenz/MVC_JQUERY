IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteRequisito_Eliminar') DROP PROCEDURE EVA_SaeTramiteRequisito_Eliminar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (07.07.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Elimina la configuración de requisitos que tiene un trámite
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
EXEC EVA_SaeTramiteRequisito_Eliminar 1, 1, 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteRequisito_Eliminar
@IdTramite		INT,
@IdRequisito	INT,
@IdCaso			INT,
@Orden			INT,
@RetVal			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SET @RetVal = -1

	DECLARE @Pendientes INT = (SELECT COUNT(*) FROM EVA_SAE_TramiteRequisito TR WHERE TR.IdTramite = @IdTramite)

	IF (@IdCaso IS NULL)
	BEGIN
		DELETE FROM EVA_SAE_TramiteRequisito
		WHERE
		IdTramite = @IdTramite
		AND IdRequisito = @IdRequisito
		AND IdCaso IS NULL
		AND Orden = @Orden
	END
	ELSE
	BEGIN
		DELETE FROM EVA_SAE_TramiteRequisito
		WHERE
		IdTramite = @IdTramite
		AND IdRequisito = @IdRequisito
		AND IdCaso = @IdCaso
		AND Orden = @Orden
	END

	IF (@@ROWCOUNT = 0)
	BEGIN
		SET @RetVal = -50
		RETURN
	END

	DECLARE @Inicio INT = @Orden + 1

	WHILE (@Inicio <= @Pendientes)
	BEGIN
		UPDATE EVA_SAE_TramiteRequisito
		SET Orden = @Inicio - 1
		WHERE
		IdTramite = @IdTramite
		AND Orden = @Inicio

		IF (@@ROWCOUNT = 0)
		BEGIN
			SET @RetVal = -50
			BREAK
		END
		ELSE
		BEGIN
			SET @RetVal = -1
		END

		SET @Inicio = @Inicio + 1
	END
END