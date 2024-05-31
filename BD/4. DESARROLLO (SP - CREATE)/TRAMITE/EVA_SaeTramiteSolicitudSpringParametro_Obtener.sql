IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpringParametro_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudSpringParametro_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Retorna los parametros necesarios para realizar la creacion de archivo XML
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpringParametro_Obtener]
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpringParametro_Obtener]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT DISTINCT 
	PE.Descripcion
	FROM ParametroEmpresa PE WITH(NOLOCK)
	Where PE.Nombre = 'EVA_NIUBIZ'
END


