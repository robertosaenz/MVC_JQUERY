IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_PasarelaPagoHistorial_Actualizar') DROP PROCEDURE EVA_PasarelaPagoHistorial_Actualizar
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
DECLARE @OUT INT
EXEC [EVA_PasarelaPagoHistorial_Actualizar] 
SELECT @OUT
*/ 
CREATE PROCEDURE [dbo].[EVA_PasarelaPagoHistorial_Actualizar]
--@NumeroOrden			INT,
--@IdtramiteSolicitud		INT,
@IdPasarela				INT,
@Currency				VARCHAR(100)= '',
@Terminal				VARCHAR(100)= '',
@Transaction_date		VARCHAR(100)= '',
@Action_code			VARCHAR(100)= '',
@Trace_number			VARCHAR(100)= '',
@Eci_description		VARCHAR(100)= '',
@Eci					VARCHAR(100)= '',
@Id_resolutor			VARCHAR(100)= '',
@Signature				VARCHAR(100)= '',
@Card					VARCHAR(100)= '',
@Merchand				VARCHAR(100)= '',
@Brand					VARCHAR(100)= '',
@Status					VARCHAR(100)= '',
@Action_description		VARCHAR(100)= '',
@Adquirente				VARCHAR(100)= '',
@Id_unico				VARCHAR(100)= '',
@Amount					VARCHAR(100)= '',
@Process_code			VARCHAR(100)= '',
@Transaction_id			VARCHAR(100)= '',
@Authorization_code		VARCHAR(100)= '',
@Cip					VARCHAR(100)= '',
@Correo					VARCHAR(100)= '',
@MedioPago				VARCHAR(100)= 'N_TARJETA',
@Resultado				BIT,
@EsFinalizadoNiubiz		BIT = 0,
@RetVal					INT OUTPUT
AS
BEGIN
	UPDATE EVA_PasarelaPago_Historial
	SET 
	Currency = @Currency,
	Terminal = @Terminal,
	Transaction_date  = @Transaction_date,
	Action_code = @Action_code,
	Trace_number = @Trace_number,
	Eci_description = @Eci_description,
	Eci = @Eci,
	Id_resolutor = @Id_resolutor,
	[Signature] = @Signature,
	[Card] = @Card,
	Merchant = @Merchand,
	Brand  = @Brand,
	[Status] = @Status,
	Action_description = @Action_description,
	Adquirente = @Adquirente,
	Id_unico = @Id_unico,
	Amount = @Amount,
	Process_code = @Process_code,
	Transaction_id = @Transaction_id,
	Authorization_code = @Authorization_code,
	Cip = @Cip,
	UsuarioModificacion = 1,
	FechaModificacion = GETDATE(),
	Correo = @Correo,
	MedioPago = @MedioPago,
	Resultado = @Resultado,
	EsFinalizadoNiubiz = @EsFinalizadoNiubiz,
	FechaTransaccion = IIF(@MedioPago ='N_TARJETA', GETDATE(), FechaTransaccion)
	WHERE IdPasarelaPagoHistorial = @IdPasarela

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END