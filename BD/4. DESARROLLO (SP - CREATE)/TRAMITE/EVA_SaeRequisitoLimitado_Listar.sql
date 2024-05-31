IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeRequisitoLimitado_Listar')
  DROP PROCEDURE EVA_SaeRequisitoLimitado_Listar
GO
--------------------------------------------------------------------------------
--Creado por  	: ALAUREANO (01/07/2022)
--Revisado por		: 
--Funcionalidad		: Lista los tramites que tienen requisitos limitados (no pueden ser usados por todos los tramites)
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeRequisitoLimitado_Listar
*/

CREATE PROCEDURE [EVA_SaeRequisitoLimitado_Listar] @Busqueda varchar(255) = '',
@Pagina int = 1,
@TamanoPagina int = 10

AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    IdTramite,
    IdRequisito,
    EsActivo
  FROM EVA_SAE_RequisitoLimitado WITH (NOLOCK)
  ORDER BY IdTramite ASC
  OFFSET (@Pagina - 1) * @TamanoPagina ROWS
  FETCH NEXT @TamanoPagina ROWS ONLY

  SELECT
    COUNT(*) AS Docs
  FROM EVA_SAE_RequisitoLimitado WITH (NOLOCK)
END