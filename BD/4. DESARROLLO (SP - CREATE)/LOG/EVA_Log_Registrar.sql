IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_Log_Registrar') DROP PROCEDURE EVA_Log_Registrar
GO 
-------------------------------------------------------------------------------    
--Creado por      :   ahurtado (26/05/2022)
--Revisado por    :    
--Funcionalidad   : Obtiene los parametros de Niubiz que le corresponden al alumno (depende de la sede en Zegel)
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:

	EXEC [EVA_Log_Registrar] 'Tramites','Ejemplo'
	EXEC [EVA_Log_Registrar] 232323,45060,'00002500'
	

*/ 

CREATE PROCEDURE [EVA_Log_Registrar]
-- PARAMETROS AQUI
@Modulo varchar(max) = NULL,
@Usuario varchar(max) = NULL,
@Param1 varchar(max) = NULL,
@Param2 varchar(max) = NULL,
@Param3 varchar(max) = NULL,
@Param4 varchar(max) = NULL,
@Param5 varchar(max) = NULL,
@Param6 varchar(max) = NULL,
@Param7 varchar(max) = NULL,
@Param8 varchar(max) = NULL,
@Param9 varchar(max) = NULL,
@Param10 varchar(max) = NULL

AS
BEGIN
  SET NOCOUNT ON
  -- TU CODIGO

  INSERT INTO EVA_Log (Modulo,Usuario,Param1,Param2,Param3,Param4,Param5,Param6,Param7,Param8,Param9,Param10)
  values (@Modulo,@Usuario,@Param1,@Param2,@Param3,@Param4,@Param5,@Param6,@Param7,@Param8,@Param9,@Param10)
END
GO
