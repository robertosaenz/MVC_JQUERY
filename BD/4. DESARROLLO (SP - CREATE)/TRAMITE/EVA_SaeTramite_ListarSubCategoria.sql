IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE TYPE = 'P'
  AND NAME = 'EVA_SaeTramite_ListarSubCategorias')
  DROP PROCEDURE EVA_SaeTramite_ListarSubCategorias
GO
-------------------------------------------------------------------------------    
--Creado por      : alaureano (06/06/2022)
--Revisado por    :    
--Funcionalidad   : Lista las subcategorias de un tramite - Modulo Pendientes Administrativos
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:

  EXEC [EVA_SaeTramite_ListarSubCategorias] 1, 1296171

*/

CREATE PROCEDURE [EVA_SaeTramite_ListarSubCategorias] @IdCategoria int = NULL,
@IdActor bigint
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    T.IdTramite,
    T.NombreInterno
  FROM EVA_SAE_Tramite T WITH (NOLOCK)
  INNER JOIN EVA_SAE_TramiteCategoria TC WITH (NOLOCK)
    ON TC.IdCategoria = T.IdCategoria
  INNER JOIN EVA_SAE_TramiteEncargado EN WITH (NOLOCK)
    ON EN.IdTramite=T.IdTramite
  WHERE TC.EsActivo = 1
  AND T.IdCategoria = @IdCategoria
  AND T.EsAutomatico = 0
  AND EN.IdActor= @IdActor

END