IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEventoEstado_Agregar') DROP PROCEDURE EVA_SaeTramiteEventoEstado_Agregar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (01.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Agrega la configuración de estados que tiene un trámite
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
EXEC EVA_SaeTramiteEventoEstado_Agregar 1, 1, 1, 2, NULL, NULL, NULL, NULL, 'INI', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteEventoEstado_Agregar
@IdTramite				INT,
@IdEstado				INT,
@FlujoNormal			INT,
@FlujoComplementario	INT,
@FlujoNegativo			INT,
@CorreoSolicitante		VARCHAR(100),
@CorreoEncargado		VARCHAR(100),
@EstadoSolicitud		CHAR(3),
@IdUsuario				INT,
@RetVal					INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Orden INT
	
	SELECT
	@Orden = COUNT(*) + 1
	FROM EVA_SAE_TramiteEventoEstado TEE
	WHERE TEE.IdTramite = @IdTramite

	INSERT EVA_SAE_TramiteEventoEstado
	(IdTramite, IdEstado, Orden, FlujoNormal, FlujoComplementario, FlujoNegativo, CorreoSolicitante, CorreoEncargado, EstadoSolicitud, FechaCreacion, UsuarioCreacion)
    VALUES
	(@IdTramite, @IdEstado, @Orden, @FlujoNormal, @FlujoComplementario, @FlujoNegativo, @CorreoSolicitante, @CorreoEncargado, @EstadoSolicitud, GETDATE(), @IdUsuario)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, @Orden)
END