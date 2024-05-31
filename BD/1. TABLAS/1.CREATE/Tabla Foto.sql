IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('EVA_Foto')) DROP TABLE EVA_Foto
GO
-------------------------------------------------------------------------------  
--Creado por      : Almendra Laureano (23/05/2022)
--Revisado por    : 
--Funcionalidad   : Guardar los registros de nuevas Fotos
--Utilizado por   : EVA
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/

/* 
Ejemplo:

*/
CREATE TABLE EVA_Foto(
	[IdFoto] int NOT NULL IDENTITY(1,1),
	[NombreFoto] varchar(250)NOT NULL,
	[ExtensionFoto] varchar(6)NOT NULL,
	[Descripcion] varchar(255) NOT NULL,
	[EsReciente] bit NOT NULL,
	[EsActivo] bit NOT NULL DEFAULT 1,
	[UsuarioCreacion] int NOT NULL,
	[FechaCreacion] datetime NOT NULL,
	[UsuarioModificacion] int NULL,
	[FechaModificacion] datetime NULL,

	CONSTRAINT PK_Foto PRIMARY KEY (IdFoto),

	CONSTRAINT FK_Foto_Usuario_UsuarioCreacion
	FOREIGN KEY (UsuarioCreacion)
	REFERENCES Usuario(IdUsuario),

	CONSTRAINT FK_Foto_Usuario_UsuarioModificacion
	FOREIGN KEY (UsuarioModificacion)
	REFERENCES Usuario(IdUsuario)
	)
--GO
--INSERT INTO EVA_Foto (Nombre,Descripcion,EsReciente,Activo,UsuarioCreacion,FechaCreacion) 
--VALUES ('CARLOS CE ZERGIO', 'FotosLuna.jpg', 1, 1,17559,GETDATE()),
--		('DIEGO ISAAC', 'libros.jpg', 1, 1,27426,GETDATE()),
--		('JUDITH ESTEFANIA', 'perfilFondoBlaco.jpg', 1, 1,34167,GETDATE())

--INSERT INTO EVA_Foto (Nombre,Descripcion,EsReciente,Activo,UsuarioCreacion,FechaCreacion) 
--VALUES ('CARLOS CE ZERGIO', 'FotosLuna.jpg', 1, 1,17559,GETDATE()),
--		('DIEGO ISAAC', 'libros.jpg', 1, 1,27426,GETDATE()),
--		('JUDITH ESTEFANIA', 'perfilFondoBlaco.jpg', 1, 1,34167,GETDATE())

--Observaciones:
--Tiene / Es :Prefijos de un Bit ok
--La extensión de un archivo debe estar en una columna nueva.Y el nombre del archivo igual. -ok
--Nombre de las columnas mas descriptivo -ok
--Relacion con la tabla usuario -ok
select*From EVA_Foto