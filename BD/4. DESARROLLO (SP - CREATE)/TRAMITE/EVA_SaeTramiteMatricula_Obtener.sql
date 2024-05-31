IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteMatricula_Obtener') DROP PROCEDURE EVA_SaeTramiteMatricula_Obtener
GO
--------------------------------------------------------------------------------      
--Creado por      : SCAYCHO (24/02/2022)
--Revisado por    : ahurtado (03/05/2022) [Pendiente optimizar proceso]
--Funcionalidad   : Retorna informaci�n necesaria para tr�mites especiales (CONSTANCIA DE NOTAS - VISADO DE SILABOS)
--Utilizado por   : EVA Tr�mites
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:     
EXEC EVA_SaeTramiteMatricula_Obtener '00002500', 1433857, 384617, 13,16
*/ 

CREATE PROCEDURE EVA_SaeTramiteMatricula_Obtener
@CompaniaSocio	CHAR(8),
@IdActor		INT,
@IdMatricula	INT,
@IdTramite		INT,
@IdCaso			INT
AS
BEGIN
	SET NOCOUNT ON 
	DECLARE @CodigoTramite VARCHAR(9), @IdCurricula INT, @Sede INT, @TerminosCodiciones varchar(max), @PagoTarjeta varchar (50), @EsIquitos BIT, @Sucursal varchar(10)

	--Se obtiene el c�digo p�blico del tr�mite
	SELECT @CodigoTramite = TRIM(T.CodigoPublico)
	FROM EVA_SAE_Tramite AS T WITH (NOLOCK)
	WHERE T.IdTramite = @IdTramite
	
	--Obtenemos la Sede de la Matricula
	SELECT @Sede = THPD.IdSede
	FROM EVA_AlumnoHistorialProductosDetalle AS THPD WITH (NOLOCK)
	WHERE THPD.IdAlumno = @IdActor AND THPD.IdUltimaMatricula = @IdMatricula

	--TerminosCondiciones y PagoTarjeta
	IF(@CompaniaSocio='00002500' AND @Sede = 4) 
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

	--Se obtiene la curr�cula
	SELECT @IdCurricula = THPD.IdCurricula
	FROM EVA_AlumnoHistorialProductosDetalle AS THPD WITH (NOLOCK)
	WHERE
	THPD.IdAlumno = @IdActor
	AND THPD.IdUltimaMatricula = @IdMatricula
	--AND THPD.EstadoAlumno = 'ACT'

	Select @Sucursal=Sucursal from Sede WHERE IdSede=@Sede

	SELECT 
	@CodigoTramite AS 'CodigoTramite', 
	@TerminosCodiciones TerminosCondiciones,
	TRIM(SC.DescripcionLocal) AS DescripcionLocal,
	IIF(@Sucursal ='SEIQ',CP2.Monto,CP.Monto) as Monto,
	@EsIquitos EsIquitos
	FROM EVA_SAE_tramite ST WITH(NOLOCK)
	LEFT JOIN dbo.CO_ServicioClasificacion SC WITH(NOLOCK) ON SC.ServicioClasificacion = IIF(@EsIquitos=0,ST.IdServicioClasificacion,ST.IdServicioClasificacion_IQ) AND SC.CompaniaSocio = @CompaniaSocio
	LEFT JOIN dbo.CO_Precio CP WITH(NOLOCK) ON CP.ItemCodigo =ST.IdServicioClasificacion AND CP.CompaniaSocio = @CompaniaSocio AND CP.UnidadNegocio = @Sucursal
	LEFT JOIN dbo.CO_Precio_ASOC CP2 WITH(NOLOCK) ON CP2.ItemCodigo =ST.IdServicioClasificacion_IQ AND CP2.CompaniaSocio = @CompaniaSocio AND CP2.UnidadNegocio = @Sucursal
	WHERE 
	ST.IdTramite = @IdTramite AND 
	ST.EsActivo = 1

	--Se obtienen los requisitos del tr�mite
	EXEC EVA_SaeRequisito_Estado @IdActor, @CompaniaSocio, @IdTramite, @IdMatricula, @IdCaso

	SELECT
	Nombre,
	Valor
	FROM Parametro WITH (NOLOCK)
	WHERE
	Nombre IN (@PagoTarjeta, 'EVA_PAGARBANCO')
	AND Activo = 1

	--Se obtienen datos personalizados seg�n el c�digo p�blico del tr�mite
	IF (@CodigoTramite = 'CONSNOT' OR @CodigoTramite = 'VISILA')
		BEGIN
			EXEC EVA_SaeCurriculaModulo_Listar @IdCurricula, @IdMatricula, @IdActor, @CodigoTramite
		END
END