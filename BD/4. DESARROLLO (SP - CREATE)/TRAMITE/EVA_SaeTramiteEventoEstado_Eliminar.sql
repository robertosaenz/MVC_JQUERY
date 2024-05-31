IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEventoEstado_Eliminar') DROP PROCEDURE EVA_SaeTramiteEventoEstado_Eliminar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (01.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Elimina la configuración de estados que tiene un trámite
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
EXEC EVA_SaeTramiteEventoEstado_Eliminar 1, 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteEventoEstado_Eliminar
@IdTramite	INT,
@IdEstado	INT,
@Orden		INT,
@RetVal		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Pendientes INT = (SELECT COUNT(*) FROM EVA_SAE_TramiteEventoEstado TEE WHERE TEE.IdTramite = @IdTramite)

	DELETE FROM EVA_SAE_TramiteEventoEstado
	WHERE
	IdTramite = @IdTramite
	AND @IdEstado = IdEstado
	AND Orden = @Orden

	DECLARE @Inicio INT = @Orden + 1

	WHILE (@Inicio <= @Pendientes)
	BEGIN
		UPDATE EVA_SAE_TramiteEventoEstado
		SET Orden = @Inicio - 1
		WHERE
		IdTramite = @IdTramite
		AND Orden = @Inicio

		SET @Inicio = @Inicio + 1
	END

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END