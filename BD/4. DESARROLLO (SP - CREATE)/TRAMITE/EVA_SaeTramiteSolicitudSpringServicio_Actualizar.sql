IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpringServicio_Actualizar') DROP PROCEDURE EVA_SaeTramiteSolicitudSpringServicio_Actualizar
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
EXEC [EVA_SaeTramiteSolicitudSpringServicio_Actualizar] 1
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpringServicio_Actualizar]
@IdTramiteSolicitud			INT,
@RetVal						INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE EVA_SAE_TramiteSolicitudSpring
	SET
	EsActualizadoSpring = 1,
	FechaActualizacionServicio = GETDATE()
	WHERE 
	IdTramiteSolicitud = @IdTramiteSolicitud

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END

