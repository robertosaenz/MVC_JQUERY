IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_CentrodePagosAPP_Listar') DROP PROCEDURE EVA_CentrodePagosAPP_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: 
--Funcionalidad		: Muestras las centros de pago disponible via app movil
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/
/*  
Ejemplo:
EXEC EVA_CentrodePagosAPP_Listar 1504980
*/
CREATE PROCEDURE [dbo].[EVA_CentrodePagosAPP_Listar]
@IdActor	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Output INT = 0
	DECLARE @IdEmpresa INT
	DECLARE @IdSede INT

	EXEC [EVA_SaeHistorialProductos_Agregar] @IdActor, @Output OUTPUT

	IF(@Output =-1)
	BEGIN
		SELECT 
		@IdEmpresa = ES.IdEmpresa, 
		@IdSede = HPD.IdSede
		FROM EVA_AlumnoHistorialProductosDetalle HPD
		INNER JOIN EmpresaSede ES ON ES.IdSede = HPD.IdSede
		WHERE IdAlumno = @IdActor

		IF(@IdSede = 4)
		BEGIN
			SELECT 
			IdEmpresa, 
			NombreCentro, 
			UrlVideoApp
			FROM EVA_CentroDePagos WHERE Idempresa = @IdEmpresa AND EsActivo=1 AND EsIquitos=1
		END
		ELSE
		BEGIN
			SELECT 
			IdEmpresa, 
			NombreCentro, 
			UrlVideoApp
			FROM EVA_CentroDePagos WHERE Idempresa = @IdEmpresa AND EsActivo=1 AND EsIquitos <>1
		END
	END
END
