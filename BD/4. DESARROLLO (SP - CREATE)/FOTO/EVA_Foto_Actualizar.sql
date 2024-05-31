IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_Foto_Actualizar') DROP PROCEDURE EVA_Foto_Actualizar
GO
-------------------------------------------------------------------------------  
--Creado por      : Almendra Laureano (23/05/2022)
--Revisado por    : 
--Funcionalidad   : Actualiza el campo seleccionado por ID
--Utilizado por   : EVA
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/

/* 
Ejemplo:

DECLARE @rpta INT = 0
EXEC EVA_Foto_Actualizar 2,'Titulo 2 temporal', 'Desc 2', 1, @rpta out
SELECT @rpta 
*/

CREATE PROCEDURE EVA_Foto_Actualizar(
@IdFoto			int,
@NombreFoto		varchar(250),
@ExtensionFoto	varchar(6),
@Descripcion	varchar(255),
@IdUsuario		int,
@RetVal			INT OUTPUT
)
AS
	Update EVA_Foto set 
	NombreFoto=@NombreFoto,
	ExtensionFoto=@ExtensionFoto,
	Descripcion=@Descripcion,
	UsuarioModificacion=@IdUsuario,
	FechaModificacion=GETDATE()
	where IdFoto=@IdFoto

	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-51)
GO

select*from EVA_Foto