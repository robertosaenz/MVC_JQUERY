IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_RequisitoOrdenMerito_Consultar') DROP PROCEDURE EVA_RequisitoOrdenMerito_Consultar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (08.08.2022)
--Revisado por		: SCAYCHO
--Funcionalidad		: Evalúa si el alumno pertenece al tercio, quinto y decima superior
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
ESCENARIO 1: TIENE ORDEN DE MERITO
DECLARE @Output INT
EXEC EVA_RequisitoOrdenMerito_Consultar 1240969, @Output OUTPUT
SELECT @Output

ESCENARIO 1: NO TIENE ORDEN DE MERITO
DECLARE @Output INT
EXEC EVA_RequisitoOrdenMerito_Consultar 1334684, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [EVA_RequisitoOrdenMerito_Consultar]
@IdActor	INT,		
@RetVal		INT OUTPUT
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
	FROM Matricula M WITH (NOLOCK)
	LEFT JOIN Registro R WITH (NOLOCK) ON R.IdRegistro = M.IdRegistro AND R.IdActor = @IdActor
	LEFT JOIN Promocion P WITH (NOLOCK) ON P.IdPromocion = M.IdPromocion
	LEFT JOIN Actor A WITH (NOLOCK) ON A.IdActor = M.IdActor 
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
		NombreCompleto VARCHAR(200),
		Division VARCHAR(100),
		Programa VARCHAR(100),
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
		@RetVal = CASE 
		WHEN PerteneceA_Prod = 'Decimo' THEN 1 
		WHEN PerteneceA_Prod = 'Quinto' THEN 1 
		WHEN PerteneceA_Prod = 'Tercio' THEN 1 
		WHEN PerteneceA_Prod = '' THEN 0
		ELSE 0
		END 
		FROM @Temp T
		WHERE  T.NumeroIdentidad = @NumeroIdentidad
		ORDER BY IdPromocion
	END
	ELSE 
	BEGIN
		SET @RetVal = 0
	END
END
