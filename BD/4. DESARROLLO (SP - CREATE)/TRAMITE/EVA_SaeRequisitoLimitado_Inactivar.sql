IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeRequisitoLimitado_Inactivar')
  DROP PROCEDURE EVA_SaeRequisitoLimitado_Inactivar
GO
--------------------------------------------------------------------------------
--Creado por    	: ALAUREANO (01/07/2022)
--Revisado por		: 
--Funcionalidad		: Inactiva los tramites que tienen requisitos limitados (no pueden ser usados por todos los tramites)
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
EXEC EVA_SaeRequisitoLimitado_Inactivar 23, 18, 16674,0, @X OUT
SELECT @X
*/

CREATE PROCEDURE [EVA_SaeRequisitoLimitado_Inactivar] @IdTramite int,
@IdRequisito int,
@IdUsuarioLog int,
@EsActivo bit,
@RetVal int OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  IF (SELECT
      EsActivo
    FROM EVA_SAE_RequisitoLimitado
    WHERE IdTramite = @IdTramite
    AND IdRequisito = @IdRequisito)
    = @EsActivo
  BEGIN
    SET @RetVal = -51
  END
  ELSE
  BEGIN
    UPDATE EVA_SAE_RequisitoLimitado
    SET EsActivo = @EsActivo,
        UsuarioModificacion = @IdUsuarioLog,
        FechaModificacion = GETDATE()
    WHERE IdTramite = @IdTramite
    AND IdRequisito = @IdRequisito

    SET @RetVal = IIF(@@ROWCOUNT > 0, -1, -50)
  END

END