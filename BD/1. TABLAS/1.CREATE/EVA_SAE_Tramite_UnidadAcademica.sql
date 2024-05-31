IF NOT EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('EVA_SAE_Tramite_UnidadAcademica'))
BEGIN

	CREATE TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica](
		[IdTramite] [int] NOT NULL,
		[IdUnidadAcademica] [int] NOT NULL,
		[FechaCreacion] [datetime] NOT NULL,
		[FechaModificacion] [datetime] NULL,
		[UsuarioCreacion] [int] NULL,
		[UsuarioModificacion] [int] NULL,
	 CONSTRAINT [PK_EVA_SAE_Tramite_UnidadAcademica] PRIMARY KEY CLUSTERED 
	(
		[IdTramite] ASC,
		[IdUnidadAcademica] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica]  WITH CHECK ADD  CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_EVA_SAE_Tramite] FOREIGN KEY([IdTramite])
	REFERENCES [dbo].[EVA_SAE_Tramite] ([IdTramite])
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica] CHECK CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_EVA_SAE_Tramite]
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica]  WITH CHECK ADD  CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_UnidadAcademica] FOREIGN KEY([IdUnidadAcademica])
	REFERENCES [dbo].[UnidadAcademica] ([IdUnidadAcademica])
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica] CHECK CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_UnidadAcademica]
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica]  WITH CHECK ADD  CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_Usuario] FOREIGN KEY([UsuarioCreacion])
	REFERENCES [dbo].[Usuario] ([IdUsuario])
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica] CHECK CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_Usuario]
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica]  WITH CHECK ADD  CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_Usuario1] FOREIGN KEY([UsuarioModificacion])
	REFERENCES [dbo].[Usuario] ([IdUsuario])
	

	ALTER TABLE [dbo].[EVA_SAE_Tramite_UnidadAcademica] CHECK CONSTRAINT [FK_EVA_SAE_Tramite_UnidadAcademica_Usuario1]
	

END