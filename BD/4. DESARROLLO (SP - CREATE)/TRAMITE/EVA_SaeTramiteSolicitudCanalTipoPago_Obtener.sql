IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudCanalTipoPago_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudCanalTipoPago_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Retorna el codigo de forma de pago necesario para crear la cabecera del archivo XML
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudCanalTipoPago_Obtener] '00002700', 'web'
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudCanalTipoPago_Obtener]
@CompaniaSocio VARCHAR(8),  
@FormaPago VARCHAR(50)   
AS
BEGIN
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	DECLARE @TipoPago CHAR(2)  

	SET NOCOUNT ON;

	IF @CompaniaSocio = '00002500'  
	BEGIN  
		IF @FormaPago = 'web' SET @TipoPago = 'PV'  
		IF @FormaPago = 'pagoefectivo' SET @TipoPago = 'PE'  
	END  
	
	ELSE IF @CompaniaSocio = '00002700'  
	BEGIN  
		IF @FormaPago = 'web' SET @TipoPago = 'PD'  
		IF @FormaPago = 'pagoefectivo' SET @TipoPago = 'EI'  
	END  

	ELSE IF @CompaniaSocio = '00002600'  
	BEGIN  
		IF @FormaPago = 'web' SET @TipoPago = 'PS' 
		IF @FormaPago = 'pagoefectivo' SET @TipoPago = 'PT'  
	END

	EXEC
	(
		'
			SELECT 
			CanalPago,
			CodigoBanco,
			TipoPago
			FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo'+'.'+'CO_CanalTipoPago WITH(NOLOCK)
			WHERE CompaniaSocio = '''+@CompaniaSocio+'''
			AND TipoPago = '''+@TipoPago+'''
		'
	)
END


