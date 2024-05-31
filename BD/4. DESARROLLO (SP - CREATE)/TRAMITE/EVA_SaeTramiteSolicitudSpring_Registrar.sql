IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpring_Registrar') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_Registrar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Registro de estados de tramites con flujo de pago
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*

Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpring_Registrar] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpring_Registrar]
@IdTramiteSolicitud			INT,
@NumeroInternoSpring		INT,
@MedioPago					VARCHAR(200),
@EsPagado					BIT,
@ActualizadoSpring			BIT,
@ActualizadoAcademico		BIT,
@TipoDocumento				CHAR(2),
@NumeroDocumento			VARCHAR(20),
@RazonSocial				VARCHAR(100),
@CorreoElectronico			VARCHAR(100),
@Direccion					VARCHAR(100),
@Departamento				VARCHAR(100),
@Provincia					VARCHAR(100),
@Distrito					VARCHAR(100),
@IdServicioClasificacion	CHAR(20) = null,
@IdUsuario					INT,
@RetVal						INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Monto Money

select @Monto=TotalPagar from EVA_SAE_TramiteSolicitud where IdTramiteSolicitud=@IdTramiteSolicitud

	INSERT INTO EVA_SAE_TramiteSolicitudSpring
	(
		IdTramiteSolicitud,
		NumeroInternoSpring,
		MedioPago,
		EsPagado,
		Moneda,
		Monto,
		EsActualizadoSpring,
		C_TipoComprobante,
		C_Ruc,
		C_Razonsocial,
		C_Direccion,
		C_CodigoDepartamento,
		C_CodigoProvincia,
		C_CodigoDistrito,
		C_Email,
		IdServicioClasificacion,
		UsuarioCreacion
	)
	VALUES
	(
		@IdTramiteSolicitud,
		@NumeroInternoSpring,
		@MedioPago,
		@EsPagado,
		'LO',
		@Monto,
		@ActualizadoSpring,
		@TipoDocumento,
		@NumeroDocumento,
		@RazonSocial,
		@Direccion,
		@Departamento,
		@Provincia,
		@Distrito,
		@CorreoElectronico,
		@IdServicioClasificacion,
		@IdUsuario
	)

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
END
