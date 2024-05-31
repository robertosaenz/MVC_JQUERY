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
           ('Justificaci�n de condici�n DPI'
           ,'Por este medio puede salir de la condici�n DPI, continuar con tus clases y ex�menes. <br>
			Primero, debes enviar una justificaci�n documentada por motivos laborales, por desastres naturales, por salud propia o de un familiar cercano.
			Recuerda es una falta grave adjuntar documentos falsos.
			<br>
			Una vez iniciado el tr�mite podr� ser atendido en un plazo de *3 d�as h�biles*. Podr�s hacer seguimiento a tu solicitud ingresando a *Tr�mites en Proceso.*'
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
           ,'Justificaci�n de condici�n DPI'
           ,NULL),

		   ('Recuperaci�n de Nota'
           ,'Podr�s justificar tu inasistencia a un examen y solicitar una nueva evaluaci�n. Primero, deber�s enviar una justificaci�n documentada
		   por motivos laborales, por desastres naturales, por salud propia o de un familiar cercano. Recuerda que es una falta grave adjuntar documentos falsos.
		   <br>
		   De ser aprobado el tr�mite, recibir�s un correo con la fecha programada para el examen. En caso de no ser aprobado, puedes comunicarte con tu docente.
		   <br>
		   Una vez iniciado el tr�mite podr� ser atendido en un plazo de *3 d�as h�biles*. Podr�s hacer seguimiento a tu solicitud ingresando a *Tr�mites en Proceso.*
		   <br>
		   Este tr�mite *no aplica para el examen final*, si quieres tr�mitarlo debes ingresar [Examen Sustitutorio]'
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
           ,'Recuperaci�n de Nota'
           ,NULL)
END
GO


