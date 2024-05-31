IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_PasarelaPagoXml_Listar') DROP PROCEDURE EVA_PasarelaPagoXml_Listar
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
EXEC EVA_PasarelaPagoXml_Listar 16, 'PE','0000158736','00002700',35
*/
CREATE PROCEDURE [dbo].[EVA_PasarelaPagoXml_Listar]
@IdPasarelaPagoHistorial INT,
@TipoDocumento  VARCHAR(10), 
@NumeroDocumento  VARCHAR(30), 
@CompaniaSocio VARCHAR(10), 
@IdSede INT
AS
BEGIN
	DECLARE @CodigoTienda VARCHAR(50)
	DECLARE @LinkedServerSpring VARCHAR(50)
	DECLARE @BaseDatosSpring VARCHAR(50)
	DECLARE @NumeroOrden INT
	DECLARE @NumeroIdentidad INT
	DECLARE @NumeroInterno INT
	DECLARE @FechaTransaccion DATETIME
	DECLARE @MontoTotal MONEY
	DECLARE @Moneda VARCHAR(10)
	DECLARE @Persona INT

	SELECT 
	@CodigoTienda = PH.CodigoTienda,
	@NumeroOrden = PH.NumeroOrden,
	@NumeroIdentidad = PH.NumeroIdentidad,
	@NumeroInterno = PH.NumeroInternoSpring,
	@FechaTransaccion = PH.FechaTransaccion,
	@MontoTotal = PH.MontoTotal,
	@Moneda = PH.Moneda,
	@Persona = PM.Persona
	FROM EVA_PasarelaPago_Historial PH 
	INNER JOIN PersonaMast PM ON PM.Documento = PH.NumeroIdentidad
	WHERE PH.IdPasarelaPagoHistorial = @IdPasarelaPagoHistorial

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 
	FROM Parametro WITH(NOLOCK) WHERE Nombre = IIF(@IdSede = 4,'ServidorVinculadoSpringASOC','ServidorVinculadoSpring')

	EXEC
	(
		'
			DECLARE @cadena VARCHAR(MAX)
			Select @cadena=Disponible1 from ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.MaestroTablaRegistro where 
			CompaniaSocio='''+@CompaniaSocio+''' and Activo=1 and Codigo='''+@CodigoTienda+'''

			DECLARE @Registros TABLE (
			numero INT identity(1,1),
			valor varchar(200)
			)

			INSERT INTO @Registros (valor)
			SELECT items FROM dbo.udf_Split(@cadena,''|'')
					   
			SELECT 
			(
				SELECT top 1 TipoPago
				FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.CO_CanalTipoPago  CTP
				INNER JOIN @Registros R4 ON  R4.numero=4 AND R4.valor=CTP.CanalPago
				INNER JOIN @Registros R5 ON  R5.numero=5 AND R5.valor=CTP.CodigoBanco
				WHERE CompaniaSocio='''+@CompaniaSocio+'''
			) AS FormaPago,
			(SELECT valor FROM @Registros where numero=4) AS  CanalPago,
			(SELECT valor FROM @Registros where numero=5) AS  CodigoBanco,
			(SELECT valor FROM @Registros where numero=7) AS  TipoConsulta,
			(SELECT valor FROM @Registros where numero=8) AS  CodigoProducto,
			'+ @NumeroOrden + ' AS NumeroOrdenNiubiz

			SELECT CO.Estado,PM.Documento as NumeroIdentidad,CAST( ISNULL(CO.MontoTotal,''0.00'') as varchar) AS TotalPagar,TRIM(MM.CodigoFiscal) as MonedaDoc 
			FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento CO
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast PM On CO.ClienteNumero=PM.Persona
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.MonedaMast MM On CO.MonedaDocumento=MM.MonedaCodigo	
			WHERE CO.NumeroDocumento=''' + @NumeroDocumento +''' and CO.TipoDocumento=''' + @TipoDocumento +''' and CO.CompaniaSocio='''+@CompaniaSocio+''' AND CO.Estado IN (''AP'',''PR'')
		'
	)

	DECLARE @PagoLinea TABLE (registro CHAR(8))

	INSERT INTO @PagoLinea
	EXEC
	(
		N'
			SELECT
			CompaniaSocio
			FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea 
			WHERE CompaniaSocio = '''+@CompaniaSocio+''' And TipoDocumento = '''+@TipoDocumento+''' And NumeroDocumento  = '''+@NumeroDocumento+'''
		'
	)
	
	IF EXISTS(SELECT registro FROM @PagoLinea)      
	BEGIN
		PRINT('UPDATE');
		EXEC
		(
			N'
				UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea
				SET
				ClienteNumero = '+@Persona+',        
				FechaEmision = '''+@FechaTransaccion+''',
				FechaVencimiento = GetDate(),
				MontoTotal = '''+@MontoTotal+''',
				MontoMora = ''0'',
				MontoDescuento = ''0'',   
				Moneda = '''+@Moneda+''',
				FechaConsulta = GetDate(),        
				TipoConsulta = 1,      
				IdConsulta = '''+@NumeroIdentidad+'''
				WHERE CompaniaSocio = '''+@CompaniaSocio+''' AND TipoDocumento = '''+@TipoDocumento+''' AND NumeroDocumento  = '''+@NumeroDocumento+''' 
			'
		)      
	END
	ELSE
	BEGIN
		PRINT('INSERT');
		EXEC
		(
			N'
				INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea        
				(        
					CompaniaSocio, TipoDocumento, NumeroDocumento, ClienteNumero, FechaEmision, FechaVencimiento, MontoTotal, MontoMora, Moneda,         
					FlagConsultado, FechaConsulta, FlagNotificacionPago, FlagPagoAnulado, TipoConsulta, IdConsulta, MontoDescuento        
				)
				VALUES
				(
					'''+@CompaniaSocio+''',
					'''+@TipoDocumento+''',
					'''+@NumeroDocumento+''',
					'+@Persona+',
					'''+@FechaTransaccion+''',
					GetDate(),
					'''+@MontoTotal+''',
					''0'',
					'''+@Moneda+''',
					1,
					GetDate(),
					0,
					0,
					1, '''+@NumeroIdentidad+''', 0
				)
			'
		)
	END
END