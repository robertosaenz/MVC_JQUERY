IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_EsMaquinalRECINASIS_Aprobar') DROP PROCEDURE EVA_EsMaquinalRECINASIS_Aprobar
GO
--------------------------------------------------------------------------------
--Creado por		: ALAUREANO
--Revisado por		: 
--Funcionalidad		: Aprobar los Tramites EsRespuestaMaquinal de Rectficación de Inasistencias
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_EsMaquinalRECINASIS_Aprobar
*/

CREATE PROCEDURE EVA_EsMaquinalRECINASIS_Aprobar
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY

		DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @ErrorProcedure VARCHAR(100),@ErrorLine INT, @ErrorMessage VARCHAR(1000)
		DECLARE @i int = 1, @IdTramiteSolicitud int, @IdTramite int, @TotalSolicitud INT, @Nombres VARCHAR (100), @Curso VARCHAR(100), @Fecha VARCHAR(20), @Respuesta VARCHAR (500)
		DECLARE @SolitudesRespuestaMaquinal AS Table (	Nro INT, 
														IdTramiteSolicitud INT,
														IdTramite INT, Nombres VARCHAR (100),
														Curso VARCHAR(100),
														Fecha VARCHAR(20),
														Respuesta VARCHAR(500))

		INSERT INTO @SolitudesRespuestaMaquinal
		SELECT ROW_NUMBER() OVER(ORDER BY TS.IdTramiteSolicitud),TS.IdTramiteSolicitud, T.IdTramite, 
		A.Nombres + ' '+ A.Paterno + ' ' + A.Materno, C.CursoNombreOficial, CONVERT(VARCHAR(20),ACA.FechaModificacion,104), TCR.Texto1
		FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
		INNER JOIN EVA_SAE_Tramite T WITH (NOLOCK) ON TS.IdTramite=T.IdTramite
		INNER JOIN EVA_SAE_DetalleTramite_RECINASIS DT WITH (NOLOCK) ON DT.IdTramiteSolicitud=TS.IdTramiteSolicitud
		INNER JOIN AlumnoCursoAsistencia ACA WITH (NOLOCK) ON ACA.IdSeccion=DT.IdSeccion AND ACA.IdHorario = DT.IdHorario AND ACA.IdSesion = DT.IdSesion AND ACA.IdAlumno = TS.IdActorSolicitante
		INNER JOIN Curso C WITH (NOLOCK) ON C.IdCurso=DT.IdCurso
		INNER JOIN Actor A WITH (NOLOCK) ON A.IdActor=TS.IdActorSolicitante
		LEFT JOIN EVA_SAE_TramiteConfiguracionRespuesta TCR WITH (NOLOCK) ON TCR.IdTramite=T.IdTramite
		WHERE EsRespuestaMaquinal=1 
		AND EstadoSolicitud='PGA' AND T.CodigoPublico='RECINASIS' AND EsAnulado=0
		--AND DATEDIFF(HOUR, TS.FechaPGA,GETDATE())>1
		AND TCR.Respuesta='APR'


		SELECT @TotalSolicitud = MAX(Nro) FROM @SolitudesRespuestaMaquinal

		IF (@TotalSolicitud>0) BEGIN

			WHILE (@i<=@TotalSolicitud) 
			BEGIN
				BEGIN TRY
					SELECT @IdTramiteSolicitud=IdTramiteSolicitud, @IdTramite=IdTramite, @Nombres=Nombres, @Curso=Curso, @Fecha=Fecha, @Respuesta=Respuesta 
					FROM @SolitudesRespuestaMaquinal WHERE Nro=@i
					
					SET @Respuesta = IIF(@Respuesta IS NULL OR @Respuesta = '','Hola '+@Nombres+'. Su asistencia ha sido rectificada.', 
										REPLACE(REPLACE(REPLACE(@Respuesta,'[Nombre_Alumno]',@Nombres),'[Nombre_Unidad_Didactica]',@Curso),'[Fecha_Rectificacion]',@Fecha))

					BEGIN TRANSACTION AprobarRecinasis
					
					-- 1) Registro Respuesta
					INSERT INTO EVA_SAE_TramiteSolicitudRespuesta
					(IdTramiteSolicitud,IdActor,TipoParticipante,Mensaje,Estado,UsuarioCreacion,FechaCreacion)
					VALUES
					(@IdTramiteSolicitud,1,'ENC',@Respuesta,'APR',1,GETDATE())
					
					IF (@@ROWCOUNT > 0) 
					BEGIN
						UPDATE EVA_SAE_TramiteSolicitud
						SET UltimoEstadoRespuesta = 'APR'
						WHERE IdTramiteSolicitud = @IdTramiteSolicitud

						IF (@@ROWCOUNT > 0) 
						BEGIN
							
							-- 2) Aprobación del Tramite
							DECLARE @X INT
							EXEC EVA_SaeDetalleTramiteRECINASIS_Aprobar @IdTramiteSolicitud, @X OUT

							IF(@X = -1) 
							BEGIN
								-- 3) Actualizar Scope
								DECLARE @Actualizar TABLE (RetVal INT)
								DECLARE @RetVal INT

								INSERT INTO @Actualizar
								EXEC EVA_SaeTramiteSolicitud_ActualizarEstado @IdTramiteSolicitud, 'NOR',0,1
								SELECT @RetVal=RetVal FROM @Actualizar

								IF (@RetVal = -1) 
								BEGIN
									SELECT @IdTramiteSolicitud IdTramiteSolicitud, -1 AS RetVal
									COMMIT TRANSACTION AprobarRecinasis
									EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS', NULL, 'Aprobación Éxitosa',NULL,NULL,NULL,@IdTramite,@IdTramiteSolicitud,NULL,'Try',NULL

								END
								ELSE BEGIN
									SELECT @IdTramiteSolicitud IdTramiteSolicitud, @RetVal AS RetVal
									ROLLBACK TRANSACTION AprobarRecinasis
									EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS', 'EVA_SaeTramiteSolicitud_ActualizarEstado', 'Falló en el ejecución del SP',NULL,NULL,NULL,@IdTramite,@IdTramiteSolicitud,NULL,'Try',NULL

								END
							END
							ELSE BEGIN
								SELECT @IdTramiteSolicitud IdTramiteSolicitud, -50 AS RetVal
								ROLLBACK TRANSACTION AprobarRecinasis
								EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS', 'EVA_SaeDetalleTramiteRECINASIS_Aprobar', 'Falló en el ejecución del SP',NULL,NULL,NULL,@IdTramite,@IdTramiteSolicitud,NULL,'Try',NULL

							END

						END
						ELSE BEGIN
							SELECT @IdTramiteSolicitud IdTramiteSolicitud, -50 AS RetVal
							ROLLBACK TRANSACTION AprobarRecinasis
							EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS', 'EVA_SAE_TramiteSolicitud', 'Falló en el UPDATE',NULL,NULL,NULL,@IdTramite,@IdTramiteSolicitud,NULL,'Try',NULL

						END

					END
					ELSE BEGIN
						SELECT @IdTramiteSolicitud IdTramiteSolicitud, -50 AS RetVal
						--ROLLBACK TRANSACTION AprobarRecinasis
						EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS', 'EVA_SAE_TramiteSolicitudRespuesta', 'Falló en el INSERT',NULL,NULL,NULL,@IdTramite,@IdTramiteSolicitud,NULL,'Try',NULL
						
					END
					

				END TRY

				BEGIN CATCH
					
					ROLLBACK TRANSACTION AprobarRecinasis

					SELECT  
					@ErrorNumber = ERROR_NUMBER()
					,@ErrorSeverity = ERROR_SEVERITY()
					,@ErrorState = ERROR_STATE()
					,@ErrorProcedure = ERROR_PROCEDURE() 
					,@ErrorLine = ERROR_LINE()
					,@ErrorMessage = ERROR_MESSAGE();

					SELECT @ErrorNumber AS ErrorNumber,@ErrorSeverity AS ErrorSeverity,@ErrorState AS ErrorState,@ErrorProcedure AS ErrorProcedure,@ErrorLine AS ErrorLine,@ErrorMessage AS ErrorMessage

					EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS',@ErrorProcedure, null,@ErrorNumber, @ErrorSeverity,@ErrorState ,@IdTramite,@IdTramiteSolicitud,@ErrorMessage,'Catch',@ErrorLine

				END CATCH

				SET @i = @i+1

			END
	END
	END TRY
	BEGIN CATCH
		SELECT  
		@ErrorNumber = ERROR_NUMBER()
		,@ErrorSeverity = ERROR_SEVERITY()
		,@ErrorState = ERROR_STATE()
		,@ErrorProcedure = ERROR_PROCEDURE() 
		,@ErrorLine = ERROR_LINE()
		,@ErrorMessage = ERROR_MESSAGE();

		SELECT @ErrorNumber AS ErrorNumber,@ErrorSeverity AS ErrorSeverity,@ErrorState AS ErrorState,@ErrorProcedure AS ErrorProcedure,@ErrorLine AS ErrorLine,@ErrorMessage AS ErrorMessage

		EXEC [EVA_Log_Registrar] 'TRAMITE - RECINASIS', 'JOB RECINASIS',@ErrorProcedure, null,@ErrorNumber, @ErrorSeverity,@ErrorState ,@IdTramite,@IdTramiteSolicitud,@ErrorMessage,'Catch',@ErrorLine
    END CATCH
	
END
