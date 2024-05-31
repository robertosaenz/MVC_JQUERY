IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeConstancia_Registrar2') DROP PROCEDURE [EVA_SaeConstancia_Registrar2]
GO

/****** Object:  StoredProcedure [dbo].[[EVA_SaeConstancia_Registrar2]]    Script Date: 19/07/2022 11:32:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
@2		19/07/22	Miler			Se modificó el tipo de devolución de los campos a reemplazar en la constancia, se envía tipo lista mediante un pivot
*/

/*      
Ejemplo:    
ESCENARIO 1
EXEC [EVA_SaeConstancia_Registrar] 681,1,1
ESCENARIO 2
EXEC [EVA_SaeConstancia_Registrar] 2,1
ESCENARIO 3
EXEC [EVA_SaeConstancia_Registrar2] 721,1
*/
CREATE PROCEDURE dbo.[EVA_SaeConstancia_Registrar2]
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

				Select @idCurricula=IdCurricula, @IdUnidadAcademica=IdUnidadAcademica, @IdProductoSel =IdProducto, @IdRegistro = IdRegistro from EVA_AlumnoHistorialProductosDetalle WITH(NOLOCK) where IdAlumno =@Actor and IdUltimaMatricula=@IdMatriculaSel
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
					ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula
					WHERE AC.IdAlumno = @Actor AND AC.IdRegistro = @IdRegistro
					GROUP BY ACC.IdModulo

					INSERT INTO @UnidadDidacticaAprobadaXModulo
					SELECT ACC.IdModulo, COUNT(*)
					FROM AlumnoCurricula AC WITH (NOLOCK)
					INNER JOIN AlumnoCurriculaCurso ACC WITH (NOLOCK)
					ON ACC.IdAlumno = AC.IdAlumno AND ACC.IdRegistro = AC.IdRegistro AND ACC.IdCurricula = AC.IdCurricula
					WHERE AC.IdAlumno = @Actor AND AC.IdRegistro = @IdRegistro AND ACC.PromedioCondicion = 'A'
					GROUP BY ACC.IdModulo

					SELECT @PeriodosLista = STUFF(
						(
							SELECT ', ' + MTR.Disponible4
							FROM @UnidadDidacticaXModulo UDXM
							INNER JOIN @UnidadDidacticaAprobadaXModulo UDCXM
							ON UDXM.IdModulo = UDCXM.IdModulo AND UDXM.Cantidad = UDCXM.Cantidad
							INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
							ON MTR.IdMaestroTabla IN (SELECT MT.IdMaestroTabla FROM MaestroTabla MT WITH (NOLOCK) WHERE MT.Codigo = 'TipoSemestre') AND UDXM.IdModulo = CONVERT(INT, ISNULL(MTR.Disponible1, 0))
							ORDER BY UDXM.IdModulo
							FOR XML PATH('')
						),
						1, 1, ''
					)
					-- @1 - fin
				END

