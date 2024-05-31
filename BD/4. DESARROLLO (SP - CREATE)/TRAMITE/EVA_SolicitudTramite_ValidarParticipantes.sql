IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SolicitudTramite_ValidarParticipantes') DROP PROCEDURE EVA_SolicitudTramite_ValidarParticipantes
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Valida el rol para iniciar el flujo de interacción
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
EXEC EVA_SolicitudTramite_ValidarParticipantes 1, 1502295, 355555, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [dbo].[EVA_SolicitudTramite_ValidarParticipantes]
@IdTramiteSolicitud INT,
@IdActor			INT,
@IdUsuario			INT,
@RetVal				INT OUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IdActorSolicitante		INT
	DECLARE @IdTipoUsuario			INT

	SELECT 
	@IdActorSolicitante = STS.IdActorSolicitante,
	@IdTipoUsuario = U.IdTipoUsuario
	FROM EVA_SAE_TramiteSolicitud STS WITH(NOLOCK) 
	LEFT JOIN Usuario U WITH(NOLOCK) ON U.IdActor = STS.IdActorSolicitante
	WHERE 
	STS.IdTramiteSolicitud = @IdTramiteSolicitud
	AND U.IdUsuario = @IdUsuario

	IF(@IdActorSolicitante = @IdActor)
	BEGIN
		IF (@IdTipoUsuario IN (1,2))
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
		SET @RetVal = -101
	END

END

