IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_Pago_ObtenerInformacion') DROP PROCEDURE EVA_Pago_ObtenerInformacion
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (27.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene la información de parámetros y centros de pagos para la página pagos.
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_Pago_ObtenerInformacion 1504980, '00002500'
*/

CREATE PROCEDURE EVA_Pago_ObtenerInformacion
@IdActor		INT,
@CompaniaSocio	CHAR(8)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
	@Output		INT,
	@IdSede		INT,
	@IdEmpresa	INT,
	@EsIquitos	BIT

	EXEC EVA_SaeHistorialProductos_Agregar @IdActor, @Output OUTPUT

	IF (@Output = -1)
	BEGIN
		SELECT TOP 1
		@IdSede = AHPD.IdSede,
		@IdEmpresa = ES.IdEmpresa
		FROM EVA_AlumnoHistorialProductosDetalle AHPD
		INNER JOIN EmpresaSede ES
		ON AHPD.IdSede = ES.IdSede
		WHERE
		IdAlumno = @IdActor
		ORDER BY AHPD.IdUltimaMatricula DESC

		SET @EsIquitos = IIF(@IdSede = 4 AND @CompaniaSocio = '00002500', 1, 0)

		DECLARE @Parametro TABLE (Nombre VARCHAR(100))

		INSERT INTO
		@Parametro
		VALUES
		('EVA_PAGOPRE'),
		('EVA_PAGOTERYCON'),
		('EVA_PAGOLINK')

		SELECT
		Nombre,
		Valor
		FROM Parametro
		WHERE
		Nombre IN (SELECT CONCAT(Nombre, IIF(@IdSede = 4 AND @CompaniaSocio = '00002500', '_IQ', '')) FROM @Parametro)
		OR
		(Nombre = 'EVA_MODULO_PAGO' AND Activo = 1)

		SELECT
		IdEmpresa,
		NombreCentro,
		Logo,
		UrlVideoPresencial,
		UrlVideoApp
		FROM EVA_CentroDePagos
		WHERE
		Idempresa = @IdEmpresa
		AND EsActivo = IIF(@EsIquitos = 0, 1,EsActivo)
		AND EsIquitos= IIF(@EsIquitos = 1, 1,EsIquitos)
	END
END