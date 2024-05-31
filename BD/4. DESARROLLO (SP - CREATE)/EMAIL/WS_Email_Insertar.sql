IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'WS_Email_Insertar') DROP PROCEDURE WS_Email_Insertar
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
DECLARE @rpta INT = 0
EXEC [WS_Email_Insertar] 'EVA IDAT', 'rsaenz@inlearning.edu.pe' ,'Asunto', 'Mensaje','HTML', @rpta out
SELECT @rpta 
*/  
CREATE PROCEDURE [dbo].[WS_Email_Insertar]
@CodigoRemitente	VARCHAR(20),
@Destinatario		VARCHAR(MAX),
@Asunto				VARCHAR(255),
@Mensaje			VARCHAR(MAX),
@FormatoMensaje		VARCHAR(20),
@RetVal INT OUTPUT
AS
BEGIN
	INSERT INTO BDSMTP.dbo.WS_EnvioCorreoAutomatico 
	(
		CodigoRemitente,
		Destinatario,
		Asunto,
		Mensaje,
		FormatoMensaje,
		FechaPublicacion
	)
	VALUES
	(
		@CodigoRemitente,
		@Destinatario,
		@Asunto,
		@Mensaje,
		@FormatoMensaje,
		GETDATE()
	)
	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END