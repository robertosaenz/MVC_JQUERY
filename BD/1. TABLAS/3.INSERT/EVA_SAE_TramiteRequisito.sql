IF NOT EXISTS(Select * from EVA_SAE_TramiteRequisito where IdTramite=26)
BEGIN
	insert into EVA_SAE_TramiteRequisito
	([IdTramite] ,[IdRequisito] ,[EsActivo] ,[FechaCreacion] ,[FechaModificacion]
		,[UsuarioCreacion] ,[UsuarioModificacion] ,[IdCaso], [Orden] )
	values
	(26, 1, 1, GETDATE(), null,
		1, null, null, 1 );

	insert into EVA_SAE_TramiteRequisito
	([IdTramite] ,[IdRequisito] ,[EsActivo] ,[FechaCreacion] ,[FechaModificacion]
		,[UsuarioCreacion] ,[UsuarioModificacion] ,[IdCaso], [Orden] )
	values
	(26, 19, 1, GETDATE(), null,
		1, null, null, 2 );
END



IF NOT EXISTS(Select * from EVA_SAE_TramiteRequisito where IdTramite=27)
BEGIN
	insert into EVA_SAE_TramiteRequisito
	([IdTramite] ,[IdRequisito] ,[EsActivo] ,[FechaCreacion] ,[FechaModificacion]
		,[UsuarioCreacion] ,[UsuarioModificacion] ,[IdCaso], [Orden] )
	values
	(27, 1, 1, GETDATE(), null,
		1, null, null, 1 );

	insert into EVA_SAE_TramiteRequisito
	([IdTramite] ,[IdRequisito] ,[EsActivo] ,[FechaCreacion] ,[FechaModificacion]
		,[UsuarioCreacion] ,[UsuarioModificacion] ,[IdCaso], [Orden] )
	values
	(27, 3, 1, GETDATE(), null,
		1, null, null, 2 );

	insert into EVA_SAE_TramiteRequisito
	([IdTramite] ,[IdRequisito] ,[EsActivo] ,[FechaCreacion] ,[FechaModificacion]
		,[UsuarioCreacion] ,[UsuarioModificacion] ,[IdCaso], [Orden] )
	values
	(27, 19, 1, GETDATE(), null,
		1, null, null, 3 );
END