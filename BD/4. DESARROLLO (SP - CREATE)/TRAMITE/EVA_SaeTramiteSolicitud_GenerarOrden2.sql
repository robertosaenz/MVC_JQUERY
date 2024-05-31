IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_GenerarOrden2') DROP PROCEDURE EVA_SaeTramiteSolicitud_GenerarOrden2
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (24.02.2022)
--Revisado por		: SCAYCHO
--Funcionalidad		: Genera la orden de compra en las tablas temporales de spring
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT = 0
EXEC EVA_SaeTramiteSolicitud_GenerarOrden2 'BV', 562001, '00002700', 'T030000390', 1, @Output OUTPUT
SELECT @Output

DECLARE @Output INT = 0
EXEC EVA_SaeTramiteSolicitud_GenerarOrden2 'FC', 562001, '00002500', '3070700010', 1, '20999999999',NULL, 'Prueba.SAC','prueba@gmail.com','Prueba 123','01','01','01', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [EVA_SaeTramiteSolicitud_GenerarOrden2]
@TipoDocumento		CHAR(2),
@IdActor			INT,
@CompaniaSocio		CHAR(8),
@ItemCodigo			CHAR(20),
@CantidadOriginal	INT,
@NumeroDocumento    VARCHAR(20),
@IdMatricula		INT = null,
@RazonSocial		VARCHAR(100),
@CorreoElectronico	VARCHAR(100),
@Direccion			VARCHAR(100),
@Departamento		CHAR(2),
@Provincia			CHAR(2),
@Distrito			CHAR(2),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
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

	-- DYNAMIC QUERY VALUES - HEADER
	DECLARE
	--@TipoDocumento CHAR(2) = NULL,
	@FechaVenc DATETIME = NULL,
	@TipoVenta CHAR(3) = NULL,
	@TipoFacturacion CHAR(3) = NULL,
	@EstablecimientoCodigo CHAR(4) = NULL, 
	@Cliente CHAR(15) = NULL,
	@ClienteCobrarA CHAR(15) = NULL,
	@Criteria CHAR(20) = NULL,
	@Monedacodigo CHAR(2) = NULL,
	@Sucursal CHAR(4) = NULL,
	@vendedor INT = NULL,
	@FechaPreparacion DATETIME = NULL,
	@Estado CHAR(2) = NULL,
	@FlagActualizacion CHAR(1) = NULL,
	@NotaCreditoDocumento CHAR(17) = NULL,
	@Descuento CHAR(6) = NULL,
	@serie CHAR(4) = NULL,
	--@NumeroDocumento CHAR(15) = NULL,
	@CuotaNumero INT = NULL,
	@EstadoSmart VARCHAR(2) = NULL,
	@FechaRetorno DATETIME = NULL,
	@Campania CHAR(10) = NULL,
	@Periodo INT = NULL,
	@Area CHAR(2) = NULL,
	@FechaCobranza DATETIME = NULL,
	@FlagCursoCargo CHAR(1) = NULL,
	@TipoServicio CHAR(1) = NULL,
	@CondicionPago CHAR(1) = NULL,
	@FechaModificacion DATETIME = NULL,
	@NumeroInternoAnterior VARCHAR(14) = NULL,
	@CodigoAlumno INT = NULL,
	@IdTipoPromocionBeca INT = NULL,
	@IdGrupoDescuento INT = NULL,
	@Interfase_Captacion CHAR(1) = NULL,
	@CondicionMatricula CHAR(1) = NULL,
	--@CompaniaSocio CHAR(8) = NULL, 
	@TipoCliente CHAR(2) = NULL,
	@TransGratuita CHAR(1) = NULL,
	@PcAutomatico CHAR(1) = NULL
	--@RetVal INT

	-- OPERATION VALUES
	DECLARE @NumeroInterno INT
	--DECLARE @Serie CHAR(4)
	DECLARE @SerieCodigo CHAR(2)
	--DECLARE @IdMatricula INT
	DECLARE @IdSede INT
	DECLARE @IdPeriodo INT
	--DECLARE @Sucursal CHAR(4)

	SELECT TOP 1
	@IdSede = S.IdSede,
	@SerieCodigo = S.Codigo,
	@Serie = S.Serie,
	@IdPeriodo = M.IdPeriodo,
	@Sucursal = S.Sucursal 
	FROM Matricula M WITH(NOLOCK)
	left join Promocion PR On PR.IdPromocion=M.IdPromocion
	LEFT JOIN Sede S WITH(NOLOCK) ON S.IdSede = PR.IdSede
	WHERE M.IdActor = @IdActor and M.IdMatricula = @IdMatricula

	IF @IdMatricula = NULL
		BEGIN
			SET @RetVal = -51
			RETURN
		END
	IF @TipoDocumento = 'BV'  
		BEGIN  
			SET @serie = 'B' + @serie  
		END  
	IF @TipoDocumento = 'FC'  
		BEGIN  
			SET @serie = 'F' + @serie  
		END 

	DECLARE @Fecha DATETIME
	--DECLARE @FechaVenc DATETIME
	--DECLARE @Cliente INT
	DECLARE @NumeroIdentidad VARCHAR(20)
	SET @Fecha = getdate()  
	SET @FechaVenc = getdate()  
	
	SELECT 
	@NumeroIdentidad = ISNULL(NumeroIdentidad,'0')
	FROM Actor WITH (NOLOCK) WHERE IdActor=@IdActor

	IF @SerieCodigo = 'IQ'
	BEGIN
		SELECT @Cliente = Persona 
		FROM PersonaMast_ASOC WITH(NOLOCK)
		WHERE Documento = @NumeroIdentidad
	END
	ELSE
	BEGIN
		SELECT @Cliente = Persona 
		FROM PersonaMast WITH(NOLOCK)
		WHERE Documento = @NumeroIdentidad
	END

	DECLARE @MontoOriginal CHAR(10)
	DECLARE @Monto CHAR(10)
	DECLARE @TipoDetalle CHAR(1)
	DECLARE @EstadoDetalle CHAR(1)
	--SET @TipoDocumento = 'BV'  
	SET @TipoDetalle = 'S'  
	SET @EstadoDetalle = 'G'  

	IF @IdSede in (4) --@3 SEDE ICA = 3 Y CHINCHA = 22 Retirada  
		BEGIN
			SET @SQL_String = N'
			EXEC '+@LinkedServerSpringASOC+'.'+@BaseDatosSpringASOC+'.'+'dbo.usp_Interfase_P09_Header_Insert 
			@TipoDocumento_input,
			@FechaVenc_input,
			@TipoVenta_input,
			@TipoFacturacion_input,
			@EstablecimientoCodigo_input,
			@Cliente_input,
			@ClienteCobrarA_input,
			@Criteria_input,
			@Monedacodigo_input,
			@Sucursal_input,
			@vendedor_input,
			@FechaPreparacion_input,
			@Estado_input,
			@FlagActualizacion_input,
			@NotaCreditoDocumento_input,
			@Descuento_input,
			@IdMatricula_input,
			@serie_input,
			@NumeroDocumento_input,
			@CuotaNumero_input,
			@EstadoSmart_input,
			@FechaRetorno_input,
			@Campania_input,
			@Periodo_input,
			@Area_input,
			@FechaCobranza_input,
			@FlagCursoCargo_input,
			@TipoServicio_input,
			@CondicionPago_input,
			@FechaModificacion_input,
			@NumeroInternoAnterior_input,
			@CodigoAlumno_input,
			@IdTipoPromocionBeca_input,
			@IdGrupoDescuento_input,
			@Interfase_Captacion_input,
			@CondicionMatricula_input,
			@CompaniaSocio_input,
			@TipoCliente_input,
			@TransGratuita_input,
			@PcAutomatico_input,
			@RetVal_output OUTPUT'

			SET @Parameter_Definition = N'
			@TipoDocumento_input CHAR(2),
			@FechaVenc_input DATETIME,
			@TipoVenta_input CHAR(3),
			@TipoFacturacion_input CHAR(3),
			@EstablecimientoCodigo_input CHAR(4), 
			@Cliente_input CHAR(15),
			@ClienteCobrarA_input CHAR(15),
			@Criteria_input CHAR(20),
			@Monedacodigo_input CHAR(2),
			@Sucursal_input CHAR(4),
			@vendedor_input INT,
			@FechaPreparacion_input DATETIME,
			@Estado_input CHAR(2),
			@FlagActualizacion_input CHAR(1),
			@NotaCreditoDocumento_input CHAR(17),
			@Descuento_input CHAR(6),
			@IdMatricula_input INT,
			@serie_input CHAR(4),
			@NumeroDocumento_input CHAR(15),
			@CuotaNumero_input INT,
			@EstadoSmart_input VARCHAR(2),
			@FechaRetorno_input DATETIME,
			@Campania_input CHAR(10),
			@Periodo_input INT,
			@Area_input CHAR(2),
			@FechaCobranza_input DATETIME,
			@FlagCursoCargo_input CHAR(1),
			@TipoServicio_input CHAR(1),
			@CondicionPago_input CHAR(1),
			@FechaModificacion_input DATETIME,
			@NumeroInternoAnterior_input VARCHAR(14),
			@CodigoAlumno_input INT,
			@IdTipoPromocionBeca_input INT,
			@IdGrupoDescuento_input INT,
			@Interfase_Captacion_input CHAR(1),
			@CondicionMatricula_input CHAR(1),
			@CompaniaSocio_input CHAR(8),
			@TipoCliente_input CHAR(2),
			@TransGratuita_input CHAR(1),
			@PcAutomatico_input CHAR(1),
			@RetVal_output INT OUTPUT'

			--SET @TipoDocumento = 'BV'
			SET @FechaVenc = GETDATE()
			SET @TipoVenta = 'INF'
			SET @TipoFacturacion =  'CON'
			SET @EstablecimientoCodigo = ''
			--SET @Cliente = '11'
			--SET @Sucursal = 'AAA'
			SET @FechaPreparacion = GETDATE()
			SET @Estado = 'GE'
			SET @FlagActualizacion = 'N'
			SET @Descuento = '0'
			SET @serie = '11'
			SET @CuotaNumero = 1
			--SET @Periodo = 11
			SET @FlagCursoCargo = 'N'
			SET @CondicionPago = 'C'
			SET @FechaModificacion = GETDATE()
			--SET @CompaniaSocio = '12345678'


			EXECUTE sp_executesql 
			@SQL_String,
			@Parameter_Definition,
			@TipoDocumento_input=@TipoDocumento,
			@FechaVenc_input=@FechaVenc,
			@TipoVenta_input=@TipoVenta,
			@TipoFacturacion_input=@TipoFacturacion,
			@EstablecimientoCodigo_input=@EstablecimientoCodigo,
			@Cliente_input=@Cliente,
			@ClienteCobrarA_input=@ClienteCobrarA,
			@Criteria_input=@Criteria,
			@Monedacodigo_input=@Monedacodigo,
			@Sucursal_input=@Sucursal,
			@vendedor_input=@vendedor,
			@FechaPreparacion_input=@FechaPreparacion,
			@Estado_input=@Estado,
			@FlagActualizacion_input=@FlagActualizacion,
			@NotaCreditoDocumento_input=@NotaCreditoDocumento,
			@Descuento_input=@Descuento,
			@IdMatricula_input=@IdMatricula,
			@serie_input=@serie,
			@NumeroDocumento_input=@NumeroDocumento,
			@CuotaNumero_input=@CuotaNumero,
			@EstadoSmart_input=@EstadoSmart,
			@FechaRetorno_input=@FechaRetorno,
			@Campania_input=@Campania,
			@Periodo_input=@IdPeriodo,
			@Area_input=@Area,
			@FechaCobranza_input=@FechaCobranza,
			@FlagCursoCargo_input=@FlagCursoCargo,
			@TipoServicio_input=@TipoServicio,
			@CondicionPago_input=@CondicionPago,
			@FechaModificacion_input=@FechaModificacion,
			@NumeroInternoAnterior_input=@NumeroInternoAnterior,
			@CodigoAlumno_input=@CodigoAlumno,
			@IdTipoPromocionBeca_input=@IdTipoPromocionBeca,
			@IdGrupoDescuento_input=@IdGrupoDescuento,
			@Interfase_Captacion_input=@Interfase_Captacion,
			@CondicionMatricula_input=@CondicionMatricula,
			@CompaniaSocio_input=@CompaniaSocio,
			@TipoCliente_input=@TipoCliente,
			@TransGratuita_input = @TransGratuita,
			@PcAutomatico_input = @PcAutomatico,
			@RetVal_output = @NumeroInterno OUTPUT
			  
			  /*OBTENEMOS LOS PRECIOS POR SEDE*/  
			  SELECT DISTINCT @MontoOriginal = monto
			  FROM CO_Precio_ASOC WITH(NOLOCK)
			  WHERE 
			  itemCodigo =@ItemCodigo AND 
			  UnidadNegocio = @Sucursal 
		
			  SELECT @Monto = (CAST(@MontoOriginal AS DECIMAL) * @CantidadOriginal)   
   
			  EXEC 
			  (
				'
					INSERT INTO '+@LinkedServerSpringASOC+'.'+@BaseDatosSpringASOC+'.dbo.CO_Interfase_P09_Detalle
					(   
						TipoDocumento,  
						NumeroInterno,  
						secuencia,  
						TipoDetalle,  
						ItemCodigo,  
						CantidadPedida,  
						Descripcion,  
						Estado,  
						MontoOriginal,  
						Monto,  
						CantidadOriginal,  
						NumeroInternoAnterior,  
						CompaniaSocio  
				    )  
					VALUES 
					(  
						''' + @TipoDocumento + ''',  
						' + @NumeroInterno + ',  
					    1,					   
						''' +  @TipoDetalle + ''',  
						''' +  @ItemCodigo + ''',  
						' +  @CantidadOriginal + ', 
					    NULL,					
						''' +  @EstadoDetalle + ''',  
						''' +  @MontoOriginal + ''',  
						''' +  @Monto + ''',  
						' +  @CantidadOriginal + ',  
						NULL,  
						''' +  @CompaniaSocio + ''' 
					)
				'
			  )
			  SET @RetVal = @NumeroInterno  
		END
	ELSE
		BEGIN
			IF @TipoDocumento = 'FC'  
			BEGIN  
				DECLARE @PersonaEmpresa INT
				EXEC EVA_SaeTramiteDocumentoFiscal_Generar @LinkedServerSpring,@BaseDatosSpring,@NumeroDocumento,@RazonSocial,@CorreoElectronico,@Direccion,@Distrito,@Provincia,@Departamento,@PersonaEmpresa OUT
				SET @ClienteCobrarA = CONVERT(char(15),@PersonaEmpresa)
			END 

			SET @SQL_String = N'
			EXEC '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.usp_Interfase_P09_Header_Insert 
			@TipoDocumento_input,
			@FechaVenc_input,
			@TipoVenta_input,
			@TipoFacturacion_input,
			@EstablecimientoCodigo_input,
			@Cliente_input,
			@ClienteCobrarA_input,
			@Criteria_input,
			@Monedacodigo_input,
			@Sucursal_input,
			@vendedor_input,
			@FechaPreparacion_input,
			@Estado_input,
			@FlagActualizacion_input,
			@NotaCreditoDocumento_input,
			@Descuento_input,
			@IdMatricula_input,
			@serie_input,
			@NumeroDocumento_input,
			@CuotaNumero_input,
			@EstadoSmart_input,
			@FechaRetorno_input,
			@Campania_input,
			@Periodo_input,
			@Area_input,
			@FechaCobranza_input,
			@FlagCursoCargo_input,
			@TipoServicio_input,
			@CondicionPago_input,
			@FechaModificacion_input,
			@NumeroInternoAnterior_input,
			@CodigoAlumno_input,
			@IdTipoPromocionBeca_input,
			@IdGrupoDescuento_input,
			@Interfase_Captacion_input,
			@CondicionMatricula_input,
			@CompaniaSocio_input,
			@TipoCliente_input,
			@TransGratuita_input,
			@PcAutomatico_input,
			@RetVal_output OUTPUT'

			SET @Parameter_Definition = N'
			@TipoDocumento_input CHAR(2),
			@FechaVenc_input DATETIME,
			@TipoVenta_input CHAR(3),
			@TipoFacturacion_input CHAR(3),
			@EstablecimientoCodigo_input CHAR(4), 
			@Cliente_input CHAR(15),
			@ClienteCobrarA_input CHAR(15),
			@Criteria_input CHAR(20),
			@Monedacodigo_input CHAR(2),
			@Sucursal_input CHAR(4),
			@vendedor_input INT,
			@FechaPreparacion_input DATETIME,
			@Estado_input CHAR(2),
			@FlagActualizacion_input CHAR(1),
			@NotaCreditoDocumento_input CHAR(17),
			@Descuento_input CHAR(6),
			@IdMatricula_input INT,
			@serie_input CHAR(4),
			@NumeroDocumento_input CHAR(15),
			@CuotaNumero_input INT,
			@EstadoSmart_input VARCHAR(2),
			@FechaRetorno_input DATETIME,
			@Campania_input CHAR(10),
			@Periodo_input INT,
			@Area_input CHAR(2),
			@FechaCobranza_input DATETIME,
			@FlagCursoCargo_input CHAR(1),
			@TipoServicio_input CHAR(1),
			@CondicionPago_input CHAR(1),
			@FechaModificacion_input DATETIME,
			@NumeroInternoAnterior_input VARCHAR(14),
			@CodigoAlumno_input INT,
			@IdTipoPromocionBeca_input INT,
			@IdGrupoDescuento_input INT,
			@Interfase_Captacion_input CHAR(1),
			@CondicionMatricula_input CHAR(1),
			@CompaniaSocio_input CHAR(8),
			@TipoCliente_input CHAR(2),
			@TransGratuita_input CHAR(1),
			@PcAutomatico_input CHAR(1),
			@RetVal_output INT OUTPUT'

			--SET @TipoDocumento = 'BV'
			SET @FechaVenc = GETDATE()
			SET @TipoVenta = 'INF'
			SET @TipoFacturacion =  'CON'
			SET @EstablecimientoCodigo = ''
			--SET @Cliente = '11'
			--SET @Sucursal = 'AAA'
			SET @FechaPreparacion = GETDATE()
			SET @Estado = 'GE'
			SET @FlagActualizacion = 'N'
			SET @Descuento = '0'
			SET @serie = '11'
			SET @CuotaNumero = 1
			--SET @Periodo = 11
			SET @FlagCursoCargo = 'N'
			SET @CondicionPago = 'C'
			SET @FechaModificacion = GETDATE()
			--SET @CompaniaSocio = '12345678'


			EXECUTE sp_executesql 
			@SQL_String,
			@Parameter_Definition,
			@TipoDocumento_input=@TipoDocumento,
			@FechaVenc_input=@FechaVenc,
			@TipoVenta_input=@TipoVenta,
			@TipoFacturacion_input=@TipoFacturacion,
			@EstablecimientoCodigo_input=@EstablecimientoCodigo,
			@Cliente_input=@Cliente,
			@ClienteCobrarA_input=@ClienteCobrarA,
			@Criteria_input=@Criteria,
			@Monedacodigo_input=@Monedacodigo,
			@Sucursal_input=@Sucursal,
			@vendedor_input=@vendedor,
			@FechaPreparacion_input=@FechaPreparacion,
			@Estado_input=@Estado,
			@FlagActualizacion_input=@FlagActualizacion,
			@NotaCreditoDocumento_input=@NotaCreditoDocumento,
			@Descuento_input=@Descuento,
			@IdMatricula_input=@IdMatricula,
			@serie_input=@serie,
			@NumeroDocumento_input=@NumeroDocumento,
			@CuotaNumero_input=@CuotaNumero,
			@EstadoSmart_input=@EstadoSmart,
			@FechaRetorno_input=@FechaRetorno,
			@Campania_input=@Campania,
			@Periodo_input=@IdPeriodo,
			@Area_input=@Area,
			@FechaCobranza_input=@FechaCobranza,
			@FlagCursoCargo_input=@FlagCursoCargo,
			@TipoServicio_input=@TipoServicio,
			@CondicionPago_input=@CondicionPago,
			@FechaModificacion_input=@FechaModificacion,
			@NumeroInternoAnterior_input=@NumeroInternoAnterior,
			@CodigoAlumno_input=@CodigoAlumno,
			@IdTipoPromocionBeca_input=@IdTipoPromocionBeca,
			@IdGrupoDescuento_input=@IdGrupoDescuento,
			@Interfase_Captacion_input=@Interfase_Captacion,
			@CondicionMatricula_input=@CondicionMatricula,
			@CompaniaSocio_input=@CompaniaSocio,
			@TipoCliente_input=@TipoCliente,
			@TransGratuita_input = @TransGratuita,
			@PcAutomatico_input = @PcAutomatico,
			@RetVal_output = @NumeroInterno OUTPUT
			  
			  /*OBTENEMOS LOS PRECIOS POR SEDE*/  
			  SELECT DISTINCT @MontoOriginal = monto
			  FROM CO_Precio WITH(NOLOCK)
			  WHERE 
			  itemCodigo =@ItemCodigo AND 
			  UnidadNegocio = @Sucursal 
		
			  SELECT @Monto = (CAST(@MontoOriginal AS DECIMAL) * @CantidadOriginal)

			  EXEC 
			  (
				'
					INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.dbo.CO_Interfase_P09_Detalle
					(   
						TipoDocumento,  
						NumeroInterno,  
						secuencia,  
						TipoDetalle,  
						ItemCodigo,  
						CantidadPedida,  
						Descripcion,  
						Estado,  
						MontoOriginal,  
						Monto,  
						CantidadOriginal,  
						NumeroInternoAnterior,  
						CompaniaSocio  
				    )  
					VALUES 
					(  
						''' + @TipoDocumento + ''',  
						' + @NumeroInterno + ',  
					    1,					   
						''' +  @TipoDetalle + ''',  
						''' +  @ItemCodigo + ''',  
						' +  @CantidadOriginal + ', 
					    NULL,					
						''' +  @EstadoDetalle + ''',  
						''' +  @MontoOriginal + ''',  
						''' +  @Monto + ''',  
						' +  @CantidadOriginal + ',  
						NULL,  
						''' +  @CompaniaSocio + ''' 
					)
				'
			  )
			  SET @RetVal = @NumeroInterno  
		END
END
