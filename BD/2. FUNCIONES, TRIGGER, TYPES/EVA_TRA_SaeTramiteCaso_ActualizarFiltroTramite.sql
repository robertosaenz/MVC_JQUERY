CREATE OR ALTER TRIGGER EVA_TRA_SaeTramiteCaso_ActualizarFiltroTramite
ON EVA_SAE_TramiteCaso
AFTER INSERT, UPDATE
AS
BEGIN
	IF (ROWCOUNT_BIG() = 0)
	BEGIN
		RETURN
	END

	DECLARE
	@EsActivo	BIT,
	@Output		VARCHAR(MAX)

	SELECT @EsActivo = EsActivo FROM inserted

	IF (@EsActivo = 1)
	BEGIN
		EXEC EVA_ParametroTramiteFiltro_Actualizar @Output OUTPUT

		RETURN
	END
END