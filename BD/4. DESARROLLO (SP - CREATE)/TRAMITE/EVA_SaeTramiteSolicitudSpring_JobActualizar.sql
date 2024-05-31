IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpring_JobActualizar') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_JobActualizar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Realiza la actualización de las columnas nroDocumento y TipoDocumento con información que procesa Spring
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpring_JobActualizar] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpring_JobActualizar]
AS
BEGIN
	SET NOCOUNT ON
	-- LINKED SERVER 
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @BaseDatosSpring varchar(50)

	-- OPERATION VALUES
	DECLARE @Indice INT
	DECLARE @Cantidad INT

	DECLARE @NumeroInternoFinal CHAR(20)

	DECLARE @IdTramiteSolicitudLocal INT
	DECLARE @IdSedeLocal INT
	DECLARE @NumeroInternoSpringLocal INT
	DECLARE @CompaniaSocio char(8)

	select @CompaniaSocio=CompaniaSocio from Empresa where Activo=1

	DECLARE @TempTable TABLE
	(
		Id INT IDENTITY(1,1),
		IdSede INT,
		NumeroInternoSpring INT,
		IdTramiteSolicitud INT
	)

	DECLARE @TempSpring TABLE
	(
		NumeroDocumento CHAR(14),
		TipoDocumento CHAR(2)
	)

	INSERT INTO @TempTable
	(IdSede,NumeroInternoSpring,IdTramiteSolicitud)
	SELECT 
	TS.IdSede ,
	TSS.NumeroInternoSpring,
	TSS.IdTramiteSolicitud
	FROM EVA_SAE_TramiteSolicitudSpring TSS WITH(NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitud TS WITH(NOLOCK) ON TS.IdTramiteSolicitud = TSS.IdTramiteSolicitud
	WHERE TSS.TipoDocumentoSpring IS NULL AND GETDATE() > DATEADD(MINUTE,1,TSS.FechaCreacion)

	SET @Cantidad= @@ROWCOUNT
	SET @Indice = 1

	WHILE (@Indice <= @Cantidad)    
	BEGIN
		SELECT 
		@NumeroInternoSpringLocal = NumeroInternoSpring,
		@IdSedeLocal = IdSede,
		@IdTramiteSolicitudLocal = IdTramiteSolicitud
		FROM @TempTable
		WHERE Id = @Indice

		SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = IIF(@IdSedeLocal='4','ServidorVinculadoSpringASOC','ServidorVinculadoSpring')

		SET @NumeroInternoFinal = Replicate('0', 10 - Len(Convert(varchar(20), @NumeroInternoSpringLocal))) + Convert(varchar(20), @NumeroInternoSpringLocal)
		
		INSERT INTO @TempSpring
		(NumeroDocumento,TipoDocumento)
		EXEC
		(
			'
				SELECT NumeroDocumento,TipoDocumento 
				FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+ '.' +'dbo.CO_DOCUMENTO WITH(NOLOCK)
				WHERE NumeroDocumento <> '' AND TipoDocumento <> '' AND NumeroInterno = '''+@NumeroInternoFinal+'''  AND CompaniaSocio=''' + @CompaniaSocio + '''
			'
		)

		IF EXISTS (Select COUNT (1) FROM @TempSpring)
		BEGIN
			DECLARE @NumeroDocumentoLocal VARCHAR(30)
			DECLARE @TipoDocumentoLocal VARCHAR(10)

			SELECT @NumeroDocumentoLocal = TRIM(NumeroDocumento),@TipoDocumentoLocal = TRIM(TipoDocumento) FROM @TempSpring

			UPDATE EVA_SAE_TramiteSolicitudSpring 
			SET NroDocumentoSpring = @NumeroDocumentoLocal, TipoDocumentoSpring = @TipoDocumentoLocal
			WHERE IdTramiteSolicitud = @IdTramiteSolicitudLocal

			SET @NumeroDocumentoLocal = null
			SET @TipoDocumentoLocal = null
		END
		
		SET @Indice = @Indice + 1
		DELETE FROM @TempSpring 
	END
END

