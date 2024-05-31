IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteRequisito_Agregar') DROP PROCEDURE EVA_SaeTramiteRequisito_Agregar
GO 
--------------------------------------------------------------------------------          
--Creado por      : Rsaenz (24/11/2021)    
--Revisado por    : Rsaenz (29/04/2022)    
--Funcionalidad   : Asociar requisitos a trámites   
--Utilizado por   : EVA    
-------------------------------------------------------------------------------       
/*      
-----------------------------------------------------------------------------    
Nro  FECHA   USUARIO     DESCRIPCION    
-----------------------------------------------------------------------------    
*/  

/*      
Ejemplo:    
DECLARE @RetVal int    
 EXEC [EVA_SaeTramiteRequisito_Agregar] 17,11,184948,3, @RetVal OUT    
SELECT @RetVal    
*/ 
CREATE PROCEDURE [EVA_SaeTramiteRequisito_Agregar]
	@IdTramite				INT,
	@IdRequisito			INT,
	@IdUsuario				INT,
	@IdCaso					INT,
	@RetVal					INT OUT  
AS  
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
	(
		SELECT 
		IdTramite,
		IdRequisito,
		IdCaso
		FROM [EVA_SAE_TramiteRequisito] TR WITH(NOLOCK) 
		WHERE TR.IdTramite = @IdTramite AND TR.IdRequisito = @IdRequisito AND TR.IdCaso=@IdCaso AND TR.EsActivo = 0
	)
		BEGIN 
			UPDATE [EVA_SAE_TramiteRequisito]
			SET 
			EsActivo = 1,
			UsuarioModificacion = @IdUsuario,
			FechaModificacion = GETDATE()
			WHERE 
			IdTramite = @IdTramite 
			AND IdRequisito = @IdRequisito
			AND IdCaso = @IdCaso

			SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
		END
	ELSE
		BEGIN
			DECLARE @Orden INT

			SELECT
			@Orden = COUNT(*) + 1
			FROM EVA_SAE_TramiteRequisito TR WITH (NOLOCK)
			WHERE
			TR.IdTramite = @IdTramite

			INSERT INTO [EVA_SAE_TramiteRequisito]
			(IdTramite,IdRequisito,EsActivo,UsuarioCreacion,FechaCreacion, IdCaso, Orden)
			VALUES
			(@IdTramite,@IdRequisito,1,@IdUsuario,GETDATE(), @IdCaso, @Orden)
			SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
		END
END