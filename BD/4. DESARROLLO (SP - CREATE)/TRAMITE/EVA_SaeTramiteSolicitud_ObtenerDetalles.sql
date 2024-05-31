IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitud_ObtenerDetalles') DROP PROCEDURE EVA_SaeTramiteSolicitud_ObtenerDetalles
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene los detalles acerca de un trámite gestionado a partir de su id
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Comentarios:
Pendiente Orden de mérito y puesto

Ejemplo:
EXEC EVA_SaeTramiteSolicitud_ObtenerDetalles 201, 1, '00002700', 1
*/

CREATE PROCEDURE [EVA_SaeTramiteSolicitud_ObtenerDetalles]
	@IdTramiteSolicitud				INT,
	@MostrarDatosSolicitante		BIT,
	@CompaniaSocio					VARCHAR(8),
	@EntornoDePrueba				BIT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Ruta	VARCHAR(100)
	
	SELECT @Ruta = P.Valor2 FROM Parametro P WITH (NOLOCK) WHERE P.Nombre = 'RutaEva'

	DECLARE @Nombre VARCHAR(100),
			@NombreEstado VARCHAR(255),
			@IdEstado INT,
			@NombreEstadoUsuario VARCHAR(255),
			@IdEstadoUsuario INT,
			@CodigoPublico VARCHAR(100),
			@NombreCertificado VARCHAR(250),
			@NombreArchivo VARCHAR(200),
			@EstadoSolicitud CHAR(3),
			@CodigoTramite VARCHAR(9),
			@ProductoNombreCertificado VARCHAR(200),
			@EsAutomatico BIT,
			@EsManual BIT,
			@TieneCosto BIT,
			@UltimoEstadoRespuesta CHAR(3),
			@FechaCreacion BIGINT,
			@IdTramite INT,
			@GeneraAdjunto VARCHAR(5),
			@IdUltimaMatricula INT,
			@IdProducto INT,
			@IdPromocion INT,
			@IdActorSolicitante INT,
			@TieneRespuestaSolicitante BIT,
			@PermiteDescargarPlantilla BIT,
			@MinimoAdjuntoEncargado INT,
			@MaximoAdjuntoEncargado INT,
			@PesoKbAdjuntoEncargado FLOAT,
			@FormatoAdjuntoEncargado VARCHAR(500),
			@Sla INT

	SELECT
	@IdTramiteSolicitud = TS.IdTramiteSolicitud,
	@Nombre = T.Nombre,
	@NombreEstado = TE.NombreEstado,
	@IdEstado = TS.IdEstado,
	@NombreEstadoUsuario = TEU.NombreEstado,
	@IdEstadoUsuario = TS.IdEstadoUsuario,
	@CodigoPublico = C.CodigoPublico,
	@NombreCertificado = IIF(C.NombreFinal IS NULL,T.Nombre,C.NombreFinal) + ' - ' + A.NombreCompleto,
	@NombreArchivo = C.NombreArchivo,
	@EstadoSolicitud = TS.EstadoSolicitud,
	@CodigoTramite = TRIM(T.CodigoPublico),
	@ProductoNombreCertificado = P.ProductoNombreCertificado,
	@EsAutomatico = T.EsAutomatico,
	@EsManual = T.EsManual,
	@TieneCosto = T.TieneCosto,
	@UltimoEstadoRespuesta = TS.UltimoEstadoRespuesta,
	@FechaCreacion = dbo.toMiliseconds(TS.FechaCreacion),
	@IdTramite = T.IdTramite,
	@GeneraAdjunto = T.GeneraAdjunto,
	@IdUltimaMatricula = TS.IdMatricula,
	@IdProducto = TS.IdProducto,
	@IdActorSolicitante = TS.IdActorSolicitante,
	@IdPromocion = TS.IdPromocion,
	@TieneRespuestaSolicitante = T.TieneRespuestaSolicitante,
	@PermiteDescargarPlantilla = T.PermiteDescargarPlantilla,
	@MinimoAdjuntoEncargado = T.MinimoAdjuntoEncargado,
	@MaximoAdjuntoEncargado = T.MaximoAdjuntoEncargado,
	@PesoKbAdjuntoEncargado = T.PesoKbAdjuntoEncargado,
	@FormatoAdjuntoEncargado = T.FormatoAdjuntoEncargado,
	@Sla = dbo.EVA_FN_RestarDiasHabiles(TS.FechaPGA, T.DiasAtencion)
	FROM EVA_SAE_TramiteSolicitud TS WITH(NOLOCK)
	INNER JOIN EVA_SAE_Tramite T WITH(NOLOCK) ON TS.IdTramite = T.IdTramite
	INNER JOIN EVA_SAE_TramiteEstados TE WITH(NOLOCK) ON TS.IdEstado = TE.IdEstado
	INNER JOIN EVA_SAE_TramiteEstados TEU WITH(NOLOCK) ON TS.IdEstadoUsuario = TEU.IdEstado
	LEFT JOIN EVA_SAE_Constancias C WITH(NOLOCK) ON C.IdTramiteSolicitud=TS.IdTramiteSolicitud
	LEFT JOIN Actor A WITH(NOLOCK) ON A.IdActor=C.IdAlumno
	LEFT JOIN Producto P WITH(NOLOCK) ON P.IdProducto = TS.IdProducto 
	WHERE
		TS.IdTramiteSolicitud = @IdTramiteSolicitud
		AND TS.EsAnulado = 0

	SELECT
	@IdTramiteSolicitud AS IdTramiteSolicitud,
	@Nombre AS Nombre,
	@NombreEstado AS NombreEstado,
	@IdEstado AS IdEstado,
	@NombreEstadoUsuario AS NombreEstadoUsuario,
	@IdEstadoUsuario AS IdEstadoUsuario,
	@CodigoPublico AS CodigoPublico,
	@NombreCertificado AS NombreCertificado,
	@NombreArchivo AS NombreArchivo,
	@EstadoSolicitud AS EstadoSolicitud,
	@CodigoTramite AS CodigoTramite,
	@ProductoNombreCertificado AS ProductoNombreCertificado,
	@EsAutomatico AS EsAutomatico,
	@EsManual AS EsManual,
	@TieneCosto AS TieneCosto,
	@UltimoEstadoRespuesta AS UltimoEstadoRespuesta,
	@FechaCreacion AS FechaCreacion,
	@GeneraAdjunto AS GeneraAdjunto,
	@TieneRespuestaSolicitante AS TieneRespuestaSolicitante,
	@PermiteDescargarPlantilla AS PermiteDescargarPlantilla,
	@MinimoAdjuntoEncargado AS MinimoAdjuntoEncargado,
	@MaximoAdjuntoEncargado AS MaximoAdjuntoEncargado,
	@PesoKbAdjuntoEncargado AS PesoKbAdjuntoEncargado,
	@FormatoAdjuntoEncargado AS FormatoAdjuntoEncargado,
	@Sla AS Sla

	SELECT
	TEE.IdEstado,
	TE.NombreEstado,
	dbo.toMiliseconds(TSHE.FechaCreacion) AS FechaCreacion
	FROM EVA_SAE_TramiteSolicitud TS WITH (NOLOCK)
	INNER JOIN EVA_SAE_TramiteEventoEstado TEE WITH (NOLOCK)
	ON TS.IdTramite = TEE.IdTramite
	INNER JOIN EVA_SAE_TramiteEstados TE WITH (NOLOCK)
	ON TEE.IdEstado = TE.IdEstado
	FULL OUTER JOIN EVA_SAE_TramiteSolicitudHistorialEstados TSHE WITH (NOLOCK)
	ON TSHE.IdEstado = TEE.IdEstado AND TSHE.IdTramiteSolicitud = @IdTramiteSolicitud
	WHERE
		TS.IdTramiteSolicitud = @IdTramiteSolicitud
		AND TE.EsActivo = 1
		AND TE.EsVisible IN ('Siempre', 'Opcional')
		AND TS.EsAnulado = 0
	ORDER BY TEE.Orden ASC
	
	SELECT
	TSR.IdTramiteSolicitudRespuesta,
	TSR.IdTramiteSolicitud,
	TSR.TipoParticipante,
	TSR.Mensaje,
	TSR.Estado,
	dbo.toMiliseconds(TSR.FechaCreacion) AS FechaCreacion,
	A.NombreCompleto
	FROM EVA_SAE_TramiteSolicitudRespuesta TSR WITH (NOLOCK)
	INNER JOIN Actor A WITH(NOLOCK) ON A.IdActor = TSR.IdActor
	WHERE TSR.IdTramiteSolicitud = @IdTramiteSolicitud

	SELECT
	TSR.IdTramiteSolicitudRespuesta,
	AE.Nombre,
	AE.Extension,
	IIF(@EntornoDePrueba=1,CONCAT(@Ruta,'test/sae/',AE.NombreCDN,'.',AE.Extension),CONCAT(@Ruta,'sae/',AE.NombreCDN,'.',AE.Extension)) AS UrlAdjunto
	FROM EVA_SAE_TramiteSolicitudRespuesta TSR WITH(NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitudRespuestaAdjunto TSRA WITH(NOLOCK) ON TSR.IdTramiteSolicitudRespuesta = TSRA.IdTramiteSolicitudRespuesta
	INNER JOIN ArchivoEVA AE WITH(NOLOCK) ON AE.IdArchivo = TSRA.IdArchivo
	WHERE TSR.IdTramiteSolicitud = @IdTramiteSolicitud

	IF(@MostrarDatosSolicitante=1)
	BEGIN
		SELECT 
		CONCAT(U.Nombres,' ',U.ApellidoPaterno,' ',U.ApellidoMaterno) AS Nombres,
		U.Login,
		ISNULL(PR.ProductoNombreCorto,PR.ProductoNombre) as ProductoNombre,
		CONCAT(E.NombreCorto,' | ',S.Nombre) AS Campus,
		LOWER(CONCAT(U.Login,IIF(@CompaniaSocio = '00002500','@zegelipae.pe',IIF(@CompaniaSocio = '00002600','@corrientealterna.edu.pe','@idat.edu.pe')))) AS CorreoInstitucional,
		CM.Nombre AS PeriodoAcademico,
		PE.Codigo AS PeriodoLectivo,
		CASE WHEN AF.NombreArchivo IS NULL THEN '' ELSE @Ruta + IIF(@EntornoDePrueba = 1, 'test/actor/', 'actor/') + AF.NombreArchivo END AS Foto
		FROM Actor A
		LEFT JOIN ActorFoto AF WITH (NOLOCK) ON A.IdActor = AF.IdActor
		LEFT JOIN Usuario U WITH(NOLOCK) ON U.IdActor = A.IdActor
		LEFT JOIN Promocion P WITH(NOLOCK) ON P.IdPromocion = @IdPromocion
		LEFT JOIN Periodo PE WITH(NOLOCK) ON PE.IdPeriodo = P.IdPeriodo
		LEFT JOIN CurriculaModulo CM WITH(NOLOCK) ON CM.IdCurricula = P.IdCurricula AND CM.IdModulo = P.IdModulo
		INNER JOIN Producto PR WITH(NOLOCK) ON PR.IdProducto= P.IdProducto
		INNER JOIN Empresa E WITH(NOLOCK) ON E.IdEmpresa = P.IdEmpresa
		INNER JOIN Sede S WITH(NOLOCK) ON S.IdSede = P.IdSede
		WHERE 
		A.IdActor = @IdActorSolicitante
	END

	SELECT TCR.Respuesta, TCR.Tipo, TCR.TextoInformativo, TCR.Texto1, TCR.Texto2
	FROM EVA_SAE_TramiteConfiguracionRespuesta TCR WITH (NOLOCK)
	WHERE TCR.IdTramite = @IdTramite

	IF (@CodigoTramite = 'CARTPRO')
		BEGIN
			SELECT
			DT.NroRuc,
			DT.RazonSocial,
			DT.Dirigido,
			DT.Cargo
			FROM EVA_SAE_DetalleTramite_CARTPRO DT WITH (NOLOCK)
			WHERE IdTramiteSolicitud = @IdTramiteSolicitud
		END
	ELSE IF (@CodigoTramite = 'CARPREPRO')
		BEGIN
			SELECT
			DT.NroRuc,
			DT.RazonSocial,
			DT.Dirigido,
			DT.Cargo
			FROM EVA_SAE_DetalleTramite_CARPREPRO DT WITH (NOLOCK)
			WHERE IdTramiteSolicitud = @IdTramiteSolicitud
		END
	ELSE IF (@CodigoTramite = 'CONSNOT' OR @CodigoTramite = 'VISILA')
		BEGIN
			DECLARE @Periodos TABLE (Codigo VARCHAR(20), Disponible3 VARCHAR(MAX), Disponible1 VARCHAR(MAX))

			INSERT INTO @Periodos
			SELECT MTR.Codigo, MTR.Disponible3, MTR.Disponible1
			FROM MaestroTabla MT WITH (NOLOCK)
			INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
			ON MT.IdMaestroTabla = MTR.IdMaestroTabla
			WHERE MT.Codigo = 'TipoSemestre'

			IF (@CodigoTramite = 'CONSNOT')
			BEGIN
				SELECT DT.IdModulo, P.Disponible3 AS Disponible3, ''
				FROM EVA_SAE_DetalleTramite_CONSNOT DT WITH (NOLOCK)
				LEFT JOIN @Periodos P
				ON DT.IdModulo = P.Disponible1
				WHERE IdTramiteSolicitud = @IdTramiteSolicitud
			END
			ELSE IF (@CodigoTramite = 'VISILA')
			BEGIN
				SELECT DT.IdModulo, P.Disponible3 + ' (' + CONVERT(VARCHAR, COUNT(*)) + ' Unidades Académicas)' AS Disponible3, ''
				FROM EVA_SAE_DetalleTramite_VISILA DT WITH (NOLOCK)
				LEFT JOIN @Periodos AS P
				ON DT.IdModulo = P.Disponible1
				WHERE IdTramiteSolicitud = @IdTramiteSolicitud
				GROUP BY DT.IdModulo, P.Disponible3
			END
		END
	ELSE IF (@CodigoTramite = 'CONSESP' OR @CodigoTramite = 'CERTPROG' OR @CodigoTramite = 'CERTESTSU' OR @CodigoTramite = 'FIRMCON' OR @CodigoTramite = 'ACREDING')
		BEGIN
			SELECT
			AE.Nombre,
			AE.Extension,
			IIF(@EntornoDePrueba = 1, CONCAT(@Ruta, 'test/sae/', AE.NombreCDN, '.', AE.Extension), CONCAT(@Ruta, 'sae/', AE.NombreCDN, '.', AE.Extension)) AS UrlAdjunto
			FROM EVA_SAE_TramiteSolicitudAdjunto TSA WITH (NOLOCK)
			INNER JOIN ArchivoEVA AE WITH (NOLOCK)
			ON TSA.IdArchivo = AE.IdArchivo
			WHERE IdTramiteSolicitud = @IdTramiteSolicitud

			IF (@CodigoTramite = 'CONSESP')
			BEGIN
				SELECT Dirigido, Detalle
				FROM EVA_SAE_DetalleTramite_CONSESP DT WITH (NOLOCK)
				WHERE IdTramiteSolicitud = @IdTramiteSolicitud
			END
		END
	ELSE IF (@CodigoTramite = 'RECINASIS')
		BEGIN
			SELECT TOP 1 C.CursoNombreOficial, R.Sustento, dbo.toMiliseconds(CA.FechaModificacion) AS FechaModificacion FROM EVA_SAE_DetalleTramite_RECINASIS R WITH (NOLOCK)
			INNER JOIN Curso C WITH (NOLOCK) ON C.IdCurso=R.IdCurso
			INNER JOIN AlumnoCursoAsistencia CA ON CA.IdSeccion=R.IdSeccion 
			WHERE IdTramiteSolicitud = @IdTramiteSolicitud
			AND CA.IdHorario=R.IdHorario AND CA.IdSesion=R.IdSesion
			AND CA.IdAlumno=@IdActorSolicitante
		END

		Select TSS.MedioPago,NumeroOrden, case WHEN TSS.MedioPago = 'N_TARJETA' THEN 'Con Tarjeta' ELSE 'PagoEfectivo' END as TipoPago,
		case WHEN TSS.MedioPago = 'N_TARJETA' THEN 
			CASE WHEN Resultado = 1 THEN 'PAGO EXISTOSO' ELSE 'RECHAZADO' END
		ELSE 'PENDIENTE DE PAGO' END as Estado,
		Cip,
		Resultado,
		dbo.toMiliseconds(DATEADD(HH,12,PPH.FechaModificacion)) as Vencimiento

		from EVA_PasarelaPago_Historial PPH
		left join EVA_SAE_TramiteSolicitudSpring TSS On TSS.IdTramiteSolicitud=PPH.IdTramiteSolicitud
		where PPH.IdTramiteSolicitud=@IdTramiteSolicitud
END
