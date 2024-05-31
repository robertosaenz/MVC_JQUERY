IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeRequisito_Actualizar')
  DROP PROCEDURE EVA_SaeRequisito_Actualizar
GO
--------------------------------------------------------------------------------
--Creado por    	: ALAUREANO (01/07/2022)
--Revisado por		: 
--Funcionalidad		: Actualiza los requisitos
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
EXEC EVA_SaeRequisito_Actualizar 18, 'Gestionarlo hasta una semana después de realizada la clase.', 'DAY', 7,1,31077, @X OUT
SELECT @X
*/

CREATE PROCEDURE [EVA_SaeRequisito_Actualizar]
@IdRequisito int,
@Nombre VARCHAR(MAX),
@Periodo varchar(20),
@ValorPeriodo int,
@EsLimitado BIT,
@IdUsuarioLog int,
@RetVal int OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

    UPDATE EVA_SAE_Requisito
    SET Nombre=@Nombre, Periodo=@Periodo, ValorPeriodo=@ValorPeriodo, EsLimitado=@EsLimitado,
        UsuarioModificacion = @IdUsuarioLog,
        FechaModificacion = GETDATE()
    WHERE IdRequisito = @IdRequisito

    SET @RetVal = IIF(@@ROWCOUNT > 0, -1, -50)

END