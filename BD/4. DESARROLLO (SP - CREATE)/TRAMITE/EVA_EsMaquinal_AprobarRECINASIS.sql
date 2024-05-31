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
EXEC EVA_EsMaquinalRECINASIS_Aprobar 642, 'NEG',0
*/

CREATE PROCEDURE EVA_EsMaquinalRECINASIS_Aprobar
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY

	DECLARE @SolitudesRespuestaMaquinal Table (Nro INT, IdTramiteSolicitud INT)
	DECLARE @i int = 1, @IdTramiteSolicitud int, @TotalSolicitud INT

	INSERT INTO @SolitudesRespuestaMaquinal
	SELECT ROW_NUMBER() OVER(ORDER BY TS.IdTramiteSolicitud),TS.IdTramiteSolicitud 
	FROM EVA_SAE_TramiteSolicitud TS
	INNER JOIN EVA_SAE_Tramite T ON TS.IdTramite=T.IdTramite
	WHERE EsRespuestaMaquinal=1 
	AND EstadoSolicitud='PGA' AND T.CodigoPublico='RECINASIS' AND EsAnulado=0
	AND DATEDIFF(HOUR, TS.FechaPGA,GETDATE())>1

	SELECT @TotalSolicitud = MAX(Nro) FROM @SolitudesRespuestaMaquinal
	

	IF (@TotalSolicitud>0) BEGIN

		WHILE (@i<=@TotalSolicitud) BEGIN
			BEGIN TRY
			BEGIN TRANSACTION

			SELECT @IdTramiteSolicitud=IdTramiteSolicitud FROM @SolitudesRespuestaMaquinal WHERE Nro=@i

			--1) Registrar la Respuesta
			--EXEC [EVA_SaeTramiteSolicitudRespuesta_Registrar] @IdTramiteSolicitud,1,1,'ENC','Se rectificó la inasistencia.',0, '','APR'
	
			INSERT INTO EVA_SAE_TramiteSolicitudRespuesta
			(IdTramiteSolicitud,IdActor,TipoParticipante,Mensaje,Estado,UsuarioCreacion,FechaCreacion)
			VALUES
			(@IdTramiteSolicitud,1,'ENC','Se rectificó la inasistencia.','APR',1,GETDATE())

			IF (@@ROWCOUNT>0) BEGIN

				UPDATE EVA_SAE_TramiteSolicitud SET UltimoEstadoRespuesta = 'APR'
				WHERE IdTramiteSolicitud = @IdTramiteSolicitud

				IF (@@ROWCOUNT>0) BEGIN
					-- 2) Aprobación del Tramite
					DECLARE @X INT
					EXEC EVA_SaeDetalleTramiteRECINASIS_Aprobar @IdTramiteSolicitud, @X OUT

					IF(@X = -1) BEGIN

						-- 3) Actualizar Scope
						DECLARE @Actualizar Table (RetVal INT)
						INSERT INTO @Actualizar
						EXEC EVA_SaeTramiteSolicitud_ActualizarEstado @IdTramiteSolicitud, 'NOR',0

						IF(SELECT RetVal FROM @Actualizar) = -1 BEGIN
							COMMIT TRANSACTION
						END
						ELSE BEGIN
							ROLLBACK TRANSACTION
						END
						
					END
					ELSE BEGIN
						ROLLBACK TRANSACTION
					END
				END
			END
			ELSE BEGIN
				ROLLBACK TRANSACTION
			END

			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION

				SELECT  
				ERROR_NUMBER() AS ErrorNumber
				,ERROR_SEVERITY() AS ErrorSeverity
				,ERROR_STATE() AS ErrorState 
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine
				,ERROR_MESSAGE() AS ErrorMessage;
			END CATCH
			
			SET @i = @i+1
		END

	END
	END TRY
	BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
	
END
