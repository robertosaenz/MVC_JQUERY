IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeConstanciaManual_Registrar') DROP PROCEDURE EVA_SaeConstanciaManual_Registrar
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
DECLARE @Output INT
EXEC EVA_SaeConstanciaManual_Registrar 1, 1
SELECT @Output
*/
CREATE PROCEDURE [dbo].[EVA_SaeConstanciaManual_Registrar]
@IdTramiteSolicitud			INT,
@EntornoDePrueba			BIT,
@RetVal						INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE 
	@Nombre				VARCHAR(100),
	@Codigo				VARCHAR(100),
	@Actor				INT,
	@Usuario			INT,
	@Valor				VARCHAR(100),
	@Valor2				VARCHAR(100),
	@Compania			VARCHAR(8) 

	SELECT 
	@Valor = ISNULL(P.Valor,''),
	@Valor2 = ISNULL(P.Valor2,'')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre='RutaEva'

	SELECT TOP 1 @Compania= CASE CompaniaSocio WHEN '00002500' THEN 'ZEGEL' ELSE 'IDAT' END  FROM Empresa WHERE Activo=1


	SELECT 
	@Codigo=CONCAT(SUBSTRING(TRIM(T.CodigoPublico),1,2),'-',SUBSTRING(convert(varchar,dbo.toMiliseconds(GETDATE())),3,8),'-',YEAR(GETDATE()),'-', @Compania),
	@Actor = TS.IdActorSolicitante,
	@Usuario = TS.UsuarioCreacion
	FROM [EVA_SAE_TramiteSolicitud] TS WITH(NOLOCK)
	INNER JOIN [Usuario] U WITH(NOLOCK) ON U.IdActor = TS.IdActorSolicitante
	INNER JOIN [EVA_SAE_Tramite] T WITH(NOLOCK) ON TS.IdTramite = T.IdTramite
	WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud AND TS.EsAnulado = 0
	GROUP BY T.CodigoPublico,TS.IdTramite,TS.IdActorSolicitante,TS.UsuarioCreacion


	INSERT [EVA_SAE_Constancias]
	(
		CodigoPublico,
		IdAlumno,
		IdTramiteSolicitud,
		NombreArchivo,
		FechaCreacion,
		UsuarioCreacion
	)
	VALUES
	(
		@Codigo,
		@Actor,
		@IdTramiteSolicitud,
		CONCAT(@Valor2,IIF(@EntornoDePrueba=1,'test/',''),'tramites/','constancias/','temporales/',@Codigo,'.docx'),
		GETDATE(),
		@Usuario
	)

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END