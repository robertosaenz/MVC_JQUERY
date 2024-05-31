IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEventoEstado_Ordenar') DROP PROCEDURE EVA_SaeTramiteEventoEstado_Ordenar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (01.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Ordena la configuración de estados que tiene un trámite
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
EXEC EVA_SaeTramiteEventoEstado_Ordenar 1, 1, 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteEventoEstado_Ordenar
@IdTramite	INT,
@IdEstado	INT,
@Orden		INT,
@OrdenNuevo	INT,
@RetVal		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
	@Old INT = IIF(@Orden > @OrdenNuevo, @OrdenNuevo, @Orden),
	@New INT = IIF(@Orden > @OrdenNuevo, @Orden, @OrdenNuevo)

	DECLARE @Estados TABLE (IdEstado INT)

	WHILE (@Old < @New)
	BEGIN
		DECLARE @Estado INT

		SELECT
		@Estado = IdEstado
		FROM EVA_SAE_TramiteEventoEstado TEE
		WHERE
		TEE.IdTramite = @IdTramite
		AND TEE.Orden = IIF(@Orden > @OrdenNuevo, @Old, @Old + 1)
		AND TEE.IdEstado NOT IN (SELECT * FROM @Estados)

		UPDATE EVA_SAE_TramiteEventoEstado
		SET Orden = IIF(@Orden > @OrdenNuevo, @Old + 1, @Old)
		WHERE
		IdTramite = @IdTramite
		AND Orden = IIF(@Orden > @OrdenNuevo, @Old, @Old + 1)
		AND IdEstado NOT IN (SELECT * FROM @Estados)

		INSERT @Estados
		VALUES (@Estado)

		SET @Old = @Old + 1
	END

	UPDATE EVA_SAE_TramiteEventoEstado
	SET Orden = @OrdenNuevo
	WHERE
	IdTramite = @IdTramite
	AND IdEstado = @IdEstado

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END