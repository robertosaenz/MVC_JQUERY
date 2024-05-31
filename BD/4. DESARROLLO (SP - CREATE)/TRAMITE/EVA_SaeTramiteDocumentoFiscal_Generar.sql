IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteDocumentoFiscal_Generar') DROP PROCEDURE EVA_SaeTramiteDocumentoFiscal_Generar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (24.02.2022)
--Revisado por		: Retorna el Id de Persona de utilizado por Spring, si no existe lo genera
--Funcionalidad		: 
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
DECLARE @rpta INT = 0
EXEC EVA_SaeTramiteDocumentoFiscal_Generar 'PLDBTEST02','SpringPruebaSEE_Diario','20999999999','Prueba.SAC','prueba@gmail.com','Prueba 123','01','01','01',@rpta out
SELECT @rpta
*/
CREATE PROCEDURE [EVA_SaeTramiteDocumentoFiscal_Generar]
	@LinkedServerSpring VARCHAR(50),
	@BaseDatosSpring	VARCHAR(50),
	@NumeroDocumento    CHAR(20),
	@RazonSocial		VARCHAR(50),
	@CorreoElectronico	VARCHAR(50),
	@Direccion			VARCHAR(100),
	@Distrito			CHAR(3),
	@Provincia			CHAR(3),
	@Departamento		CHAR(3),
	@RetVal				INT OUTPUT
