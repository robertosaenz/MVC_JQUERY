IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteConfiguracion_Listar') DROP PROCEDURE EVA_SaeTramiteConfiguracion_Listar
GO 
--------------------------------------------------------------------------------          
--Creado por      : Rsaenz (24/11/2021)    
--Revisado por    : Rsaenz (29/04/2022)    
--Funcionalidad   : Lista todos los tramites con paginación    
--Utilizado por   : EVA    
-------------------------------------------------------------------------------       
/*      
-----------------------------------------------------------------------------    
Nro  FECHA   USUARIO     DESCRIPCION    
-----------------------------------------------------------------------------    
*/  

/*      
Ejemplo:    
DECLARE @TotalDocumentos int    
 EXEC [EVA_SaeTramiteConfiguracion_Listar] '',1,10, @TotalDocumentos OUT    
SELECT @TotalDocumentos    
*/  
CREATE PROCEDURE [EVA_SaeTramiteConfiguracion_Listar]  
  @Busqueda varchar(255) = '',  
  @Pagina int,  
  @TamanoPagina int,  
  @TotalDocumentos int OUT  
AS  
BEGIN  
	SET NOCOUNT ON;

	SELECT  
	T.IdTramite,
	T.CodigoPublico,
	T.NombreInterno,
	dbo.toMiliseconds(T.FechaCreacion) AS FechaCreacion ,
	dbo.toMiliseconds(T.FechaModificacion) AS FechaModificacion,
	TC.Nombre as NombreCategoria,
	T.EsActivo
	FROM [EVA_SAE_Tramite] T WITH (NOLOCK)  
	INNER JOIN [EVA_SAE_TramiteCategoria] TC WITH (NOLOCK) ON T.IdCategoria = TC.IdCategoria
	WHERE T.Nombre LIKE '%' + @Busqueda + '%' OR T.CodigoPublico LIKE '%' + @Busqueda + '%'
	ORDER BY T.Nombre ASC  
	OFFSET (@Pagina - 1) * @TamanoPagina ROWS  
	FETCH NEXT @TamanoPagina ROWS ONLY  
  
	SET @TotalDocumentos =  
	(
		SELECT  
		COUNT(*) AS TotalDocumentos  
		FROM [EVA_SAE_Tramite] T WITH (NOLOCK)  
		WHERE T.Nombre LIKE '%' + @Busqueda + '%' OR T.CodigoPublico LIKE '%' + @Busqueda + '%'
	) 
END