/* FIN DE CONSULTAS PERSONALIZADAS POR TRÁMITE*/	
				
					

				IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.tables C WHERE C.OBJECT_ID=OBJECT_ID('TEMP')) DROP TABLE TEMP
				--SI CAMBIA EL NOMBRE A REEMPLAZAR EN ALGUNOS DOCUMENTOS, AGREGAR UN NUEVO CAMPO CON EL NOMBRE Y ALMACENAR EL MISMO VALOR:
				--EJEMPLO: En un documento existe [Nombre_del_Curso_o_Diplomado] y en otro [Nombre_del_Curso]
				--Crear [Nombre_del_Curso] e igualmente almacenar el mismo valor que [Nombre_del_Curso_o_Diplomado]

				CREATE TABLE TEMP
				(	[APELLIDOS_Y_NOMBRES] varchar(200),
					CodigoAlumno varchar(20),
					[Nombre_del_Curso_o_Diplomado] varchar(200),
					[PROGRAMA_DE_ESTUDIOS] VARCHAR(20),
					[PERIODO] varchar(20),
					[DNI] VARCHAR(40),
					[Ciudad] varchar(200),
					[SEDE] varchar(100),
					PromocionCodigo varchar(50),
					[Día] varchar(50),
					[Mes] varchar(200),
					[Año] varchar(50),
					[EG-0XXX-2021-SG-IDAT] varchar (100),
					NombreBeca varchar(1000),
					[Nº_PERDIODO_ACADÉMICO] int,
					[PERIODO_ACADÉMICO] VARCHAR(100),
					IdActor int,
					NivelFormativo varchar(100),
					ListaPeriodos VARCHAR(100),
					OrdenMeritoProductoTexto VARCHAR(50),
					[Curso_o_Diplomado] varchar(1000) )

				SET LANGUAGE Spanish
				INSERT INTO TEMP 
				SELECT TOP 1
				CONCAT(U.Nombres,' ',U.ApellidoPaterno,' ',U.ApellidoMaterno) AS NombreSolicitante,
				U.Login AS CodigoAlumno,
				ISNULL(P.ProductoNombreCorto,'No Especificado') AS ProductoNombreCorto,
				ISNULL(P.ProductoNombreCorto,'No Especificado') AS ProductoNombreCorto,
				ISNULL(PE.Codigo,'No Especificado') AS CodigoPeriodo,
				ISNULL(A.NumeroIdentidad,0) AS NumeroIdentidad,
				LOWER(ISNULL(S.DireccionRegional,'')) AS DireccionRegional,
				UPPER(S.Nombre) AS NombreSede,
				PR.PromocionCodigo,
				DAY(getdate()) AS Dia,
				DATENAME(MONTH, GETDATE()) AS Mes,
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
	 
				 SELECT P.SUB as IdCampo, P.Name AS Value
				 FROM (
					 SELECT
						 CAST([APELLIDOS_Y_NOMBRES] as varchar(200)) [APELLIDOS_Y_NOMBRES],
						 CAST([Nombre_del_Curso_o_Diplomado] as varchar(200)) [Nombre_del_Curso_o_Diplomado],
						 CAST([PROGRAMA_DE_ESTUDIOS] AS VARCHAR(200)) [PROGRAMA_DE_ESTUDIOS],
						 CAST([SEDE] as varchar(200)) [SEDE],
						 CAST([DNI] AS VARCHAR(200)) [DNI],
						 CAST([Nº_PERDIODO_ACADÉMICO] AS VARCHAR(200)) [Nº_PERDIODO_ACADÉMICO],
						 CAST([PERIODO_ACADÉMICO] AS VARCHAR(200)) [PERIODO_ACADÉMICO],
						 CAST([PERIODO] as varchar(200)) [PERIODO],
						 CAST([Ciudad] as varchar(200)) [Ciudad],
						 CAST([Día] as varchar(200)) [Día],
						 CAST([Mes] as varchar(200)) [Mes],
						 CAST([Año] as varchar(200)) [Año],
						 CAST([EG-0XXX-2021-SG-IDAT] as varchar(200)) [EG-0XXX-2021-SG-IDAT],
						 CAST([Curso_o_Diplomado] AS VARCHAR(200)) [Curso_o_Diplomado]
					 FROM TEMP
				 ) TEMP1
				 UNPIVOT
				 (
					Name
					FOR SUB IN (
							[APELLIDOS_Y_NOMBRES],
							[Nombre_del_Curso_o_Diplomado], 
							[PROGRAMA_DE_ESTUDIOS],
							[DNI],
							[Nº_PERDIODO_ACADÉMICO],
							[PERIODO_ACADÉMICO],
							[PERIODO],
							[Ciudad], 
							[SEDE],
							[Día], 
							[Mes], 
							[Año],
							[EG-0XXX-2021-SG-IDAT],
							[Curso_o_Diplomado])
					 ) P
	
				IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.tables C WHERE C.OBJECT_ID=OBJECT_ID('TEMP')) DROP TABLE TEMP
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
