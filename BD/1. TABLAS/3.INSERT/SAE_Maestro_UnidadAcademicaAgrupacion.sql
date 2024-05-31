DECLARE @IdMaestro INT
DECLARE @IdMaestroRegistro INT
select @IdMaestro = max(IdMaestroTabla)+1 from MaestroTabla
select @IdMaestroRegistro = max(IdMaestroRegistro)+1 from MaestroTablaRegistro

insert into MaestroTabla 
(IdMaestroTabla,Codigo,Nombre,Activo,UsuarioCreacion,FechaCreacion,UsuarioModificacion,FechaModificacion,IdUsuarioCreacion,IdUsuarioModificacion)
VALUES
(@IdMaestro,'EvaSaeUniAcaAgr', 'Eva Sae UnidadAcademicaAgrupación', 1,1,GETDATE(),1,GETDATE(),1,1 )

insert into MaestroTablaRegistro(IdMaestroRegistro,IdMaestroTabla,Codigo,Nombre,Descripcion,Activo,UsuarioCreacion,FechaCreacion)
values(@IdMaestroRegistro,@IdMaestro,'EUNIACAAGR01','Curso','',1,1,getdate())
SET @IdMaestroRegistro = @IdMaestroRegistro + 1

insert into MaestroTablaRegistro(IdMaestroRegistro,IdMaestroTabla,Codigo,Nombre,Descripcion,Activo,UsuarioCreacion,FechaCreacion)
values(@IdMaestroRegistro,@IdMaestro,'EUNIACAAGR02','Diplomado','',1,1,getdate())
SET @IdMaestroRegistro = @IdMaestroRegistro + 1


--select * from maestroTabla WHERE Codigo='EvaSaeTramiteFilOper'
select * from MaestroTablaRegistro WHERE IdMaestroTabla in (select IdMaestroTabla from maestroTabla WHERE Codigo='EvaSaeUniAcaAgr')
--select * from maestroTabla WHERE Codigo='EvaSaeTramiteFilColu'
select * from MaestroTablaRegistro WHERE IdMaestroTabla in (select IdMaestroTabla from maestroTabla WHERE Codigo='EvaSaeUniAcaAgr')
