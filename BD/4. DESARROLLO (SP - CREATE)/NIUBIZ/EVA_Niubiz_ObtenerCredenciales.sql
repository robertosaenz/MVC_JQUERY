IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_Niubiz_ObtenerCredenciales') DROP PROCEDURE EVA_Niubiz_ObtenerCredenciales
GO 
-------------------------------------------------------------------------------    
--Creado por      :   ahurtado (26/05/2022)
--Revisado por    :    
--Funcionalidad   : Obtiene los parametros de Niubiz que le corresponden al alumno (depende de la sede en Zegel)
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:

	EXEC [EVA_Niubiz_ObtenerCredenciales] 232323,152833,'00002500'
	EXEC [EVA_Niubiz_ObtenerCredenciales] 232323,45060,'00002500'
	

*/ 

CREATE PROCEDURE [EVA_Niubiz_ObtenerCredenciales]
-- PARAMETROS AQUI
@IdActor int,
@IdUsuario int,
@CompaniaSocio varchar(10)
AS
BEGIN
  SET NOCOUNT ON
  -- TU CODIGO

  DECLARE @IdSede int
  DECLARE @NombreParametro varchar(100)
  SET @NombreParametro = 'EVA_NIUBIZ'

  SELECT TOP 1
    @IdSede = IdSede
  FROM EVA_InformacionActorDetalle
  WHERE IdUsuario = @IdUsuario

  IF (@IdSede = 4
    AND @CompaniaSocio = '00002500')
  BEGIN
    SET @NombreParametro = 'EVA_NIUBIZ_IQ'
  END
  SELECT
    Valor AS Valor_Correo,
	Valor2 AS Valor2_Contrasenia,
	Valor3 AS Valor3_Api,
	Valor4 AS Valor4_CodigoComercio
  FROM ParametroEmpresa
  WHERE Nombre = @NombreParametro

	DECLARE
	@EMail				VARCHAR(50),
	@Nombres			VARCHAR(50),
	@Apellidos			VARCHAR(100),
	@IdDocumentoTipo	INT,
	@NumeroIdentidad	VARCHAR(20),
	@DiasRegistrado		INT,
	@DocumentoTipo		VARCHAR(20)

	SELECT
	@EMail = U.EMail,
	@Nombres = U.Nombres,
	@Apellidos = CONCAT(U.ApellidoPaterno, ' ', U.ApellidoMaterno),
	@IdDocumentoTipo= A.IdDocumentoTipo,
	@NumeroIdentidad = A.NumeroIdentidad,
	@DiasRegistrado = DATEDIFF (DAY, U.FechaCreacion, GETDATE())
	FROM Usuario U WITH (NOLOCK)
	INNER JOIN Actor A WITH (NOLOCK)
	ON U.IdActor = A.IdActor
	WHERE
	U.IdUsuario = @IdUsuario

	SELECT
	@DocumentoTipo = MTR.Codigo
	FROM MaestroTabla MT WITH (NOLOCK)
	INNER JOIN MaestroTablaRegistro MTR WITH (NOLOCK)
	ON MT.IdMaestroTabla = MTR.IdMaestroTabla
	WHERE
	MT.Codigo IN ('TipoDocumento')
	AND MTR.IdMaestroRegistro = @IdDocumentoTipo

	SELECT
	@EMail AS EMail,
	@Nombres AS Nombres,
	@Apellidos AS Apellidos,
	@DocumentoTipo AS DocumentoTipo,
	@NumeroIdentidad AS NumeroIdentidad,
	@DiasRegistrado AS DiasRegistrado
END
GO
