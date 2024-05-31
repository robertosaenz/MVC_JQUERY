IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaePasarelaPagoHistorial_Obtener') DROP PROCEDURE EVA_SaePasarelaPagoHistorial_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   :
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaePasarelaPagoHistorial_Obtener] 3,193
*/ 
CREATE PROCEDURE [dbo].[EVA_SaePasarelaPagoHistorial_Obtener]
	@IdPasarelaPagoHistorial INT,
	@IdTramiteSolicitud INT = null
AS
BEGIN
	SELECT Moneda,MontoTotal,NumeroOrden,
	Valor AS Valor_Correo,
	Valor2 AS Valor2_Contrasenia,
	Valor3 AS Valor3_Api,
	Valor4 AS Valor4_CodigoComercio
	FROM EVA_PasarelaPago_Historial  PPH
	INNER JOIN ParametroEmpresa PE ON PE.Valor4=PPH.CodigoTienda
	where IdPasarelaPagoHistorial=@IdPasarelaPagoHistorial and IdTramiteSolicitud=@IdTramiteSolicitud
END