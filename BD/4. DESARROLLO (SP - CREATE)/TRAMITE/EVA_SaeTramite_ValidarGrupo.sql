IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_ValidarGrupo') DROP PROCEDURE EVA_SaeTramite_ValidarGrupo
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (06.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Valida si un trámite tiene sub grupos
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
EXEC EVA_SaeTramite_ValidarGrupo 24, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [EVA_SaeTramite_ValidarGrupo]
	@IdTramiteGrupo	INT,
	@RetVal INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT IdTramite FROM EVA_SAE_Tramite WITH(NOLOCK) WHERE IdTramite = @IdTramiteGrupo AND EsGrupo = 1)
	BEGIN 
		SET @RetVal = -1 RETURN
	END
	ELSE
	BEGIN
		SET @RetVal = -51 RETURN
	END
END