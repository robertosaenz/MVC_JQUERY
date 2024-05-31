IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_PasarelaPagoPendientes_Listar') DROP PROCEDURE EVA_PasarelaPagoPendientes_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   :
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 
/*  
Ejemplo:
EXEC EVA_PasarelaPagoPendientes_Listar
*/ 
CREATE PROCEDURE [dbo].[EVA_PasarelaPagoPendientes_Listar]
AS
BEGIN
	SELECT
	PPH.IdPasarelaPagoHistorial,
	PPH.IdTramiteSolicitud,
	TSS.TipoDocumentoSpring,
	TSS.NroDocumentoSpring,
	TS.IdSede,
	PPH.MedioPago 
	FROM EVA_PasarelaPago_Historial PPH WITH(NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK) ON  TSS.IdTramiteSolicitud=PPH.IdTramiteSolicitud
	INNER JOIN EVA_SAE_TramiteSolicitud TS WITH(NOLOCK) ON TS.IdTramiteSolicitud=PPH.IdTramiteSolicitud
	WHERE
	PPH.Resultado=1 
	AND PPH.EsActualizadoSpring = 0 
	AND PPH.EsFinalizadoNiubiz = 1 
	AND TSS.NroDocumentoSpring IS NOT NULL 
	AND TSS.EsAnulado=0 
	AND TSS.EsActualizadoSpring=0
	AND TSS.MedioPago in ('N_TARJETA','N_PAGOE')
END

