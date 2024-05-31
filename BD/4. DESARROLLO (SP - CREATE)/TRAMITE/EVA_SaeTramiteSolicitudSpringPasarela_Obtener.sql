IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpringPasarela_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudSpringPasarela_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Retorna los parametros necesarios para realizar la creación del detalle del archivo XML
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpringPasarela_Obtener]
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpringPasarela_Obtener]
@IdTramiteSolicitud INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
	TSS.IdTramiteSolicitud,
	TSS.IdNiubiz,
	TSS.NumeroInternoSpring
	FROM EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK)
	Where TSS.IdTramiteSolicitud = @IdTramiteSolicitud
END

