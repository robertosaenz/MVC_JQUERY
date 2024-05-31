IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpring_ActualizarDatosSpring') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_ActualizarDatosSpring
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
EXEC [EVA_SaeTramiteSolicitudSpring_ActualizarDatosSpring] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpring_ActualizarDatosSpring]
@IdTramiteSolicitud			INT,
@MedioPagoFinal				VARCHAR(200),
@MontoFinal					MONEY,
@MonedaFinal				VARCHAR(20),
@TipoDocumentoSpring		VARCHAR(10),
@NroDocumentoSpring			VARCHAR(30),
@FechaPago					BIGINT,
@RetVal						INT OUTPUT
AS
BEGIN

SET DATEFORMAT MDY 
	SET NOCOUNT ON 
	UPDATE EVA_SAE_TramiteSolicitudSpring
	SET
	MedioPagoFinal = @MedioPagoFinal,
	EsPagado = 1,
	MontoFinal = @MontoFinal,
	MonedaFinal = @MonedaFinal,
	FechaPago =dbo.toDatetime(@FechaPago),
	EsActualizadoSpring = 1,
	FechaActualizacionServicio = GETDATE(),
	UsuarioModificacion = 1,
	FechaModificacion = GETDATE()
	WHERE 
	IdTramiteSolicitud = @IdTramiteSolicitud

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END


