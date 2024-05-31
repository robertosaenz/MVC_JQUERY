IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_PasarelaPagoHistorial_ActualizarSpring') DROP PROCEDURE EVA_PasarelaPagoHistorial_ActualizarSpring
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
EXEC [EVA_PasarelaPagoHistorial_ActualizarSpring]
*/
CREATE PROCEDURE [dbo].[EVA_PasarelaPagoHistorial_ActualizarSpring]
AS
BEGIN
	SET XACT_ABORT ON;

	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @BaseDatosSpring varchar(50)

	DECLARE @Indice INT
	DECLARE @Cantidad INT

	DECLARE 
	@IdPasarelaPagoHistorial INT,
	@TipoDocumentoSpring VARCHAR(20),
	@NroDocumentoSpring VARCHAR(20),
	@CodigoTienda INT,
	@NumeroOrden INT,
	@Descripcion VARCHAR(50),
	@FechaVen VARCHAR(20),
	@MonedaDocPendiente INT,
	@Monto DECIMAL,
	@Signature VARCHAR(200),
	@NroPedido INT,
	@Action_Code VARCHAR(20),
	@Id_unico  VARCHAR(50),
	@Action_description VARCHAR(200),
	@FechaTransaccion DATEtIME,
	@Resultado INT,
	@MontoTotal DECIMAL,
	@DNI VARCHAR(8),
	@Card VARCHAR(100),
	@Cip INT,
	@IdSede INT

	DECLARE @Temptable TABLE
	(
		Id INT IDENTITY(1,1),
		IdPasarelaPagoHistorial INT,
		TipoDocumentoSpring VARCHAR(20),
		NroDocumentoSpring VARCHAR(20),
		CodigoTienda INT,
		NumeroOrden INT,
		Descripcion VARCHAR(50),
		FechaVen DATETIMe,
		MonedaDocPendiente INT,
		Monto DECIMAL,
		Signature VARCHAR(200),
		NroPedido INT,
		Action_Code VARCHAR(20),
		Id_unico  VARCHAR(50),
		Action_description VARCHAR(200),
		FechaTransaccion DATEtIME,
		Resultado INT,
		MontoTotal DECIMAL,
		DNI VARCHAR(8),
		Card VARCHAR(100),
		Cip INT,
		IdSede INT
	)

	INSERT INTO @Temptable
	(
		IdPasarelaPagoHistorial,
		TipoDocumentoSpring,
		NroDocumentoSpring,
		CodigoTienda,
		NumeroOrden,
		Descripcion,
		FechaVen,
		MonedaDocPendiente,
		Monto,
		Signature,
		NroPedido,
		Action_Code,
		Id_unico,
		Action_description,
		FechaTransaccion,
		Resultado,
		MontoTotal,
		DNI,
		Card,
		Cip,
		IdSede
	)

	SELECT 
	TOP 1
	PPH.IdPasarelaPagoHistorial,
	TSS.TipoDocumentoSpring,
	TSS.NroDocumentoSpring,
	CodigoTienda,
	NumeroOrden, 
	T.Nombre AS Descripcion,
	GETDATE() as FechaVen, 
	1 as MonedaDocPendiente,
	TSS.Monto,
	PPH.Signature,
	NumeroOrden as NroPedido,
	Action_code,
	Id_unico,
	Action_description,
	FechaTransaccion,
	Resultado,
	PPH.MontoTotal, 
	PPH.NumeroIdentidad as DNI,
	Card,
	Cip,
	TS.IdSede
	FROM EVA_PasarelaPago_Historial PPH
	INNER join EVA_SAE_TramiteSolicitudSpring TSS ON TSS.IdTramiteSolicitud=PPH.IdTramiteSolicitud AND TSS.NroDocumentoSpring IS NOT NULL
	INNER JOIN EVA_SAE_TramiteSolicitud TS ON TS.IdTramiteSolicitud = PPH.IdTramiteSolicitud
	INNER JOIN EVA_SAE_Tramite T ON T.IdTramite = TS.IdTramite
	WHERE 
	EsInsertadoPPSpring = 0
	AND IdSede <> 4
	AND ((PPH.MedioPago='N_TARJETA') OR (PPH.MedioPago='N_PAGOE' and PPH.Status in ('Expired','Paid')))

	SET @Cantidad= @@ROWCOUNT
	SET @Indice = 1

	WHILE (@Indice <= @Cantidad)    
	BEGIN
		SELECT 
		@IdPasarelaPagoHistorial = IdPasarelaPagoHistorial,
		@TipoDocumentoSpring = TipoDocumentoSpring,
		@NroDocumentoSpring = NroDocumentoSpring,
		@CodigoTienda = CodigoTienda ,
		@NumeroOrden = NumeroOrden,
		@Descripcion = Descripcion,
		@FechaVen = Convert(VARCHAR(20),fechaVen,103),
		@MonedaDocPendiente = MonedaDocPendiente,
		@Monto = Monto,
		@Signature = Signature,
		@NroPedido = NroPedido,
		@Action_Code = Action_Code,
		@Id_unico = Id_unico,
		@Action_description = Action_description,
		@FechaTransaccion = FechaTransaccion,
		@Resultado = Resultado,
		@MontoTotal = MontoTotal,
		@DNI = DNI,
		@Card = Card,
		@Cip = Cip,
		@IdSede = IdSede
		FROM @Temptable
		WHERE Id = @Indice

		SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = IIF(@IdSede='4','ServidorVinculadoSpringASOC','ServidorVinculadoSpring')

		EXEC
		(
			'
			BEGIN TRY 
				BEGIN TRANSACTION
				IF NOT EXISTS(SELECT NumeroOrden FROM  '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PasarelaPago WHERE NumeroOrden = '+@NumeroOrden+' AND CodigoTienda = '''+@CodigoTienda+''')
				BEGIN
					INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PasarelaPago
					(  
						CodigoTienda,  
						NumeroOrden,  
						Eticket,  
						Resultado,  
						MontoTotal,  
						NumeroIdentidad,  
						FechaCreacion,
						FechaHoraTransaccion,
						IdUnico,
						CodigoAccion,
						DscCodigoAccion,
						IdPedido
					)  
					VALUES 
					(  
						'+@CodigoTienda+',  
						'+ @NumeroOrden+',  
						'''+@Signature+''',  
						'+@Resultado+',  
						'+@MontoTotal+',  
						'''+@DNI+''',  
						GETDATE(),
						'''+@FechaTransaccion+''',
						'''+@Id_unico+''',
						'''+@Action_Code+''',
						'''+@Action_description+''',
						'+ @NumeroOrden+'  
					)  
			
					INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PasarelaPagoDocumento
					(
						CodigoTienda,
						NumeroOrden,
						NumDocumento,
						DescDocumento,
						FechaVencimiento,
						MonedaDoc,
						Deuda,
						Mora,
						TotalPagar,
						FechaCreacion
					)
					VALUES 
					(
						'+@CodigoTienda+',
						'+@NumeroOrden+',
						'''+@TipoDocumentoSpring+@NroDocumentoSpring+''',
						'''+@Descripcion+''',
						'''+@FechaVen+''',
						'+@MonedaDocPendiente+',
						0,
						0,
						'+@MontoTotal+',
						GETDATE()
					)

					UPDATE EVA_PasarelaPago_Historial SET EsInsertadoPPSpring = 1, FechaInsertadoPPSpring = GETDATE()
					WHERE IdPasarelaPagoHistorial = '+@IdPasarelaPagoHistorial+'

					IF(@@ROWCOUNT = 0)
					BEGIN
						ROLLBACK TRANSACTION
						EXEC EVA_Log_Registrar ''Tramite PP Spring Actualizar'',''Job EVA'',''Error'',''No se actualizo Pasarela Pago Historial'','+@IdPasarelaPagoHistorial+'
					END
				END
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessage VARCHAR(MAX)
				SELECT  @ErrorMessage = ERROR_MESSAGE()

				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION

				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION

				EXEC EVA_Log_Registrar ''Tramite PP Spring Actualizar'',''Job EVA'',''Error'',@ErrorMessage,'+@IdPasarelaPagoHistorial+'
			END CATCH
			'
		)
		SET @Indice = @Indice + 1
		Select @NumeroOrden
	END
END