AS
BEGIN
	SET XACT_ABORT ON 

	-- DEFAULT VALUES ACTOR
	DECLARE @DocumentoTipoInput INT = 25
	DECLARE @TipoInput CHAR(1) = 'E'
	DECLARE @UsuarioCreacionInput INT = 1
	DECLARE @FechaCreacionInput DATETIME = GETDATE()
	DECLARE @EsPrivadoFechaNacInput INT = 1

	-- GENERATED ACTOR
	DECLARE @CorrelativoActor INT

	-- PERSONA MASTER
	DECLARE @PersonaActual INT
	DECLARE @CorrelativoPersona INT


	-- OPERATION VALUES
	DECLARE @TablePersonaInt TABLE (id int)

	DECLARE @TablePersona TABLE 
	(
		PersonaActual				INT,
		PersonaAntActual			CHAR(15),
		DireccionActual				VARCHAR(80),
		CodigoPostalActual			CHAR(3),
		ProvinciaActual				CHAR(3),
		DepartamentoActual			CHAR(3),
		CorreoElectronicoActual		VARCHAR(50),
		correoelectronicoFEActual	VARCHAR(150)
	)

	INSERT @TablePersona (PersonaActual,PersonaAntActual,DireccionActual,CodigoPostalActual,ProvinciaActual,DepartamentoActual,CorreoElectronicoActual,correoelectronicoFEActual)
	EXEC
	(
		'SELECT
		 Persona,
		 PersonaAnt,
		 Direccion,
		 CodigoPostal,
		 Provincia,
		 Departamento, 
		 CorreoElectronico,
		 correoelectronicoFE 
		 FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PersonaMast
		 WHERE documento = '''+@NumeroDocumento+'''         
		'
	)
	
	IF EXISTS(SELECT PersonaActual FROM @TablePersona)
	BEGIN 
		DECLARE @PersonaLocal				INT
		DECLARE @PersonaAntLocal			CHAR(15)
		DECLARE @DireccionLocal				VARCHAR(80)
		DECLARE @CodigoPostalLocal			CHAR(3)
		DECLARE @ProvinciaLocal				CHAR(3)
		DECLARE @DepartamentoLocal			CHAR(3)
		DECLARE @CorreoElectronicoLocal		VARCHAR(50)
		DECLARE @CorreoelectronicoFELocal	VARCHAR(150)

		DECLARE @UpdateDireccion			VARCHAR(100)
		DECLARE @UpdateDistrito				VARCHAR(100)
		DECLARE @UpdateDepartamento			VARCHAR(100)
		DECLARE @UpdateProvincia			VARCHAR(100)
		DECLARE @UpdateCorreoElectronico	VARCHAR(100)
		DECLARE @UpdateCorreoElectronicoFE	VARCHAR(100)
		
		SELECT
		@PersonaLocal = PersonaActual,
		@PersonaAntLocal = PersonaAntActual,
		@DireccionLocal = DireccionActual,
		@CodigoPostalLocal = CodigoPostalActual,
		@ProvinciaLocal = ProvinciaActual,
		@DepartamentoLocal = DepartamentoActual,
		@CorreoElectronicoLocal = CorreoElectronicoActual,
		@CorreoelectronicoFELocal = correoelectronicoFEActual
		FROM @TablePersona

		IF(@CorreoElectronico <> @CorreoElectronicoLocal)
		BEGIN
			SET @UpdateCorreoElectronico = ',CorreoElectronico = '''+@CorreoElectronico+''''
			SET @UpdateCorreoElectronicoFE = ',CorreoElectronicoFE = '''+@CorreoElectronico+''''
		END

		IF(@Direccion <> @DireccionLocal)
		BEGIN
			SET @UpdateDireccion = ',Direccion = '''+@Direccion+''''
		END
		
		IF(@Distrito <> @CodigoPostalLocal)
		BEGIN
			SET @UpdateDistrito = ',Distrito = '''+@Distrito+''''
		END

		IF(@Departamento <> @DepartamentoLocal)
		BEGIN
			SET @UpdateDepartamento = ',Departamento = '''+@Departamento+''''
		END
		IF(@Provincia <> @ProvinciaLocal)
		BEGIN
			SET @UpdateProvincia = ',Provincia = '''+@Provincia+''''
		END
		
		EXEC 
		(
			'
				UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.persona_inter
				SET
				tiporegistro = ''I''
				'+ @UpdateCorreoElectronico +'
				'+ @UpdateDireccion +'
				'+ @UpdateDistrito +'
				'+ @UpdateDepartamento +'
				'+ @UpdateProvincia +'
			'
		)

		EXEC
		(
			'
				UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PersonaMast
				SET
				PersonaAnt = '''+@PersonaAntLocal+'''
				'+ @UpdateCorreoElectronico +'
				'+ @UpdateCorreoElectronicoFE +'
				'+ @UpdateDireccion +'
				'+ @UpdateDistrito +'
				'+ @UpdateDepartamento +'
				'+ @UpdateProvincia +'
				WHERE Persona = '+@PersonaLocal+'
			'
		)
		SET @RetVal = @PersonaAntLocal
	END
	ELSE
	BEGIN
		EXEC BDAdmin.DBO.fxSpNewCorrelativo 0, 'Actor', 15, 1, @DocumentoTipoInput, @NumeroDocumento, @TipoInput, @CorrelativoActor OUTPUT 
		
		INSERT INTO Actor
		(
			IdActor,
			NombreCompleto,
			NombreSoloBusqueda,
			IdDocumentoTipo,
			Ruc,
			DireccionCompleta,
			Tipo,
			UsuarioCreacion,
			FechaCreacion,
			EsPrivadoFechaNac
		)
		VALUES
		(
			@CorrelativoActor,
			@RazonSocial,
			@RazonSocial,
			@DocumentoTipoInput,
			@NumeroDocumento,
			@Direccion,
			@TipoInput,
			@UsuarioCreacionInput,
			@FechaCreacionInput,
			@EsPrivadoFechaNacInput
		)

		INSERT INTO @TablePersonaInt(id)
		EXEC 
		(
			'
			INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.persona_inter
			(
				personacodigo,
				nombrecompleto,
				busqueda,
				tipodocumento,
				documento,
				tipopersona,
				direccion,
				codigoPostal,
				provincia,
				departamento,
				telefono,
				documentofiscal,
				documentoidentidad,
				correoelectronico,
				procesado,
				tipodocumentoCO,
				tiporegistro
			)
			VALUES
			(
				'+@CorrelativoActor+',
				'''+ @RazonSocial +''',
				'''+ @RazonSocial +''',
				''R'',
				'''+ @NumeroDocumento +''',
				''J'',
				'''+ @Direccion +''',
				'''+ @Distrito +''',
				'''+ @Provincia +''',
				'''+ @Departamento +''',
				''123456789'',
				'''+ @NumeroDocumento +''',
				'''+ @NumeroDocumento +''',
				'''+ @CorreoElectronico +''',
				''SI'',
				''BV'',
				''I''
			);
			SELECT  MAX(id) FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.persona_inter
		')
		
		DECLARE @TableUnidadReplicacion TABLE (CorrelativoPersona INT)

		INSERT INTO @TableUnidadReplicacion(CorrelativoPersona)
		EXEC
		(
			'
				SELECT CASE WHEN PersonaActual % 2 = 1 THEN PersonaActual+2 ELSE PersonaActual+3 END 
				FROM '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.SY_UnidadReplicacion
				WHERE UnidadReplicacion = ''LIMA''
			'
		)

		SELECT @CorrelativoPersona = CorrelativoPersona FROM @TableUnidadReplicacion

		EXEC
		(
			'
				UPDATE '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.SY_UnidadReplicacion
				SET 
				PersonaActualImp = '+@CorrelativoPersona+',
				PersonaActual = '+@CorrelativoPersona+',
				UltimoUsuario = ''MISESF'',
				UltimaFechaModif = GetDate()
				WHERE UnidadReplicacion = ''LIMA''
			'
		)

		DECLARE @OrigenInput CHAR(4) = 'LIMA'
		DECLARE @TipoDocumentoInput CHAR(1) = 'R'
		DECLARE @EsClienteInput CHAR(1) = 'S'
		DECLARE @EsProveedorInput CHAR(1) = 'N'
		DECLARE @EsEmpleadoInput CHAR(1) = 'N'
		DECLARE @EsOtroInput CHAR(1) = 'N'
		DECLARE @TipoPersonaInput CHAR(1) = 'J'
		DECLARE @EstadoCivilInput CHAR(1) = 'S'
		DECLARE @EnfermedadGraveFlagInput CHAR(1) = 'N'
		DECLARE @EstadoInput CHAR(1) = 'A'
		DECLARE @UltimoUsuarioInput CHAR(20) = 'MISESF'
		DECLARE @IngresoFechaRegistroInput DATETIME = GETDATE()
		DECLARE @IngresoAplicacionCodigoInput CHAR(1) = 'CO'
		DECLARE @IngresoUsuarioInput CHAR(20) = 'MISESF'
		DECLARE @PYMEFlagInput CHAR(1) = 'M'

		EXEC
		(
			'
				INSERT INTO '+@LinkedServerSpring+'.'+@BaseDatosSpring+'.'+'dbo.PersonaMast
				(
					Persona,
					Origen,
					NombreCompleto,
					Busqueda,
					TipoDocumento,
					Documento,
					EsCliente,
					EsProveedor,
					EsEmpleado,
					EsOtro,
					TipoPersona,
					EstadoCivil,
					Direccion,
					CodigoPostal,
					Provincia,
					Departamento,
					Telefono,
					DocumentoFiscal,
					DocumentoIdentidad,
					PersonaAnt,
					CorreoElectronico,
					EnfermedadGraveFlag,
					Estado,
					UltimoUsuario,
					IngresoFechaRegistro,
					IngresoAplicacionCodigo,
					IngresoUsuario,
					PYMEFlag,
					CorreoElectronicoFE
				)
				VALUES
				(
					'+ @CorrelativoPersona +',
					'''+ @OrigenInput +''',
					'''+ @RazonSocial +''',
					'''+ @RazonSocial +''',
					'''+ @TipoDocumentoInput +''',
					'''+ @NumeroDocumento +''',
					'''+ @EsClienteInput +''',
					'''+ @EsProveedorInput +''',
					'''+ @EsEmpleadoInput +''',
					'''+ @EsOtroInput +''',
					'''+ @TipoPersonaInput +''',
					'''+ @EstadoCivilInput +''',
					'''+ @Direccion +''',
					'''+ @Distrito +''',
					'''+ @Provincia +''',
					'''+ @Departamento +''',
					''123456789'',
					'''+ @NumeroDocumento +''',
					'''+ @NumeroDocumento +''',
					'''+ @CorrelativoActor +''',
					'''+ @CorreoElectronico +''',
					'''+ @EnfermedadGraveFlagInput +''',
					'''+ @EstadoInput +''',
					'''+ @UltimoUsuarioInput +''',
					'''+ @IngresoFechaRegistroInput +''',
					'''+ @IngresoAplicacionCodigoInput +''',
					'''+ @IngresoUsuarioInput +''',
					'''+ @PYMEFlagInput +''',
					'''+ @CorreoElectronico +'''
				);

			'
		)
		SET @RetVal = @CorrelativoActor
	END
	--select Ruc,* from Actor where Tipo = 'E' order by idactor desc
	--select Ruc,* from Actor where IdActor=1542104
	--select * from @ScopeIdentity
	--delete from actor where Ruc= '20999999999'
END
