IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_Registrar') DROP PROCEDURE EVA_SaeTramiteSolicitud_Registrar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (29.11.21)
--Revisado por		: SCAYCHO
--Funcionalidad		: Registra solicitudes de trámite, también adjunta archivos
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeTramiteSolicitud_Registrar 1, 1294897, 167886, '', 343040,0, 0,@Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitud_Registrar]
@IdTramite				INT,
@IdActorSolicitante		INT,
@IdUsuario				INT,
@IdsArchivos			VARCHAR(MAX),
@IdMatricula			INT,
@ItemCodigo				CHAR(20),
@CantidadOriginal		INT,
@CompaniaSocio			CHAR(8),
@IdCaso					INT,
@EsAutomatico			BIT,
@EsRespuestaMaquinal	BIT,
@RetVal					INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @EsActivo				INT
	DECLARE @TramiteTipoSolicitante	INT
	DECLARE @TipoSolicitante		INT
	DECLARE @TieneCosto				BIT

	SELECT @EsActivo = T.EsActivo, @TramiteTipoSolicitante = T.IdSolicitante, @TieneCosto = T.TieneCosto
	FROM EVA_SAE_Tramite T WITH (NOLOCK)
	WHERE T.IdTramite = @IdTramite

	IF (@EsActivo IS NULL) --TRÁMITE NO EXISTE
		BEGIN
			SET @RetVal = -200
			RETURN
		END
	ELSE IF (@EsActivo = 0) --TRÁMITE INACTIVO
		BEGIN
			SET @RetVal = -201
			RETURN
		END

	--SELECT @TipoSolicitante = IdTipoUsuario FROM Usuario WHERE IdUsuario = @IdActorSolicitante

	--IF (@TipoSolicitante <> @TramiteTipoSolicitante) --TIPO DE SOLICITANTE DIFERENTE
	--	BEGIN
	--		SET @RetVal = -4000
	--		RETURN
	--	END
	--ELSE
		BEGIN
			DECLARE @IdTramiteSolicitud INT 
			DECLARE @IdProducto			INT
			DECLARE @IdPromocion		INT
			DECLARE @IdSede				INT

			SELECT
			@IdSede = THPD.IdSede,
			@IdProducto = THPD.IdProducto,
			@IdPromocion = THPD.IdPromocion
			FROM EVA_AlumnoHistorialProductosDetalle THPD WITH (NOLOCK)
			WHERE
			THPD.IdAlumno = @IdActorSolicitante
			AND THPD.IdUltimaMatricula = @IdMatricula

			--
			DECLARE @Sucursal CHAR(4), @MontoOriginal CHAR(10), @Monto CHAR(10)

			IF (@TieneCosto = 1)
				BEGIN
					SELECT
					@Sucursal = S.Sucursal
					FROM Sede S WITH (NOLOCK)
					WHERE S.IdSede=@IdSede

					IF (@IdSede = 4)
						BEGIN
							SELECT DISTINCT @MontoOriginal = CPA.Monto
							FROM CO_Precio_ASOC CPA WITH(NOLOCK)
							WHERE
							CPA.ItemCodigo = @ItemCodigo
							AND CPA.UnidadNegocio = @Sucursal
							AND CPA.CompaniaSocio = @CompaniaSocio
						END
					ELSE
						BEGIN
							SELECT DISTINCT @MontoOriginal = CP.Monto
							FROM CO_Precio CP WITH(NOLOCK)
							WHERE
							CP.ItemCodigo = @ItemCodigo
							AND CP.UnidadNegocio = @Sucursal
							AND CP.CompaniaSocio = @CompaniaSocio
						END

					SET @Monto = (CAST(@MontoOriginal AS DECIMAL) * @CantidadOriginal)
				END
			--

			INSERT INTO EVA_SAE_TramiteSolicitud
			(
				IdTramite, 
				IdActorSolicitante,
				IdMatricula,
				IdProducto,
				IdPromocion,
				TotalPagar,
				FechaCreacion, 
				UsuarioCreacion,
				IdCaso,
				IdSede,
				EsAutomatico,
				EsRespuestaMaquinal
			)
			VALUES
			(	@IdTramite, 
				@IdActorSolicitante,
				@IdMatricula,
				@IdProducto,
				@IdPromocion,
				@Monto,
				GETDATE(), 
				@IdUsuario,
				@IdCaso,
				@IdSede,
				@EsAutomatico,
				@EsRespuestaMaquinal
			)
			SET @IdTramiteSolicitud = SCOPE_IDENTITY()
			
			IF(@IdsArchivos <> '')
			BEGIN
				INSERT INTO EVA_SAE_TramiteSolicitudAdjunto
				(IdTramiteSolicitud,IdArchivo)
				SELECT @IdTramiteSolicitud,Items FROM dbo.udf_Split(@IdsArchivos,',')
			END

			SET @RetVal = @IdTramiteSolicitud

			RETURN
		END
END