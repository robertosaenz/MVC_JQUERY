IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteProducto_Listar') DROP PROCEDURE EVA_SaeTramiteProducto_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (21.02.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista los productos de la BD de Spring
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
EXEC EVA_SaeTramiteProducto_Listar '00002700'
EXEC EVA_SaeTramiteProducto_Listar '00002500',1
*/

CREATE PROCEDURE [EVA_SaeTramiteProducto_Listar]
@CompaniaSocio CHAR(8),
@EsIquitos BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)

	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	IF(@EsIquitos = 1)
	BEGIN 
		--SC.CompaniaSocio = '+@CompaniaSocio+' AND
		EXEC
		(
			'SELECT 
			 SC.ServicioClasificacion,
			 CONCAT(TRIM(SC.ServicioClasificacion),'' - '',TRIM(SC.DescripcionLocal),'' - S/.'',CP.Monto) AS DescripcionLocal,
			 ''ASOC'' AS Sede
			 FROM '+ @LinkedServerSpringASOC + '.' + @BaseDatosSpringASOC + '.' + 'dbo.CO_ServicioClasificacion SC WITH (NOLOCK)
			 LEFT JOIN dbo.CO_Precio CP WITH(NOLOCK) ON CP.ItemCodigo =SC.ServicioClasificacion
			 WHERE 
			 SC.NumeroDigitos = 10 AND 
			 SC.ServicioClasificacion in (
			''3070700640'',
			''3070700650'',
			''3070700660'',
			''3070700670'',
			''3070700680'',
			''3070700690'', 
			''3070700700'',
			''3070700710'',
			''3070700720'',
			''3070700730'',
			''3070700740'',
			''3070700750'',
			''3070700760''
			);
			'
		)
	END
	ELSE
	BEGIN
		EXEC
		(
			'SELECT DISTINCT
			 SC.ServicioClasificacion,
			 CONCAT(TRIM(SC.ServicioClasificacion),'' - '',TRIM(SC.DescripcionLocal),'' - S/.'',CP.Monto) AS DescripcionLocal,
			 ''ACADEMICO'' AS Sede
			 FROM '+ @LinkedServerSpring + '.' + @BaseDatosSpring + '.' + 'dbo.CO_ServicioClasificacion SC WITH (NOLOCK)
			 LEFT JOIN dbo.CO_Precio CP WITH(NOLOCK) ON CP.ItemCodigo =SC.ServicioClasificacion
			 WHERE
			 CP.CompaniaSocio = '+@CompaniaSocio+' AND 
			 SC.NumeroDigitos = 10 AND
			 SC.CompaniaSocio = '+@CompaniaSocio+' AND SC.ServicioClasificacion in (
			''T030000440'',
			''T030000450'',
			''T030000460'',
			''T030000470'',
			''T030000480'',
			''T030000490'',
			''T030000500'',
			''T030000510'',
			''T030000520'',
			''T030000530'',
			''T030000540'',
			''T030000550'',
			''T030000560'',
			''3070700640'',
			''3070700650'',
			''3070700660'',
			''3070700670'',
			''3070700680'',
			''3070700690'',
			''3070700700'',
			''3070700710'',
			''3070700720'',
			''3070700730'',
			''3070700740'',
			''3070700750'',
			''3070700760''
			);
			'
		)
	END
END