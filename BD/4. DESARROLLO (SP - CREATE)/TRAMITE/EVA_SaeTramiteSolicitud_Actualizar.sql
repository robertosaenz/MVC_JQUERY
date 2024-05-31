IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitud_Actualizar') DROP PROCEDURE EVA_SaeTramiteSolicitud_Actualizar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Registro de estados de tramites con flujo de pago
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*

Ejemplo:
EXEC [EVA_SaeTramiteSolicitud_Actualizar] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitud_Actualizar]
@IdTramiteSolicitud			INT,
@RetVal						INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE EVA_SAE_TramiteSolicitud
	SET
	IdEstado = 3
	WHERE 
	IdTramiteSolicitud = @IdTramiteSolicitud
	AND EsAnulado = 0

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END
