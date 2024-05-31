IF NOT EXISTS( SELECT 1 FROM EVA_SAE_Tramite WHERE CodigoPublico in ('JUSTDPI','RECUPNOTA'))
BEGIN
INSERT INTO [dbo].[EVA_SAE_Tramite]
           ([Nombre]
           ,[Descripcion]
           ,[DescripcionGrupo]
           ,[CodigoPublico]
           ,[EsActivo]
           ,[EsAutomatico]
           ,[TieneCosto]
           ,[GeneraAdjunto]
           ,[IdSolicitante]
           ,[IdEncargado]
           ,[IdCategoria]
           ,[IdServicioClasificacion]
           ,[HoraVencimiento]
           ,[DiasAtencion]
           ,[DiasHabilesResponderObservacion]
           ,[EsGrupo]
           ,[IdTramiteGrupo]
           ,[IdArchivoPortada]
           ,[MinimoAdjunto]
           ,[MaximoAdjunto]
           ,[TieneRespuestaSolicitante]
           ,[PermiteDescargarPlantilla]
           ,[FechaCreacion]
           ,[FechaModificacion]
           ,[UsuarioCreacion]
           ,[UsuarioModificacion]
           ,[PesoKbAdjunto]
           ,[FormatoAdjunto]
           ,[MinimoAdjuntoEncargado]
           ,[MaximoAdjuntoEncargado]
           ,[PesoKbAdjuntoEncargado]
           ,[FormatoAdjuntoEncargado]
           ,[TextoDetalle]
           ,[TextoAdjunto]
           ,[TituloDetalle]
           ,[TituloAdjunto]
           ,[NombreInterno]
           ,[IdServicioClasificacion_IQ])
     VALUES
           ('Justificación de condición DPI'
           ,'Por este medio puede salir de la condición DPI, continuar con tus clases y exámenes. <br>
			Primero, debes enviar una justificación documentada por motivos laborales, por desastres naturales, por salud propia o de un familiar cercano.
			Recuerda es una falta grave adjuntar documentos falsos.
			<br>
			Una vez iniciado el trámite podrá ser atendido en un plazo de *3 días hábiles*. Podrás hacer seguimiento a tu solicitud ingresando a *Trámites en Proceso.*'
           ,NULL
           ,'JUSTDPI'
           ,1
           ,0
           ,0
           ,'NO'
           ,1
           ,1
           ,2
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,NULL
           ,NULL
           ,0
           ,0
           ,0
           ,1
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,0
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,'Justificación de condición DPI'
           ,NULL),

		   ('Recuperación de Nota'
           ,'Podrás justificar tu inasistencia a un examen y solicitar una nueva evaluación. Primero, deberás enviar una justificación documentada
		   por motivos laborales, por desastres naturales, por salud propia o de un familiar cercano. Recuerda que es una falta grave adjuntar documentos falsos.
		   <br>
		   De ser aprobado el trámite, recibirás un correo con la fecha programada para el examen. En caso de no ser aprobado, puedes comunicarte con tu docente.
		   <br>
		   Una vez iniciado el trámite podrá ser atendido en un plazo de *3 días hábiles*. Podrás hacer seguimiento a tu solicitud ingresando a *Trámites en Proceso.*
		   <br>
		   Este trámite *no aplica para el examen final*, si quieres trámitarlo debes ingresar [Examen Sustitutorio]'
		   ,NULL
           ,'RECUPNOTA'
           ,1
           ,0
           ,0
           ,'NO'
           ,1
           ,1
           ,2
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,NULL
           ,NULL
           ,0
           ,0
           ,0
           ,1
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,0
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,'Recuperación de Nota'
           ,NULL)
END
GO


