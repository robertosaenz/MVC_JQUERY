IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeConstanciaMatricula_Obtener') DROP PROCEDURE EVA_SaeConstanciaMatricula_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Información para constancia de matricula
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:

EXEC [EVA_SaeConstanciaMatricula_Obtener] 1458695,3

*/ 
CREATE PROCEDURE [dbo].[EVA_SaeConstanciaMatricula_Obtener]
@IdActor INT,
@IdTramiteSolicitud INT 
AS
BEGIN
		SET NOCOUNT ON;

		DECLARE @IdMatricula INT
		SELECT TOP 1 @IdMatricula=IdMatricula FROM EVA_SAE_TramiteSolicitud WHERE IdActorSolicitante = @IdActor AND IdTramiteSolicitud = @IdTramiteSolicitud
		

		SELECT
		UPPER(ISNULL(C.CursoNombreOficial,C.CursoNombre)) AS CursoNombreOficial,
		CC.CursoCredito,
		AC.NumVezCurso,
		UPPER(ISNULL(MTRPA.Codigo,ISNULL(CM.Codigo,''))) AS PeriodoAcademico
		FROM AlumnoCurso AC WITH(NOLOCK)
		INNER JOIN Curso C WITH (NOLOCK) ON AC.IdCurso = C.IdCurso 
		INNER JOIN Promocion P WITH (NOLOCK) ON P.IdPromocion = AC.IdPromocion
		LEFT JOIN CurriculaCurso CC WITH (NOLOCK) ON AC.IdCurricula = CC.IdCurricula AND AC.IdCurso = CC.IdCurso    
		LEFT JOIN CurriculaModulo CM WITH (NOLOCK) ON CM.IdCurricula = AC.IdCurricula and CM.IdModulo = P.IdModulo
		LEFT JOIN MaestroTablaRegistro MTRPA WITH(NOLOCK) ON MTRPA.IdMaestroTabla in (SELECT IdMaestroTabla FROM MaestroTabla WHERE Codigo= 'TipoSemestre') AND CONVERT(int, ISNULL(MTRPA.Disponible1,0))=CM.IdModulo
		INNER JOIN Periodo PE WITH(NOLOCK) ON PE.IdPeriodo = P.IdPeriodo
		WHERE IdAlumno = @IdActor AND IdMatricula=@IdMatricula
END
