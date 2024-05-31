IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEventoEstado_Editar') DROP PROCEDURE EVA_SaeTramiteEventoEstado_Editar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (01.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Edita la configuración de estados que tiene un trámite
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
EXEC EVA_SaeTramiteEventoEstado_Editar 1, 1, 1, 2, NULL, NULL, NULL, NULL, 'INI', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteEventoEstado_Editar
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
	
	UPDATE EVA_SAE_TramiteEventoEstado
	SET
	FlujoNormal = @FlujoNormal,
	FlujoComplementario = @FlujoComplementario,
	FlujoNegativo = @FlujoNegativo,
	CorreoSolicitante = @CorreoSolicitante,
	CorreoEncargado = @CorreoEncargado,
	EstadoSolicitud = @EstadoSolicitud,
	FechaModificacion = GETDATE(),
	UsuarioModificacion = @IdUsuario
	WHERE
	IdTramite = @IdTramite
	AND IdEstado = @IdEstado

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END