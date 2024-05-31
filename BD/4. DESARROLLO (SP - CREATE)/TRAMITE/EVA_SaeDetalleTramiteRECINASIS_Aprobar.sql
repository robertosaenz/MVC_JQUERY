IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE type = 'P'
  AND name = 'EVA_SaeDetalleTramiteRECINASIS_Aprobar')
  DROP PROCEDURE EVA_SaeDetalleTramiteRECINASIS_Aprobar
GO
--------------------------------------------------------------------------------
--Creado por    	: ALAUREANO (07/07/2022)
--Revisado por		: 
--Funcionalidad		: Rectifica la asistencia de un alumno pasandolo de "F" hacia "A"
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
EXEC EVA_SaeDetalleTramiteRECINASIS_Aprobar 415, @X OUT
SELECT @X
*/

CREATE PROCEDURE [EVA_SaeDetalleTramiteRECINASIS_Aprobar]
@IdTramiteSolicitud int,
@RetVal int OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

    UPDATE CA SET CA.Valor='A', CA.Observacion='Asistencia rectificada '+IIF(TS.EsRespuestaMaquinal=1,'automáticamente ','')+'por EVA - Trámite '+CONVERT(VARCHAR(10),TS.IdTramiteSolicitud)
	, FechaModificacion=GETDATE(), UsuarioModificacion = 1
	FROM EVA_SAE_TramiteSolicitud TS
	INNER JOIN EVA_SAE_DetalleTramite_RECINASIS DT ON DT.IdTramiteSolicitud=TS.IdTramiteSolicitud
	INNER JOIN AlumnoCurso AL ON AL.IdAlumno=TS.IdActorSolicitante AND AL.IdCurso=DT.IdCurso AND AL.IdSeccion=DT.IdSeccion AND AL.IdMatricula=TS.IdMatricula
	INNER JOIN AlumnoCursoAsistencia CA ON CA.IdAlumno=AL.IdAlumno AND CA.IdSeccion=DT.IdSeccion AND CA.IdHorario=DT.IdHorario AND CA.IdSesion=DT.IdSesion
	WHERE TS.IdTramiteSolicitud=@IdTramiteSolicitud
	AND CA.Valor='F'

    SET @RetVal = IIF(@@ROWCOUNT > 0, -1, -50)

END