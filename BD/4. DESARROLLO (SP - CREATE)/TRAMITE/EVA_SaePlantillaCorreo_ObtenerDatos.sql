IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaePlantillaCorreo_ObtenerDatos') DROP PROCEDURE EVA_SaePlantillaCorreo_ObtenerDatos
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (31.03.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Retorna información necesaria del actor y organización para envio de correo
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaePlantillaCorreo_ObtenerDatos 29, 'CONCERANU', 1
*/

CREATE PROCEDURE EVA_SaePlantillaCorreo_ObtenerDatos
@IdTramiteSolicitud INT,
@CodigoPlantillaCorreo CHAR(9),
@EsSolicitante BIT
AS
BEGIN
	DECLARE @Nombre VARCHAR(150), @NombreTramite VARCHAR(100), @Codigo INT, @HoraVencimiento INT, @Correos VARCHAR(MAX)
	DECLARE @IdTramite INT, @IdActor INT, @IdSolicitante INT

	SELECT @Codigo = TS.IdTramiteSolicitud, @IdTramite = TS.IdTramite, @IdActor = IIF(@EsSolicitante = 1, TS.IdActorSolicitante, TS.IdActorEncargado)
	FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud

	IF (@CodigoPlantillaCorreo = 'CONCERPRO' OR @CodigoPlantillaCorreo = 'CONCEROBS' OR @CodigoPlantillaCorreo = 'CONCERFIN' OR @CodigoPlantillaCorreo = 'CONCERANU')
		BEGIN
			SELECT @NombreTramite = T.Nombre, @HoraVencimiento = T.HoraVencimiento, @IdSolicitante = T.IdSolicitante
			FROM EVA_SAE_Tramite T WITH (NOLOCK)
			WHERE T.IdTramite = @IdTramite

			SELECT @Nombre = U.Nombres, @Correos = LOWER(U.EMail) + ';'
			FROM Usuario U WITH (NOLOCK)
			WHERE
			U.IdActor = @IdActor
			AND U.IdTipoUsuario = @IdSolicitante
		END

	SELECT @Correos += STRING_AGG(LOWER(AE.Descripcion), ';')
	FROM ActorEmail AE WITH (NOLOCK)
	WHERE AE.IdActor = @IdActor
	GROUP BY AE.IdActor

	SELECT @Nombre AS Nombre, @NombreTramite AS NombreTramite, @Codigo AS Codigo, @HoraVencimiento AS HoraVencimiento, @Correos AS Correos
END