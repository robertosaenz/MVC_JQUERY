CREATE OR ALTER TRIGGER EVA_TRA_SaeTramiteSolicitud_ActualizarFechaPGA
ON EVA_SAE_TramiteSolicitud
AFTER UPDATE
AS
BEGIN
	IF (ROWCOUNT_BIG() = 0)
	BEGIN
		RETURN
	END

	DECLARE
	@IdTramiteSolicitud	INT,
	@EstadoSolicitud	CHAR(3),
	@FechaPGA			DATETIME

	SELECT
	@IdTramiteSolicitud = IdTramiteSolicitud,
	@EstadoSolicitud = EstadoSolicitud,
	@FechaPGA = FechaPGA
	FROM inserted

	IF (@EstadoSolicitud = 'PGA' AND @FechaPGA IS NULL)
	BEGIN
		UPDATE EVA_SAE_TramiteSolicitud
		SET
		FechaPGA = GETDATE()
		WHERE
		IdTramiteSolicitud = @IdTramiteSolicitud

		RETURN
	END
END