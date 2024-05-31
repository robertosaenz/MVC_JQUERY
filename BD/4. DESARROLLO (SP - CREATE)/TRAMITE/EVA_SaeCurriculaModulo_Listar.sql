IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeCurriculaModulo_Listar') DROP PROCEDURE EVA_SaeCurriculaModulo_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (25.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista los modulos en base a una curricula y matricula
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
@1		15.07.22	scaycho			Se agregó el parámetro CodigoPublicoTramite
*/

/*  
Ejemplo:
EXEC EVA_SaeCurriculaModulo_Listar 5606, 393246, 1283674, 'CONSNOT'
EXEC EVA_SaeCurriculaModulo_Listar 5606, 393246, 1283674, 'VISILA'
*/

CREATE PROCEDURE EVA_SaeCurriculaModulo_Listar
@IdCurricula INT,
@IdMatricula INT,
@IdActor INT,
@CodigoPublicoTramite VARCHAR(9)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @IdRegistro INT, @IdModuloActual INT, @IdUnidadNegocio INT

	SELECT @IdRegistro = HPD.IdRegistro, @IdModuloActual = HPD.IdModulo, @IdUnidadNegocio = HPD.IdUnidadNegocio
	FROM EVA_AlumnoHistorialProductosDetalle HPD WITH (NOLOCK)
	WHERE HPD.IdAlumno = @IdActor AND HPD.IdUltimaMatricula = @IdMatricula AND HPD.IdCurricula = @IdCurricula

	IF (@CodigoPublicoTramite = 'CONSNOT')
	BEGIN
		DECLARE @UnidadDidacticaXModuloCONSNOT INT = 0
		DECLARE @UnidadDidacticaAprobadaXModuloCONSNOT INT = 0

		SELECT @UnidadDidacticaXModuloCONSNOT = COUNT(*)
		FROM AlumnoCurricula AC WITH (NOLOCK)
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula AND ACC.IdModulo = @IdModuloActual
		WHERE AC.IdAlumno = @IdActor AND AC.IdRegistro = @IdRegistro
		GROUP BY ACC.IdModulo

		SELECT @UnidadDidacticaAprobadaXModuloCONSNOT = COUNT(*)
		FROM AlumnoCurricula AC WITH (NOLOCK)
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula AND ACC.IdModulo = @IdModuloActual AND ACC.PromedioCondicion IN ('A', 'D')
		WHERE AC.IdAlumno = @IdActor AND AC.IdRegistro = @IdRegistro
		GROUP BY ACC.IdModulo

		SET @IdModuloActual = IIF(@UnidadDidacticaXModuloCONSNOT <> @UnidadDidacticaAprobadaXModuloCONSNOT, @IdModuloActual - 1, @IdModuloActual)

		SELECT CM.IdModulo, IIF(CM.IdModulo <= @IdModuloActual, 1, 0) AS EsActivo, MTR.Disponible3 AS Disponible3_PeriodoAcademico
		FROM AlumnoCurricula AC WITH (NOLOCK)
		INNER JOIN CurriculaModulo CM WITH (NOLOCK)
		ON CM.IdCurricula = AC.IdCurricula
		INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
		ON
		MTR.IdMaestroTabla IN (SELECT MT.IdMaestroTabla FROM MaestroTabla MT WITH (NOLOCK) WHERE MT.Codigo = 'TipoSemestre')
		AND ((MTR.Disponible1 IS NULL AND @IdUnidadNegocio <> 1) OR (MTR.Disponible1 = CM.IdModulo AND @IdUnidadNegocio = 1))
		WHERE AC.IdAlumno = @IdActor AND AC.IdRegistro = @IdRegistro
		ORDER BY CM.IdModulo
	END
	ELSE IF (@CodigoPublicoTramite = 'VISILA')
	BEGIN
		DECLARE @UnidadDidacticaXModuloVISILA TABLE (IdModulo INT, UnidadesAcademicas INT)
		DECLARE @UnidadDidacticaAprobadaXModuloVISILA TABLE (IdModulo INT, UnidadesAcademicas INT)

		INSERT INTO @UnidadDidacticaXModuloVISILA
		SELECT ACC.IdModulo, COUNT(*)
		FROM AlumnoCurricula AC WITH (NOLOCK)
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula
		WHERE AC.IdAlumno = @IdActor AND AC.IdRegistro = @IdRegistro
		GROUP BY ACC.IdModulo

		INSERT INTO @UnidadDidacticaAprobadaXModuloVISILA
		SELECT ACC.IdModulo, COUNT(*)
		FROM AlumnoCurricula AC WITH (NOLOCK)
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula AND ACC.PromedioCondicion = 'A'
		WHERE AC.IdAlumno = @IdActor AND AC.IdRegistro = @IdRegistro
		GROUP BY ACC.IdModulo

		SELECT
		UDXM.IdModulo,
		UDXM.UnidadesAcademicas,
		ISNULL(UDAXM.UnidadesAcademicas, 0) AS UnidadesAcademicasAprobadas,
		IIF(ISNULL(UDAXM.UnidadesAcademicas, 0) > 0 AND UDXM.IdModulo <= @IdModuloActual, 1, 0) EsActivo,
		MTR.Disponible3 AS Disponible3_PeriodoAcademico,
		ACC.IdCurso,
		CASE ACC.PromedioCondicion
			WHEN 'A' THEN 'APROBADO'
			WHEN 'D' THEN 'DESAPROBADO'
			ELSE 'PENDIENTE'
		END AS PromedioCondicion,
		CC.CursoNombreOficial
		FROM @UnidadDidacticaXModuloVISILA UDXM
		LEFT JOIN @UnidadDidacticaAprobadaXModuloVISILA UDAXM
		ON UDAXM.IdModulo = UDXM.IdModulo
		INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
		ON
		MTR.IdMaestroTabla IN (SELECT MT.IdMaestroTabla FROM MaestroTabla MT WITH (NOLOCK) WHERE MT.Codigo = 'TipoSemestre')
		AND ((MTR.Disponible1 IS NULL AND @IdUnidadNegocio <> 1) OR (MTR.Disponible1 = UDXM.IdModulo AND @IdUnidadNegocio = 1))
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = @IdActor AND ACC.IdRegistro = @IdRegistro AND ACC.IdCurricula = @IdCurricula AND ACC.IdModulo = UDXM.IdModulo
		INNER JOIN CurriculaCurso CC WITH (NOLOCK)
		ON CC.IdCurricula = ACC.IdCurricula AND CC.IdCurso = ACC.IdCurso
		ORDER BY UDXM.IdModulo
	END
END