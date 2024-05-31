IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteRequisito_Inactivar') DROP PROCEDURE EVA_SaeTramiteRequisito_Inactivar
GO 
--------------------------------------------------------------------------------          
--Creado por      : Rsaenz (24/11/2021)    
--Revisado por    : Rsaenz (29/04/2022)    
--Funcionalidad   : Inactivar Requisitos   
--Utilizado por   : EVA    
-------------------------------------------------------------------------------       
/*      
-----------------------------------------------------------------------------    
Nro  FECHA   USUARIO     DESCRIPCION    
-----------------------------------------------------------------------------    
*/  

/*      
Ejemplo:    
DECLARE @RetVal	INT    
EXEC [EVA_SaeTramiteRequisito_Inactivar] 1,1,309195, @RetVal OUT    
SELECT @RetVal	    
*/  
CREATE PROCEDURE [EVA_SaeTramiteRequisito_Inactivar]
	@IdTramite				INT,
	@IdRequisito			INT,
	@IdCaso					INT,
	@IdUsuario				INT,
	@EsActivo				BIT,
	@RetVal					INT OUT  
AS  
BEGIN  
	SET NOCOUNT ON;

	IF (@IdCaso IS NULL)
	BEGIN
		UPDATE [EVA_SAE_TramiteRequisito]
		SET 
		EsActivo = @EsActivo,
		UsuarioModificacion = @IdUsuario,
		FechaModificacion = GETDATE()
		WHERE 
		IdTramite= @IdTramite 
		AND IdRequisito = @IdRequisito
		AND IdCaso IS NULL
	END
	ELSE
	BEGIN
		UPDATE [EVA_SAE_TramiteRequisito]
		SET 
		EsActivo = @EsActivo,
		UsuarioModificacion = @IdUsuario,
		FechaModificacion = GETDATE()
		WHERE 
		IdTramite= @IdTramite 
		AND IdRequisito = @IdRequisito
		AND IdCaso = @IdCaso
	END

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
END

