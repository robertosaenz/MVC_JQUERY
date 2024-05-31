IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeConstanciaNotas_Obtener') DROP PROCEDURE EVA_SaeConstanciaNotas_Obtener
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

EXEC [EVA_SaeConstanciaNotas_Obtener] 1433542,16

*/ 
CREATE PROCEDURE [dbo].[EVA_SaeConstanciaNotas_Obtener]
@IdActor int,
@IdTramiteSolicitud int
AS
BEGIN
		SET NOCOUNT ON;

		--DECLARE @IdTramiteSolicitud INT = 453, @IdActor INT = 1283674

		DECLARE @Notas TABLE (
			Id					INT IDENTITY,
			CursoNombreOficial	VARCHAR(200),
			CursoCredito		DECIMAL,
			PromedioFinal		VARCHAR(10),
			Codigo				VARCHAR(10),
			IdConvalidacion		INT,
			PeriodoCodigo		VARCHAR(20),
			IdRegistro			INT,
			IdCurricula			INT,
			IdCurso				INT,
			PromedioCondicion	VARCHAR(20)
		)

		INSERT INTO @Notas
		SELECT
		CC.CursoNombreOficial,
		ISNULL(CC.CursoCredito, -1),
		ISNULL(ACC.PromedioFinal, '-'),
		CM.Codigo,
		ISNULL(ACC.IdConvalidacion, -1),
		'-1',
		HPD.IdRegistro,
		AC.IdCurricula,
		ACC.IdCurso,
		ISNULL(ACC.PromedioCondicion, '')
		FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
		INNER JOIN EVA_AlumnoHistorialProductosDetalle HPD WITH (NOLOCK)
		ON HPD.IdAlumno = TS.IdActorSolicitante AND HPD.IdUltimaMatricula = TS.IdMatricula AND HPD.IdProducto = TS.IdProducto
		INNER JOIN AlumnoCurricula AC WITH (NOLOCK)
		ON AC.IdAlumno = HPD.IdAlumno AND AC.IdRegistro = HPD.IdRegistro
		INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
		ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula
		INNER JOIN EVA_SAE_DetalleTramite_CONSNOT DT WITH (NOLOCK)
		ON DT.IdTramiteSolicitud = TS.IdTramiteSolicitud AND DT.IdModulo = ACC.IdModulo
		LEFT JOIN CurriculaModulo CM WITH (NOLOCK)
		ON CM.IdModulo = ACC.IdModulo AND CM.IdCurricula = ACC.IdCurricula
		LEFT JOIN CurriculaCurso CC WITH (NOLOCK)
		ON CC.IdCurricula = ACC.IdCurricula AND CC.IdCurso = ACC.IdCurso
		LEFT JOIN Producto P WITH (NOLOCK)
		ON P.IdProducto = HPD.IdProducto
		WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud AND TS.IdActorSolicitante = @IdActor
		ORDER BY P.ProductoNombre, AC.IdCurricula, CM.Orden, CC.Orden

		DECLARE @CurId INT, @MaxId INT

		SELECT @CurId = 1, @MaxId = MAX(N.Id) FROM @Notas N

		DECLARE
		@CurIdConvalidacion				INT,
		@CurIdRegistro					INT,
		@CurIdCurricula					INT,
		@CurIdCurso						INT,
		@CurCursoPeriodoCodigo			VARCHAR(20),
		@CurConvalidacionDescripcion	BIT,
		@CurPromedioCondicion			VARCHAR(20)

		WHILE (@MaxId >= @CurId)
		BEGIN
			SELECT
			@CurIdConvalidacion = N.IdConvalidacion,
			@CurIdRegistro = N.IdRegistro,
			@CurIdCurricula = N.IdCurricula,
			@CurIdCurso = N.IdCurso,
			@CurPromedioCondicion = N.PromedioCondicion
			FROM @Notas N
			WHERE N.Id = @CurId

			SET @CurCursoPeriodoCodigo = ''
			SET @CurConvalidacionDescripcion = 0

			IF (@CurIdConvalidacion > 0)
			BEGIN
				SELECT @CurCursoPeriodoCodigo = ISNULL(P.Codigo, ''), @CurConvalidacionDescripcion = 1
				FROM Convalidacion C WITH (NOLOCK)
				LEFT JOIN Periodo P WITH (NOLOCK)
				ON P.IdPeriodo = C.IdPeriodoAnual
				WHERE C.IdConvalidacion = @CurIdConvalidacion AND C.Estado = 'R'
			END
			ELSE
			BEGIN
				SELECT @CurCursoPeriodoCodigo = ISNULL(P.Codigo, ''), @CurConvalidacionDescripcion = 1
				FROM CargoAlumno CA WITH (NOLOCK)
				INNER JOIN Cargo C WITH (NOLOCK)
				ON C.IdCargo = CA.IdCargo
				INNER JOIN Periodo P WITH (NOLOCK)
				ON P.IdPeriodo = C.IdPeriodo
				INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
				ON ACC.IdAlumno = @IdActor AND ACC.IdRegistro = CA.IdRegistro AND ACC.IdCurricula = CA.IdCurricula AND ACC.IdCurso = CA.IdCurso
				WHERE
				CA.IdAlumno = @IdActor
				AND CA.IdRegistro = @CurIdRegistro
				AND CA.IdCurricula = @CurIdCurricula
				AND CA.IdCurso = @CurIdCurso
				AND CA.Nota = ACC.PromedioFinal

				IF (LTRIM(RTRIM(@CurConvalidacionDescripcion)) = 0)
				BEGIN
					SELECT
					@CurCursoPeriodoCodigo = ISNULL(P.Codigo, ''),
					@CurConvalidacionDescripcion =
						CASE
							WHEN ISNULL(AC.IdDecreto, -1) = -1 THEN 0
							ELSE 1
						END
					FROM AlumnoCurso AC WITH (NOLOCK)
					INNER JOIN Matricula M WITH (NOLOCK)
					ON M.IdMatricula = AC.IdMatricula
					INNER JOIN PromocionGrupo PG WITH (NOLOCK)
					ON PG.IdPromocion = AC.IdPromocion and PG.IdGrupo = AC.IdGrupo
					LEFT JOIN Decreto D WITH (NOLOCK)
					ON D.IdDecreto = AC.IdDecreto
					LEFT JOIN DecretoCabecera DC WITH (NOLOCK)
					ON DC.IdDecretoCabecera = D.IdDecretoCabecera
					LEFT JOIN Periodo P WITH (NOLOCK)
					ON P.IdPeriodo = DC.IdPeriodo
					WHERE
					AC.IdAlumno = @IdActor
					AND AC.IdRegistro = @CurIdRegistro
					AND ISNULL(AC.IdCurriculaOriginal, AC.IdCurricula) = @CurIdCurricula
					AND ISNULL(AC.IdCursoOriginal, AC.IdCurso) = @CurIdCurso
					AND M.Estado != 'X'
					AND AC.estado = 'NO'
					AND M.EsMatricula = 1
					AND AC.EsMatricula = 1
					ORDER BY ISNULL(M.MatriculaFecha, M.InscritoFecha) DESC
				END
			END

			IF (LTRIM(RTRIM(@CurPromedioCondicion)) != '' AND LTRIM(RTRIM(@CurConvalidacionDescripcion)) = 0)
			BEGIN
				SELECT TOP 1
				@CurCursoPeriodoCodigo = PE.Codigo,
				@CurConvalidacionDescripcion = 1
				FROM AlumnoCurso AC WITH (NOLOCK)
				INNER JOIN Promocion P WITH (NOLOCK)
				ON P.IdPromocion = AC.IdPromocion
				INNER JOIN Periodo PE WITH (NOLOCK)
				ON PE.IdPeriodo = P.IdPeriodo
				INNER JOIN Matricula M WITH (NOLOCK)
				ON M.IdMatricula = AC.IdMatricula
				INNER JOIN PromocionGrupo PG WITH (NOLOCK)
				ON PG.IdPromocion = AC.IdPromocion AND PG.IdGrupo = AC.IdGrupo
				WHERE
				AC.IdAlumno = @IdActor
				AND AC.IdRegistro = @CurIdRegistro
				AND ISNULL(AC.IdCurriculaOriginal, AC.IdCurricula) = @CurIdCurricula
				AND ISNULL(AC.IdCursoOriginal, AC.IdCurso) =  @CurIdCurso
				AND AC.EsMatricula = 1
				AND M.Estado != 'X'
				AND AC.estado = 'NO'
				ORDER BY ISNULL(M.MatriculaFecha, M.InscritoFecha) DESC
			end

			UPDATE N
			SET
			N.PeriodoCodigo = @CurCursoPeriodoCodigo
			FROM @Notas N
			WHERE N.Id = @CurId AND N.IdCurso = @CurIdCurso

			SET @CurId = @CurId + 1
		END

		SELECT N.CursoNombreOficial, N.CursoCredito, N.PromedioFinal AS PromedioReal, N.Codigo AS Ciclo, N.PeriodoCodigo AS Periodo
		FROM @Notas N


		--DECLARE @IdUnidadAcademica INT
		--DECLARE @IdProducto VARCHAR(200)

		--SELECT TOP 1 
		--@IdUnidadAcademica = P.IdUnidadAcademica 
		--FROM Matricula M WITH(NOLOCK)
		--INNER JOIN Promocion P WITH(NOLOCK) ON P.IdPromocion = M.IdPromocion
		--WHERE M.IdActor = @IdActor AND M.EsMatricula=1 ORDER BY M.IdMatricula DESC

		--SELECT        
		--ISNULL(CASE WHEN PR.TipoServicio = 'P' OR PR.TipoServicio = 'C' THEN CC.CursoNombreOficial END,C.CursoNombre) AS CursoNombreOficial,     
		--ISNULL(CC.CursoCredito,0) AS CursoCredito,
		--ISNULL(AC.PromedioReal,'') AS PromedioReal,  
		--UPPER(ISNULL(MTRPA.Codigo,ISNULL(CM.Codigo,''))) AS Ciclo,
		--ISNULL(PE.Codigo,'')  AS Periodo
		----ISNULL(PG.GrupoCodigo,'') AS GrupoCodigo,    

	 --  FROM AlumnoCurso AC WITH (NOLOCK)      
		--INNER JOIN EVA_SAE_TramiteSolicitud TS ON TS.IdActorSolicitante=AC.IdAlumno 
		--INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)  ON AC.IdAlumno = ACC.IdAlumno    
		--			 AND ISNULL(AC.IdCurriculaOriginal,AC.IdCurricula) = ACC.IdCurricula     
		--			 AND AC.IdRegistro = ACC.IdRegistro    
		--			 AND ISNULL(AC.IdCursoOriginal,AC.IdCurso) = ACC.IdCurso      
		--INNER JOIN CurriculaCurso CC WITH (NOLOCK)   ON AC.IdCurricula=CC.IdCurricula    
		--			 AND AC.IdCurso=CC.IdCurso     
		--INNER JOIN EVA_SAE_DetalleTramite_CONSNOT DT ON DT.IdTramiteSolicitud = TS.IdTramiteSolicitud and CC.IdModulo=DT.IdModulo  
		--LEFT JOIN CurriculaModulo CM WITH (NOLOCK)   ON CC.IdModulo=CM.IdModulo    
		--			 AND CC.IdCurricula=CM.IdCurricula      
		--LEFT JOIN MaestroTablaRegistro MTRPA WITH(NOLOCK) ON MTRPA.IdMaestroTabla in (select IdMaestroTabla from MaestroTabla where Codigo= 'TipoSemestre') AND CONVERT(int, ISNULL(MTRPA.Disponible1,0))=CM.IdModulo
		--LEFT JOIN Seccion S WITH (NOLOCK)     ON AC.IdSeccion=S.IdSeccion          
		--INNER JOIN Curso C WITH (NOLOCK)     ON CASE WHEN ac.idseccion IS NULL THEN AC.IdCurso ELSE S.IdCurso END = C.IdCurso        
		--LEFT JOIN Curricula CRR WITH (NOLOCK)    ON AC.IdCurricula = CRR.IdCurricula        
		--LEFT JOIN Producto P WITH (NOLOCK)     ON CRR.IdProducto=P.IdProducto AND P.IdProducto =TS.IdProducto   
		--INNER JOIN Promocion PR2 WITH (NOLOCK)    ON AC.IdPromocion=PR2.IdPromocion 
		--INNER JOIN Periodo PE WITH(NOLOCK) ON PE.IdPeriodo = PR2.IdPeriodo
		--INNER JOIN Matricula M WITH (NOLOCK)    ON M.IdMatricula = AC.IdMatricula          
		--INNER JOIN Promocion PR WITH (NOLOCK)    ON M.IdPromocion=PR.IdPromocion        
		--INNER JOIN UnidadNegocio UN WITH (NOLOCK)   ON PR.IdUnidadNegocio=UN.IdUnidadNegocio       
		--LEFT JOIN PromocionGrupo PG WITH(NOLOCK)   ON M.IdPromocion=PG.IdPromocion    
		--			 AND M.IdGrupo=PG.IdGrupo       
	 -- WHERE AC.IdAlumno=@IdActor    and TS.IdTramiteSolicitud=@IdTramiteSolicitud  
		--AND AC.EsMatricula=1    
		--AND AC.PromedioReal <> ''
	 -- ORDER BY CM.Orden,CC.Orden       
      
END


