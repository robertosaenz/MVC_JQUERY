IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE TYPE = 'P'
  AND NAME = 'EVA_PasarelaPagoHistorial_SmartMobileActualizar')
  DROP PROCEDURE EVA_PasarelaPagoHistorial_SmartMobileActualizar
GO
CREATE PROCEDURE [EVA_PasarelaPagoHistorial_SmartMobileActualizar]
@Cip VARCHAR(100),
@Status VARCHAR(20),
@Amount VARCHAR(10),
@OperationNumber VARCHAR(50),
@CompaniaSocio VARCHAR(20),
@RetVal INT OUTPUT
AS
BEGIN
	-- 0 Ninguna Accion se realizo
	-- 1 update
	-- 2 updated
	DECLARE @ContadorExistencia INT
	DECLARE @ContadorExistenciaFINAL INT

	SELECT @ContadorExistencia = COUNT(Cip) FROM EVA_PasarelaPago_Historial WHERE Cip=@Cip
	SELECT @ContadorExistenciaFINAL = COUNT(Cip) FROM EVA_PasarelaPago_Historial WHERE Cip=@Cip and EsFinalizadoNiubiz=1 

	IF(@ContadorExistencia <> 0)
	BEGIN
		IF(@ContadorExistenciaFINAL<>0)
		BEGIN
			SET @RetVal = 2
		END
		ELSE
		BEGIN
			UPDATE EVA_PasarelaPago_Historial 
			SET 
			Signature=@OperationNumber,
			Status=@Status,
			Action_description=@Status,
			Resultado= IIF(@Status = 'Paid', 1,0),
			Amount=@amount,
			FechaTransaccion = GETDATE(),
			EsFinalizadoNiubiz = 1
			WHERE Cip=@Cip and EsFinalizadoNiubiz=0

			SET @RetVal = IIF(@@ROWCOUNT<>0,1,0)
		END
	END
	ELSE
	BEGIN
		SET @RetVal = 3
	END
END