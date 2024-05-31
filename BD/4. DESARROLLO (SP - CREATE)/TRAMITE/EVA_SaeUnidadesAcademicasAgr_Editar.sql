IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeUnidadesAcademicasAgr_Editar') DROP PROCEDURE EVA_SaeUnidadesAcademicasAgr_Editar
GO
--------------------------------------------------------------------------------
--Creado por		: Miler Rodriguez (08.07.2022)
--Revisado por		: Miler Rodriguez
--Funcionalidad		: Actualiza la agrupacion de unidades academicas con el nuevo alias de la tabla MaestroTablaRegistro
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*  
Ejemplo:
DECLARE @Output INT = 0
EXEC EVA_SaeUnidadesAcademicasAgr_Editar
30600,
1,
1,
@Output OUT
SELECT @Output
*/
CREATE PROCEDURE [EVA_SaeUnidadesAcademicasAgr_Editar]
@IdAgrupacion         INT,
@IdUnidadAcademica    INT,
@UsuarioModificacion  INT,
@RetVal				  INT OUT  
AS
BEGIN
	SET NOCOUNT ON
	IF NOT EXISTS (SELECT IdUnidadAcademica FROM EVA_SAE_UnidadAcademicaAgrupacion WHERE IdUnidadAcademica = @IdUnidadAcademica)
		BEGIN
			INSERT INTO EVA_SAE_UnidadAcademicaAgrupacion (IdAgrupacion, IdUnidadAcademica, FechaCreacion, UsuarioCreacion)
			VALUES (@IdAgrupacion, @IdUnidadAcademica, GETDATE(), @UsuarioModificacion)
			SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
		END
	ELSE
		BEGIN
			UPDATE EVA_SAE_UnidadAcademicaAgrupacion SET IdAgrupacion = @IdAgrupacion, FechaModificacion = GETDATE(),
			UsuarioModificacion = @UsuarioModificacion WHERE IdUnidadAcademica = @IdUnidadAcademica
			SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
		END
END


