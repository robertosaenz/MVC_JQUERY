IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteRECINASIS_Obtener') DROP PROCEDURE EVA_SaeTramiteRECINASIS_Obtener
GO
--------------------------------------------------------------------------------
--Creado por		: ALAUREANO	(04/07/2022)
--Revisado por		: 
--Funcionalidad		: Obtiene los cursos y las faltas de un determinado alumno por su idActor
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC [EVA_SaeTramiteRECINASIS_Obtener] 1569679 // idat
EXEC [EVA_SaeTramiteRECINASIS_Obtener] 1552253 //zegel
EXEC [EVA_SaeTramiteRECINASIS_Obtener] 1566669
*/

--exec EVA_SaeTramiteRECINASIS_Obtener @IdActor=465349
CREATE PROCEDURE [EVA_SaeTramiteRECINASIS_Obtener]
	@IdActor INT
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @ValorPeriodo int = (select R.ValorPeriodo from EVA_SAE_Tramite T WITH(NOLOCK)
									INNER JOIN EVA_SAE_TramiteRequisito TR WITH(NOLOCK) ON TR.IdTramite=T.IdTramite
									INNER JOIN EVA_SAE_Requisito R WITH(NOLOCK) ON R.IdRequisito = TR.IdRequisito AND EsLimitado=1
									where CodigoPublico = 'RECINASIS')

	SELECT IdUltimaMatricula, P.IdProducto, CC.IdCurso, CC.CursoNombreOficial
	FROM EVA_AlumnoHistorialProductosDetalle AHP WITH(NOLOCK)
	INNER JOIN Producto P WITH(NOLOCK) ON P.IdProducto=AHP.IdProducto
	INNER JOIN Curricula C WITH(NOLOCK) ON C.IdCurricula=AHP.IdCurricula
	INNER JOIN CurriculaCurso CC WITH(NOLOCK) ON CC.IdCurricula=C.IdCurricula
	AND CC.IdModulo=AHP.IdModulo
	WHERE IdAlumno = @IdActor

	Declare @TablaDetalleRecinasis As Table (IdTramiteSolicitud int
									,IdCurso int
									,IdSeccion int
									,IdHorario int
									,IdSesion int)

	Insert into @TablaDetalleRecinasis
	Select MAX(IdTramiteSolicitud)IdTramiteSolicitud,IdCurso, IdSeccion, IdHorario, IdSesion
	From EVA_SAE_DetalleTramite_RECINASIS
	GROUP BY IdCurso, IdSeccion, IdHorario, IdSesion, UsuarioCreacion

	--Fechas
	SELECT
	AHP.IdUltimaMatricula,
	AC.Idcurso, 
	AC.IdSeccion,
	ACA.IdHorario,
	ACA.IdSesion,
	Dbo.toMiliseconds(ACA.FechaModificacion) AS FechaModificacion,
	DATEDIFF(DAY, ACA.FechaModificacion,GETDATE()) DiasTranscurridos,
	TS.EstadoSolicitud
	FROM EVA_AlumnoHistorialProductosDetalle AHP WITH(NOLOCK)
	INNER JOIN AlumnoCurso AC WITH(NOLOCK) ON AC.IdMatricula=AHP.IdUltimaMatricula AND AC.IdAlumno=AHP.IdAlumno
	INNER JOIN AlumnoCursoAsistencia ACA WITH(NOLOCK) ON ACA.IdSeccion=AC.IdSeccion
	LEFT JOIN @TablaDetalleRecinasis TDR ON TDR.IdCurso=AC.IdCurso AND TDR.IdSeccion=AC.IdSeccion AND TDR.IdHorario=ACA.IdHorario AND TDR.IdSesion=ACA.IdSesion
	LEFT JOIN EVA_SAE_TramiteSolicitud TS WITH(NOLOCK) ON TS.IdTramiteSolicitud=TDR.IdTramiteSolicitud
	WHERE AC.Idalumno = ACA.IdAlumno
	AND ACA.IdAlumno = @IdActor
	AND ACA.Valor='F'
	--AND (EstadoSolicitud IS NULL OR EstadoSolicitud = 'PGA')
	AND DATEDIFF(DAY, ACA.FechaModificacion,GETDATE())<=@ValorPeriodo

END