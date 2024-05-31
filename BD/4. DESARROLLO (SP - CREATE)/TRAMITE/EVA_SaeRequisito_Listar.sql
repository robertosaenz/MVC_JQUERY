IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisito_Listar') DROP PROCEDURE EVA_SaeRequisito_Listar
GO 
--------------------------------------------------------------------------------          
--Creado por      : Rsaenz (24/11/2021)    
--Revisado por    : Rsaenz (29/04/2022)    
--Funcionalidad   : Lista requisitos con paginación    
--Utilizado por   : EVA    
-------------------------------------------------------------------------------       
/*      
-----------------------------------------------------------------------------    
Nro  FECHA   USUARIO     DESCRIPCION    
-----------------------------------------------------------------------------    
*/  

/*      
Ejemplo:    
EXEC [EVA_SaeRequisito_Listar] 1,'deuda',1,10
*/  
CREATE PROCEDURE EVA_SaeRequisito_Listar
@IdTramite		INT,
@Busqueda		VARCHAR(255) = '',
@Pagina			INT = 1,
@TamanoPagina	INT = 5
AS
BEGIN
	SET NOCOUNT ON

	SELECT
	IdRequisito,
	Nombre
	FROM EVA_SAE_Requisito WITH (NOLOCK)
	WHERE
	Nombre LIKE '%' + @Busqueda + '%'
	ORDER BY Nombre ASC
	OFFSET (@Pagina - 1) * @TamanoPagina ROWS
	FETCH NEXT @TamanoPagina ROWS ONLY

	SELECT
	COUNT(*) AS Docs
	FROM EVA_SAE_Requisito WITH (NOLOCK)
	WHERE
	Nombre LIKE '%' + @Busqueda + '%'
END