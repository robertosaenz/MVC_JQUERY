IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEncargado_Listar') DROP PROCEDURE EVA_SaeTramiteEncargado_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (13.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista los encargados del trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_SaeTramiteEncargado_Listar 12, '', 1, 5
*/

CREATE PROCEDURE EVA_SaeTramiteEncargado_Listar
@IdTramite		INT,
@Busqueda		VARCHAR(255) = '',
@Pagina			INT = 1,
@TamanoPagina	INT = 5
AS
BEGIN
	SET NOCOUNT ON

	SELECT
	TE.IdActor,
	U.Nombres,
	CONCAT(U.ApellidoPaterno, ' ', U.ApellidoMaterno) AS Apellidos
	FROM EVA_SAE_TramiteEncargado TE WITH (NOLOCK)
	INNER JOIN Usuario U WITH (NOLOCK)
	ON TE.IdActor = U.IdActor AND U.IdTipoUsuario = 3
	WHERE
	TE.IdTramite = @IdTramite
	AND TE.EsActivo = 1
	AND U.Nombres LIKE '%' + @Busqueda + '%'
	ORDER BY U.Nombres ASC
	OFFSET (@Pagina - 1) * @TamanoPagina ROWS
	FETCH NEXT @TamanoPagina ROWS ONLY

	SELECT COUNT(*) AS Docs
	FROM EVA_SAE_TramiteEncargado TE WITH (NOLOCK)
	INNER JOIN Usuario U WITH (NOLOCK)
	ON TE.IdActor = U.IdActor AND U.IdTipoUsuario = 3
	WHERE
	TE.IdTramite = @IdTramite
	AND TE.EsActivo = 1
	AND U.Nombres LIKE '%' + @Busqueda + '%'
END