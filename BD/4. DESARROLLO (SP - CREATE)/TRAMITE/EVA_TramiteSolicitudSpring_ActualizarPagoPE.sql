IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_TramiteSolicitudSpring_ActualizarPagoPE') DROP PROCEDURE EVA_TramiteSolicitudSpring_ActualizarPagoPE
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
EXEC EVA_TramiteSolicitudSpring_ActualizarPagoPE
*/ 
CREATE PROCEDURE [dbo].[EVA_TramiteSolicitudSpring_ActualizarPagoPE]
@IdPasarelaPagoHistorial	INT,
@RetVal						INT OUTPUT
AS
BEGIN
	UPDATE TSS
	SEt 
	TSS.EsPagado= 1, 
	TSS.EsActualizadoSpring= 1, 
	TSS.FechaActualizacionServicio=GETDATE(),
	TSS.MedioPagoFinal = PH.MedioPago,
	TSS.MonedaFinal = PH.Moneda,
	TSS.MontoFinal = PH.MontoTotal,
	TSS.FechaPago =PH.FechaTransaccion
	FROM EVA_SAE_TramiteSolicitudSpring TSS
	INNER JOIN EVA_PasarelaPago_Historial AS PH ON PH.IdTramiteSolicitud=TSS.IdTramiteSolicitud
	WHERE PH.IdPasarelaPagoHistorial = @IdPasarelaPagoHistorial

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END




