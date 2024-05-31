IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE TYPE = 'P'
  AND NAME = 'EVA_SaeTramite_ActivarTramite')
  DROP PROCEDURE EVA_SaeTramite_ActivarTramite
GO
-------------------------------------------------------------------------------    
--Creado por      : ALAUREANO (27/06/2022)
--Revisado por    :    
--Funcionalidad   : Activar o inactivar un tramite
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:
  DECLARE @Salida int
	EXEC [EVA_SaeTramite_ActivarTramite] 1,0,157688, @Salida out
	Select @Salida

*/

CREATE PROCEDURE [EVA_SaeTramite_ActivarTramite] @IdTramite int,
@EsActivo bit,
@UsuarioLog int,
@RetVal int OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  IF ((SELECT
      EsActivo
    FROM EVA_SAE_Tramite
    WHERE IdTramite = @IdTramite)
    = @EsActivo)
  BEGIN
    SET @RetVal = -50
  END
  ELSE
  BEGIN
    UPDATE EVA_SAE_Tramite
    SET EsActivo = @EsActivo,
        UsuarioModificacion = @UsuarioLog,
        FechaModificacion = GETDATE()
    WHERE IdTramite = @IdTramite

    SET @RetVal = IIF(@@ROWCOUNT <> 0, -1, -51)
  END

END