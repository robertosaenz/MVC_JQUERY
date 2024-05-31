IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeComprobante_Obtener') DROP PROCEDURE EVA_SaeComprobante_Obtener
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (23.09.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene el detalle de un pago efectuado de un alumno
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeComprobante_Obtener 'BV', '010-0003378'
*/

CREATE PROCEDURE [dbo].[EVA_SaeComprobante_Obtener]
@TipoDocumento CHAR(2),
@NumeroDocumento VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
	CASE 
	WHEN TipoDocumento = 'BV' THEN 'Boleta de Venta'
	WHEN TipoDocumento = 'FC' THEN 'Factura'
	ELSE TipoDocumento END AS TipoDocumento,
	FechaDocumento,
	ClienteNombre,
	ClienteRuc,
	ClienteDireccion,
	MontoTotal
	--FROM PLDBTEST02.SpringPruebaSEE_Diario.dbo.CO_Documento
	FROM CO_Documento D WITH (NOLOCK)
	WHERE
	D.TipoDocumento = @TipoDocumento 
	AND D.NumeroDocumento = @NumeroDocumento

	SELECT
	DD.Descripcion,
	DD.UnidadCodigo,
	DD.CantidadPedida,
	DD.Monto
	FROM CO_DocumentoDetalle DD WITH (NOLOCK)
	WHERE
	DD.TipoDocumento = @TipoDocumento 
	AND DD.NumeroDocumento = @NumeroDocumento
END


