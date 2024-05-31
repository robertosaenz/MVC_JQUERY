IF NOT EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('EVA_SAE_UnidadAcademicaAgrupacion'))
BEGIN
	CREATE TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion](
		[IdAgrupacion] [int] NOT NULL,
		[IdUnidadAcademica] [int] NOT NULL,
		[FechaCreacion] [datetime] NOT NULL,
		[FechaModificacion] [datetime] NULL,
		[UsuarioCreacion] [int] NULL,
		[UsuarioModificacion] [int] NULL,
		 CONSTRAINT [PK_EVA_SAE_UnidadAcademicaAgrupacion] PRIMARY KEY CLUSTERED 
		(
			[IdAgrupacion] ASC,
			[IdUnidadAcademica] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]


	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion] WITH CHECK ADD CONSTRAINT
	[FK_EVA_SAE_UnidadAcademicaAgrupacion_MaestroTablaRegistro] FOREIGN KEY(IdMaestroRegistro)
	REFERENCES [dbo].[MaestroTablaRegistro] (IdMaestroRegistro)

	ALTER TABLE [EVA_SAE_UnidadAcademicaAgrupacion] CHECK CONSTRAINT [FK_EVA_SAE_UnidadAcademicaAgrupacion_MaestroTablaRegistro]

	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion] WITH CHECK ADD CONSTRAINT
	[FK_EVA_SAE_UnidadAcademicaAgrupacion_UnidadAcademica] FOREIGN KEY(IdUnidadAcademica)
	REFERENCES [dbo].[UnidadAcademica] (IdUnidadAcademica)

	ALTER TABLE [EVA_SAE_UnidadAcademicaAgrupacion] CHECK CONSTRAINT [FK_EVA_SAE_UnidadAcademicaAgrupacion_UnidadAcademica]

	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion]  WITH CHECK ADD  CONSTRAINT 
	[FK_EVA_SAE_UnidadAcademicaAgrupacion_Usuario] FOREIGN KEY([UsuarioCreacion])
	REFERENCES [dbo].[Usuario] ([IdUsuario])

	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion] CHECK CONSTRAINT [FK_EVA_SAE_UnidadAcademicaAgrupacion_Usuario]

	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion]  WITH CHECK ADD  CONSTRAINT 
	[FK_EVA_SAE_UnidadAcademicaAgrupacion_Usuario1] FOREIGN KEY([UsuarioModificacion])
	REFERENCES [dbo].[Usuario] ([IdUsuario])

	ALTER TABLE [dbo].[EVA_SAE_UnidadAcademicaAgrupacion] CHECK CONSTRAINT [FK_EVA_SAE_UnidadAcademicaAgrupacion_Usuario1]

END