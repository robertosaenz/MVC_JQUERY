IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeDetalleTramiteRECINASIS_Insertar')
  DROP PROCEDURE EVA_SaeDetalleTramiteRECINASIS_Insertar
GO
--------------------------------------------------------------------------------
--Creado por  	: ALAUREANO(05/07/22)
--Revisado por		: 
--Funcionalidad		: Inserta información complementaria para el trámite RECTIFIACION DE INASISTENCIA.
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT
EXEC EVA_SaeDetalleTramiteRECINASIS_Insertar 518, 9801, 'prueba xxx', 515916, 9,1,515916, @Output OUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteRECINASIS_Insertar @IdTramiteSolicitud int,
@IdCurso int,
@Sustento varchar(500),
@IdSeccion int,
@IdHorario int,
@IdSesion int,
@IdUsuario int,
@RetVal int OUTPUT
AS
BEGIN
  SET NOCOUNT ON
  IF EXISTS (SELECT
      1
    FROM EVA_SAE_DetalleTramite_RECINASIS
    WHERE IdTramiteSolicitud = @IdTramiteSolicitud)
  BEGIN
    SET @RetVal = -50
  END
  ELSE
  BEGIN

    IF EXISTS (SELECT
        1
      FROM EVA_SAE_DetalleTramite_RECINASIS WITH (NOLOCK)
      WHERE IdCurso = @IdCurso
      AND IdSeccion = @IdSeccion
      AND IdHorario = @IdHorario
      AND IdSesion = @IdSesion
      AND UsuarioCreacion = @IdUsuario)
    BEGIN
      SET @RetVal = -50
    END
    ELSE
    BEGIN
      INSERT EVA_SAE_DetalleTramite_RECINASIS (IdTramiteSolicitud, IdCurso, Sustento, IdSeccion, IdHorario, IdSesion, UsuarioCreacion)
        VALUES (@IdTramiteSolicitud, @IdCurso, @Sustento, @IdSeccion, @IdHorario, @IdSesion, @IdUsuario)

      IF (@@ROWCOUNT > 0)
      BEGIN

        DECLARE @RespuestaMaquinal bit = (SELECT
          ISNULL(EsRespuestaMaquinal, 0)
        FROM EVA_SAE_TramiteSolicitud
        WHERE IdTramiteSolicitud = @IdTramiteSolicitud)
        DECLARE @IdActorEncargado int

        IF (@RespuestaMaquinal = 0)
        BEGIN
          SELECT
            @IdActorEncargado = IdActor
          FROM SeccionProfesor
          WHERE IdSeccion = @IdSeccion
          AND EsResponsable = 1
          AND Activo = 1
        END
        ELSE
        BEGIN
          SET @IdActorEncargado = 1
        END

        UPDATE EVA_SAE_TramiteSolicitud
        SET IdActorEncargado = @IdActorEncargado
        WHERE IdTramiteSolicitud = @IdTramiteSolicitud

        SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
      END
      ELSE
      BEGIN
        SET @RetVal = -50
      END
    END
  END
END