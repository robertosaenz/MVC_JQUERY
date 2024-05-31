IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisito_Estado') DROP PROCEDURE EVA_SaeRequisito_Estado
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (08/08/2022)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Eval�a el estado de los requisitos enviados a trav�s de un string separado por comas
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 
/*  
Ejemplo:
EXEC [EVA_SaeRequisito_Estado] '1;2',1335517
EXEC [EVA_SaeRequisito_Estado] 774950,'00002500',17 No Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 562001,'00002500' Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 1568256,'00002700' No Cumple idat
EXEC [EVA_SaeRequisito_Estado] 1427776,'00002700' Cumple Idat
EXEC [EVA_SaeRequisito_Estado] 774950,'00002500' No Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 562001,'00002500' Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 1568584,'00002700' No Cumple idat
EXEC [EVA_SaeRequisito_Estado] 1427776,'00002700' Cumple Idat
EXEC [EVA_SaeRequisito_Estado] 256623,'00002500' No Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 1476162,'00002500',11,17445895 Cumple Zegel
EXEC [EVA_SaeRequisito_Estado] 1476162,'00002700' Cumple Idat
EXEC [EVA_SaeRequisito_Estado] 1229912,'00002700' Cumple Idat
EXEC [EVA_SaeRequisito_Estado] 1569679,'00002700', 23, 384264, NULL ---No Cumple Idat
*/ 
CREATE PROCEDURE [EVA_SaeRequisito_Estado]
@IdActor				INT,
@CompaniaSocio			CHAR(8),
@IdTramite				INT,
@IdUltimaMatricula		INT,
@IdCaso					INT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IdEmpresa		INT
	DECLARE @IdSede			INT
	DECLARE @IdCurricula	INT
	DECLARE @IdRegistro		INT
	DECLARE @Periodo_Fin	DATETIME
	DECLARE @PPP			INT =0
	DECLARE @OrdenMerito    INT

	--EXEC [EVA_SaeRequisitoPPP_Consultar] @IdActor,@CompaniaSocio,@PPP OUT -- Revisar su inclusion en el case
	--EXEC [EVA_RequisitoOrdenMerito_Consultar] @IdActor,@OrdenMerito out -- Incluir en el mismo CASE para no consultar a cada rato 

	-- Matricula

	SELECT @IdRegistro=HPD.IdRegistro,@IdCurricula=HPD.IdCurricula, @Periodo_Fin = P.Fin from EVA_AlumnoHistorialProductosDetalle HPD WITH(NOLOCK)
	LEFT JOIN Periodo P WITH(NOLOCK) ON HPD.IdPeriodo = P.IdPeriodo
	WHERE IdAlumno=@IdActor AND IdUltimaMatricula= @IdUltimaMatricula
	
	-- Periodo 
	DECLARE 
	@IdPeriodo INT,
	@EsActual INT
	DECLARE @rpta INT = 0
	SELECT TOP 1 @IdPeriodo=P.IdPeriodo
	FROM Matricula M WITH(NOLOCK)
	INNER JOIN Promocion P WITH(NOLOCK) ON P.IdPromocion = M.IdPromocion
	WHERE M.IdActor = @IdActor AND M.EsMatricula=1 AND M.Estado = 'N'
	ORDER BY M.IdMatricula DESC


	SELECT TR.IdRequisito,
	R.Nombre,
	R.Detalle,
	CASE 
		WHEN R.CodigoInterno= 'NoDeuda' -- No tener deudas (OK)
		THEN
		(
			SELECT
			CASE WHEN COUNT(Personaant)>0
			THEN 0
			ELSE 1
			END
			FROM Vw_Deudas WITH(NOLOCK)
			WHERE PersonaAnt=CONVERT(VARCHAR,@IdActor)                   
			AND CONVERT(VARCHAR,FechaVencimiento,112) < CONVERT(VARCHAR,getdate(),112) 
		)
		WHEN R.CodigoInterno = 'MatPerAct' -- Estar matriculado en el periodo lectivo actual (OK)
		THEN
		(
			SELECT
				CASE
					WHEN COUNT(*) > 0 THEN 1
					ELSE 0
				END
			FROM EVA_AlumnoHistorialProductosDetalle HPD WITH(NOLOCK)
			WHERE HPD.IdAlumno = @IdActor AND HPD.IdUltimaMatricula = @IdUltimaMatricula AND HPD.EstadoAlumno = 'ACT'
		)
		WHEN R.CodigoInterno = 'TraRetiro' -- Haber tramitado retiro (OK)
		THEN
		(
			SELECT
			CASE WHEN COUNT(IdRetiro)>0
			THEN 1
			ELSE 0
			END
			FROM MatriculaRetiro MR WITH(NOLOCK)
			WHERE MR.IdMatricula = @IdUltimaMatricula
		)
		WHEN R.CodigoInterno = 'PerPosSup' -- Pertenecer al tercio, quinto o decimo
		THEN
		(
			Select IIF(OrdenMeritoProductoTexto in ('Tercio','Quinto','Decimo'),1,0) from (
				select top 1 M.IdMatricula,M.IdRegistro,M.IdModulo,M.IdGrupo,P.IdPromocion,PG.FechaInicio,PG.FechaFin,  PGC.OrdenMeritoProductoTexto from Matricula M WITH(NOLOCK)
				INNER join Promocion P WITH(NOLOCK) On P.IdPromocion=M.IdPromocion
				INNER join PromocionGrupo PG WITH(NOLOCK) On PG.IdPromocion=P.IdPromocion and M.IdGrupo=PG.IdGrupo
				INNER join PromocionGrupoCierre PGC WITH(NOLOCK) ON PGC.IdPromocion=PG.IdPromocion and PGC.IdActor=M.IdActor and PGC.IdCierre is not null
				where M.IdActor=@IdActor and M.Estado in ('N','R') and M.IdRegistro = @IdRegistro
				order by M.IdMatricula desc
			) as Temporal
		)
		WHEN R.CodigoInterno = 'TodExpApr' -- Tener todo el expediente aprobado. (P)
		THEN
		(
			SELECT 1
		)
		WHEN R.CodigoInterno = 'AprTodUni' -- Aprobar todas las unidades did�cticas del plan de estudios (P)
		THEN
		(
			select CASE WHEN count(ACC.IdCurso) - sum(CASE WHEN ACC.PromedioCondicion = 'A' THEN 1 ELSE 0 END) > 0 THEN 0 ELSE 1 END
			from EVA_AlumnoHistorialProductosDetalle HPD WITH(NOLOCK)
			LEFT JOIN AlumnoCurricula AC WITH(NOLOCK) on AC.IdAlumno=HPD.IdAlumno and AC.IdRegistro=HPD.IdRegistro and AC.IdCurricula=HPD.IdCurricula
			LEFT JOIN AlumnoCurriculaCurso ACC WITH(NOLOCK) on ACC.IdAlumno=HPD.IdAlumno and ACC.IdCurricula=HPD.IdCurricula and ACC.IdRegistro=HPD.IdRegistro
			where HPD.IdAlumno=@IdActor and HPD.IdUltimaMatricula=@IdUltimaMatricula AND  HPD.IdRegistro=@IdRegistro
		)

		WHEN R.CodigoInterno = '30diaCier' -- Haber pasado 30 dias de cierre del periodo lectivo (MEJORAR)
		THEN
		(
			SELECT 
			CASE WHEN getdate() > dateadd(mm,1, @Periodo_Fin)
			THEN 1
			ELSE 0
			END
		)
		WHEN R.CodigoInterno = 'CumHorPra' -- Haber cumplido con sus horas de practicas pre- profesionales o validacion de practicas (MEJORAR)
		THEN
		(
			SELECT @PPP
		)
		WHEN R.CodigoInterno = 'HabAprMod' -- Haber aprobado los m�dulos (2 por ciclo. (P)
		THEN
		(
			SELECT 1
		)
		WHEN R.CodigoInterno = 'ParProBec' -- Ser parte del programa de becas (Mejorar)
		THEN
		(
			SELECT 
			CASE WHEN COUNT(IdPromocionBeca)>0
			THEN 1
			ELSE 0
			END  
			FROM PromocionBeca WITH(NOLOCK)  
			where IdActor =@IdActor AND 
			(
				dbo.toMiliseconds(getdate()) >= dbo.toMiliseconds(FechaInicioVigencia) AND
				dbo.toMiliseconds(getdate()) <= dbo.toMiliseconds(FechaFinVigencia)
			)
		)
		WHEN R.CodigoInterno = 'EgresMax3' -- Haber egresado m�ximo 3 a�os atr�s
		THEN
		(
			SELECT CASE WHEN YEAR(GETDATE()) - (SELECT TOP 1 YEAR(FechaCreacion) AS anio FROM Egresados WITH(NOLOCK) WHERE IdRegistro=@IdRegistro AND IdAlumno=@IdActor AND IdCurricula =@IdCurricula)  <=3 THEN 1 ELSE 0 END
		)
		WHEN R.CodigoInterno = 'UnTraXDia' -- Realizar un tr�mite por d�a. (OK)
		THEN
		(
			SELECT CASE WHEN ISNULL((SELECT TOP 1 1 FROM EVA_SAE_TramiteSolicitud WITH(NOLOCK) WHERE IdActorSolicitante=@IdActor AND IdTramite=@IdTramite AND CONVERT(DATE, FechaCreacion) = CONVERT(DATE, GETDATE()) AND EstadoSolicitud IN ('PGA','FIN')),0) = 1 THEN 0 ELSE 1 END
		)
		WHEN R.CodigoInterno = 'NoTenXDen' THEN 1 --Temporal - alaureano
		WHEN R.CodigoInterno = 'AdjCerCon' THEN 1 --Temporal - scaycho
	END AS EsValido,
	R.Link AS LinkVerMas,
	TRIM(R.CodigoInterno) AS CodigoInterno, R.Periodo, R.ValorPeriodo, TRIM(R.TipoValidacion) AS TipoValidacion
 	FROM EVA_SAE_TramiteRequisito TR WITH(NOLOCK)
	INNER JOIN EVA_SAE_Requisito R WITH(NOLOCK) ON R.IdRequisito = TR.IdRequisito
	WHERE
	TR.IdTramite = @IdTramite
	AND TR.EsActivo = 1
	AND (IdCaso IS NULL OR IdCaso = @IdCaso)
	ORDER BY TR.Orden
END
