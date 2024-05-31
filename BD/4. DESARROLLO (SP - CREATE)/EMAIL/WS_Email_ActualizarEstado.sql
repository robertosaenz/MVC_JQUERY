USE BDSMTP
GO
IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'WS_Email_ActualizarEstado') DROP PROCEDURE WS_Email_ActualizarEstado
GO 
-------------------------------------------------------------------------------  
--Creado por      : Rsaenz (23/09/2021)      
--Revisado por    :  
--Funcionalidad   : 
--Utilizado por   : EMAIL  
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/ 

/*
Ejemplo:
DECLARE @out INT
EXEC [WS_Email_ActualizarEstado] 1 ,@out OUT
SELECT @out
*/  
CREATE PROCEDURE [dbo].[WS_Email_ActualizarEstado]
@IdCorreo INT,
@RetVal INT OUTPUT
AS
BEGIN
	UPDATE WS_EnvioCorreoAutomatico
	SET 
	Estado = 1,
	FechaEnvio= GETDATE() 
	WHERE IdCorreo = @IdCorreo

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END