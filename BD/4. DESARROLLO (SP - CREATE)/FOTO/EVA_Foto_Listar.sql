IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_Foto_Listar') DROP PROCEDURE EVA_Foto_Listar
GO
-------------------------------------------------------------------------------  
--Creado por      : Almendra Laureano (23/05/2022)
--Revisado por    : 
--Funcionalidad   : Lista los campos contenidos en la Tabla EVA_Foto
--Utilizado por   : EVA
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/

/* 
Ejemplo:

EXEC [EVA_Foto_Listar] 1,5
*/
CREATE PROCEDURE EVA_Foto_Listar(
@Pagina			INT = 1,
@TamanoPagina	INT = 5
)
AS
	SET NOCOUNT ON;
	
	SELECT
	IdFoto,
	NombreFoto+ExtensionFoto AS 'NombreFoto',
	Descripcion
	FROM EVA_Foto WITH(NOLOCK)
	WHERE  EsActivo=1
	ORDER BY IdFoto
	OFFSET(@Pagina - 1) * @TamanoPagina ROWS
	FETCH NEXT @TamanoPagina ROWS ONLY;

	SELECT COUNT(1) AS Docs FROM EVA_Foto WHERE EsActivo=1

GO

--Obervaciones:
	-- Reemplazar el Count