IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_PasarelaPagoPendientes_Actualizar') DROP PROCEDURE EVA_PasarelaPagoPendientes_Actualizar
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
EXEC EVA_PasarelaPagoPendientes_Actualizar
*/ 
CREATE PROCEDURE [dbo].[EVA_PasarelaPagoPendientes_Actualizar]
@IdPasarelaPagoHistorial	INT,
@RetVal						INT OUTPUT
AS
BEGIN
	UPDATE EVA_PasarelaPago_Historial
	SET 
	EsActualizadoSpring = 1,
	FechaActualizacionSpring = GETDATE()
	WHERE IdPasarelaPagoHistorial=@IdPasarelaPagoHistorial

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END