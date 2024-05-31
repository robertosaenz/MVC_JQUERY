IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_TramiteEncargado_Listar') DROP PROCEDURE EVA_TramiteEncargado_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (26.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista todos los encargados asociados a un trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_TramiteEncargado_Listar 17, 'torres angie',1,10
*/

CREATE PROCEDURE [dbo].[EVA_TramiteEncargado_Listar]
@IdTramite			INT,
@Busqueda			VARCHAR(255) = '',
@Pagina				INT = 1,
@TamanoPagina		INT = 5,
@EntornoDePrueba	BIT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Ruta VARCHAR(100)
	SELECT @Ruta = P.Valor2 + IIF(@EntornoDePrueba = 1, 'test/', '')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre = 'RutaEva'

	SELECT 
	@IdTramite AS IdTramite, 
	CASE WHEN AF.NombreArchivo IS NULL THEN '' ELSE @Ruta + 'actor/' + AF.NombreArchivo END AS NombreArchivo,
	U.Login,
	U.IdActor,
	CONCAT(dbo.InitCap(ISNULL(U.ApellidoPaterno, '')), ' ', dbo.InitCap(ISNULL(U.ApellidoMaterno, '')), ' ' , dbo.InitCap(ISNULL(U.Nombres, ''))) AS Nombre
	FROM Usuario U WITH(NOLOCK)
	LEFT JOIN ActorFoto AF WITH(NOLOCK) ON AF.IdActor = U.IdActor
	LEFT JOIN EVA_SAE_TramiteEncargado TE WITH(NOLOCK) ON TE.IdActor = U.IdActor AND TE.IdTramite = @IdTramite
	WHERE TE.IdActor IS NULL AND 
	U.Nombre LIKE '%' + Replace(@Busqueda,' ','%') + '%' AND
	U.IdTipoUsuario = 3
	ORDER BY U.Nombre ASC
	OFFSET (@Pagina - 1) * @TamanoPagina ROWS
	FETCH NEXT @TamanoPagina ROWS ONLY
	
	SELECT
	COUNT(*) AS Docs
	FROM Usuario U WITH(NOLOCK)
	LEFT JOIN EVA_SAE_TramiteEncargado TE WITH(NOLOCK) ON TE.IdActor = U.IdActor AND TE.IdTramite = @IdTramite
	WHERE TE.IdActor IS NULL AND 
	U.Nombre LIKE '%' + @Busqueda + '%' AND
	U.IdTipoUsuario = 3
END




