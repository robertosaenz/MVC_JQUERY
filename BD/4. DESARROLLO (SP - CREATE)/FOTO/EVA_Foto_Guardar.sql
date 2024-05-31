IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_Foto_Guardar') DROP PROCEDURE EVA_Foto_Guardar
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

DECLARE @rpta INT = 0
EXEC EVA_Foto_Guardar 'librosazules' ,'.jpeg', 'Libro del año azul',1, 17559, @rpta out
SELECT @rpta 
*/   
CREATE PROCEDURE EVA_Foto_Guardar(
@NombreFoto		varchar(250),
@ExtensionFoto	varchar(6),
@Descripcion	varchar(255),
@EsReciente		bit,
@IdUsuario		int,
@RetVal			INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO EVA_Foto(
	NombreFoto,
	ExtensionFoto,
	Descripcion,
	EsReciente,
	UsuarioCreacion,
	FechaCreacion
	) VALUES (
	@NombreFoto,
	@ExtensionFoto,
	@Descripcion,
	@EsReciente,
	@IdUsuario,
	GETDATE()
	)

	Declare @IdFoto INT
	SET @IdFoto = (SELECT SCOPE_IDENTITY())
	
	SET @RetVal = IIF(@@ROWCOUNT<>0,@IdFoto,-50)
	
END

select*From EVA_Foto