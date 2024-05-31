IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeRequisito_ListarTodos')
  DROP PROCEDURE EVA_SaeRequisito_ListarTodos
GO
--------------------------------------------------------------------------------
--Creado por		: ALAUREANO (01/07/2022)
--Revisado por		: 
--Funcionalidad		: Lista todos los requisitos existentes para los tramites
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeRequisito_ListarTodos
*/

CREATE PROCEDURE [EVA_SaeRequisito_ListarTodos] @Busqueda varchar(255) = '',
@Pagina int = 1,
@TamanoPagina int = 10
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    IdRequisito,
    CodigoInterno,
    Nombre,
    Periodo,
    ValorPeriodo,
    EsLimitado
  FROM EVA_SAE_Requisito WITH (NOLOCK)
  WHERE Nombre LIKE '%' + @Busqueda + '%'
  ORDER BY Nombre ASC
  OFFSET (@Pagina - 1) * @TamanoPagina ROWS
  FETCH NEXT @TamanoPagina ROWS ONLY

  SELECT
    COUNT(*) AS Docs
  FROM EVA_SAE_Requisito WITH (NOLOCK)
  WHERE Nombre LIKE '%' + @Busqueda + '%'

END