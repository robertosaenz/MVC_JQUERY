IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SAE_PasarelaPagoHistorial_Registrar') DROP PROCEDURE EVA_SAE_PasarelaPagoHistorial_Registrar
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
EXEC [EVA_SAE_PasarelaPagoHistorial_Registrar] 182,'TICKET','BANCO', @OUT OUTPUT
SELECT @OUT
*/ 
CREATE PROCEDURE [dbo].[EVA_SAE_PasarelaPagoHistorial_Registrar]
@IdTramiteSolicitud INT,    
@Eticket VARCHAR(50),    
@MedioPago VARCHar(200),
@RetVal			INT OUTPUT
AS
BEGIN
	DECLARE @CodigoTienda VARCHAR(50)
	DECLARE @NumeroInterno INT
	DECLARE @Monto MONEY

	SELECT 
	@NumeroInterno = TSS.NumeroInternoSpring,
	@Monto= TSS.Monto,
	@CodigoTienda = Substring(Descripcion, 0, Charindex('|', Descripcion)) 
	FROM 
	EVA_SAE_TramiteSolicitudSpring TSS
	INNER JOIN ParametroEmpresa PE ON PE.Nombre = 'EVA_NIUBIZ'
	WHERE IdTramiteSolicitud = @IdTramiteSolicitud

	INSERT INTO EVA_PasarelaPago_Historial
	(IdTramiteSolicitud,NumeroInternoSpring,MedioPago,CodigoTienda,MontoTotal)
	VALUES
	(
		@IdTramiteSolicitud,
		@NumeroInterno,
		@MedioPago,
		@CodigoTienda,
		@Monto
	)
	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
END