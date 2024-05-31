IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpring_Actualizar') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_Actualizar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : ahurtado (03/05/2022)
--Funcionalidad   : Actualiza la informacion de pago de una solicitud  de Trámite, via Job asociado a Spring o directamente desde EVA
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*

Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpring_Actualizar] 1,'100',1,'121221',null
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitudSpring_Actualizar
@IdTramiteSolicitud	INT,
@MedioPago			VARCHAR(200),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	
	UPDATE EVA_SAE_TramiteSolicitudSpring
	SET
	MedioPago = @MedioPago
	WHERE
	IdTramiteSolicitud = @IdTramiteSolicitud

	SET @RetVal = IIF(@@ROWCOUNT = 0, -51, -1)
END