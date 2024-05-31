IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SAE_TramiteSolicitudPasarelaPago_Registrar') DROP PROCEDURE EVA_SAE_TramiteSolicitudPasarelaPago_Registrar
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
EXEC [EVA_SAE_TramiteSolicitudPasarelaPago_Registrar] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SAE_TramiteSolicitudPasarelaPago_Registrar]
@CodigoTienda VARCHAR(50),    
@Eticket VARCHAR(50),    
@Resultado VARCHAR(500),    
@MontoTotal DECIMAL,    
@NumeroIdentidad VARCHAR(10)
AS
BEGIN
	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH (NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH (NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	-- DYNAMIC QUERY VALUES
	DECLARE @SQL_String NVARCHAR(max)
	DECLARE @Parameter_Definition NVARCHAR(max)

	-- OPERATION VALUES
	DECLARE @NumeroOrden INT

	SET @SQL_String = N'
			EXEC '+@LinkedServerSpringASOC+'.'+@BaseDatosSpringASOC+'.'+'dbo.cPasarelaPago_Ins_Grabar 
			@CodigoTienda_input,
			@Eticket_input,
			@Resultado_input,
			@MontoTotal_input,
			@NumeroIdentidad_input,
			@RetVal_output OUTPUT'

	SET @Parameter_Definition = N'
			@CodigoTienda_input VARCHAR(50),
			@Eticket_input VARCHAR(50),
			@Resultado_input VARCHAR(500),
			@MontoTotal_input DECIMAL,
			@NumeroIdentidad_input VARCHAR(10),
			@RetVal_output INT OUTPUT'

	EXECUTE sp_executesql 
			@SQL_String,
			@Parameter_Definition,
			@CodigoTienda_input=@CodigoTienda,
			@Eticket_input=@Eticket,
			@Resultado_input=@Resultado,
			@MontoTotal_input=@MontoTotal,
			@NumeroIdentidad_input=@NumeroIdentidad,
			@RetVal_output = @NumeroOrden OUTPUT



	DECLARE @Pasarela TABLE 
	(
		CodigoTienda VARCHAR(100),
		NumeroOrden VARCHAR(50),
		Eticket VARCHAR(50),
		Resultado VARCHAR(200),
		MontoTotal VARCHAR(20),
		NumeroIdentidad VARCHAR(20),
		FechaHoraTransaccion VARCHAR(20),
		NumDocumento VARCHAR(50),
		DescDocumento VARCHAR(100),
		TotalPagar VARCHAR(10),
		MonedaDoc VARCHAR(10),
		NroTarjeta VARCHAR(20),
		CompaniaSocio VARCHAR(20)
	)

	INSERT INTO @Pasarela
	(
		CodigoTienda,
		NumeroOrden,
		Eticket,
		Resultado,
		MontoTotal,
		NumeroIdentidad,
		FechaHoraTransaccion,
		NumDocumento,
		DescDocumento,
		TotalPagar,
		MonedaDoc,
		NroTarjeta,
		CompaniaSocio
	)
	EXEC
	(
		'
			SELECT 
			PP.CodigoTienda,
			PP.NumeroOrden,
			PP.Eticket,
			PP.Resultado,
			PP.MontoTotal,
			PP.NumeroIdentidad,
			PP.FechaHoraTransaccion,
			PPD.NumDocumento,
			PPD.DescDocumento,
			PPD.TotalPagar,
			PPD.MonedaDoc,
			PP.NroTarjeta,
			MTR.CompaniaSocio
			FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.PasarelaPago PP WITH (NOLOCK)
			INNER JOIN '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.PasarelaPagoDocumento PPD WITH (NOLOCK) ON PP.CodigoTienda= PPD.CodigoTienda  AND PP.NumeroOrden = PPD.NumeroOrden      
			INNER JOIN '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.MaestroTablaRegistro MTR WITH (NOLOCK)  ON MTR.IdMaestroTabla = 1 AND MTR.Codigo = PP.CodigoTienda  
			WHERE 
			PP.CodigoTienda=ISNULL('''+@CodigoTienda+''',PP.CodigoTienda)
			AND PP.NumeroOrden=ISNULL('+@NumeroOrden+',PP.NumeroOrden)

		'
	)

	SELECT
	'CodigoTienda' = ISNULL(CodigoTienda,''),      
    'NumeroOrden' = ISNULL(NumeroOrden,-1),      
    'Eticket'=ISNULL(Eticket,''),      
	'Resultado'=ISNULL(Resultado,''),      
	'MontoTotal'= ISNULL(MontoTotal,0.0),      
	'NumeroIdentidad'=ISNULL(NumeroIdentidad,''),      
	'FechaHoraTransaccion' =   ISNULL( CONVERT(VARCHAR,FechaHoraTransaccion,103) + ' '+  CONVERT(VARCHAR,FechaHoraTransaccion,108) , '') ,    
	'NumDocumento'= ISNULL(NumDocumento,''),      
	'DescDocumento'=DescDocumento,      
	'TotalPagar'= CAST( ISNULL(TotalPagar,'0.00') as varchar) ,      
	'MonedaDoc' = MonedaDoc ,  
	'NroTarjeta' = ISNULL(NroTarjeta,''),  
	'CompaniaSocio' = ISNULL(CompaniaSocio,'')  
	FROM @Pasarela
END