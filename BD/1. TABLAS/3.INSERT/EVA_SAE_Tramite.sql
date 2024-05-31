IF NOT EXISTS(Select * from EVA_SAE_Tramite where CodigoPublico='CONSNOAFC')
BEGIN
	INSERT 
	[dbo].[EVA_SAE_Tramite] 
	([Nombre], [Descripcion], [DescripcionGrupo], [CodigoPublico], [EsActivo], [EsAutomatico], [TieneCosto], 
	 [GeneraAdjunto], [IdSolicitante], [IdEncargado], [IdCategoria], [IdServicioClasificacion], [HoraVencimiento], 
	 [DiasAtencion], [DiasHabilesResponderObservacion], [EsGrupo], [IdTramiteGrupo], [IdArchivoPortada], [MinimoAdjunto], 
	 [MaximoAdjunto], [TieneRespuestaSolicitante], [PermiteDescargarPlantilla], [FechaCreacion], [FechaModificacion], 
	 [UsuarioCreacion], [UsuarioModificacion], [PesoKbAdjunto], [FormatoAdjunto], [MinimoAdjuntoEncargado], [MaximoAdjuntoEncargado], 
	 [PesoKbAdjuntoEncargado], [FormatoAdjuntoEncargado], [TextoDetalle], [TextoAdjunto], [TituloDetalle], [TituloAdjunto], 
	 [NombreInterno], [IdServicioClasificacion_IQ], [MostrarCursoDiplomado]) 
	 
	 VALUES (N'Constancia de no adeudo EE', N'Es un documento que acredita que no tienes obligaciones de pago vigentes con nuestra institución.  Revisa un ejemplo de la constancia [LINK_CONSTANCIA_AQUI]  Tras finalizar el proceso, podrás descargar tu constancia ingresando a *Trámites finalizados.*', 
		NULL, N'CONSNOAFC', 1, 1, 0, N'AUTO', 1, 3, 1, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, 0, 0, 0, NULL, CAST(N'2022-06-30T16:46:52.240' AS DateTime), 
		NULL, 157688, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, N'Constancia de no adeudo FC', NULL, 1
	)
END 

IF NOT EXISTS(Select * from EVA_SAE_Tramite where CodigoPublico='CONSTREFC')
BEGIN
	INSERT 
		[dbo].[EVA_SAE_Tramite] 
		([Nombre], [Descripcion], [DescripcionGrupo], [CodigoPublico], [EsActivo], [EsAutomatico], [TieneCosto], 
		 [GeneraAdjunto], [IdSolicitante], [IdEncargado], [IdCategoria], [IdServicioClasificacion], [HoraVencimiento], 
		 [DiasAtencion], [DiasHabilesResponderObservacion], [EsGrupo], [IdTramiteGrupo], [IdArchivoPortada], [MinimoAdjunto], 
		 [MaximoAdjunto], [TieneRespuestaSolicitante], [PermiteDescargarPlantilla], [FechaCreacion], [FechaModificacion], 
		 [UsuarioCreacion], [UsuarioModificacion], [PesoKbAdjunto], [FormatoAdjunto], [MinimoAdjuntoEncargado], [MaximoAdjuntoEncargado], 
		 [PesoKbAdjuntoEncargado], [FormatoAdjuntoEncargado], [TextoDetalle], [TextoAdjunto], [TituloDetalle], [TituloAdjunto], 
		 [NombreInterno], [IdServicioClasificacion_IQ], [MostrarCursoDiplomado]) 

		 VALUES ('Constancia de retiro EE', 'Es un documento que acredita tu retiro del curso o diplomado.  Revisa un ejemplo de la constancia [LINK_CONSTANCIA_AQUI]  Tras finalizar el proceso, podrás descargar tu constancia ingresando a *Trámites finalizados.*  Recuerda que si deseas tramitar tu retiro puedes hacerlo en el trámite Trámites/Retiro de cursos o diplomados.*',
				NULL, 'CONSTREFC', 1, 1, 1, 'AUTO', 1, 0, 1, '3070700650', 24, NULL, NULL, 0, NULL, NULL, 0, 0, 0, 0, GETDATE(), NULL,
				1, 1, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Constancia de retiro FC', NULL, 1
		 )
END