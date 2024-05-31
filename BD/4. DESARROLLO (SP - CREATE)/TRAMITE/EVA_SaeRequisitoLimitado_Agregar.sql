IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeRequisitoLimitado_Agregar')
  DROP PROCEDURE EVA_SaeRequisitoLimitado_Agregar
GO
--------------------------------------------------------------------------------
--Creado por  		: ALAUREANO (01/07/2022)
--Revisado por		: 
--Funcionalidad		: Agrega nuevos tramites que tienen requisitos limitados (no pueden ser usados por todos los tramites)
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @X INT
EXEC EVA_SaeRequisitoLimitado_Agregar 23, 18, 16674, @X OUT
SELECT @X
*/
CREATE PROCEDURE [EVA_SaeRequisitoLimitado_Agregar]
@IdTramite INT, 
@IdRequisito INT, 
@IdUsuario INT,
@RetVal INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS(SELECT 1 FROM EVA_SAE_RequisitoLimitado WHERE IdTramite=@IdTramite AND IdRequisito=@IdRequisito)
  BEGIN
		SET @RetVal = -100
  END
  ELSE
  BEGIN
	INSERT INTO EVA_SAE_RequisitoLimitado (IdTramite, IdRequisito, UsuarioCreacion)
	VALUES (@IdTramite,@IdRequisito, @IdUsuario)

	SET @RetVal = IIF(@@ROWCOUNT>0,-1,-50)
  END
END
