IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudUbigeo_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudUbigeo_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (02/05/2022)
--Funcionalidad   : Retorna los id de ubigeo del departamento,pronvincia y distrito ingresados.
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudUbigeo_Obtener] 'LIMA','LIMA','MIRAFLORES',769050
EXEC [EVA_SaeTramiteSolicitudUbigeo_Obtener] 'LIMA','LIMA','LIMA',769050
EXEC [EVA_SaeTramiteSolicitudUbigeo_Obtener] 'LIMA2','LIMA2','LIMA2',769050
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudUbigeo_Obtener]
@Departamento VARCHAR(50),
@Provincia VARCHAR(50),
@Distrito VARCHAR(50),
@IdActor INT = 54680
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;  

	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	-- TEMP TABLE
	DECLARE @UbigeoTemp TABLE 
	(
		IdDepartamento CHAR(3),
		NombreDepartamento VARCHAR(100),
		IdProvincia CHAR(3),
		NombreProvincia VARCHAR(100),
		IdDistrito CHAR(3),
		NombreDistrito VARCHAR(100),
		Ubigeo VARCHAR(10)
	)

	-- GETTING UBIGEO
	DECLARE @IdDepartamento INT
	DECLARE @IdProvincia INT 
	DECLARE @IdDistrito INT

	-- GETTING BRAND
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
			INSERT INTO @UbigeoTemp
			EXEC
			(
				'
					SELECT 
					TRIM(ZP.Departamento),
					TRIM(D.DescripcionCorta),
					TRIM(ZP.Provincia),
					TRIM(P.DescripcionCorta),
					TRIM(ZP.CodigoPostal),
					TRIM(ZP.DescripcionCorta),
					TRIM(ZP.Ubigeo)
					FROM '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.ZonaPostal ZP WITH(NOLOCK)
					LEFT JOIN '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' +'dbo.Departamento D WITH(NOLOCK) ON ZP.Departamento = D.Departamento
					LEFT JOIN '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' +'dbo.Provincia P WITH(NOLOCK) ON ZP.Provincia = P.Provincia aND ZP.Departamento = P.Departamento
				'	
			)
		END
		ELSE
		BEGIN
			INSERT INTO @UbigeoTemp
			EXEC
			(
				'
					SELECT 
					TRIM(ZP.Departamento),
					TRIM(D.DescripcionCorta),
					TRIM(ZP.Provincia),
					TRIM(P.DescripcionCorta),
					TRIM(ZP.CodigoPostal),
					TRIM(ZP.DescripcionCorta),
					TRIM(ZP.Ubigeo)
					FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.ZonaPostal ZP WITH(NOLOCK)
					LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' +'dbo.Departamento D WITH(NOLOCK) ON ZP.Departamento = D.Departamento
					LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' +'dbo.Provincia P WITH(NOLOCK) ON ZP.Provincia = P.Provincia aND ZP.Departamento = P.Departamento
				'	
			)
		END
		
		SELECT DISTINCT
		@IdDepartamento = U.IdDepartamento
		FROM @UbigeoTemp U 
		WHERE U.NombreDepartamento = @Departamento 
	
		SELECT DISTINCT
		@IdProvincia = U.IdProvincia
		FROM @UbigeoTemp U 
		WHERE U.NombreProvincia = @Provincia AND U.IdDepartamento = @IdDepartamento

		SELECT
		@IdDistrito = U.IdDistrito
		FROM @UbigeoTemp U 
		WHERE U.NombreDistrito = @Distrito AND U.IdDepartamento = @IdDepartamento AND U.IdProvincia = @IdProvincia

		SELECT
		ISNULL(@IdDepartamento,0) AS IdDepartamento,
		ISNULL(@IdProvincia,0) AS IdProvincia,
		ISNULL(@IdDistrito,0) AS IdDistrito
	END
END