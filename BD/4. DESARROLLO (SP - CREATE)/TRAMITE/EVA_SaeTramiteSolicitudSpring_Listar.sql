IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteSolicitudSpring_Listar') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (26.05.2022)
--Revisado por		: 
--Funcionalidad		: 
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
	EXEC EVA_SaeTramiteSolicitudSpring_Listar
*/
CREATE PROCEDURE [EVA_SaeTramiteSolicitudSpring_Listar]
AS
BEGIN
	-- SPRING SERVER VALUES
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @LinkedServerSpringASOC varchar(50)
	DECLARE @BaseDatosSpring varchar(50)
	DECLARE @BaseDatosSpringASOC varchar(50)
	DECLARE @CompaniaSocio char(8)
	-- PENDIENTE CONSULTAR SPRINGASOC Y REALIZAR UN UNION EN ZEGEL
	SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpring'
	SELECT @LinkedServerSpringASOC = Valor, @BaseDatosSpringASOC = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = 'ServidorVinculadoSpringASOC'

	select @CompaniaSocio=CompaniaSocio from Empresa where Activo=1

	-- FALTA AGREGAR EL PAGO EFECTIVO
	EXEC
	(
		'
		SELECT 
		TSS.IdTramiteSolicitud,
		''BANCO'' as MedioPagoFinal,
		COD.MontoTotal as MontoFinal,
		COD.MonedaDocumento as MonedaFinal,
		dbo.toMiliseconds(UltimaFechaModif) as FechaPago,  
		COD.TipoDocumento as TipoDocumentoSpring,
		TRIM(COD.NumeroDocumento) as NroDocumentoSpring
		FROM EVA_SAE_TramiteSolicitudSpring TSS
		INNER JOIN '+@LinkedServerSpring+'.'+@BaseDatosSpring+ '.' +'dbo.CO_Documento COD 
		ON COD.NumeroDocumento = TSS.NroDocumentoSpring AND COD.TipoDocumento = TSS.TipoDocumentoSpring AND COD.Estado IN (''CO'',''FA'')
		WHERE TSS.NroDocumentoSpring IS NOT NULL AND TSS.EsPagado=0 and EsAnulado=0 and EsActualizadoSpring=0  and COD.CompaniaSocio=''' + @CompaniaSocio + '''
		--UNION ALL
		--SELECT 
		--TSS.IdTramiteSolicitud,
		--''BANCO'' as MedioPagoFinal,
		--COD.MontoTotal as MontoFinal,
		--COD.MonedaDocumento as MonedaFinal,
		--dbo.toMiliseconds(UltimaFechaModif) as FechaPago,  
		--COD.TipoDocumento as TipoDocumentoSpring,
		--COD.NumeroDocumento as NroDocumentoSpring
		--FROM EVA_SAE_TramiteSolicitudSpring TSS
		--INNER JOIN '+@BaseDatosSpringASOC+'.'+@BaseDatosSpringASOC+ '.' +'dbo.CO_Documento COD 
		--ON COD.NumeroInterno = Replicate(''0'', 10 - Len(Convert(varchar(20), TSS.NumeroInternoSpring))) + Convert(varchar(20), TSS.NumeroInternoSpring) AND COD.Estado IN (''CO'',''FA'')  and COD.CompaniaSocio=''' + @CompaniaSocio + '''
		--WHERE  TSS.EsPagado=0 and EsAnulado=0 and EsActualizadoSpring=0
		'
	)

END
