IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeRequisitoPPP_Consultar') DROP PROCEDURE EVA_SaeRequisitoPPP_Consultar
GO
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (08/08/2022)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Valida el estado de practicas pre profesionales
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
DECLARE @rpta INT=0
EXEC [EVA_SaeRequisitoPPP_Consultar] 256623,'00002500',@rpta OUT
SELECT @rpta

DECLARE @rpta INT=0
EXEC [EVA_SaeRequisitoPPP_Consultar] 562001,'00002500',@rpta OUT
SELECT @rpta
*/ 
CREATE PROCEDURE [EVA_SaeRequisitoPPP_Consultar]
@IdActor			INT,
@CompaniaSocio		CHAR(8),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ValorCadena		VARCHAR(100)
	DECLARE @ValorTotal			INT
	DECLARE @ValorConsulta		INT

	IF(TRIM(@CompaniaSocio) = '00002700')
	BEGIN 
		SET @RetVal = 1
		RETURN @RetVal  
	END

	DECLARE @Temp TABLE   
	(
	 Id INT  
	 ,IdAlumno INT  
	 ,IdRegistro INT  
	 ,IdEmpresa INT  
	 ,IdSede INT  
	 ,IdFacultad INT  
	 ,IdUnidadNegocio INT  
	 ,IdUnidadAcademica INT  
	 ,UnidadAcademicaCodigo VARCHAR(10)  
	 ,UnidadAcademicaNombre VARCHAR(200)  
	 ,IdProducto INT  
	 ,ProductoCodigo VARCHAR(10)  
	 ,ProductoNombre VARCHAR(200)  
	 ,IdCurricula INT  
	 ,CurriculaNombre VARCHAR(200)  
	 ,CurriculaCodigo VARCHAR(200)  
	 ,SedeNombre VARCHAR(200)  
	 ,FacultadNombre VARCHAR(200)  
	 ,UnidadNegocioNombre VARCHAR(200)  
	 ,IdCurriculaProducto INT  
	 ,CodigoCurriculaProducto VARCHAR(200)        
	 ,NombreCurriculaProducto VARCHAR(200)       
	 ,IdCertificado INT  
	 ,CertificadoCodigo VARCHAR(200)  
	 ,CertificadoNombre VARCHAR(200)  
	 ,ACumplirAcad INT  
	 ,CumplidasAcad INT  
	 ,PromedioFinal VARCHAR(10)  
	 ,PromedioReal VARCHAR(10)  
	 ,PromedioCondicion VARCHAR(200)       
	 ,ACumplirPPP INT  
	 ,CumplidasPPP INT  
	 ,Glosa VARCHAR(500)       
	 ,Entregado INT  
	 ,ObservacionEntrega VARCHAR (MAX)  
	 ,IdUsuarioEntregaCreacion INT  
	 ,FechaEntrega VARCHAR(10)  
	 ,Certifica VARCHAR(2)  
	 ,Impreso INT  
	 ,FechaImprime VARCHAR(10)  
	 ,UsuarioImprime INT   
	)

	INSERT INTO @Temp    
	exec cCertificacionCurricular_Sel_Listar @IdActor

	SELECT 
	@ValorCadena=STRING_AGG(CASE WHEN ACumplirPPP=CumplidasPPP THEN 1 ELSE 0 END,',') 
	FROM @Temp 
	
	SELECT 
    @ValorTotal=COUNT(items)
	FROM dbo.udf_Split(@ValorCadena,',');

	SELECT 
    @ValorConsulta=COUNT(items)
	FROM 
    dbo.udf_Split(@ValorCadena,',')
	WHERE items = 1

	IF (@ValorTotal = @ValorConsulta)
	BEGIN
		SET @RetVal = 1
		RETURN @RetVal
	END

	IF (@ValorTotal = @ValorConsulta)
	BEGIN
		SET @RetVal = 1
		RETURN @RetVal
	END
	ELSE
	BEGIN
		SET @RetVal = 0
		RETURN @RetVal
	END
END

