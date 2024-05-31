IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_ActualizarEstado') DROP PROCEDURE EVA_SaeTramiteSolicitud_ActualizarEstado
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (11.03.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Actualiza el estado de la solicitud al siguiente, según lo configurado en el trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramiteSolicitud_ActualizarEstado 642, 'NOR',0
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitud_ActualizarEstado
@IdTramiteSolicitud		INT,
@TipoFlujo				CHAR(3),
@Job					BIT =0,
@EsRespuestaMaquinal	BIT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @IdTramite INT, @IdEstado INT, @EsVisible VARCHAR(10), @Flujo INT, @CorreoSolicitante VARCHAR(100), @CorreoEncargado VARCHAR(100), @EstadoSolicitud CHAR(3)

	SELECT @IdTramite = IdTramite, @IdEstado = IdEstado FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK) WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud AND TS.EsAnulado = 0

	IF (@IdTramite IS NULL)
		BEGIN
			SELECT -4201 AS 'RetVal'
			RETURN
		END

	IF (@IdEstado IS NULL)
		BEGIN
			SELECT TOP 1 @IdEstado = TEE.IdEstado, @EsVisible = TE.EsVisible, @CorreoSolicitante = TEE.CorreoSolicitante, @CorreoEncargado = TEE.CorreoEncargado, @EstadoSolicitud = TEE.EstadoSolicitud
			FROM EVA_SAE_TramiteEventoEstado TEE WITH (NOLOCK)
			INNER JOIN EVA_SAE_TramiteEstados TE WITH (NOLOCK)
			ON TEE.IdEstado = TE.IdEstado
			WHERE TEE.IdTramite = @IdTramite
			ORDER BY TEE.Orden ASC

			IF (@IdEstado IS NULL)
				BEGIN
					SELECT -4101 AS 'RetVal'
					RETURN
				END

			IF (@EsVisible <> 'Interno')
				BEGIN
					IF (@EstadoSolicitud IS NULL)
						BEGIN
							UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @IdEstado, IdEstadoUsuario = @IdEstado WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
						END
					ELSE
						BEGIN
							UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @IdEstado, IdEstadoUsuario = @IdEstado, EstadoSolicitud = @EstadoSolicitud WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
						END
				END
			ELSE
				BEGIN
					IF (@EstadoSolicitud IS NULL)
						BEGIN
							UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @IdEstado WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
						END
					ELSE
						BEGIN
							UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @IdEstado, EstadoSolicitud = @EstadoSolicitud WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
						END
				END

			IF (@@ROWCOUNT = 0)
				BEGIN
					SELECT -4051 AS 'RetVal'
					RETURN
				END

			INSERT INTO EVA_SAE_TramiteSolicitudHistorialEstados (IdTramiteSolicitud, IdEstado, FechaCreacion) VALUES (@IdTramiteSolicitud, @IdEstado, GETDATE())

			IF (@@ROWCOUNT = 0)
				BEGIN
					SELECT -4050 AS 'RetVal'
					RETURN
				END

			IF(@Job =1)
			BEGIN
				SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
				FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
				WHERE PC.Codigo = @CorreoSolicitante
			END
			ELSE
			BEGIN
				SELECT -1 AS 'RetVal'

				IF (@EsRespuestaMaquinal=0) BEGIN

					SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
					FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
					WHERE PC.Codigo = @CorreoSolicitante

					SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
					FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
					WHERE PC.Codigo = @CorreoEncargado
				END
			END
	END
	ELSE
		BEGIN
			SELECT TOP 1 @EsVisible = TE.EsVisible, @Flujo = (CASE WHEN @TipoFlujo = 'NOR' THEN TEE.FlujoNormal WHEN @TipoFlujo = 'COM' THEN TEE.FlujoComplementario ELSE TEE.FlujoNegativo END)
			FROM EVA_SAE_TramiteEventoEstado TEE WITH (NOLOCK)
			INNER JOIN EVA_SAE_TramiteEstados TE WITH (NOLOCK)
			ON (CASE WHEN @TipoFlujo = 'NOR' THEN TEE.FlujoNormal WHEN @TipoFlujo = 'COM' THEN TEE.FlujoComplementario ELSE TEE.FlujoNegativo END) = TE.IdEstado
			WHERE TEE.IdTramite = @IdTramite AND TEE.IdEstado = @IdEstado

			IF (@Flujo IS NULL)
				BEGIN
					SELECT -4070 AS 'RetVal'
					RETURN
				END
			ELSE
				BEGIN
					SELECT @CorreoSolicitante = TEE.CorreoSolicitante, @CorreoEncargado = TEE.CorreoEncargado, @EstadoSolicitud = TEE.EstadoSolicitud
					FROM EVA_SAE_TramiteEventoEstado TEE WITH (NOLOCK)
					WHERE TEE.IdTramite = @IdTramite AND TEE.IdEstado = @Flujo

					IF (@EsVisible <> 'Interno')
						BEGIN
							IF (@EstadoSolicitud IS NULL)
								BEGIN
									UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @Flujo, IdEstadoUsuario = @Flujo WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
								END
							ELSE
								BEGIN
									UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @Flujo, IdEstadoUsuario = @Flujo, EstadoSolicitud = @EstadoSolicitud WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
								END
						END
					ELSE
						BEGIN
							IF (@EstadoSolicitud IS NULL)
								BEGIN
									UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @Flujo WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
								END
							ELSE
								BEGIN
									UPDATE EVA_SAE_TramiteSolicitud SET IdEstado = @Flujo, EstadoSolicitud = @EstadoSolicitud WHERE IdTramiteSolicitud = @IdTramiteSolicitud AND EsAnulado = 0
								END
						END

					IF (@@ROWCOUNT = 0)
						BEGIN
							SELECT -4051 AS 'RetVal'
							RETURN
						END

					INSERT INTO EVA_SAE_TramiteSolicitudHistorialEstados (IdTramiteSolicitud, IdEstado, FechaCreacion) VALUES (@IdTramiteSolicitud, @Flujo, GETDATE())

					IF (@@ROWCOUNT = 0)
						BEGIN
							SELECT -4050 AS 'RetVal'
							RETURN
						END
					
					IF(@Job =1)
					BEGIN
						SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
						FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
						WHERE PC.Codigo = @CorreoSolicitante
					END
					ELSE
					BEGIN
						SELECT -1 AS 'RetVal'

						IF (@EsRespuestaMaquinal=0) BEGIN

							SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
							FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
							WHERE PC.Codigo = @CorreoSolicitante

							SELECT PC.IdPlantilla, PC.CodigoRemitente, PC.Codigo, PC.AsuntoMensaje, PC.CuerpoMensaje
							FROM EVA_PlantillasCorreos PC WITH (NOLOCK)
							WHERE PC.Codigo = @CorreoEncargado
						END
					END
					
				END
		END
END



