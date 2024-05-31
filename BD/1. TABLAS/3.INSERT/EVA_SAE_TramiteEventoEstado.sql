IF NOT EXISTS(Select * from EVA_SAE_TramiteEventoEstado where IdTramite=26)
BEGIN
	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(26, 1, 1, 3, null, null, null, null, 'INI', GETDATE(), null, 157688, 157688)

	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(26, 3, 2, 5, null, null, null, null, null, GETDATE(), null, 157688, 157688)

	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(26, 5, 3, null, null, null, 'CONCERFIN', null, 'FIN', GETDATE(), null, 157688, 157688)
END


IF NOT EXISTS(Select * from EVA_SAE_TramiteEventoEstado where IdTramite=27)
BEGIN
	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(27, 1, 1, 2, null, null, null, null, 'INI', GETDATE(), null, 157688, 157688)

	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(27, 2, 2, 3, null, 7, null, null, null, GETDATE(), null, 157688, 157688)

	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(27, 5, 4, null, null, null, 'CONCERFIN', null, 'FIN', GETDATE(), null, 157688, 157688)

	INSERT 
		EVA_SAE_TramiteEventoEstado
		([IdTramite],[IdEstado],[Orden],[FlujoNormal],[FlujoComplementario],[FlujoNegativo],[CorreoSolicitante],
			[CorreoEncargado],[EstadoSolicitud],[FechaCreacion],[FechaModificacion],[UsuarioCreacion],[UsuarioModificacion])
		VALUES
		(27, 7, 5, null, null, null, null, null, 'FIN', GETDATE(), null, 157688, 157688)
END
