IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE TYPE = 'P'
  AND NAME = 'EVA_ListaAgrupada_FiltrosSAE')
  DROP PROCEDURE EVA_ListaAgrupada_FiltrosSAE
GO
-------------------------------------------------------------------------------    
--Creado por      : Almendra Laureano (02/06/2022)
--Revisado por    :    
--Funcionalidad   : Listar los datos que se usarán para llenar los filtros del modulo Tickets Pendiente - Administrativos
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:

  	EXEC [EVA_ListaAgrupada_FiltrosSAE]
*/

CREATE PROCEDURE [EVA_ListaAgrupada_FiltrosSAE]
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Sede AS TABLE (
    IdSede int NULL,
    Nombre varchar(50)
  )
  DECLARE @Producto AS TABLE (
    IdProducto int,
    ProductoNombreCorto varchar(200)
  )
  DECLARE @EVA_SAE_TramiteCategoria AS TABLE (
    IdCategoria int,
    Nombre varchar(50)
  )

  --Campus
  --INSERT INTO @Sede (Nombre)
  --  VALUES ('Ninguno')
  INSERT INTO @Sede
    SELECT
      IdSede,
      Nombre
    FROM Sede WITH (NOLOCK)
    WHERE Activo = 1

  SELECT
    *
  FROM @Sede

  --Programa de Estudio
  --INSERT INTO @Producto
  --  SELECT
  --    NULL,
  --    'Ninguno'
  INSERT INTO @Producto
    SELECT
      IdProducto,
      ProductoNombreCorto
    FROM Producto WITH (NOLOCK)
    WHERE Estado = 'A'

  SELECT
    *
  FROM @Producto

  --Categoria
  --INSERT INTO @EVA_SAE_TramiteCategoria
  --  SELECT
  --    NULL,
  --    'Ninguno'
  INSERT INTO @EVA_SAE_TramiteCategoria
    SELECT
      IdCategoria,
      Nombre
    FROM EVA_SAE_TramiteCategoria WITH (NOLOCK)
    WHERE EsActivo = 1

  SELECT
    *
  FROM @EVA_SAE_TramiteCategoria

END