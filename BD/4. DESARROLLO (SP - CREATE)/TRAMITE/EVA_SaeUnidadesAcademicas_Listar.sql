IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeUnidadesAcademicasAgr_Listar') DROP PROCEDURE EVA_SaeUnidadesAcademicasAgr_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Miler Rodriguez (07.07.2022)
--Revisado por		: Miler Rodriguez
--Funcionalidad		: Obtiene Las Unidades Academicas y su relacion con la Tabla de Agrupacion
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
ID		CODIGO			NOMBRE			IDAGRUPACION
--------------------------------------------------------------------------------
*/
/*  
Ejemplo:
EXEC EVA_SaeUnidadesAcademicas_Listar
*/
CREATE PROCEDURE [EVA_SaeUnidadesAcademicasAgr_Listar]
AS
BEGIN
	SET NOCOUNT ON
	SELECT 
		'Id'=UA.IdUnidadAcademica
		,'Codigo'=ISNULL(UA.Codigo,'')
		,'Nombre'=ISNULL(UA.Nombre,'')
		,'IdAgrupacion'=UAA.IdAgrupacion
	FROM UnidadAcademica UA WITH (NOLOCK)
		LEFT JOIN EVA_SAE_UnidadAcademicaAgrupacion UAA WITH (NOLOCK)
	ON UA.IdUnidadAcademica = UAA.IdUnidadAcademica
	WHERE UA.Activo=1

	SELECT 
		IdMaestroRegistro, 
		Nombre
	FROM MaestroTablaRegistro WITH (NOLOCK)
	WHERE IdMaestroTabla IN (
	SELECT 
		IdMaestroTabla 
	FROM maestroTabla 
	WHERE Codigo='EvaSaeUniAcaAgr' )
END