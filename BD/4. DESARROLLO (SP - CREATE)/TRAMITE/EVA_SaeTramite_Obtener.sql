IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_Obtener') DROP PROCEDURE EVA_SaeTramite_Obtener
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.21)
--Revisado por		: SCAYCHO
--Funcionalidad		: Obtiene informaci�n relevante de un tr�mite y sus requisitos a partir de su id
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC [EVA_SaeTramite_Obtener] 18, 1303432, '00002500', 1
EXEC [EVA_SaeTramite_Obtener] 4, 1506372, '00002500', 1,'232323'
EXEC [EVA_SaeTramite_Obtener] 1, 1566669, '00002500',0, 0
EXEC [EVA_SaeTramite_Obtener] 23, 1569679, '00002500',1, 1204594

*/

--exec EVA_SaeTramite_Obtener @IdTramite=1,@IdActor=465349,@CompaniaSocio=N'00002500',@IdMatricula=0,@EntornoDePrueba=1
CREATE PROCEDURE [EVA_SaeTramite_Obtener]
	@IdTramite  INT,
	@IdActor INT,
	@CompaniaSocio CHAR(8),
	@EntornoDePrueba BIT,
	@IdMatricula int = null,
	@IdCaso	INT = null
AS
BEGIN
	SET NOCOUNT ON;
 DECLARE @NiubizMontoFijo MONEY  
  
 SELECT @NiubizMontoFijo = IIF(Valor <> '', Valor, NULL) FROM Parametro WITH (NOLOCK) WHERE Nombre = 'EVA_NIUBIZMONTOFIJO' AND Activo = 1  

	DECLARE @Sucursal CHAR(4)
	DECLARE @ValorEVATramiteFiltro varchar(max)
	DECLARE @Ruta	VARCHAR(100)

	DECLARE @TerminosCodiciones varchar(max), @PagoTarjeta varchar (50), @EsIquitos BIT

	SELECT @Ruta=Valor2 FROM Parametro WITH(NOLOCK) WHERE nombre = 'RutaEva'
	SELECT @ValorEVATramiteFiltro=Valor from  Parametro WHERE Nombre = 'EVA_TRAMITEFILTRO' 

	-- CONFIGURATION

	DECLARE @IdUltimaMatricula INT
	IF (@IdMatricula is null or @IdMatricula = 0) 
		BEGIN

	    DECLARE @SqlQuery NVARCHAR(MAX)
        SET @SqlQuery = 'SELECT TOP 1 @IdUltimaMatricula = HPD.IdUltimaMatricula
			FROM EVA_AlumnoHistorialProductosDetalle HPD WITH(NOLOCK)
			left join EVA_SAE_Tramite T WITH(NOLOCK) on T.IdTramite = '+ convert(varchar, @IdTramite) + ' and T.EsActivo=1
			LEFT JOIN CambioProductoCurricula CPC on CPC.IdAlumno=HPD.IdAlumno and CPC.IdUnidadNegocio=HPD.IdUnidadNegocio and CPC.IdUnidadAcademica=HPD.IdUnidadAcademica and CPC.IdCurriculaAnterior=HPD.IdCurricula and CPC.IdProductoAnterior=HPD.IdProducto and CPC.Estado=1
			LEFT JOIN TrasladoSede TRS on TRS.IdAlumno=HPD.IdAlumno and TRS.IdUnidadNegocio=HPD.IdUnidadNegocio and TRS.IdCurriculaAnterior=HPD.IdCurricula and TRS.IdProductoAnterior=HPD.IdProducto and TRS.IdCurriculaAnterior!=TRS.IdCurriculaNueva and TRS.IdProductoAnterior!=TRS.IdProductoNueva
			INNER JOIN EVA_SAE_TramiteCaso TC on TC.IdTramite = T.IdTramite
			WHERE HPD.IdAlumno = ' + convert(varchar, @IdActor) + ' and CPC.IdEmpresa is null and TRS.IdEmpresa is null and ('
			+ @ValorEVATramiteFiltro +
			') ORDER BY HPD.IdUltimaMatricula DESC'

        EXEC SP_EXECUTESQL @SqlQuery,  N'@IdUltimaMatricula INT OUTPUT', @IdUltimaMatricula OUTPUT

		END
	ELSE
		BEGIN
			SET @IdUltimaMatricula = @IdMatricula
		END

	SELECT TOP 1
	@Sucursal=ISNULL(TRIM(S.Sucursal),'')
	FROM Matricula M WITH(NOLOCK)
	INNER JOIN Sede S WITH(NOLOCK) ON S.IdSede = M.IdSede
	WHERE M.IdActor = @IdActor AND M.EsMatricula = 1 and IdMatricula=@IdUltimaMatricula
	ORDER BY IdMatricula

	--Terminos y Condiciones
	IF(@CompaniaSocio='00002500' AND @Sucursal ='SEIQ') 
		BEGIN
			SET @TerminosCodiciones = (SELECT Valor FROM Parametro WHERE NOMBRE ='EVA_PAGOTERYCON_IQ')
			SET @PagoTarjeta = 'EVA_PAGARTARJETA_IQ'
			SET @EsIquitos = 1
		END
	ELSE
		BEGIN
			SET @TerminosCodiciones = (SELECT Valor FROM Parametro WHERE NOMBRE ='EVA_PAGOTERYCON')
			SET @PagoTarjeta = 'EVA_PAGARTARJETA'
			SET @EsIquitos = 0
		END

	-- OUTPUT
	SELECT 
	ST.IdTramite,
	ST.Nombre,
	ST.Descripcion,
	TRIM(ST.CodigoPublico) AS CodigoPublico,
	ST.TieneCosto,
	TRIM(ST.IdServicioClasificacion) AS IdServicioClasificacion,
	ST.HoraVencimiento,
	ST.DiasAtencion,
	ST.MinimoAdjunto,
	ST.MaximoAdjunto,
	ST.PesoKbAdjunto,
	ST.FormatoAdjunto,
	ST.TituloDetalle,
	ST.TituloAdjunto,
	ST.TextoDetalle,
	ST.TextoAdjunto,
	TRIM(SC.DescripcionLocal) AS DescripcionLocal,
	CASE WHEN @Sucursal ='SEIQ' THEN CP2.Monto ELSE CP.Monto END as Monto,
	ST.EsGrupo,
	ST.IdTramiteGrupo,
	@NiubizMontoFijo AS NiubizMontoFijo,
	@TerminosCodiciones AS TerminosCondiciones,
	ST.GeneraAdjunto,
	ST.MostrarCursoDiplomado,
	@EsIquitos EsIquitos
	FROM EVA_SAE_tramite ST WITH(NOLOCK)
	LEFT JOIN dbo.CO_ServicioClasificacion SC WITH(NOLOCK) 
	ON SC.ServicioClasificacion = IIF(@EsIquitos=0,ST.IdServicioClasificacion,ST.IdServicioClasificacion_IQ) AND SC.CompaniaSocio = @CompaniaSocio
	LEFT JOIN dbo.CO_Precio CP WITH(NOLOCK) 
	ON CP.ItemCodigo =ST.IdServicioClasificacion AND CP.CompaniaSocio = @CompaniaSocio AND CP.UnidadNegocio = @Sucursal
	LEFT JOIN dbo.CO_Precio_ASOC CP2 WITH(NOLOCK) 
	ON CP2.ItemCodigo =ST.IdServicioClasificacion_IQ AND CP2.UnidadNegocio = @Sucursal
	WHERE 
	ST.IdTramite = @IdTramite AND 
	ST.EsActivo = 1

	--REGISTROS
	DECLARE @query varchar(max) = '
select
R.IdRegistro,
R.IdProducto,
R.IdUltimaMatricula,
R.IdPeriodo,
R.EstadoUltimaMatricula,
R.IdModulo,
R.IdUnidadnegocio,
R.IdUnidadacademica,
R.IdCurricula,
R.EstadoAlumno,
R.ProductoNombreCorto,
R.CodigoCurricula,
R.IdCaso, ' +
IIF(@EntornoDePrueba = 1, 'CONCAT('''+@Ruta+''', ''test/tramites/constancias/ejemplos/'', AE.NombreCDN, ''.'', AE.Extension)', 'CONCAT('''+@Ruta+''', ''tramites/constancias/ejemplos/'', AE.NombreCDN, ''.'', AE.Extension)')  + ' AS UrlEjemplo,
R.IdAgrupacion
from (
SELECT
distinct
  HPD.IdRegistro,
  HPD.IdProducto,
  HPD.IdUltimaMatricula,
  HPD.IdPeriodo,
  HPD.EstadoUltimaMatricula,
  HPD.IdModulo,
  HPD.IdUnidadnegocio,
  CASE
		WHEN (HPD.IdUnidadAcademica IS NOT NULL) AND (PAR.Valor IS NOT NULL) THEN PAR.Valor
		ELSE HPD.IdUnidadAcademica
  END AS IdUnidadacademica,
  HPD.IdCurricula,
  HPD.EstadoAlumno,
  P.ProductoNombreCorto,
  C.Codigo AS CodigoCurricula,
  min(TC.IdCaso) as IdCaso,
	UAG.IdAgrupacion
  FROM EVA_AlumnoHistorialProductosDetalle HPD WITH(NOLOCK)
  INNER join EVA_SAE_Tramite T WITH(NOLOCK) on T.IdTramite = '+ convert(varchar, @IdTramite) +' and T.EsActivo=1
  INNER JOIN Producto P WITH (NOLOCK) ON HPD.IdProducto = P.IdProducto
  INNER JOIN Curricula C WITH (NOLOCK) ON HPD.IdCurricula = C.IdCurricula
  LEFT JOIN CambioProductoCurricula CPC on CPC.IdAlumno=HPD.IdAlumno and CPC.IdUnidadNegocio=HPD.IdUnidadNegocio and CPC.IdUnidadAcademica=HPD.IdUnidadAcademica and CPC.IdCurriculaAnterior=HPD.IdCurricula and CPC.IdProductoAnterior=HPD.IdProducto and CPC.Estado=1
  LEFT JOIN TrasladoSede TRS on TRS.IdAlumno=HPD.IdAlumno and TRS.IdUnidadNegocio=HPD.IdUnidadNegocio and TRS.IdCurriculaAnterior=HPD.IdCurricula and TRS.IdProductoAnterior=HPD.IdProducto and TRS.IdCurriculaAnterior!=TRS.IdCurriculaNueva and TRS.IdProductoAnterior!=TRS.IdProductoNueva
  INNER JOIN EVA_SAE_TramiteCaso TC on TC.IdTramite = T.IdTramite
	LEFT JOIN EVA_SAE_UnidadAcademicaAgrupacion UAG WITH (NOLOCK) ON UAG.IdUnidadAcademica = HPD.IdUnidadAcademica
	LEFT JOIN ParametroUnidadAcademica PAR WITH (NOLOCK) ON HPD.IdUnidadAcademica = PAR.IdUnidadAcademica AND HPD.IdProducto = PAR.IdProducto AND PAR.Nombre = ''UnidadAcademicaRealVirtual''
  WHERE
  HPD.IdAlumno = '+ convert(varchar, @IdActor) +'  and CPC.IdEmpresa is null and TRS.IdEmpresa is null and ('
	+ @ValorEVATramiteFiltro +
	')
  GROUP BY
  HPD.IdRegistro,
  HPD.IdProducto,
  HPD.IdUltimaMatricula,
  HPD.IdPeriodo,
  HPD.EstadoUltimaMatricula,
  HPD.IdModulo,
  HPD.IdUnidadnegocio,
  HPD.IdUnidadacademica,
  HPD.IdCurricula,
  HPD.EstadoAlumno,
  P.ProductoNombreCorto,
  C.Codigo,
	UAG.IdAgrupacion,
	PAR.Valor
) AS R
INNER JOIN EVA_SAE_TramiteCaso TC
ON R.IdCaso = TC.IdCaso
LEFT JOIN ArchivoEVA AE
ON TC.IdArchivoEjemplo = AE.IdArchivo
ORDER BY IdUltimaMatricula DESC'

	DECLARE @Registros TABLE (
		IdRegistro INT,
		IdProducto INT,
		IdUltimaMatricula INT,
		IdPeriodo INT,
		EstadoUltimaMatricula CHAR(1),
		IdModulo INT,
		IdUnidadnegocio INT,
		IdUnidadacademica INT,
		IdCurricula INT,
		EstadoAlumno CHAR(3),
		ProductoNombreCorto VARCHAR(200),
		CodigoCurricula VARCHAR(20),
		IdCaso INT,
		UrlEjemplo VARCHAR(MAX),
		IdAgrupacion INT
	)
	INSERT INTO @Registros
	EXEC (@query)

	IF (@IdCaso IS NULL OR @IdCaso = 0)
	BEGIN
		SELECT TOP 1 @IdCaso = IdCaso FROM @Registros
	END

	--REQUISITOS
	EXEC [EVA_SaeRequisito_Estado] @IdActor,@CompaniaSocio, @IdTramite, @IdUltimaMatricula, @IdCaso

	--Programas de Estudio
	IF (@CompaniaSocio ='00002700')-- Condicional para mostrar solo el ultimo producto de carrera para 
		BEGIN
			DECLARE @RegistrosIdat TABLE (
				IdRegistro INT,
				IdProducto INT,
				IdUltimaMatricula INT,
				IdPeriodo INT,
				EstadoUltimaMatricula CHAR(1),
				IdModulo INT,
				IdUnidadnegocio INT,
				IdUnidadacademica INT,
				IdCurricula INT,
				EstadoAlumno CHAR(3),
				ProductoNombreCorto VARCHAR(200),
				CodigoCurricula VARCHAR(20),
				IdCaso INT,
				UrlEjemplo VARCHAR(MAX),
				IdAgrupacion INT
			)
			INSERT INTO @RegistrosIdat
			SELECT top 1 *
			FROM @Registros where IdUnidadnegocio =1 order by IdUltimaMatricula desc

			SELECT * from @RegistrosIdat
			union 
			--SELECT IdRegistro,IdProducto,IdUltimaMatricula,IdPeriodo,EstadoUltimaMatricula,IdModulo,IdUnidadnegocio,IdUnidadacademica,IdCurricula,EstadoAlumno,ProductoNombreCorto,CodigoCurricula,IdCaso,UrlEjemplo FROM @Registros where IdUnidadnegocio = 1
			SELECT * FROM @Registros where IdUnidadnegocio != 1
		END
	ELSE
		BEGIN
			SELECT * FROM @Registros
		END	
	

	SELECT
	Nombre,
	Valor
	FROM Parametro WITH (NOLOCK)
	WHERE
	Nombre IN ('EVA_NIUBIZMONTOFIJO', @PagoTarjeta, 'EVA_PAGARBANCO')
	AND Activo = 1


	SELECT 
		IdMaestroRegistro, 
		Nombre
	FROM MaestroTablaRegistro WITH (NOLOCK)
	WHERE IdMaestroTabla IN (
	SELECT 
		IdMaestroTabla 
	FROM maestroTabla 
	WHERE Codigo='EvaSaeUniAcaAgr' )
END
