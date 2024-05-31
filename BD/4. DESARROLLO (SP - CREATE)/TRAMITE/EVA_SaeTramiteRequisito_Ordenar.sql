IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteRequisito_Ordenar') DROP PROCEDURE EVA_SaeTramiteRequisito_Ordenar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (07.07.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Ordena la configuración de requisitos que tiene un trámite
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
EXEC EVA_SaeTramiteRequisito_Ordenar 1, 1, 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteRequisito_Ordenar
@IdTramite		INT,
@IdRequisito	INT,
@Orden			INT,
@OrdenNuevo		INT,
@RetVal			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
	@Old INT = IIF(@Orden > @OrdenNuevo, @OrdenNuevo, @Orden),
	@New INT = IIF(@Orden > @OrdenNuevo, @Orden, @OrdenNuevo)

	DECLARE @Requisitos TABLE (IdRequisito INT)

	WHILE (@Old < @New)
	BEGIN
		DECLARE @Requisito INT

		SELECT
		@Requisito = IdRequisito
		FROM EVA_SAE_TramiteRequisito TR
		WHERE
		TR.IdTramite = @IdTramite
		AND TR.Orden = IIF(@Orden > @OrdenNuevo, @Old, @Old + 1)
		AND TR.IdRequisito NOT IN (SELECT * FROM @Requisitos)

		UPDATE EVA_SAE_TramiteRequisito
		SET Orden = IIF(@Orden > @OrdenNuevo, @Old + 1, @Old)
		WHERE
		IdTramite = @IdTramite
		AND Orden = IIF(@Orden > @OrdenNuevo, @Old, @Old + 1)
		AND IdRequisito NOT IN (SELECT * FROM @Requisitos)

		INSERT @Requisitos
		VALUES (@Requisito)

		SET @Old = @Old + 1
	END

	UPDATE EVA_SAE_TramiteRequisito
	SET Orden = @OrdenNuevo
	WHERE
	IdTramite = @IdTramite
	AND IdRequisito = @IdRequisito

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END