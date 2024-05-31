IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeConstancia_Registrar') DROP PROCEDURE EVA_SaeConstancia_Registrar
GO
--------------------------------------------------------------------------------          
--Creado por      : Rsaenz (12/12/2021)    
--Revisado por    : ahurtado (03/05/2021)  [Pendiente optimizar]
--Funcionalidad   : Valida que no se haya generado una constancia con anterioridad, en caso no exista se inserta un nuevo registro y genera la informaci�n necesaria para reemplazar estos datos en la plantilla de word (Esta informaci�n se reemplaza en el DataAccess.
--Utilizado por   : EVA    
-------------------------------------------------------------------------------       
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
@1		14.07.22	scaycho			Se modificó la forma de obtener los periodos académicos
*/

/*      
Ejemplo:    
ESCENARIO 1
EXEC [EVA_SaeConstancia_Registrar] 681,1,1
ESCENARIO 2
EXEC [EVA_SaeConstancia_Registrar] 2,1
ESCENARIO 3
EXEC [EVA_SaeConstancia_Registrar] 5,1
*/
CREATE PROCEDURE [dbo].[EVA_SaeConstancia_Registrar]
@IdTramiteSolicitud			INT,
@EntornoDePrueba			BIT,
@EsRectificacion			BIT =0
AS
BEGIN
	SET NOCOUNT ON 

	DECLARE 
	@Estado							INT,
	@Nombre							VARCHAR(100),
	@Codigo							VARCHAR(100),
	@IdTramite						INT,
	@Actor							INT,
	@Usuario						INT,
	@Valor							VARCHAR(100),
	@Valor2							VARCHAR(100),
	@IdConstanciasCertificados		INT,
	@ContadorInformacion			INT,
	@ContadorConstancias			INT,
	@Compania						VARCHAR(8),
	@CodigoPublicoTramite			VARCHAR(9),
	@UrlDocumentoPlantilla			VARCHAR(5000)
	-- CONFIGURATION FILE SERVER
	DECLARE @Ruta VARCHAR(200)
	DECLARE @Servidor VARCHAR(200)

	SELECT 
	@Servidor=ISNULL(P.Valor,'')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre='RutaEva'

	IF(@EntornoDePrueba = 1)
	BEGIN
		SET @Ruta=@Servidor+'test\tramites\constancias\plantillas\'
	END
	ELSE
	BEGIN
		SET @Ruta=@Servidor+'tramites\constancias\plantillas\'
	END

	SELECT TOP 1 @Compania= CASE CompaniaSocio WHEN '00002500' THEN 'ZEGEL' ELSE 'IDAT' END  FROM Empresa WHERE Activo=1

	SELECT 
	@Estado=TS.IdEstado,
	@Nombre=CONCAT(TRIM(T.CodigoPublico),'-',UPPER(LEFT(U.ApellidoPaterno,1))+LOWER(SUBSTRING(U.ApellidoPaterno,2,LEN(U.ApellidoPaterno))),'-',DAY(GETDATE()),'_',MONTH(GETDATE()),'_',YEAR(GETDATE()),'-',DATEPART(HOUR,GETDATE()),DATEPART(MINUTE,GETDATE()),DATEPART(SECOND,GETDATE())),
	@Codigo=CONCAT(SUBSTRING(TRIM(T.CodigoPublico),1,2),'-',SUBSTRING(convert(varchar,dbo.toMiliseconds(GETDATE())),3,8),'-',YEAR(GETDATE()),'-', @Compania),
	@IdTramite = TS.IdTramite,
	@Actor = TS.IdActorSolicitante,
	@Usuario = TS.UsuarioCreacion,
	@CodigoPublicoTramite = TRIM(T.CodigoPublico),
	@UrlDocumentoPlantilla = CONCAT(@Ruta, AE.NombreCDN, '.', AE.Extension)
	FROM [EVA_SAE_TramiteSolicitud] TS WITH(NOLOCK)
	INNER JOIN [Usuario] U WITH(NOLOCK) ON U.IdActor = TS.IdActorSolicitante AND U.IdTipoUsuario = 1
	INNER JOIN [EVA_SAE_Tramite] T WITH(NOLOCK) ON TS.IdTramite = T.IdTramite
	INNER JOIN EVA_SAE_TramiteCaso TC WITH (NOLOCK) ON TC.IdCaso = TS.IdCaso
	INNER JOIN ArchivoEVA AE WITH (NOLOCK) ON AE.IdArchivo = TC.IdPlantillaAdjunto
	WHERE TS.IdTramiteSolicitud = @IdTramiteSolicitud AND TS.EsAnulado = 0
	
	SELECT @ContadorInformacion= COUNT(IdRegistro) FROM Registro R WITH (NOLOCK) WHERE R.IdActor=@Actor
	SELECT @ContadorConstancias= COUNT(IdConstanciasCertificados) FROM EVA_SAE_Constancias CC WITH(NOLOCK) WHERE CC.IdTramiteSolicitud = @IdTramiteSolicitud

	SELECT 
	@Valor=ISNULL(P.Valor,''),
	@Valor2=ISNULL(P.Valor2,'')
	FROM Parametro P WITH (NOLOCK)
	WHERE P.Nombre='RutaEva'

	-- Declarar variables temporales para los casos
	DECLARE @IdMatriculaSel INT 
	DECLARE @IdUnidadAcademica INT
	DECLARE @IdProductoSel INT
	DECLARE @IdRegistro INT 
	DECLARE @PeriodosLista VARCHAR(100)
	DECLARE @idCurricula INT
	DECLARE @periodos INT
	DECLARE @OrdenMerito VARCHAR(50) = 'NO CUENTA CON PONDERADO'
	DECLARE @IdModuloActual INT, @IdUnidadNegocio INT
	

	IF(@ContadorConstancias >0 and @EsRectificacion = 0) --si ya existe una constancia generada, devolvemos la constancia generada anteriormente
	BEGIN 
		SELECT 
		-100 AS Codigo,
		@IdTramite AS IdTramite,
		Concat(@Valor,IIF(@EntornoDePrueba=1, 'test\', '') + 'constancias\',@Nombre,'.docx') AS NombreArchivo,
		Concat(@Valor2,IIF(@EntornoDePrueba=1, 'test/', '') + 'constancias/',@Nombre,'.pdf') AS NombreArchivoCDN,
		CC.CodigoPublico AS CodigoPublico
		FROM EVA_SAE_Constancias CC WITH(NOLOCK)
		WHERE CC.IdTramiteSolicitud = @IdTramiteSolicitud
	END
	ELSE --si no existe una constancia generada, se inserta una nueva
		BEGIN
			IF(@ContadorInformacion>0)
				BEGIN
				IF (@Estado = 3 or @EsRectificacion = 1)
				BEGIN
					IF(@EsRectificacion=1)
					BEGIN
						-- SE OBTIENE EL ID DE LA CONSTANCIA A RECTIFICAR
						SELECT 
						@Codigo = CodigoPublico,
						@IdConstanciasCertificados= IdConstanciasCertificados 
						FROM EVA_SAE_Constancias 
						WHERE IdTramiteSolicitud= @IdTramiteSolicitud

						-- SE ACTUALIZA EL CODIGO PUBLICO
						UPDATE EVA_SAE_Constancias 
						SET
						CodigoPublico = @Codigo,
						NombreArchivo = Concat(@Valor2,IIF(@EntornoDePrueba=1,'test/',''),'constancias/',@Nombre,'.pdf'),
						FechaModificacion = GETDATE()
						WHERE IdTramiteSolicitud= @IdTramiteSolicitud
					END
					ELSE 
					BEGIN
						INSERT [EVA_SAE_Constancias]
						(CodigoPublico,IdAlumno,IdTramiteSolicitud,NombreArchivo,FechaCreacion,UsuarioCreacion)
						VALUES
						(@Codigo,@Actor,@IdTramiteSolicitud,Concat(@Valor2,IIF(@EntornoDePrueba=1,'test/',''),'constancias/',@Nombre,'.pdf'),GETDATE(),@Usuario)
						SET @IdConstanciasCertificados = SCOPE_IDENTITY()
					END

					SELECT
					-1 AS Codigo,
					@IdTramite AS IdTramite,
					Concat(@Valor,IIF(@EntornoDePrueba=1, 'test\', '') + 'constancias\',@Nombre,'.docx') AS NombreArchivo,
					Concat(@Valor2,IIF(@EntornoDePrueba=1, 'test/', '') + 'constancias/',@Nombre,'.pdf') AS NombreArchivoCDN,
					@codigo AS CodigoPublico,
					@CodigoPublicoTramite AS CodigoPublicoTramite,
					@UrlDocumentoPlantilla AS UrlDocumentoPlantilla



 /* INICIO CAMBIO EN BASE A HISTORIAL_PRODUCTOS */

				--DECLARE @IdMatriculaSel INT 
				--DECLARE @IdUnidadAcademica INT
				--DECLARE @IdProductoSel INT
				--DECLARE @IdRegistro INT 
				--DECLARE @PeriodosLista VARCHAR(100)
				--DECLARE @idCurricula INT
				--DECLARE @periodos INT

				Select @IdMatriculaSel=IdMatricula from EVA_SAE_TramiteSolicitud WITH(NOLOCK) where IdTramiteSolicitud = @IdTramiteSolicitud and IdActorSolicitante=@Actor

				SELECT
				@idCurricula = IdCurricula,
				@IdUnidadAcademica = IdUnidadAcademica,
				@IdProductoSel = IdProducto,
				@IdRegistro = IdRegistro,
				@IdModuloActual = IdModulo,
				@IdUnidadNegocio = IdUnidadNegocio
				FROM EVA_AlumnoHistorialProductosDetalle WITH(NOLOCK)
				WHERE IdAlumno = @Actor AND IdUltimaMatricula = @IdMatriculaSel

				select @periodos = count(1) from CurriculaModulo WITH(NOLOCK) where IdCurricula=@idCurricula

/* CONSULTAS PERSONALIZADAS POR TRÁMITE */ 
				-- Declarar variables temporales para cada caso
				--DECLARE @OrdenMerito VARCHAR(50) = 'NO CUENTA CON PONDERADO'

				-- CONSSUP  
				IF (TRIM(@CodigoPublicoTramite) = 'CONSSUP')
				BEGIN
					Select @OrdenMerito =OrdenMeritoProductoTexto, @IdMatriculaSel = IdMatricula from (
						select top 1 M.IdMatricula,M.IdRegistro,M.IdModulo,M.IdGrupo,P.IdPromocion,PG.FechaInicio,PG.FechaFin,  PGC.OrdenMeritoProductoTexto from Matricula M WITH(NOLOCK)
						INNER join Promocion P WITH(NOLOCK) On P.IdPromocion=M.IdPromocion
						INNER join PromocionGrupo PG WITH(NOLOCK) On PG.IdPromocion=P.IdPromocion and M.IdGrupo=PG.IdGrupo
						INNER join PromocionGrupoCierre PGC WITH(NOLOCK) ON PGC.IdPromocion=PG.IdPromocion and PGC.IdActor=M.IdActor and PGC.IdCierre is not null
						where M.IdActor=@Actor and M.Estado in ('N','R') and M.IdRegistro = @IdRegistro
						order by M.IdMatricula desc
					) as Temporal

					UPDATE [EVA_SAE_Constancias] SET NombreFinal = @OrdenMerito WHERE IdConstanciasCertificados = @IdConstanciasCertificados
				END

				-- CONSCUL  
				IF (TRIM(@CodigoPublicoTramite) = 'CONSCUL')
				BEGIN
					-- @1 - inicio
					DECLARE @UnidadDidacticaXModulo TABLE (IdModulo INT, Cantidad INT)
					DECLARE @UnidadDidacticaAprobadaXModulo TABLE (IdModulo INT, Cantidad INT)
					
					INSERT INTO @UnidadDidacticaXModulo
					SELECT ACC.IdModulo, COUNT(*)
					FROM AlumnoCurricula AC WITH (NOLOCK)
					INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
					ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula AND ACC.IdModulo <= @IdModuloActual
					WHERE AC.IdAlumno = @Actor AND AC.IdRegistro = @IdRegistro
					GROUP BY ACC.IdModulo

					INSERT INTO @UnidadDidacticaAprobadaXModulo
					SELECT ACC.IdModulo, COUNT(*)
					FROM AlumnoCurricula AC WITH (NOLOCK)
					INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
					ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula AND ACC.IdModulo <= @IdModuloActual
					WHERE AC.IdAlumno = @Actor AND AC.IdRegistro = @IdRegistro AND ACC.PromedioCondicion = 'A'
					GROUP BY ACC.IdModulo

					SELECT @PeriodosLista = STUFF(
						(
							SELECT ', ' + MTR.Disponible4
							FROM @UnidadDidacticaXModulo UDXM
							INNER JOIN @UnidadDidacticaAprobadaXModulo UDCXM
							ON UDXM.IdModulo = UDCXM.IdModulo AND UDXM.Cantidad = UDCXM.Cantidad
							INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
							ON
							MTR.IdMaestroTabla IN (SELECT MT.IdMaestroTabla FROM MaestroTabla MT WITH (NOLOCK) WHERE MT.Codigo = 'TipoSemestre')
							AND ((MTR.Disponible1 IS NULL AND @IdUnidadNegocio <> 1) OR (MTR.Disponible1 = UDXM.IdModulo AND @IdUnidadNegocio = 1))
							ORDER BY UDXM.IdModulo
							FOR XML PATH('')
						),
						1, 1, ''
					)
					-- @1 - fin
				END

/* FIN DE CONSULTAS PERSONALIZADAS POR TRÁMITE*/	
				
					

					SELECT TOP 1
					CONCAT(U.Nombres,' ',U.ApellidoPaterno,' ',U.ApellidoMaterno) AS NombreSolicitante,
					U.Login AS CodigoAlumno,
					ISNULL(P.ProductoNombreCorto,'No Especificado') AS ProductoNombreCorto,
					ISNULL(PE.Codigo,'No Especificado') AS CodigoPeriodo,
					ISNULL(A.NumeroIdentidad,0) AS NumeroIdentidad,
					LOWER(ISNULL(S.DireccionRegional,'')) AS DireccionRegional,
					UPPER(S.Nombre) AS NombreSede,
					PR.PromocionCodigo,
					DAY(getdate()) AS Dia,
					MONTH(getdate()) AS Mes,
					YEAR(getdate()) AS Ano,
					ISNULL(CC.CodigoPublico,'No Especificado') AS CodigoPublico,
					ISNULL(MTR.Nombre,'No Cuenta con Beca') AS NombreBeca,
					@periodos AS CantidadTotalPeriodos,
					UPPER(ISNULL(MTRPA.Disponible3,ISNULL(CM.Nombre,''))) AS PeriodoAcademico,
					@Actor AS IdActor,
					P.NivelFormativo,
					@PeriodosLista as 'ListaPeriodos',
					@OrdenMerito as OrdenMeritoProductoTexto,
					MTRPAX.Nombre as CursoDiplomado
					FROM 
					Matricula M WITH(NOLOCK)
					LEFT JOIN Usuario U WITH(NOLOCK) ON U.IdActor = M.IdActor AND U.IdTipoUsuario = 1
					LEFT JOIN Actor A WITH(NOLOCK) ON A.IdActor = U.IdActor
					LEFT JOIN Promocion PR WITH(NOLOCK) ON PR.IdPromocion = M.IdPromocion  
					LEFT JOIN CurriculaModulo CM WITH(NOLOCK) ON CM.IdCurricula = PR.IdCurricula AND CM.IdModulo = PR.IdModulo
					LEFT JOIN MaestroTablaRegistro MTRPA WITH(NOLOCK) ON MTRPA.IdMaestroTabla in (select IdMaestroTabla from MaestroTabla WITH(NOLOCK) where Codigo= 'TipoSemestre') AND MTRPA.Codigo=CM.Codigo
					LEFT JOIN MaestroTablaRegistro MTRPAX WITH(NOLOCK) ON MTRPAX.IdMaestroTabla in (select IdMaestroTabla from MaestroTabla WITH(NOLOCK) where Codigo= 'EvaSaeUniAcaAgr')
					LEFT JOIN EVA_SAE_UnidadAcademicaAgrupacion SUA WITH(NOLOCK) ON SUA.IdAgrupacion = MTRPAX.IdMaestroRegistro
					LEFT JOIN Producto P WITH(NOLOCK) ON P.IdProducto= PR.IdProducto  
					LEFT JOIN Periodo PE WITH(NOLOCK) ON PE.IdPeriodo= PR.IdPeriodo  
					LEFT JOIN Empresa E WITH(NOLOCK) ON E.IdEmpresa = M.IdEmpresa  
					LEFT JOIN Sede S WITH(NOLOCK) ON S.IdSede = M.IdSede  
					LEFT JOIN EVA_SAE_Constancias CC WITH(NOLOCK) ON CC.IdConstanciasCertificados = @IdConstanciasCertificados
					LEFT JOIN PromocionBeca PB WITH(NOLOCK) ON PB.IdActor = A.IdActor AND (getdate() >= PB.FechaInicioVigencia AND getdate() <= PB.FechaFinVigencia )
					LEFT JOIN Maestrotablaregistro MTR WITH(NOLOCK) ON MTR.IdMaestroTabla in (select IdMaestroTabla from MaestroTabla where Codigo = 'GrupoDes') AND MTR.IdMaestroRegistro = PB.IdTipoPromocionBeca
					WHERE M.IdActor = @Actor and M.IdMatricula=@IdMatriculaSel -- AND M.EsMatricula = 1
					ORDER BY M.IdMatricula DESC
				END
			ELSE IF (@Estado <> 3)
				BEGIN
					SELECT 
					-50 AS Codigo,
					NULL AS IdTramite,
					NULL AS NombreArchivo, 
					NULL AS NombreArchivoCDN,
					NULL AS CodigoPublico
				END
			ELSE
				BEGIN
					SELECT 
					-101 AS Codigo,
					NULL AS IdTramite,
					NULL AS NombreArchivo, 
					NULL AS NombreArchivoCDN,
					NULL AS CodigoPublico
				END
			END
			ELSE
			BEGIN
				SELECT 
				-99 AS Codigo,
				NULL AS IdTramite,
				NULL AS NombreArchivo, 
				NULL AS NombreArchivoCDN,
				NULL AS CodigoPublico
			END
		END
END