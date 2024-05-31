IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteSolicitudSpring_Anular') DROP PROCEDURE EVA_SaeTramiteSolicitudSpring_Anular
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (18/11/2021)
--Revisado por    : 
--Funcionalidad   : Realiza la anulación de una solicitud de trámite a partir del tiempo de vencimiento establecido. 
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
EXEC [EVA_SaeTramiteSolicitudSpring_Anular] 
*/ 
CREATE PROCEDURE [dbo].[EVA_SaeTramiteSolicitudSpring_Anular]
AS
BEGIN
	SET NOCOUNT ON;

	-- LINKED SERVER 
	DECLARE @LinkedServerSpring varchar(50)
	DECLARE @BaseDatosSpring varchar(50)

	-- OPERATION VALUES
	DECLARE @Indice INT
	DECLARE @Cantidad INT

	-- LOCAL VALUES
	DECLARE @IdTramiteSolicitudLocal INT
	DECLARE @FechaCreacionLocal DATETIME
	DECLARE @HoraVencimientoLocal INT
	DECLARE @IdSedeLocal INT
	DECLARE @NumeroInternoSpringLocal INT
	DECLARE @CompaniaSocioLocal CHAR(8)
	DECLARE @NumeroInternoFinal CHAR(20)
	
	-- TEMPORAL TABLE
	DECLARE @Temp TABLE
	(
		Id INT Identity(1,1),
		IdTramiteSolicitud INT,
		FechaCreacion DATETIME,
		HoraVencimiento INT,
		IdSede INT,
		NumeroInternoSpring INT,
		CompaniaSocio CHAR(20)
	)
	

	INSERT INTO @Temp
	(IdTramiteSolicitud,FechaCreacion,HoraVencimiento,IdSede,NumeroInternoSpring,CompaniaSocio)
	SELECT
	TSS.IdTramiteSolicitud,
	TSS.FechaCreacion,
	TR.HoraVencimiento,
	TS.IdSede,
	TSS.NumeroInternoSpring,
	E.CompaniaSocio
	FROM EVA_SAE_TramiteSolicitudSpring TSS
	INNER JOIN EVA_SAE_TramiteSolicitud TS ON TSS.IdTramiteSolicitud = TS.IdTramiteSolicitud
	INNER JOIN EVA_SAE_Tramite TR ON TR.IdTramite = TS.IdTramite 
	INNER JOIN EmpresaSede ES ON ES.IdSede = TS.IdSede
	INNER JOIN Empresa E ON E.IdEmpresa = ES.IdEmpresa
	WHERE EsPagado=0 and TSS.EsAnulado=0

	SET @Cantidad= @@ROWCOUNT
	SET @Indice = 1

	WHILE (@Indice <= @Cantidad)    
	BEGIN
		SELECT
		@IdTramiteSolicitudLocal = IdTramiteSolicitud,
		@FechaCreacionLocal = FechaCreacion,
		@HoraVencimientoLocal = HoraVencimiento,
		@IdSedeLocal = IdSede,
		@NumeroInternoSpringLocal = NumeroInternoSpring,
		@CompaniaSocioLocal = CompaniaSocio
		FROM @Temp 
		WHERE Id = @Indice

		IF(GETDATE() > DATEADD(HOUR,@HoraVencimientoLocal,@FechaCreacionLocal))
		BEGIN
			SELECT @LinkedServerSpring = Valor ,@BaseDatosSpring = Valor2 FROM Parametro WITH(NOLOCK) WHERE Nombre = IIF(@IdSedeLocal='4','ServidorVinculadoSpringASOC','ServidorVinculadoSpring')

			SET @NumeroInternoFinal = Replicate('0', 10 - Len(Convert(varchar(20), @NumeroInternoSpringLocal))) + Convert(varchar(20), @NumeroInternoSpringLocal)

			EXEC
			(
				'
					DECLARE @NumeroDocumento CHAR(14)
					DECLARE @TipoDocumento VARCHAR(2)
					DECLARE @Estado CHAR(2)

					SELECT @NumeroDocumento=NumeroDocumento,@TipoDocumento=TipoDocumento,@Estado=Estado from '+@LinkedServerSpring+'.'+@BaseDatosSpring+ '.' +'dbo.CO_DOCUMENTO WHERE CompaniaSocio = '''+@CompaniaSocioLocal+'''
					AND NumeroInterno = '''+@NumeroInternoFinal+'''
					IF (@NumeroDocumento is not null)
					BEGIN 
						IF (@Estado =''AP'' or @Estado=''PR'')
						BEGIN
							UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+ '.' +'dbo.CO_DOCUMENTO
							SET Estado = ''AN'',
							UltimoUsuario = ''EVAJOB'',
							UltimaFechaModif = GETDATE()
							WHERE 
							CompaniaSocio = '''+@CompaniaSocioLocal+'''
							AND NumeroDocumento = @NumeroDocumento 
							AND TipoDocumento = @TipoDocumento 
							AND Estado IN (''AP'',''PR'')
						END

						IF (@Estado =''AP'' or @Estado=''PR'' or @Estado=''AN'')
						BEGIN
							UPDATE EVA_SAE_TramiteSolicitudSpring 
							SET 
							EsAnulado = 1,
							FechaAnulacion = GETDATE(),
							FechaModificacion = GETDATE(),
							UsuarioModificacion=1
							WHERE
							IdTramiteSolicitud = '+ @IdTramiteSolicitudLocal  +'
						END
					END
					
				'	
			)
		END

		SET @Indice = @Indice + 1
	END
END


