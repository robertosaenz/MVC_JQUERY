IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeArchivo_Obtener') DROP PROCEDURE EVA_SaeArchivo_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Registra las respuesta a las solicitudes de trámite y los archivos adjuntados.
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
DECLARE @out INT
EXEC [EVA_SaeArchivo_Obtener] 1,640
SELECT @out
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeArchivo_Obtener]
@IdArchivo int,
@EsEntornoPrueba bit
AS
BEGIN
	SET NOCOUNT ON;

	Declare @RutaEva varchar(500) = (SELECT Valor2 
										FROM Parametro P WITH (NOLOCK) 
										WHERE P.Nombre='RutaEva' AND Activo=1)+IIF(@EsEntornoPrueba=1,'test','')+'/tramites/constancias/'
	Declare @Param varchar(25)
	
	IF EXISTS(SELECT 1 FROM EVA_SAE_TramiteCaso WHERE IdArchivoEjemplo=@IdArchivo) Set @Param='ejemplos/'
	 Else
		IF EXISTS(SELECT 1 FROM EVA_SAE_TramiteCaso WHERE IdPlantillaAdjunto=@IdArchivo) Set @Param='plantillas/'
	
	SELECT DISTINCT 
	AE.Nombre,
	AE.Extension,
	AE.NombreCDN,
	ISNULL(@RutaEva+@Param+AE.NombreCDN+'.'+AE.Extension,'') AS Url
	FROM [ArchivoEVA] AE WITH(NOLOCK)
	Where AE.IdArchivo = @idArchivo
END
