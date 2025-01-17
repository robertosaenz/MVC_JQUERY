IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitud_Listar') DROP PROCEDURE EVA_SaeTramiteSolicitud_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : SCAYCHO
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Retorna todas las solicitudes de trámite
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
exec EVA_SaeTramiteSolicitud_Listar 1034150, 1, ''

*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitud_Listar]
@IdUsuario		INT,
@EsFinalizado	BIGINT,
@Busqueda		VARCHAR(255) = '',
@Pagina			INT = 1,
@TamanoPagina	INT = 5
AS
BEGIN
	SET NOCOUNT ON;
	IF (@EsFinalizado = 0)
		BEGIN
			SELECT
				TS.IdTramiteSolicitud,
				TS.IdTramite,
				[dbo].[toMiliseconds](TS.FechaCreacion) AS 'FechaCreacion',
				TS.IdEstado,
				TS.IdEstadoUsuario,
				ISNULL([dbo].[toMiliseconds](TS.FechaActualizacion),
				NULL) AS 'FechaActualizacion',
				T.Nombre,
				TE.NombreEstado,
				TEU.NombreEstado AS 'NombreEstadoUsuario',
				TS.UltimoEstadoRespuesta
			FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
			INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK)
			ON TS.IdTramite = T.IdTramite
			INNER JOIN EVA_SAE_TramiteEstados TE WITH(NOLOCK)
			ON TS.IdEstado = TE.IdEstado
			INNER JOIN EVA_SAE_TramiteEstados TEU WITH(NOLOCK)
			ON TS.IdEstadoUsuario = TEU.IdEstado
			LEFT JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK)
			ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
			WHERE
				TS.IdActorSolicitante = @IdUsuario
				AND TE.NombreEstado NOT IN ('Resuelto', 'Rechazado')
				AND (TS.IdTramiteSolicitud LIKE '%' + @Busqueda + '%' OR T.Nombre LIKE '%' + @Busqueda + '%')
				AND TS.EsAnulado = 0
				AND (TSS.EsPagado = 1 OR TSS.EsPagado IS NULL)
			ORDER BY TS.FechaCreacion DESC
			OFFSET (@Pagina - 1) * @TamanoPagina ROWS
			FETCH NEXT @TamanoPagina ROWS ONLY

			SELECT COUNT(*) AS Docs
			FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
			INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK)
			ON TS.IdTramite = T.IdTramite
			INNER JOIN EVA_SAE_TramiteEstados TE WITH(NOLOCK)
			ON TS.IdEstado = TE.IdEstado
			INNER JOIN EVA_SAE_TramiteEstados TEU WITH(NOLOCK)
			ON TS.IdEstadoUsuario = TEU.IdEstado
			LEFT JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK)
			ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
			WHERE
				TS.IdActorSolicitante = @IdUsuario
				AND TE.NombreEstado NOT IN ('Resuelto', 'Rechazado')
				AND (TS.IdTramiteSolicitud LIKE '%' + @Busqueda + '%' OR T.Nombre LIKE '%' + @Busqueda + '%')
				AND TS.EsAnulado = 0
				AND (TSS.EsPagado = 1 OR TSS.EsPagado IS NULL)
		END
	ELSE
		BEGIN
			SELECT
				TS.IdTramiteSolicitud,
				TS.IdTramite,
				[dbo].[toMiliseconds](TS.FechaCreacion) AS FechaCreacion,
				TS.IdEstado,
				TS.IdEstadoUsuario,
				ISNULL([dbo].[toMiliseconds](TS.FechaActualizacion),
				NULL) AS 'FechaActualizacion',
				T.Nombre,
				TE.NombreEstado,
				IIF(TEU.NombreEstado='Resuelto', 'Aprobado',TEU.NombreEstado) AS 'NombreEstadoUsuario',
				TS.UltimoEstadoRespuesta
			FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
			INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK)
			ON TS.IdTramite = T.IdTramite
			INNER JOIN EVA_SAE_TramiteEstados TE WITH(NOLOCK)
			ON TS.IdEstado = TE.IdEstado
			INNER JOIN EVA_SAE_TramiteEstados TEU WITH(NOLOCK)
			ON TS.IdEstadoUsuario = TEU.IdEstado
			WHERE
				TS.IdActorSolicitante = @IdUsuario
				AND TE.NombreEstado IN ('Resuelto', 'Rechazado')
				AND (TS.IdTramiteSolicitud LIKE '%' + @Busqueda + '%' OR T.Nombre LIKE '%' + @Busqueda + '%')
				AND TS.EsAnulado = 0
			ORDER BY TS.FechaCreacion DESC
			OFFSET (@Pagina - 1) * @TamanoPagina ROWS
			FETCH NEXT @TamanoPagina ROWS ONLY

			SELECT COUNT(*) AS Docs
			FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
			INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK)
			ON TS.IdTramite = T.IdTramite
			INNER JOIN EVA_SAE_TramiteEstados TE WITH(NOLOCK)
			ON TS.IdEstado = TE.IdEstado
			INNER JOIN EVA_SAE_TramiteEstados TEU WITH(NOLOCK)
			ON TS.IdEstadoUsuario = TEU.IdEstado
			WHERE
				TS.IdActorSolicitante = @IdUsuario
				AND TE.NombreEstado IN ('Resuelto', 'Rechazado')
				AND (TS.IdTramiteSolicitud LIKE '%' + @Busqueda + '%' OR T.Nombre LIKE '%' + @Busqueda + '%')
				AND TS.EsAnulado = 0
		END
END
