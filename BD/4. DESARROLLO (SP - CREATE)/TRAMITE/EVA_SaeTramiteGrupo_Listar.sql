IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteGrupo_Listar') DROP PROCEDURE EVA_SaeTramiteGrupo_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Listar los trámites a partir de su grupo
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteGrupo_Listar] 14, 1
*/ 

CREATE PROCEDURE [EVA_SaeTramiteGrupo_Listar]
	@IdTramiteGrupo	INT,
	@EntornoDePrueba BIT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
	Nombre,
	Descripcion,
	IdArchivoPortada
	FROM
	EVA_SAE_Tramite ST WITH(NOLOCK)
	WHERE 
	ST.IdTramite = @IdTramiteGrupo
	AND ST.EsGrupo = 1

	SELECT
	ST.IdTramite,
	ST.Nombre,
	ST.DescripcionGrupo,
	ST.HoraVencimiento
	FROM
	EVA_SAE_Tramite ST WITH(NOLOCK)
	WHERE 
	ST.IdTramiteGrupo = @IdTramiteGrupo
END
