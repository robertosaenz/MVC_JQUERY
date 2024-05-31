IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramite_Editar') DROP PROCEDURE EVA_SaeTramite_Editar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (24.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Edita la configuración de un trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeTramite_Editar
1,
'Constancia de matrícula',
'Constancia de matrícula',
'Es un documento que acre',
NULL,
1,
'AUTO',
1,
0,
1,
157688,
3070700640,
24,
null,
null,
1,
1,
1,
1,
0,
0,
0,
0,
null,
null,
0,
0,
null,
null
,null
,null
,null
,null,
@Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [EVA_SaeTramite_Editar]
	@IdTramite							INT,
	@Nombre								VARCHAR(100),
	@NombreInterno						VARCHAR(150),
	@Descripcion						VARCHAR(MAX),
	@DescripcionGrupo					VARCHAR(MAX),
	@TieneCosto							BIT,
	@GeneraAdjunto						VARCHAR(5),
	@IdSolicitante						INT,
	@IdEncargado						INT,
	@IdCategoria						INT,
	@IdUsuario							INT,
	@IdServicioClasificacion			CHAR(20),
	@IdServicioClasificacion_IQ			CHAR(20),
	@HoraVencimiento					INT,
	@DiasAtencion						INT,
	@DiasHabilesResponderObservacion	INT,
	@TieneRespuestaSolicitante			BIT,
	@PermiteDescargarPlantilla			BIT,
	@MinimoAdjunto						INT,
	@MaximoAdjunto						INT,
	@PesoKbAdjunto						FLOAT,
	@FormatoAdjunto						VARCHAR(500),
	@MinimoAdjuntoEncargado				INT,
	@MaximoAdjuntoEncargado				INT,
	@PesoKbAdjuntoEncargado				FLOAT,
	@FormatoAdjuntoEncargado			VARCHAR(500),
	@TituloDetalle						VARCHAR(1000),
	@TituloAdjunto						VARCHAR(1000),
	@TextoDetalle						VARCHAR(1000),
	@TextoAdjunto						VARCHAR(1000),
	@MostrarCursoDiplomado				BIT,
	@RetVal								INT OUT  
AS 
BEGIN 
	SET NOCOUNT ON

	UPDATE [EVA_SAE_Tramite]
		SET 
		Nombre = @Nombre,
		NombreInterno = @NombreInterno,
		Descripcion = @Descripcion,
		DescripcionGrupo = @DescripcionGrupo,
		TieneCosto = @TieneCosto,
		GeneraAdjunto = @GeneraAdjunto,
		IdSolicitante = @IdSolicitante,
		IdEncargado = @IdEncargado,
		IdCategoria = @IdCategoria,
		IdServicioClasificacion = @IdServicioClasificacion,
		IdServicioClasificacion_IQ = @IdServicioClasificacion_IQ,
		HoraVencimiento = @HoraVencimiento,
		DiasAtencion = @DiasAtencion,
		DiasHabilesResponderObservacion = @DiasHabilesResponderObservacion,
		TieneRespuestaSolicitante = @TieneRespuestaSolicitante,
		PermiteDescargarPlantilla = @PermiteDescargarPlantilla,
		MinimoAdjunto = @MinimoAdjunto,
		MaximoAdjunto = @MaximoAdjunto,
		PesoKbAdjunto = @PesoKbAdjunto,
		FormatoAdjunto = @FormatoAdjunto,
		MinimoAdjuntoEncargado = @MinimoAdjuntoEncargado,
		MaximoAdjuntoEncargado = @MaximoAdjuntoEncargado,
		PesoKbAdjuntoEncargado = @PesoKbAdjuntoEncargado,
		FormatoAdjuntoEncargado = @FormatoAdjuntoEncargado,
		TituloDetalle = @TituloDetalle,
		TituloAdjunto = @TituloAdjunto,
		TextoDetalle = @TextoDetalle,
		TextoAdjunto = @TextoAdjunto,
		UsuarioModificacion = @IdUsuario,
		MostrarCursoDiplomado = @MostrarCursoDiplomado,
		FechaModificacion = GETDATE()
		WHERE 
		IdTramite = @IdTramite
		SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)

		--IF @MostrarCursoDiplomado = 0
		--BEGIN
		--	DELETE FROM EVA_SAE_Tramite_UnidadAcademica WHERE IdTramite = @IdTramite
		--END
END


