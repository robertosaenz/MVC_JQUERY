IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_RespuestaMaquinal_Validar') DROP PROCEDURE EVA_RespuestaMaquinal_Validar
GO
--------------------------------------------------------------------------------      
--Creado por      : ALAUREANO (30/06/2022)
--Revisado por    : 
--Funcionalidad   : Valida Si es RespuestaMaquinal (Que el tramite sera resuelto por la maquina)
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 
/*  
Ejemplo:
EXEC [EVA_RespuestaMaquinal_Validar] 370371

*/ 
CREATE PROCEDURE [EVA_RespuestaMaquinal_Validar]
@IdSeccion				VARCHAR(20)
AS
BEGIN

	SET NOCOUNT ON;

	Declare @IdTipoModalidad INT = (SELECT IdTipoModalidad FROM Seccion WITH(NOLOCK) WHERE Idseccion=@IdSeccion)

	Declare @Modalidad VARCHAR(20)= (SELECT Codigo FROM MaestroTablaRegistro WITH(NOLOCK) WHERE IdMaestroRegistro=@IdTipoModalidad)

	Declare @RespuestaMaquinal BIT

	IF (@Modalidad = 'MODPRESENCIAL' OR @Modalidad IS NULL) BEGIN
		SET @RespuestaMaquinal = 0
	END
	ELSE
		BEGIN
			IF (@Modalidad = 'MODVIRTUAL') BEGIN
				SET @RespuestaMaquinal = 1
			END
		END
	
	SELECT @IdSeccion IdSeccion, @Modalidad Modalidad, @RespuestaMaquinal RespuestaMaquinal
	
END
