IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_Listar') DROP PROCEDURE EVA_SaeTramite_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Listar los tr�mites disponibles a partir de un parametro de b�squeda
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramite_Listar '', 1303432
*/

CREATE PROCEDURE [EVA_SaeTramite_Listar]
	@Busqueda		VARCHAR(255) = '',
	@IdActor		INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ValorEVATramiteFiltro varchar(max)

	SELECT 
	IdCategoria,
	Nombre,
	RTRIM(CodigoPublico) AS CodigoPublico
	FROM [EVA_SAE_TramiteCategoria] WITH(NOLOCK)
	WHERE EsActivo=1

	SELECT @ValorEVATramiteFiltro=Valor from  Parametro WHERE Nombre = 'EVA_TRAMITEFILTRO' 

	DECLARE @query varchar(max) = 'Select distinct 	T.IdTramite, Nombre, IdCategoria, EsGrupo
		FROM EVA_SAE_Tramite T WITH (NOLOCK)
		LEFT JOIN EVA_AlumnoHistorialProductosDetalle HPD	WITH (NOLOCK) ON HPD.IdAlumno=' + convert(varchar, @IdActor) + '
		LEFT JOIN CambioProductoCurricula CPC on CPC.IdAlumno=HPD.IdAlumno and CPC.IdUnidadNegocio=HPD.IdUnidadNegocio and CPC.IdUnidadAcademica=HPD.IdUnidadAcademica and CPC.IdCurriculaAnterior=HPD.IdCurricula and CPC.IdProductoAnterior=HPD.IdProducto and CPC.Estado=1
		LEFT JOIN TrasladoSede TRS on TRS.IdAlumno=HPD.IdAlumno and TRS.IdUnidadNegocio=HPD.IdUnidadNegocio and TRS.IdCurriculaAnterior=HPD.IdCurricula and TRS.IdProductoAnterior=HPD.IdProducto and TRS.IdCurriculaAnterior!=TRS.IdCurriculaNueva and TRS.IdProductoAnterior!=TRS.IdProductoNueva
		INNER JOIN EVA_SAE_TramiteCaso TC on TC.IdTramite = T.IdTramite
		where T.EsActivo = 1 and CPC.IdEmpresa is null and TRS.IdEmpresa is null  and (' + @ValorEVATramiteFiltro + ')'

	EXEC (@query)

	SELECT
	CASE 
		WHEN TS.IdEstado = 1 THEN 'TRAMITEINCONCLUSO'
		WHEN TS.IdEstado = 2 THEN 'TRAMITEPENDIENTEPAGO'
	END AS Codigo, 
	TS.IdTramite,
	CASE WHEN TS.IdEstado = 2 THEN TSS.Monto ELSE NULL END AS Monto,
	CASE WHEN TS.IdEstado = 2 THEN TSS.Moneda ELSE NULL END AS Moneda
	FROM [EVA_SAE_TramiteSolicitud] TS WITH(NOLOCK)
	LEFT JOIN [EVA_SAE_TramiteSolicitudSpring] TSS WITH(NOLOCK) ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
	WHERE 
	TS.IdActorSolicitante = @IdActor AND
	(TS.IdEstado = 1 OR TS.IdEstado =2)
	AND TS.EsAnulado = 0
	UNION
	SELECT 'ENCUESTA' AS Codigo, S.IdTramiteSolicitud AS IdTramite, 0 AS Monto, T.Nombre AS Moneda FROM EVA_SAE_TramiteSolicitud S WITH(NOLOCK)
	INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK) ON T.IdTramite = S.IdTramite
	LEFT JOIN EVA_SAE_TramiteSolicitudSpring TS WITH(NOLOCK) ON S.IdTramiteSolicitud=TS.IdTramiteSolicitud
	WHERE IdActorSolicitante = @IdActor AND idProgramacionDetalle IS NULL AND ((T.TieneCosto=1 AND Ts.EsPagado=1) OR T.TieneCosto=0)
END