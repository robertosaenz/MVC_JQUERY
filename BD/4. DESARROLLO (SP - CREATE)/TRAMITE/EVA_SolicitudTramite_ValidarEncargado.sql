IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SolicitudTramite_ValidarEncargado') DROP PROCEDURE EVA_SolicitudTramite_ValidarEncargado
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Valida si el usuario tiene el perfil de encargado
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
EXEC EVA_SolicitudTramite_ValidarEncargado 1, 1502295, 355555, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [dbo].[EVA_SolicitudTramite_ValidarEncargado]
@IdTramiteSolicitud INT,
@IdActor			INT,
@IdUsuario			INT,
@RetVal				INT OUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IdActorEncargado		INT
	DECLARE @IdTipoUsuario			INT

	SELECT 
	@IdActorEncargado = STS.IdActorEncargado,
	@IdTipoUsuario = U.IdTipoUsuario
	FROM EVA_SAE_TramiteSolicitud STS WITH(NOLOCK) 
	LEFT JOIN Usuario U WITH(NOLOCK) ON U.IdActor = STS.IdActorEncargado
	WHERE 
	STS.IdTramiteSolicitud = @IdTramiteSolicitud
	AND U.IdUsuario = @IdUsuario

	IF(@IdActorEncargado = @IdActor)
	BEGIN
		IF(@IdTipoUsuario IN (2,3))
		BEGIN
			SET @RetVal = -1 RETURN;
		END
		ELSE
		BEGIN
			SET @RetVal = -102 RETURN;
		END
	END
	ELSE
	BEGIN
		SET @RetVal = -101 RETURN;
	END

END

