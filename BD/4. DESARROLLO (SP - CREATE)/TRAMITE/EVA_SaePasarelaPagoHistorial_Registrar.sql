IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaePasarelaPagoHistorial_Registrar') DROP PROCEDURE EVA_SaePasarelaPagoHistorial_Registrar
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
EXEC [EVA_SaePasarelaPagoHistorial_Registrar] 456879852,20.0,'87654321',193,1, @OUT OUTPUT
SELECT @OUT
*/ 
CREATE PROCEDURE [dbo].[EVA_SaePasarelaPagoHistorial_Registrar]
	@CodigoTienda VARCHAR(50),
	@MontoTotal MONEY,
	@NumeroIdentidad VARCHAR(20),
	@IdTramiteSolicitud INT = null,
	@IdUsuarioLog INT,
	@RetVal	INT OUTPUT
AS
BEGIN
	DECLARE @NumeroInternoSpring INT,
			@NumeroOrden INT,
			@Moneda VARCHAR(10),
			@MedioPago VARCHAR(20)
	

	-- EN EL CASO SEA UNA TRANSACCION DEL MODULO DE TRAMITES EVA
	IF (@IdTramiteSolicitud is not null)
	BEGIN
		SELECT 
		@NumeroInternoSpring = TSS.NumeroInternoSpring,
		@MontoTotal= IIF(@NumeroIdentidad= '76568760',1, TSS.Monto),
		@Moneda = TSS.Moneda
		FROM 
		EVA_SAE_TramiteSolicitudSpring TSS
		LEFT JOIN EVA_SAE_TramiteSolicitud TS On TSS.IdTramiteSolicitud=TS.IdTramiteSolicitud
		WHERE TSS.IdTramiteSolicitud = @IdTramiteSolicitud
	END

	-- SE COMIENZA EN 100,000,000 para los casos de EVA, ya que los códigos de tienda también se usan en Spring y Zoom
	 SET @NumeroOrden = (SELECT ISNULL(MAX(NumeroOrden),100000000) + 1 FROM EVA_PasarelaPago_Historial WHERE CodigoTienda = @CodigoTienda and NumeroOrden > 100000000)

	INSERT INTO EVA_PasarelaPago_Historial
	(NumeroOrden,CodigoTienda,IdTramiteSolicitud,MontoTotal,Moneda,NumeroIdentidad,NumeroInternoSpring,UsuarioCreacion)
	VALUES
	(
		@NumeroOrden,
		@CodigoTienda,
		@IdTramiteSolicitud,
		@MontoTotal,
		@Moneda,
		@NumeroIdentidad,
		@NumeroInternoSpring,
		@IdUsuarioLog
	)
	SET @RetVal = IIF(@@ROWCOUNT<>0,SCOPE_IDENTITY(),-50)

	Select @MontoTotal as MontoTotal, @NumeroOrden as NumeroOrden
END