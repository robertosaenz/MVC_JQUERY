IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudCARPREPRO_Obtener') DROP PROCEDURE EVA_SaeTramiteSolicitudCARPREPRO_Obtener
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Lista la informacion necesaria para reemplazar los parametros en la constancia de carta pre profesional
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudCARPREPRO_Obtener] 1
*/ 

CREATE PROCEDURE [EVA_SaeTramiteSolicitudCARPREPRO_Obtener]
	@IdTramiteSolicitud				INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
	NroRuc,
	REPLACE(RazonSocial,'&','&amp;') AS RazonSocial,
	Dirigido,
	Cargo
	FROM EVA_SAE_DetalleTramite_CARPREPRO WITH(NOLOCK)
	WHERE 
	IdTramiteSolicitud = @IdTramiteSolicitud

END