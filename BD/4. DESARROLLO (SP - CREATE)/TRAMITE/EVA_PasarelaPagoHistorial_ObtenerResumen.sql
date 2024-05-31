IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_PasarelaPagoHistorial_ObtenerResumen') DROP PROCEDURE EVA_PasarelaPagoHistorial_ObtenerResumen
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (14.06.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene el registro de pasarela pago historial relacionado con el registro de Niubiz
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_PasarelaPagoHistorial_ObtenerResumen 2, 566105
*/

CREATE PROCEDURE EVA_PasarelaPagoHistorial_ObtenerResumen
@IdPasarelaPagoHistorial	INT,
@IdActor					INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
	PPH.NumeroOrden,
	PPH.IdTramiteSolicitud,
	PPH.Resultado,
	PPH.Cip,
	PPH.Card,
	PPH.Brand,
	PPH.Action_description,
	dbo.toMiliseconds(PPH.FechaCreacion) AS FechaCreacion,
	T.Nombre,
	TSS.MedioPago,
	IIF(TSS.MedioPago = 'N_TARJETA', 'Con Tarjeta', 'Pago Efectivo') AS TipoPago,
	IIF(TSS.MedioPago = 'N_TARJETA', IIF(PPH.Resultado = 1, 'Pagado con exito', 'Rechazado'), 'Pendiente de pago') AS Estado,
	dbo.toMiliseconds(DATEADD(HH, 12, PPH.FechaModificacion)) AS FechaVencimiento,
	C.NombreArchivo
	FROM EVA_PasarelaPago_Historial PPH WITH (NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	ON PPH.IdTramiteSolicitud = TS.IdTramiteSolicitud AND TS.IdActorSolicitante = @IdActor
	INNER JOIN EVA_SAE_Tramite T WITH (NOLOCK)
	ON TS.IdTramite = T.IdTramite
	INNER JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH (NOLOCK)
	ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
	LEFT JOIN EVA_SAE_Constancias C WITH (NOLOCK)
	ON TS.IdTramiteSolicitud = C.IdTramiteSolicitud
	WHERE
	PPH.IdPasarelaPagoHistorial = @IdPasarelaPagoHistorial
END