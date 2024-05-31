if not exists(Select * from EVA_SAE_UnidadAcademicaAgrupacion)
BEGIN
	insert into EVA_SAE_UnidadAcademicaAgrupacion
	(IdAgrupacion, IdUnidadAcademica, FechaCreacion, FechaModificacion, UsuarioCreacion, UsuarioModificacion)
	values (30615, 48, getdate(), null, 157688, null)
insert into EVA_SAE_UnidadAcademicaAgrupacion
	(IdAgrupacion, IdUnidadAcademica, FechaCreacion, FechaModificacion, UsuarioCreacion, UsuarioModificacion)
	values (30615, 54, getdate(), null, 157688, null)

insert into EVA_SAE_UnidadAcademicaAgrupacion
	(IdAgrupacion, IdUnidadAcademica, FechaCreacion, FechaModificacion, UsuarioCreacion, UsuarioModificacion)
	values (30615, 55, getdate(), null, 157688, null)

insert into EVA_SAE_UnidadAcademicaAgrupacion
	(IdAgrupacion, IdUnidadAcademica, FechaCreacion, FechaModificacion, UsuarioCreacion, UsuarioModificacion)
	values (30615, 63, getdate(), null, 157688, null)

insert into EVA_SAE_UnidadAcademicaAgrupacion
	(IdAgrupacion, IdUnidadAcademica, FechaCreacion, FechaModificacion, UsuarioCreacion, UsuarioModificacion)
	values (30616, 2, getdate(), null, 157688, null)
END