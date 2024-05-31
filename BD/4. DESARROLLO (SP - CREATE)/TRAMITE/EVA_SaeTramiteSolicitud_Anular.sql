IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitud_Anular') DROP PROCEDURE EVA_SaeTramiteSolicitud_Anular
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Realiza la anulación de una solicitud de trámite a partir del estado de anulación de tramitesolicitudSpring
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitud_Anular] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitud_Anular]
AS
BEGIN
	SET NOCOUNT ON;
	-- OPERATION VALUES
	DECLARE @Indice						INT
	DECLARE @Cantidad					INT

	-- LOCAL VALUES
	DECLARE @IdTramiteSolicitudLocal	INT
	
	DECLARE @NombreLocal				VARCHAR(50)
	DECLARE @NombreTramiteLocal			VARCHAR(50)
	DECLARE @CorreosLocal				VARCHAR(MAX)

	-- TEMPORAL TABLE
	DECLARE @Temp TABLE
	(
		Id								INT IDENTITY(1,1),
		IdTramiteSolicitud				INT
	)
	DECLARE @TempCorreo TABLE
	(
		Nombre							VARCHAR(100),
		NombreTramite					VARCHAR(100),
		Codigo							INT,
		HoraVencimiento					INT,
		Correos							VARCHAR(MAX)
	)
	DECLARE @ValoresReemplazo TABLE
	(
		Id								INT,
		NombreColumna					VARCHAR(50),
		ValorColumna					VARCHAR(50)
	)

	DECLARE @CodigoRemitenteLocal		VARCHAR(20)
	DECLARE @CodigoLocal				CHAR(9) 
	DECLARE	@AsuntoMensajeLocal			VARCHAR(255)
	DECLARE	@CuerpoMensajeLocal			VARCHAR(MAX)

	INSERT INTO @Temp
	(IdTramiteSolicitud)
	SELECT TS.IdTramiteSolicitud FROM EVA_SAE_TramiteSolicitud TS 
	INNER JOIN EVA_SAE_Tramite T ON T.IdTramite = TS.IdTramite
	INNER JOIN EVA_SAE_TramiteSolicitudSpring TSS ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud 
	WHERE TS.EsAnulado=0 AND T.TieneCosto = 1 AND TSS.EsAnulado=1 AND TS.IdEstado = 2

	SET @Cantidad= @@ROWCOUNT
	SET @Indice = 1

	WHILE (@Indice <= @Cantidad)    
	BEGIN
		DECLARE @TempPlantilla TABLE
		(
			IdPlantilla						INT,
			CodigoRemitente					VARCHAR(20),
			Codigo							CHAR(9),
			AsuntoMensaje					VARCHAR(255),
			CuerpoMensaje					VARCHAR(MAX)
		)

		SELECT
		@IdTramiteSolicitudLocal = IdTramiteSolicitud
		FROM @Temp 
		WHERE Id = @Indice

		INSERT INTO @TempPlantilla
		(IdPlantilla,CodigoRemitente,Codigo,AsuntoMensaje,CuerpoMensaje)
		EXEC EVA_SaeTramiteSolicitud_ActualizarEstado @IdTramiteSolicitudLocal,'NEG',1	

		SELECT 
		@CodigoRemitenteLocal = CodigoRemitente, 
		@CodigoLocal = TRIM(Codigo), 
		@AsuntoMensajeLocal = AsuntoMensaje,
		@CuerpoMensajeLocal = CuerpoMensaje
		FROM @TempPlantilla

		INSERT INTO @TempCorreo
		(Nombre,NombreTramite,Codigo,HoraVencimiento,Correos)
		EXEC EVA_SaePlantillaCorreo_ObtenerDatos @IdTramiteSolicitudLocal,@CodigoLocal, 1

		SET @CorreosLocal = (SELECT TOP 1 Correos FROM @TempCorreo)

		DECLARE @XmlCorreo XML

		SET @XmlCorreo = (SELECT TC.Nombre,TC.NombreTramite,TC.Codigo,TC.HoraVencimiento
		FROM 
		(SELECT 1) as D(N)
		OUTER APPLY 
		(
			SELECT TOP(1) Nombre,NombreTramite,Codigo,HoraVencimiento,Correos
			FROM @TempCorreo
		) AS TC
		FOR XML PATH(''), elements xsinil, type)

		INSERT INTO @ValoresReemplazo
		(Id,NombreColumna,ValorColumna)
		SELECT  
		row_number() OVER (ORDER BY Tbl.Col.value('local-name(.)', 'sysname')) ,
		Tbl.Col.value('local-name(.)', 'sysname'),
		Tbl.Col.value('(.)[1]', 'varchar(50)')
		FROM   @XmlCorreo.nodes('*') Tbl(Col)

		DECLARE @IndiceParametros int = 1
		DECLARE @CantidadParametros INT
		SELECT @CantidadParametros= COUNT(Id) FROM @ValoresReemplazo

		WHILE @IndiceParametros <= @CantidadParametros
		BEGIN
			DECLARE @NombreColumnaLocal VARCHAR(MAX)
			DECLARE @ValorColumnaLocal VARCHAR(MAX)

			SELECT  
			@NombreColumnaLocal = NombreColumna,
			@ValorColumnaLocal = ValorColumna
			FROM @ValoresReemplazo where Id = @IndiceParametros

			SET @AsuntoMensajeLocal= Replace(@AsuntoMensajeLocal,'['+@NombreColumnaLocal+']',@ValorColumnaLocal)
			SET @CuerpoMensajeLocal= Replace(@CuerpoMensajeLocal,'['+@NombreColumnaLocal+']',@ValorColumnaLocal)

			SET @IndiceParametros = @IndiceParametros + 1
		END

		-- LINEA DE PRUEBA
		--SELECT @CodigoRemitenteLocal,@CorreosLocal,@AsuntoMensajeLocal,@CuerpoMensajeLocal

		-- ENVIO A BDSMTP
		--DECLARE @rptaEnvioCorreo INT = 0
		--EXEC WS_Email_Insertar @CodigoRemitenteLocal,@CorreosLocal,@AsuntoMensajeLocal,@CuerpoMensajeLocal,'HTML', @rptaEnvioCorreo OUT

		--IF(@rptaEnvioCorreo =-51)
		--BEGIN
		--	EXEC EVA_Log_Registrar 'Trámites','EVA JOB' , 'EVA_SaeTramiteSolicitud_Anular' , 'No se inserto email en BDSMTP'
		--END
		
		UPDATE EVA_SAE_TramiteSolicitud SET EsAnulado = 1 WHERE IdTramiteSolicitud = @IdTramiteSolicitudLocal

		SET @Indice = @Indice + 1

		DELETE FROM @TempCorreo
		DELETE FROM @ValoresReemplazo 
	END
END


