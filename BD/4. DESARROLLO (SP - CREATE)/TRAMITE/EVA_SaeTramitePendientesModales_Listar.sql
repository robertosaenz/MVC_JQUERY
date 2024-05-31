IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramitePendientesModales_Listar') DROP PROCEDURE EVA_SaeTramitePendientesModales_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Ahurtado (29/03/2022)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Listar solicitudes de trámites pendientes en modales
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramitePendientesModales_Listar] 'rec'
*/ 

CREATE PROCEDURE [EVA_SaeTramitePendientesModales_Listar]
	@IdActor	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
	S.IdTramiteSolicitud, 
	T.Nombre 
	FROM EVA_SAE_TramiteSolicitud S
	INNER JOIN EVA_SAE_Tramite T on T.IdTramite = S.IdTramite
	INNER JOIN EVA_SAE_TramiteSolicitudSpring TS on S.IdTramiteSolicitud=TS.IdTramiteSolicitud AND EsPagado=1
	WHERE IdActorSolicitante = @IdActor AND idProgramacionDetalle IS NULL
END