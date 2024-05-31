IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SpringPagosCompletados_Listar') DROP PROCEDURE EVA_SpringPagosCompletados_Listar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (08/08/2022)
--Revisado por    : ahurtado (03/05/2022)
--Funcionalidad   : Lista los pagos completados de la BD de Spring filtrando por el Numero de Documento de Identidad
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:

EXEC [EVA_SpringPagosCompletados_Listar] 74550640 , '00002700' 
EXEC [EVA_SpringPagosCompletados_Listar] 48051990 , '00002700'
EXEC [EVA_SpringPagosCompletados_Listar] 74550640 , '00002500'
EXEC [EVA_SpringPagosCompletados_Listar] 70016932 , '00002500'
EXEC [EVA_SpringPagosCompletados_Listar] 73107495 , '00002500'
*/ 
CREATE PROCEDURE [EVA_SpringPagosCompletados_Listar]
@NumeroIdentidad CHAR(20),
@CompaniaSocio CHAR(8),
@Pagina			INT = 1,
@TamanoPagina	INT = 5
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON  

	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	DECLARE @TempPagos TABLE 
	(
		TipoDocumento CHAR(2),
		DescripcionCorta VARCHAR(100),
		NumeroDocumento VARCHAR(100),
		Descripcion VARCHAR(200),
		Sigla CHAR(3),
		DescripcionMoneda VARCHAR(50),
		MontoPagado MONEY,
		UltimaFechaModif VARCHAR(20),
		Interfase_Cuota INT
	)
	
	IF(@CompaniaSocio = '00002500')
	BEGIN
		
		INSERT INTO @TempPagos
		EXEC
		(
			'
			 SELECT 
			 TRIM(CD.TipoDocumento) AS TipoDocumento,
			 TRIM(TC.DescripcionCorta) AS DescripcionCorta,
			 TRIM(CD.NumeroDocumento) AS NumeroDocumento,
			 STUFF
			 (
				(
					SELECT '','' + TRIM(CDD.Descripcion) 
					FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_DocumentoDetalle CDD 
					WHERE CD.NumeroDocumento = CDD.NumeroDocumento AND CD.TipoDocumento = CDD.TipoDocumento AND CDD.Linea = 1
					GROUP BY CDD.Descripcion
					FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''varchar(MAX)''
				),1,1,''''
			 ) as Descripcion,
			 TRIM(MM.Sigla) AS Sigla,
			 TRIM(UPPER(LEFT(MM.DescripcionCorta,1))+LOWER(SUBSTRING(MM.DescripcionCorta,2,LEN(MM.DescripcionCorta)))) AS DescripcionMoneda,
			 CD.MontoPagado,
			 [dbo].[toMiliseconds](CD.UltimaFechaModif) as UltimaFechaModif,
			 ISNULL(CD.Interfase_Cuota,0) AS Interfase_Cuota
			 FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento CD WITH(NOLOCK)
			 INNER JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast PM WITH(NOLOCK) ON PM.Persona=CD.ClienteNumero
			 LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.MonedaMast MM  WITH(NOLOCK) ON CD.MonedaDocumento = MM.MonedaCodigo
			 LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.TipoComprobanteMast TC  WITH(NOLOCK) ON CD.TipoDocumento = TC.TipoComprobante
			 WHERE PM.Documento = ''' + @NumeroIdentidad + ''' AND CD.Estado=''CO'' AND CD.CompaniaSocio = ' + @CompaniaSocio + '
			 GROUP BY CD.TipoDocumento,TC.DescripcionCorta,CD.NumeroDocumento,cd.MonedaDocumento,MM.Sigla,MM.DescripcionCorta,CD.MontoPagado,CD.UltimaFechaModif,CD.Interfase_Cuota
			 UNION ALL
			 SELECT 
			 TRIM(CD.TipoDocumento) AS TipoDocumento,
			 TRIM(TC.DescripcionCorta) AS DescripcionCorta,
			 TRIM(CD.NumeroDocumento) AS NumeroDocumento,
			 STUFF
			 (
				(
					SELECT '','' + TRIM(CDD.Descripcion) 
					FROM '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.CO_DocumentoDetalle CDD 
					WHERE CD.NumeroDocumento = CDD.NumeroDocumento AND CD.TipoDocumento = CDD.TipoDocumento AND CDD.Linea = 1
					GROUP BY CDD.Descripcion
					FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''varchar(MAX)''
				),1,1,''''
			 ) as Descripcion,
			 TRIM(MM.Sigla) AS Sigla,
			 TRIM(UPPER(LEFT(MM.DescripcionCorta,1))+LOWER(SUBSTRING(MM.DescripcionCorta,2,LEN(MM.DescripcionCorta)))) AS DescripcionMoneda,
			 CD.MontoPagado,
			 [dbo].[toMiliseconds](CD.UltimaFechaModif) as UltimaFechaModif,
			 ISNULL(CD.Interfase_Cuota,0) AS Interfase_Cuota
			 FROM '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.CO_Documento CD  WITH(NOLOCK)
			 INNER JOIN '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.PersonaMast PM WITH(NOLOCK) ON PM.Persona=CD.ClienteNumero
			 LEFT JOIN '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.MonedaMast MM WITH(NOLOCK) ON CD.MonedaDocumento = MM.MonedaCodigo
			 LEFT JOIN '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.TipoComprobanteMast TC WITH(NOLOCK) ON CD.TipoDocumento = TC.TipoComprobante
			 WHERE PM.Documento = ''' + @NumeroIdentidad + ''' AND CD.Estado=''CO'' AND CD.CompaniaSocio = ' + @CompaniaSocio + '
			 GROUP BY CD.TipoDocumento,TC.DescripcionCorta,CD.NumeroDocumento,cd.MonedaDocumento,MM.Sigla,MM.DescripcionCorta,CD.MontoPagado,CD.UltimaFechaModif,CD.Interfase_Cuota;
			'
		)
	END
	IF(@CompaniaSocio = '00002600' OR @CompaniaSocio = '00002700')
	BEGIN
		INSERT INTO @TempPagos
		EXEC
		(
			'
			 SELECT 
			 TRIM(CD.TipoDocumento) AS TipoDocumento,
			 TRIM(TC.DescripcionCorta) AS DescripcionCorta,
			 TRIM(CD.NumeroDocumento) AS NumeroDocumento,
			 STUFF
			 (
				(
					SELECT '','' + TRIM(CDD.Descripcion) 
					FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_DocumentoDetalle CDD WITH(NOLOCK) 
					WHERE CD.NumeroDocumento = CDD.NumeroDocumento AND CD.TipoDocumento = CDD.TipoDocumento AND CDD.Linea = 1
					GROUP BY CDD.Descripcion
					FOR XML PATH(''''),TYPE).value(''(./text())[1]'',''varchar(MAX)''
				),1,1,''''
			 ) as Descripcion,
			 TRIM(MM.Sigla) AS Sigla,
			 TRIM(UPPER(LEFT(MM.DescripcionCorta,1))+LOWER(SUBSTRING(MM.DescripcionCorta,2,LEN(MM.DescripcionCorta)))) AS DescripcionMoneda,
			 CD.MontoPagado,
			 [dbo].[toMiliseconds](CD.UltimaFechaModif) as UltimaFechaModif,
			 ISNULL(CD.Interfase_Cuota,0) AS Interfase_Cuota
			 FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_Documento CD WITH(NOLOCK)
			 INNER JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.PersonaMast PM WITH(NOLOCK) ON PM.Persona=CD.ClienteNumero
			 LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.MonedaMast MM  WITH(NOLOCK) ON CD.MonedaDocumento = MM.MonedaCodigo
			 LEFT JOIN '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.TipoComprobanteMast TC  WITH(NOLOCK) ON CD.TipoDocumento = TC.TipoComprobante
			 WHERE PM.Documento = ''' + @NumeroIdentidad + ''' AND CD.Estado=''CO'' AND CD.CompaniaSocio = ' + @CompaniaSocio + '
			 GROUP BY CD.TipoDocumento,TC.DescripcionCorta,CD.NumeroDocumento,cd.MonedaDocumento,MM.Sigla,MM.DescripcionCorta,CD.MontoPagado,CD.UltimaFechaModif,CD.Interfase_Cuota
			'
		)
	END
	SELECT 
	TipoDocumento,
	DescripcionCorta,
	NumeroDocumento,
	Descripcion,
	Sigla,
	DescripcionMoneda,
	MontoPagado,
	UltimaFechaModif,
	Interfase_Cuota
	FROM @TempPagos
	ORDER BY UltimaFechaModif DESC
	OFFSET (@Pagina - 1) * @TamanoPagina ROWS
	FETCH NEXT @TamanoPagina ROWS ONLY

	SELECT COUNT(*) AS Docs 
	FROM @TempPagos
END



