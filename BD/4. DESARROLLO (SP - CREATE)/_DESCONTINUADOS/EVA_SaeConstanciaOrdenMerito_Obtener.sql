IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeConstanciaOrdenMerito_Obtener') DROP PROCEDURE EVA_SaeConstanciaOrdenMerito_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Información para constancia de orden de merito
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeConstanciaOrdenMerito_Obtener] 1240969
EXEC [EVA_SaeConstanciaOrdenMerito_Obtener] 1230297 

*/ 
CREATE PROCEDURE [dbo].[EVA_SaeConstanciaOrdenMerito_Obtener]
@IdActor int
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IdEmpresa			INT
	DECLARE @IdSede				INT
	DECLARE @IdFacultad			INT
	DECLARE @IdUnidadNegocio	INT
	DECLARE @IdUnidadAcademica  INT
	DECLARE @IdProducto			INT
	DECLARE @IdPeriodo			INT = -1
	DECLARE @IdPromocion        INT = -1
	DECLARE @IdGrupo		    INT = -1
	DECLARE @NumeroIdentidad    VARCHAR(20)


	SELECT TOP 1 
	@IdEmpresa = R.IdEmpresa,
	@IdSede = R.IdSede,
	@IdFacultad = R.IdFacultad,
	@IdUnidadNegocio = R.IdUnidadNegocio,
	@IdUnidadAcademica = P.IdUnidadAcademica,
	--@IdPromocion = M.IdPromocion,
	--@IdPeriodo = M.IdPeriodo,
	--@Idgrupo = M.IdGrupo,
	@IdProducto = R.IdProducto,
	@NumeroIdentidad = A.NumeroIdentidad
	FROM Matricula M WITH(NOLOCK)
	LEFT JOIN Registro R WITH(NOLOCK) ON R.IdRegistro = M.IdRegistro
	LEFT JOIN Promocion P WITH(NOLOCK) ON P.IdPromocion = M.IdPromocion
	LEFT JOIN Actor A WITH(NOLOCK) ON A.IdActor = M.IdActor 
	WHERE 
	M.EsMatricula = 1 AND
	M.Estado = 'N' AND
	M.IdActor = @IdActor
	ORDER BY M.IdMatricula DESC
	
	DECLARE @Temp TABLE
	(
		IdProducto INT,
		IdPromocion INT,
		Idgrupo	INT,
		NumeroIdentidad VARCHAR(20),
		[Login] VARCHAR(20),
		NombreCompleto VARCHAR(100),
		Division VARCHAR(100),
		Programa CHAR(3),
		GrupoCodigo VARCHAR(20),
		PromocionCodigo VARCHAR(50),
		ProductoNombre VARCHAR(150),
		PonderadoActual FLOAT,
		PonderadoAcumulado FLOAT,
		Asistencia FLOAT,
		OrdenMeritoSeccion INT,
		PerteneceA_Seccion VARCHAR(20),
		OrdenMeritoPromocion INT,
		OrdenMeritoProducto INT,
		PerteneceA_Prod VARCHAR(20),
		CursosMatriculados INT
	)
	INSERT INTO @Temp
	exec cNotaReporte_Rpt_NOT00011 
	@IdEmpresa,
	@IdSede,
	@IdFacultad,
	@IdUnidadNegocio,
	@IdUnidadAcademica,
	@IdPeriodo,
	@IdProducto,
	@IdPromocion,
	@IdGrupo
	
	IF EXISTS (SELECT * FROM @Temp T WHERE  T.NumeroIdentidad = @NumeroIdentidad)
	BEGIN 
			SELECT TOP 1
			CASE 
			WHEN PerteneceA_Prod = '' THEN 'No pertenece'
			WHEN PerteneceA_Prod IS NULL THEN  'No pertenece'
			ELSE PerteneceA_Prod END AS PerteneceA_Prod
			FROM @Temp T
			WHERE  T.NumeroIdentidad = @NumeroIdentidad
			ORDER BY IdPromocion
	END
	ELSE
	BEGIN
			SELECT 
			'No especificado' AS PerteneceA_Prod
	END
END
