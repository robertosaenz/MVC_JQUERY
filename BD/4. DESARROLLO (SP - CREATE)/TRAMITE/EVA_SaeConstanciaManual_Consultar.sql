IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeConstanciaManual_Consultar') DROP PROCEDURE EVA_SaeConstanciaManual_Consultar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (09.05.2022)
--Revisado por		: 
--Funcionalidad		: 
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:

EXEC EVA_SaeConstanciaManual_Consultar 1, 1

*/
CREATE PROCEDURE [dbo].[EVA_SaeConstanciaManual_Consultar]
@IdTramiteSolicitud			INT,
@EntornoDePrueba			BIT
AS
BEGIN
	DECLARE @Valor		VARCHAR(100)
	DECLARE @Valor2		VARCHAR(100)

	SELECT 
	@Valor=ISNULL(P.Valor,''),
	@Valor2=ISNULL(P.Valor2,'')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre='RutaEva'


	IF NOT EXISTS (SELECT IdTramiteSolicitud,CodigoPublico,NombreArchivo FROM EVA_SAE_Constancias C WHERE IdTramiteSolicitud = @IdTramiteSolicitud)
	BEGIN
		SELECT
		-51 AS IdTramiteSolicitud,
		'' AS CodigoPublico,
		'' AS NombreArchivo,
		'' AS NombreArchivoCDN
	END
	ELSE
	BEGIN
		SELECT 
		IdTramiteSolicitud,
		CodigoPublico,
		CONCAT(@Valor,IIF(@EntornoDePrueba=1,'test/',''),'tramites/','constancias/','temporales/',CodigoPublico,'.docx') AS NombreArchivo,
		CONCAT(@Valor,IIF(@EntornoDePrueba=1,'test/',''),'tramites/','constancias/','temporales/',CodigoPublico,'.docx') AS NombreArchivoCDN
		FROM EVA_SAE_Constancias C 
		WHERE IdTramiteSolicitud = @IdTramiteSolicitud
	END
	
END
