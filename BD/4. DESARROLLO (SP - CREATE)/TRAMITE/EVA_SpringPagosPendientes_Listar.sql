IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SpringPagosPendientes_Listar') DROP PROCEDURE EVA_SpringPagosPendientes_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (08/08/2022)
--Revisado por    : 
--Funcionalidad   : Lista los pagos pendientes de la BD de Spring filtrando por el Numero de Documento de Identidad
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC EVA_SpringPagosPendientes_Listar '004','1','43128033','00002700'
EXEC EVA_SpringPagosPendientes_Listar '001','1','43128033','00002500' 
EXEC EVA_SpringPagosPendientes_Listar '001','1','42834315','00002500' 
EXEC EVA_SpringPagosPendientes_Listar '001','1','75414981','00002500'
EXEC EVA_SpringPagosPendientes_Listar '001','1','74132821','00002500'
EXEC EVA_SpringPagosPendientes_Listar '004','1','76568760','00002700'
EXEC EVA_SpringPagosPendientes_Listar '001','25','76568760','00002500'
EXEC EVA_SpringPagosPendientes_Listar '002','25','73107495','00002500'
*/ 
CREATE PROCEDURE [EVA_SpringPagosPendientes_Listar]
@CodigoProducto VARCHAR(3),
@TipoDocumento VARCHAR(1),
@NumeroIdentidad VARCHAR(14),
@CompaniaSocio CHAR(8)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @BaseDatosSpring varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 
	FROM Parametro WITH(NOLOCK) WHERE Nombre = IIF(@CodigoProducto = '002','ServidorVinculadoSpringASOC','ServidorVinculadoSpring')

	-- DYNAMIC QUERY VALUES
	DECLARE @SQL_String NVARCHAR(max)
	DECLARE @SQL_String1 NVARCHAR(max)
	DECLARE @Parameter_Definition NVARCHAR(max)
	DECLARE @Parameter_Definition1 NVARCHAR(max)

	-- LOCAL VARIABLES
	DECLARE @w_rows BIGINT, @k BIGINT, @w_count BIGINT     
	DECLARE @w_estado CHAR(1)      
	DECLARE @w_flag VARCHAR        
    DECLARE @w_fechavencimiento DATETIME        
    DECLARE @w_mora MONEY, @w_igv DECIMAL, @w_totalmora MONEY, @w_totalmoraadm DECIMAL        
    DECLARE @w_factor DECIMAL, @w_factorcompra DECIMAL, @w_factorventa DECIMAL, @w_factorpromedio DECIMAL        
    DECLARE @w_factorventasbs DECIMAL, @w_factorcomprasbs DECIMAL     

	DECLARE @w_datetime DATETIME        
    DECLARE @w_datestring VARCHAR        
    DECLARE @vNumeroDocumento VARCHAR(14)        
    DECLARE @vTipoDocumento CHAR(2)        
    DECLARE @w_MoraAdmDia DECIMAL        
    DECLARE @w_MoraAdmMto DECIMAL        
    DECLARE @w_NotaCreditoDocumento VARCHAR(17)        
    DECLARE @vMontoPagado MONEY        
    DECLARE @w_dias INT        
    DECLARE @w_moraporce DECIMAL        
    DECLARE @w_percent DECIMAL     

	DECLARE @vIdPersona int 
	DECLARE @vIdPersonaAnt int 
	DECLARE @vCompaniaSocio char(8)        
	DECLARE @vMonedaDocumento char(2)        
	DECLARE @vMontoTotal money        
	DECLARE @vFechaDocumento datetime        
	DECLARE @vClienteNumero int        
	DECLARE @vInterfase_Area char(2)        
	DECLARE @vInterfase_Descuento char(6)        
	DECLARE @vMontoDescuento money        
	DECLARE @vPorcentageDescuento money        
	DECLARE @vUnidadNegocio char(4)    
       
	DECLARE @vGrupoDescuento int    
	DECLARE @vGrupoTipo int    
	DECLARE @vCaptacion char(1)     
	DECLARE @vCampana char(10)     
	DECLARE @vTipoFacturacion char(3)    
	DECLARE @vCompania Char(6)  
	DECLARE @vPorcentajeNew Money  
	DECLARE @vInterfase_Cuota int

	-- TEMP TABLES
	
	DECLArE @tmpGestionados TABLE
	(
	  DescripcionLocal CHAR(100) COLLATE DataBase_Default,
	  FechaPreparacion DATETIME,
	  FechaVencimiento DATETIME,
	  Monto MONEY,
	  Periodo INT,
	  Campania CHAR(10),
	  CuotaNumero INT,
	  Monedacodigo CHAR (10)
	)

	DECLARE @tmpDeuda TABLE
	(        
      Id INT Identity(1,1),        
      CompaniaSocio CHAR(8) COLLATE DataBase_Default,         
      TipoDocumento CHAR(2) COLLATE DataBase_Default,         
      NumeroDocumento CHAR(14) COLLATE DataBase_Default,         
      Estado CHAR(2) COLLATE DataBase_Default,         
      FechaDocumento DATETIME,         
      ClienteNombre CHAR(60) COLLATE DataBase_Default,         
      MonedaDocumento CHAR(2) COLLATE DataBase_Default,         
      MontoTotal MONEY,         
      ImpresionPendienteFlag CHAR(1) COLLATE DataBase_Default,         
      FechaVencimiento DATETIME,         
      MontoPagado MONEY,         
      MontoNoAfecto MONEY,         
      AprobadoPor INT,         
      FechaAprobacion datetime,         
      ClienteCobrarA INT,         
      Busqueda CHAR(50) COLLATE DataBase_Default,         
      Sucursal CHAR(4) COLLATE DataBase_Default,         
      Clasificacion CHAR(2) COLLATE DataBase_Default,        
      ClienteNumero INT,        
      FormadePago CHAR(3) COLLATE DataBase_Default,        
      NotaCreditoDocumento CHAR(17) COLLATE DataBase_Default,        
      MontoDescuentos MONEY,        
      MontoAfecto MONEY,        
      MontoImpuestoVentas MONEY,        
      MontoImpuestos MONEY,        
      Comentarios CHAR(255) COLLATE DataBase_Default,        
      CampoReferencia CHAR(12) COLLATE DataBase_Default,        
      NumeroInterno CHAR(15) COLLATE DataBase_Default,        
      VoucherPeriodo CHAR(6) COLLATE DataBase_Default,        
      Mora MONEY,        
      Descripcion VARCHAR(255) COLLATE DataBase_Default,        
      UnidadReplicacion CHAR(4) COLLATE DataBase_Default,        
      Interfase_Area CHAR(2) COLLATE DataBase_Default,        
      Interfase_Descuento CHAR(6) COLLATE DataBase_Default,        
      MontoMinimo MONEY,      
      UnidadNegocio CHAR(4) COLLATE DataBase_Default,    
      GrupoDescuento INT,    
      GrupoTipo INT,    
      Captacion CHAR(1) COLLATE DataBase_Default,    
      Campana CHAR(10) COLLATE DataBase_Default,    
      TipoFacturacion CHAR(3) COLLATE DataBase_Default,
	  Interfase_Cuota INT
	)   

	DECLARE @tmpDescuento TABLE 
	(  
      MontoDescuento money  
	)  
	
	DECLARE @TmpTipoCambioMast TABLE
	(
		Factor REAL,
		FactorCompra REAL,
		FactorVenta REAL,
		FactorPromedio REAL,
		FactorCompraSBS REAL,
		FactorVentaSBS REAL,
		Estado CHAR(1)
	)

	-- QUERYING DOCUMENT TYPE
	IF @TipoDocumento =1  
    BEGIN  
		SET @SQL_String = 
		N'
			SELECT TOP 1 
			@Persona_input = Persona,
			@PersonaAnt_input = PersonaAnt
			FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast WITH (NOLOCK)
			WHERE 
			Documento LIKE LEFT(''' + @NumeroIdentidad + ''',8)+''%'' AND 
			Estado = ''A'' AND 
			(EsOtro = ''S'' OR EsCliente = ''S'') 
			ORDER BY Busqueda  
		'
		
		SET @Parameter_Definition = 
		N'
			@Persona_input INT OUT,
			@PersonaAnt_input INT OUT
		'
		EXECUTE sp_executesql 
		@SQL_String,
		@Parameter_Definition,
		@Persona_input=@vIdPersona OUT,
		@PersonaAnt_input=@vIdPersonaAnt OUT       
	END   
	ELSE  
	BEGIN
		SET @SQL_String = 
		N'
			SELECT TOP 1 
			@Persona_input = Persona,
			@PersonaAnt_input = PersonaAnt
			FROM ' + +@LinkedServerSpring + '.' + +@BaseDatosSpring+ '.' + 'dbo.PersonaMast WITH (NOLOCK)
			WHERE 
			CASE
			WHEN '''+ @TipoDocumento + ''' = ''1'' THEN Documento       
			WHEN '''+ @TipoDocumento + ''' = ''2'' THEN DocumentoFiscal
			END = '''+ @NumeroIdentidad+''' AND Estado = ''A'' AND (EsOtro = ''S'' OR EsCliente = ''S'')         
			ORDER BY Busqueda   
		'
	
		SET @Parameter_Definition = 
		N'
			@Persona_input INT OUT,
			@PersonaAnt_input INT OUT
		'
		EXECUTE sp_executesql 
		@SQL_String,
		@Parameter_Definition,
		@Persona_input=@vIdPersona OUT,
		@PersonaAnt_input=@vIdPersonaAnt OUT       
	END
	
	-- QUERYING DEUDA
	INSERT INTO @tmpDeuda
	(        
		CompaniaSocio, TipoDocumento, NumeroDocumento, Estado, FechaDocumento, ClienteNombre, MonedaDocumento, MontoTotal,         
		ImpresionPendienteFlag, FechaVencimiento, MontoPagado, MontoNoAfecto, AprobadoPor, FechaAprobacion, ClienteCobrarA,       
		Busqueda, Sucursal, Clasificacion, ClienteNumero, FormadePago, NotaCreditoDocumento, MontoDescuentos, MontoAfecto,         
		MontoImpuestoVentas, MontoImpuestos, Comentarios, CampoReferencia, NumeroInterno, VoucherPeriodo, Mora, Descripcion,         
		UnidadReplicacion, Interfase_Area, Interfase_Descuento, UnidadNegocio, GrupoDescuento, GrupoTipo, Captacion, Campana,    
		TipoFacturacion, Interfase_Cuota    
	)  
	EXEC
	(
		N'
			SELECT 
			Doc.CompaniaSocio, Doc.TipoDocumento, Doc.NumeroDocumento, Doc.Estado, Doc.FechaDocumento,         
            Doc.ClienteNombre, Doc.MonedaDocumento, Doc.MontoTotal - Doc.MontoPagado, Doc.ImpresionPendienteFlag, Doc.FechaVencimiento,         
            Doc.MontoPagado, Doc.MontoNoAfecto, Doc.AprobadoPor, Doc.FechaAprobacion, Doc.ClienteCobrarA,         
            Per.Busqueda, Doc.Sucursal, Tip.Clasificacion, Doc.ClienteNumero, Doc.FormadePago,         
            Doc.NotaCreditoDocumento, Doc.MontoDescuentos, Doc.MontoAfecto, Doc.MontoImpuestoVentas,         
            Doc.MontoImpuestos, Doc.Comentarios, Doc.CampoReferencia, Doc.NumeroInterno, Doc.VoucherPeriodo, 0.00, docdet.Descripcion, Doc.UnidadReplicacion,        
            Doc.Interfase_Area, Doc.Interfase_Descuento, Doc.UnidadNegocio, Doc.Interfase_GrupoDescuento, Doc.GrupoTipo,    
            Doc.interfase_captacion, Doc.Interfase_Campana, Doc.TipoFacturacion, Doc.Interfase_Cuota    
			FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento Doc WITH (NOLOCK)
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast Per WITH (NOLOCK) ON Doc.ClienteCobrarA = Per.Persona         
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_TipoDocumento Tip WITH (NOLOCK) ON Doc.TipoDocumento = Tip.TipoDocumento         
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_DocumentoDetalle docdet WITH (NOLOCK) ON docdet.CompaniaSocio = Doc.CompaniaSocio And docdet.TipoDocumento = Doc.TipoDocumento And docdet.NumeroDocumento = Doc.NumeroDocumento And         
                                     docdet.Linea = docdet.Linea and docdet.itemcodigo <> ''4010100010'' AND docdet.Linea = 1  
			WHERE 
			(
				(Doc.CompaniaSocio = '''+@CompaniaSocio+''') AND
				(Doc.MontoTotal  <> Doc.MontoPagado) AND  
				(doc.Interfase_grupodescuento <> 1905 or doc.Interfase_grupodescuento IS NULL ) AND              
				(Doc.TipoDocumento <> '''') AND                  
				(Doc.Estado In (''PR'',''AP'')) AND                  
				(Doc.ClienteNumero = '+@vIdPersona+') AND    
				(Doc.NumeroDocumento >= '''') AND
				(Tip.Clasificacion Not In (''PE'',''LE''))
			)  
			AND         
            (Doc.TipoDocumento <> ''PE'') And (Tip.Clasificacion = ''DC'') 
			UNION ALL   
			SELECT 
			Doc.CompaniaSocio, Doc.TipoDocumento, Doc.NumeroDocumento, Doc.Estado, Doc.FechaDocumento,         
            Doc.ClienteNombre, Doc.MonedaDocumento, Doc.MontoTotal, Doc.ImpresionPendienteFlag, Doc.FechaVencimiento,         
            Doc.MontoPagado, Doc.MontoNoAfecto, Doc.AprobadoPor, Doc.FechaAprobacion, Doc.ClienteCobrarA,         
            Per.Busqueda, Doc.Sucursal, Tip.Clasificacion, Doc.ClienteNumero, Doc.FormadePago,         
            Doc.NotaCreditoDocumento, Doc.MontoDescuentos, Doc.MontoAfecto, Doc.MontoImpuestoVentas,         
            Doc.MontoImpuestos, Doc.Comentarios, Doc.CampoReferencia, Doc.NumeroInterno, Doc.VoucherPeriodo, 0.00, docdet.Descripcion, Doc.UnidadReplicacion,        
            Doc.Interfase_Area, Doc.Interfase_Descuento, Doc.UnidadNegocio, Doc.Interfase_GrupoDescuento, Doc.GrupoTipo,    
            Doc.interfase_captacion, Doc.Interfase_Campana, Doc.TipoFacturacion, Doc.Interfase_Cuota    
			FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento Doc WITH (NOLOCK)
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast Per WITH (NOLOCK) ON Doc.ClienteCobrarA = Per.Persona         
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_TipoDocumento Tip WITH (NOLOCK) ON Doc.TipoDocumento = Tip.TipoDocumento         
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_DocumentoDetalle docdet WITH (NOLOCK) ON docdet.CompaniaSocio = Doc.CompaniaSocio And        
            docdet.TipoDocumento = Doc.TipoDocumento AND docdet.NumeroDocumento = Doc.NumeroDocumento AND docdet.Linea = docdet.Linea AND docdet.Linea = 1     
			WHERE 
			(
				(Doc.CompaniaSocio = '''+@CompaniaSocio+''') AND         
				(Doc.MontoTotal  <> Doc.MontoPagado) AND         
				(Doc.TipoDocumento <> '''') AND         
				(Doc.Estado = ''AP'') AND         
				(Doc.ClienteNumero = '+@vIdPersona+') AND 
				(Doc.NumeroDocumento >= '''')
			) 
			AND            
            (Doc.TipoDocumento = ''PE'')  AND         
            (FormaFacturacion <> ''GF'')         
			ORDER BY Doc.TipoDocumento ASC, Doc.NumeroDocumento ASC
		'
	)

	Set @w_rows = @@RowCount  

	-- QUERYING GESTIONADOS
	INSERT INTO @tmpGestionados
	(
		DescripcionLocal,
		FechaPreparacion,
		FechaVencimiento ,
		Monto ,
		Periodo ,
		Campania ,
		CuotaNumero ,
		Monedacodigo 
	)
	EXEC
	(
		N'
			SELECT
			SC.DescripcionLocal,
			IPH.FechaPreparacion,
			IPH.FechaVencimiento,
			IPD.Monto,
			IPH.Periodo,
			IPH.Campania,
			IPH.CuotaNumero,
			IPH.Monedacodigo
			FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' +'dbo.CO_Interfase_P09_Header IPH WITH(NOLOCK)
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' +'dbo.CO_Interfase_P09_Detalle IPD WITH(NOLOCK) ON IPH.NumeroInterno = IPD.NumeroInterno
			INNER JOIN ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' +'dbo.CO_ServicioClasificacion SC WITH(NOLOCK) ON  SC.ServicioClasificacion = IPD.ItemCodigo
			WHERE IPH.Cliente = '+@vIdPersonaAnt+' AND IPH.Estado =''GE'' AND IPH.CompaniaSocio = '''+@CompaniaSocio+'''
		'
	)
	
	--Calcular la Mora de cada documento        
	SET @w_igv = (18.0 + 100.0) / 100.0  
	
	SET @w_datetime = GetDate()        
	SET @w_datestring = Convert(varchar(8), @w_datetime, 112) 

	INSERT INTO @TmpTipoCambioMast
	(
		Factor,FactorCompra,FactorVenta,FactorPromedio,FactorCompraSBS,FactorVentaSBS,Estado
	)
	EXEC
	(
		N'
			SELECT 
			TC.Factor,         
			TC.FactorCompra,         
			TC.FactorVenta,         
			TC.FactorPromedio,         
			TC.FactorCompraSBS,         
			TC.FactorVentaSBS,         
			TC.Estado    
			FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.TipoCambioMast TC WITH (NOLOCK)
			WHERE ( TC.MonedaCodigo = ''EX'' ) AND                  
			( TC.MonedaCambioCodigo = ''LO'' ) AND                  
			( TC.FechaCambioString = Convert(varchar(8), GETDATE(), 112) )
		'
	)

	SELECT @w_factor= Factor, @w_factorcompra=FactorCompra, @w_factorventa = FactorVenta, @w_factorpromedio = FactorPromedio, @w_factorventasbs = FactorVentaSBS, @w_factorcomprasbs = FactorCompraSBS, @w_estado = Estado FROM @TmpTipoCambioMast

	IF(@w_estado <> 'A')        
	BEGIN
		Set @w_estado = 'I'
	END
              
    SET @vNumeroDocumento = ''        
	SET @vTipoDocumento = ''        
	SET @k = 1        
	SET @w_totalmoraadm = 0        
	SET @w_totalmora = 0        
           
	SET @vInterfase_Area = ''        
	SET @vInterfase_Descuento = ''    
	SET @vTipoFacturacion = '' 
  
	WHILE (@k <= @w_rows)    
	BEGIN
		DECLARE @PagoLinea TABLE (registro CHAR(8))

		SELECT @vNumeroDocumento = RTrim(NumeroDocumento),
             @vTipoDocumento = TipoDocumento,
             @w_NotaCreditoDocumento = TipoDocumento + '-' + RTrim(NumeroDocumento),        
             @w_fechavencimiento = FechaVencimiento,        
             @vMontoPagado = MontoPagado,                     
             @vClienteNumero = ClienteNumero,        
             @vFechaDocumento = FechaDocumento,         
             @vMontoTotal = MontoTotal,        
             @vMonedaDocumento = MonedaDocumento,        
             @vInterfase_Area = Interfase_Area,        
             @vInterfase_Descuento = Interfase_Descuento,      
             @vUnidadNegocio = UnidadNegocio,    
             @vGrupoDescuento = GrupoDescuento,    
             @vGrupoTipo = GrupoTipo,    
             @vCaptacion = Captacion,    
             @vCampana = Campana,    
             @vTipoFacturacion = TipoFacturacion,
			 @vInterfase_Cuota = Interfase_Cuota,
			 @vCompaniaSocio = CompaniaSocio
		FROM @tmpDeuda        
		WHERE Id = @k    
		
		SET @w_totalmoraadm = 0        
		SET @w_totalmora = 0 
		
		IF (@vTipoDocumento = 'PE' Or @vTipoDocumento = 'PC')
		BEGIN
			SET @vMontoDescuento = 0
			SET @vPorcentageDescuento = 0  
			DECLARE @adad MONEY
			 
			SET @SQL_String1 = 
			N'
				EXEC '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.COp_CalcularDescuentoSpring 
				@vUnidadNegocio_input,
				@vInterfase_Area_input,
				@vCaptacion_input,
				@vTipoDocumento_input,
				@vTipoFacturacion_input,
				@vGrupoDescuento_input,
				@vCampana_input,
				@vMontoTotal_input,'+
				IIF(@CodigoProducto='002', '','@CompaniaSocio_input,')+
				'@RetVal_output OUTPUT
			'
			SET @Parameter_Definition1 = 
			N'
				@vUnidadNegocio_input CHAR(4),
				@vInterfase_Area_input CHAR(2),
				@vCaptacion_input CHAR(2),
				@vTipoDocumento_input CHAR(2),
				@vTipoFacturacion_input CHAR(3),
				@vGrupoDescuento_input INT,
				@vCampana_input CHAR(10),
				@vMontoTotal_input MONEY,' +
				IIF(@CodigoProducto='002', '','@CompaniaSocio_input VARCHAR(8),')+
				'@RetVal_output MONEY OUTPUT
			'
			IF(@CodigoProducto='002')
			BEGIN
				INSERT INTO @tmpDescuento
				EXECUTE sp_executesql 
				@SQL_String1,
				@Parameter_Definition1,
				@vUnidadNegocio_input = @vUnidadNegocio,
				@vInterfase_Area_input = @vInterfase_Area,
				@vCaptacion_input = @vCaptacion,
				@vTipoDocumento_input = @vTipoDocumento,
				@vTipoFacturacion_input = @vTipoFacturacion,
				@vGrupoDescuento_input = @vGrupoDescuento,
				@vCampana_input = @vCampana,
				@vMontoTotal_input = @vMontoTotal,
				@RetVal_output = @vMontoDescuento OUTPUT

			END
			ELSE
			BEGIN
				INSERT INTO @tmpDescuento
				EXECUTE sp_executesql 
				@SQL_String1,
				@Parameter_Definition1,
				@vUnidadNegocio_input = @vUnidadNegocio,
				@vInterfase_Area_input = @vInterfase_Area,
				@vCaptacion_input = @vCaptacion,
				@vTipoDocumento_input = @vTipoDocumento,
				@vTipoFacturacion_input = @vTipoFacturacion,
				@vGrupoDescuento_input = @vGrupoDescuento,
				@vCampana_input = @vCampana,
				@vMontoTotal_input = @vMontoTotal,
				@CompaniaSocio_input = @CompaniaSocio,
				@RetVal_output = @vMontoDescuento OUTPUT
			END

			SELECT @vMontoDescuento =MontoDescuento FROM @tmpDescuento

			--Actualizamos el monto a cobrar        
			IF (@vMontoDescuento > 0.00)        
			BEGIN       
				Update @tmpDeuda        
				Set MontoTotal = Round(MontoTotal - @vMontoDescuento, 0)        
				Where Id = @k            
			End   

			--Actualizamos el Monto Minimo        
			UPDATE @tmpDeuda        
			SET MontoMinimo = MontoTotal        
			WHERE Id = @k   

			INSERT INTO @PagoLinea
			EXEC
			(
				N'
					SELECT
					CompaniaSocio
					FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea 
					WHERE CompaniaSocio = '''+@vCompaniaSocio+''' And TipoDocumento = '''+@vTipoDocumento+''' And NumeroDocumento  = '''+@vNumeroDocumento+'''
				'
			)
			IF Exists(SELECT * FROM @PagoLinea)        
			BEGIN
				--Se actualiza los datos de consulta en el log
				PRINT('update')
				EXEC
						(
				
							N'
								UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea
								SET
								ClienteNumero = '+@vClienteNumero+',        
								FechaEmision = '''+@vFechaDocumento+''',
								FechaVencimiento = '''+@w_fechavencimiento+''',
								MontoTotal = '''+@vMontoTotal+''',
								MontoMora = '+@w_totalmora+',
								MontoDescuento = ''0'',   
								Moneda = '''+@vMonedaDocumento+''',
								FechaConsulta = GetDate(),        
								TipoConsulta = 1,      
								IdConsulta = '''+@NumeroIdentidad+'''

								WHERE CompaniaSocio = '''+@vCompaniaSocio+''' AND TipoDocumento = '''+@vTipoDocumento+''' AND NumeroDocumento  = '''+@vNumeroDocumento+''' 
							'
						)              
			END        
			ELSE        
			BEGIN
				--Se Inserta un nuevo registro log 
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
									'''+@vCompaniaSocio+''',
									'''+@vTipoDocumento+''',
									'''+@vNumeroDocumento+''',
									'+@vClienteNumero+',
									'''+@vFechaDocumento+''',
									'''+@w_fechavencimiento+''',
									'''+@vMontoTotal+''',
									'+@w_totalmora+',
									'''+@vMonedaDocumento+''',
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
		ELSE
		BEGIN
			DECLARE @Contador TABLE(cantidad INT)
			DECLARE @Letras TABLE(flag VARCHAR)
			--Se verifica si es documento MORA        
			IF(@vNumeroDocumento <> 'MORA')        
			BEGIN        
				--Se verifica si el tipo de documento es donación        
				IF (@vTipoDocumento <> 'DO')        
				BEGIN
					SET @w_mora = 0.00        
					SET @w_count = 0        
					SET @w_flag = ''        
					SET @w_totalmoraadm = 0        
					SET @w_totalmora = 0        
					SET @w_moraporce = 0.00        
					SET @w_percent = 0.00        
             
					--Calculo de la 1ra Mora        
					SET @w_dias = DateDiff(day, @w_fechavencimiento, @w_datetime)        
					If (@w_dias > 0) --Ya vencio        
					BEGIN 
						--Porcentaje Mensual de Mora    
						SET @vCompania =Left(@CompaniaSocio,6)                              
                   
						SELECT @w_moraporce = ParametrosMast.Numero         
					FROM ParametrosMast	 WITH(NOLOCK)     
					WHERE ( ParametrosMast.CompaniaCodigo = '999999' )   
					AND ( ParametrosMast.AplicacionCodigo ='CO' )   
					AND ( ParametrosMast.ParametroClave ='MORA%' )         
       
						SET @w_percent = Power(((@w_moraporce / 100.00) + 1.00), (1.00/30.00)) - 1.00 --Tasa diaria        
						SET @w_percent = Power((@w_percent + 1.00), @w_dias) - 1.00        
                          
						SET @w_mora = round(@vMontoPagado * @w_percent, 2)        
                             
						IF (@w_mora < 0.00)        
						BEGIN
							Set @w_mora = 0.00      
						END   
        
						IF @CompaniaSocio <> '00002500'       
						BEGIN
							SET @vCompania =Left(@CompaniaSocio,6)       
       
							SELECT @vPorcentajeNew = ParametrosMast.Numero         
							FROM ParametrosMast         
							WHERE ( ParametrosMast.CompaniaCodigo = @vCompania )   
							AND ( ParametrosMast.AplicacionCodigo ='CO' )   
							AND ( ParametrosMast.ParametroClave ='MORAXDIA' )  
       
							SET @vPorcentajeNew = @vPorcentajeNew /100       
       
							SET @w_mora = Round(@vMontoTotal * @w_dias * @vPorcentajeNew / 100,2)  
       
							IF (@w_mora < 0.00)        
							BEGIN        
								Set @w_mora = 0.00   
							END 
						END   
					END        
                       
					SET @w_totalmora = @w_totalmora + @w_mora        
            
					IF (@CompaniaSocio = '00002500')    
					BEGIN
						--Nro de dias para cobrar 2da mora        
						SELECT @w_MoraAdmDia = ParametrosMast.Numero        
						FROM ParametrosMast         
						WHERE ( ParametrosMast.CompaniaCodigo ='999999' ) AND ( ParametrosMast.AplicacionCodigo ='CO' ) AND ( ParametrosMast.ParametroClave ='MORAADMDIA' )         
                       
						--Monto para cobrar 2da Mora        
						SELECT @w_MoraAdmMto = ParametrosMast.Numero        
						FROM ParametrosMast         
						WHERE ( ParametrosMast.CompaniaCodigo ='999999' ) AND ( ParametrosMast.AplicacionCodigo ='CO' ) AND ( ParametrosMast.ParametroClave ='MORAADMMTO' )         
                       
						INSERT INTO @Contador
						EXEC
						(
							N'
								SELECT COUNT (*)
								FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento WITH (NOLOCK)
								WHERE ( CO_Documento.CompaniaSocio = '''+@vCompaniaSocio+''' ) AND         
								( CO_Documento.TipoDocumento = ''ND'' ) AND         
								( CO_Documento.Estado <> ''AN'' ) AND         
								( CO_Documento.NotaCreditoDocumento = '''+@w_NotaCreditoDocumento+''')
							'
						)
						SELECT @w_count = cantidad FROM @Contador
                             
						IF (@w_count > 0)        
						BEGIN        
							SET @w_MoraAdmMto = 0        
						END        
                       
						--Verificar S/. 50        
						
						INSERT INTO @Letras
						EXEC
						(
							N'
								SELECT CO_Documento.LetraDescuentoCanjeFlag
								FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento WITH (NOLOCK)
								Where ( CO_Documento.CompaniaSocio = '''+@vCompaniaSocio+''' ) AND         
								( CO_Documento.TipoDocumento = '''+@vTipoDocumento+''' ) AND         
								( CO_Documento.NumeroDocumento = '''+@vNumeroDocumento+''' )  
							'
						)
						SELECT @w_flag = flag FROM @Letras
                       
						IF (@w_flag = 'S')        
						BEGIN        
							SET @w_MoraAdmMto = 0        
						END        
                       
						IF (DateDiff(day, @w_fechavencimiento, @w_datetime) >= @w_MoraAdmDia)        
						BEGIN        
							SET @w_totalmoraadm = @w_totalmoraadm + @w_MoraAdmMto        
							SET @w_totalmora = @w_totalmora + @w_MoraAdmMto        
						END        
					END  
					ELSE  
					BEGIN 
						--IDAT  
						IF (@CompaniaSocio = '00002700')    
						BEGIN
							--Valida ND generada por P61
							INSERT INTO @Contador
							EXEC
							(
								N'
									SELECT COUNT (*)
									FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento WITH (NOLOCK)
									WHERE ( CO_Documento.CompaniaSocio = '''+@vCompaniaSocio+''' ) AND         
									( CO_Documento.TipoDocumento = ''ND'' ) AND         
									( CO_Documento.Estado <> ''AN'' ) AND         
									( CO_Documento.NotaCreditoDocumento = '''+@w_NotaCreditoDocumento+''')
								'
							)
							SELECT @w_count = cantidad FROM @Contador
                             
							IF (@w_count > 0)        
							BEGIN        
								SET @w_MoraAdmMto = 0        
							End        
							
							INSERT INTO @Letras
							EXEC
							(
								N'
									SELECT CO_Documento.LetraProtestoNDFlag
									FROM ' + @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento WITH (NOLOCK)
									Where ( CO_Documento.CompaniaSocio = '''+@vCompaniaSocio+''' ) AND         
									( CO_Documento.TipoDocumento = '''+@vTipoDocumento+''' ) AND         
									( CO_Documento.NumeroDocumento = '''+@vNumeroDocumento+''' )  
								'
							)
							SELECT @w_flag = flag FROM @Letras
                       
							IF (@w_flag = 'S')        
							BEGIN        
								SET @w_MoraAdmMto = 0    
								SET @w_totalmora=0  
							END        
                       
							IF (DateDiff(day, @w_fechavencimiento, @w_datetime) >= @w_MoraAdmDia)        
							BEGIN        
								SET @w_totalmoraadm = @w_totalmoraadm + @w_MoraAdmMto        
								SET @w_totalmora = @w_totalmora + @w_MoraAdmMto        
							END        
						END  

						--Ultima Verificación de Aplicación de Mora   
						--mora CAlterna
						IF @vCompaniaSocio = '00002600' --Inicio--BGB 2020.10.14		
						BEGIN
							SET @vCompania =Left(@vCompaniaSocio,6)   
							SET @w_totalmoraadm = 0          
							SET @w_totalmora = 0   

							SELECT @w_MoraAdmDia = ParametrosMast.Numero          
							FROM ParametrosMast           
							WHERE ( ParametrosMast.CompaniaCodigo =@vCompania ) AND ( ParametrosMast.AplicacionCodigo ='CO' ) AND ( ParametrosMast.ParametroClave ='MORADIAMIN' )           
                         
							--Monto para cobrar 2da Mora          
							SELECT @w_MoraAdmMto = ParametrosMast.Numero          
							FROM ParametrosMast           
							WHERE ( ParametrosMast.CompaniaCodigo =@vCompania ) AND ( ParametrosMast.AplicacionCodigo ='CO' ) AND ( ParametrosMast.ParametroClave ='MORAXDIA' )   
					
							SET @w_mora = (@w_dias-@w_MoraAdmDia) * @w_MoraAdmMto 
					
							IF (@w_mora < 0.00)      
							BEGIN
								SET @w_mora = 0.00 
							END

							IF (DateDiff(day, @w_fechavencimiento, @w_datetime) >= @w_MoraAdmDia)          
							BEGIN
								SET @w_totalmoraadm = @w_totalmoraadm + @w_mora          
								SET @w_totalmora = @w_totalmora + @w_mora        
							END    
						END
					END
					--Ultima Verificación de Aplicación de Mora        
					IF (@vTipoDocumento <> 'PE')        
						--Actualizamos la mora al registro        
						Update @tmpDeuda        
						Set Mora = @w_totalmora        
						Where Id = @k        
					ELSE        
						--Actualizamos la mora al registro        
						Update @tmpDeuda        
						Set Mora = 0        
						Where Id = @k        
                       
					--Registramos en Tabla Log de Pagos en Linea
					INSERT INTO @PagoLinea
					EXEC
					(
						N'
							SELECT
							CompaniaSocio
							FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea 
							WHERE CompaniaSocio = '''+@vCompaniaSocio+''' And TipoDocumento = '''+@vTipoDocumento+''' And NumeroDocumento  = '''+@vNumeroDocumento+'''
						'
					)
					If Exists(SELECT * FROM @PagoLinea)        
					BEGIN
						--Se actualiza los datos de consulta en el log
						PRINT('update')
						EXEC
						(
				
							N'
								UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_RegistroPagoLinea
								SET
								ClienteNumero = '+@vClienteNumero+',        
								FechaEmision = '''+@vFechaDocumento+''',
								FechaVencimiento = '''+@w_fechavencimiento+''',
								MontoTotal = '''+@vMontoTotal+''',
								MontoMora = '+@w_totalmora+',
								MontoDescuento = ''0'',   
								Moneda = '''+@vMonedaDocumento+''',
								FechaConsulta = GetDate(),        
								TipoConsulta = 1,      
								IdConsulta = '''+@NumeroIdentidad+'''

								WHERE CompaniaSocio = '''+@vCompaniaSocio+''' AND TipoDocumento = '''+@vTipoDocumento+''' AND NumeroDocumento  = '''+@vNumeroDocumento+''' 
							'
						)       
					END        
					ELSE        
					BEGIN
						--Se Inserta un nuevo registro log 
						print('insert')

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
									'''+@vCompaniaSocio+''',
									'''+@vTipoDocumento+''',
									'''+@vNumeroDocumento+''',
									'+@vClienteNumero+',
									'''+@vFechaDocumento+''',
									'''+@w_fechavencimiento+''',
									'''+@vMontoTotal+''',
									'+@w_totalmora+',
									'''+@vMonedaDocumento+''',
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
         End        
			END
		
		Set @vInterfase_Area = ''        
		Set @vInterfase_Descuento = ''        
		Set @vNumeroDocumento = ''        
		Set @vTipoDocumento = ''        
		Set @w_totalmora = 0        
		Set @w_mora = 0        
		Set @k = @k + 1    
	END
	
	DECLARE @Output TABLE
	(
		Estado CHAR(2),
		IdConsulta VARCHAR(15),
		CodigoProducto CHAR(3),
		NumDocumento VARCHAR(50),
		DescDocumento VARCHAR(255),
		FechaVencimiento VARCHAR(20),
		Deuda VARCHAR(12),
		Mora VARCHAR(12),
		Anio CHAR(4),
		Cuota CHAR(2),
		MonedaDoc CHAR(2),
		DesMoendaDoc VARCHAR(15),
		TotalPagar VARCHAR(15)
	)

	INSERT INTO @Output
	SELECT	
	'Estado' = 'PE',
	'IdConsulta' = @NumeroIdentidad , 
	'CodigoProducto' = @CodigoProducto, 
	'NumDocumento' = TipoDocumento + RTrim(NumeroDocumento), 
	'DescDocumento' = Descripcion, 
	'FechaVencimiento' = dbo.toMiliseconds(FechaVencimiento),
	'Deuda'= CONVERT(VARCHAR, MontoTotal ) , 
	'Mora' = CONVERT(VARCHAR,Mora ),
	'Anio' = SubString(VoucherPeriodo, 1, 4), 
	'Cuota'=Interfase_Cuota,
	'MonedaDoc' = CASE MonedaDocumento WHEN 'LO' THEN '1' WHEN 'EX' THEN '2' END,
	'DesMonedaDoc' = Case MonedaDocumento WHEN 'LO' THEN 'SOLES' WHEN 'EX' THEN 'DOLARES' END,  
	'TotalPagar'=CAST( (MontoTotal + Mora ) as varchar)
	FROM @tmpDeuda     
	UNION ALL
	SELECT
	'Estado' = 'GE',
	'IdConsulta' =@NumeroIdentidad, 
	'CodigoProducto' = @CodigoProducto, 
	'NumDocumento' = '', 
	'DescDocumento' =DescripcionLocal, 
	'FechaVencimiento' = dbo.toMiliseconds(FechaVencimiento),
	'Deuda'= Monto , 
	'Mora' = '0.00',
	'Anio' = SUBSTRING(Campania, 1, 4), 
	'Cuota'=CuotaNumero,
	'MonedaDoc' = CASE Monedacodigo WHEN 'LO' THEN '1' WHEN 'EX' THEN '2' END,
	'DesMonedaDoc' = Case Monedacodigo WHEN 'LO' THEN 'SOLES' WHEN 'EX' THEN 'DOLARES' END,
	'TotalPagar'=Monto
	FROM @tmpGestionados

	SELECT 
	TRIM(Estado),
	IdConsulta,
	TRIM(CodigoProducto),
	NumDocumento,
	DescDocumento,
	FechaVencimiento,
	Deuda,
	Mora,
	TRIM(Anio),
	TRIM(Cuota),
	TRIM(MonedaDoc),
	DescDocumento,
	TotalPagar
	FROM @Output ORDER BY FechaVencimiento ASC
	--DROP TABLE #tmpDeuda
	--DROP TABLE #tmpGestionados
	--DROP TABLE #TmpTipoCambioMast
	--DROP TABLE #tmpDescuento
END

