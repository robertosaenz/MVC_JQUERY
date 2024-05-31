IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeArchivoMasivo_Guardar') DROP PROCEDURE EVA_SaeArchivoMasivo_Guardar
GO 
-------------------------------------------------------------------------------  
--Creado por      : Rsaenz (23/09/2021)      
--Revisado por    : Rsaenz (29/04/2022) 
--Funcionalidad   : Guardar masivo en la tabla ArchivoEVA
--Utilizado por   : EVA  
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/ 

/*
Ejemplo:
EXEC [EVA_SaeArchivoMasivo_Guardar] 'a1,png,a1|a2,png,a2|a3,png,a3',763701
EXEC [EVA_SaeArchivoMasivo_Guardar] 'Convenio de Prácticas Pre  PROFESIONALES - GOMEZ GODOY JIMMY (1)[1401] (1),png,cef86079-637b-4e90-93b9-15192783313f',309195
*/  
CREATE PROCEDURE [dbo].[EVA_SaeArchivoMasivo_Guardar]
	@Archivos			VARCHAR(MAX),
	@IdUsuario			INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Foraneas				TABLE (Fk1 INT);
	DECLARE @Ids					VARCHAR(MAX)

	INSERT INTO ArchivoEVA
	(Nombre,Extension,NombreCDN,UsuarioCreacion,FechaCreacion)
	OUTPUT inserted.IdArchivo INTO @Foraneas 
	SELECT 
	LEFT(items, CHARINDEX(',', items) - 1),
	SUBSTRING(items, CHARINDEX(',', items)+1, LEN(items) - CHARINDEX(',', REVERSE(items)) - CHARINDEX(',', items)),
	REVERSE(LEFT(REVERSE(items), CHARINDEX(',', REVERSE(items)) - 1)),
	@IdUsuario,
	GETDATE() 
	FROM dbo.udf_Split(@Archivos,'|')

	SELECT STRING_AGG(Fk1, ',') AS IdsArchivos FROM @Foraneas
END