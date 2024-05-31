IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_ObtenerReciente') DROP PROCEDURE EVA_SaeTramiteSolicitud_ObtenerReciente
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (16.03.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene la informacion reciente de una solicitud de trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramiteSolicitud_ObtenerReciente 1, 1294897
*/

CREATE PROCEDURE EVA_SaeTramiteSolicitud_ObtenerReciente
@IdTramite	INT,
@IdActor	INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT NULL AS IdTramiteSolicitud, NULL AS FechaCreacion
	--DECLARE @IdTramiteSolicitud INT, @FechaCreacion BIGINT, @EsPagado BIT

	--SELECT TOP 1
	--	@IdTramiteSolicitud = TS.IdTramiteSolicitud,
	--	@FechaCreacion = dbo.toMiliseconds(TS.FechaCreacion),
	--	@EsPagado = CASE
	--					WHEN TSS.EsPagado IS NULL THEN 1
	--					ELSE TSS.EsPagado
	--				END
	--FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	--LEFT JOIN EVA_SAE_TramiteSolicitudSpring TSS WITH (NOLOCK)
	--ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
	--WHERE
	--	TS.IdTramite = @IdTramite
	--	AND TS.IdActorSolicitante = @IdActor
	--	AND DATEDIFF(MINUTE, TS.FechaCreacion, GETDATE()) < 1440
	--	AND TS.EsAnulado = 0
	--ORDER BY TS.FechaCreacion DESC

	--SELECT IIF(@EsPagado = 1, NULL, @IdTramiteSolicitud) AS IdTramiteSolicitud, IIF(@EsPagado = 1, NULL, @FechaCreacion) AS FechaCreacion
END