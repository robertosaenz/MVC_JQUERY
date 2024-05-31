IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaePagosIdentidadDocumento_Obtener') DROP PROCEDURE EVA_SaePagosIdentidadDocumento_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Obtiene el DNI asociado al Actor
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaePagosIdentidadDocumento_Obtener] 763701
*/ 
CREATE PROCEDURE [dbo].[EVA_SaePagosIdentidadDocumento_Obtener]
@IdActor int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT 
	A.IdDocumentoTipo,
	A.NumeroIdentidad
	FROM [Actor] A WITH(NOLOCK)
	WHERE A.IdActor = @IdActor
END
