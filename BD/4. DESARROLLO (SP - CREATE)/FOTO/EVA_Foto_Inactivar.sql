IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_Foto_Inactivar') DROP PROCEDURE EVA_Foto_Inactivar
GO
------------------------------------------------------------------------------  
--Creado por      : Almendra Laureano (23/05/2022)
--Revisado por    : 
--Funcionalidad   : Inactiva el campo selecionado
--Utilizado por   : EVA
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/

/* 
Ejemplo:

	DECLARE @rpta INT = 0
	EXEC [EVA_Foto_Inactivar] 1, @rpta out
	SELECT @rpta 
*/

CREATE PROCEDURE [EVA_Foto_Inactivar]
@IdFoto	INT,
@RetVal INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT*FROM EVA_Foto WHERE IdFoto=@IdFoto AND EsActivo=1) Begin
		UPDATE  EVA_Foto
		SET EsActivo=0
		WHERE IdFoto=@IdFoto
		SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
	END
	ELSE
		SET @RetVal = -51

END
GO