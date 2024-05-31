IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramiteEncuesta_Responder') DROP PROCEDURE EVA_SaeTramiteEncuesta_Responder
GO 
--------------------------------------------------------------------------------      
--Creado por      : Ahurtado (29/03/2022)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Actualiza información asociada a las encuestas
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
*/ 
CREATE PROCEDURE [EVA_SaeTramiteEncuesta_Responder]
	@IdTramiteSolicitud		INT,
	@RespuestaInterna		VARCHAR(1),
	@Comentario				VARCHAR(1000),
	@RetVal					INT OUT 
AS
BEGIN
SET NOCOUNT ON;

DECLARE @IdFicha		Int,
		@IdPregunta		Int,
		@IdAlternativa	Int,
		@IdActor		Int

select @IdActor=IdActorSolicitante from EVA_SAE_TramiteSolicitud where IdTramiteSolicitud=@IdTramiteSolicitud
select @IdFicha= IdFicha from Ficha where Codigo='ENCTRA'


select @IdPregunta=FP.IdPregunta  from FichaPregunta FP
INNER JOIN MaestroTablaRegistro MR  ON FP.IdPregunta = MR.IdMaestroRegistro 
where FP.IdFicha = @IdFicha and MR.Codigo = 'PRETRA1'

select @IdAlternativa=IdAlternativa from PreguntaAlternativa as PA
INNER JOIN MaestroTablaRegistro A  ON PA.IdAlternativa = A.IdMaestroRegistro 
where IdPregunta = @IdPregunta and Orden=@RespuestaInterna

INSERT INTO FichaRespuestaActor
	(IdFicha, IdPregunta, IdAlternativa, Respuesta, Fecha, IdActor, UsuarioCreacion, FechaCreacion,Tiempo, IdProgramacionDetalle, IdSistema)
	VALUES
	(@IdFicha, @IdPregunta, @IdAlternativa, null, GETDATE(), @IdActor, 1, GETDATE(), 'TRAMITEEVA', @IdTramiteSolicitud, 72)

select @IdPregunta=FP.IdPregunta  from FichaPregunta FP
INNER JOIN MaestroTablaRegistro MR  ON FP.IdPregunta = MR.IdMaestroRegistro 
where FP.IdFicha = @IdFicha and MR.Codigo = 'PRETRA2'

INSERT INTO FichaRespuestaActor
	(IdFicha, IdPregunta, IdAlternativa, Respuesta, Fecha, IdActor, UsuarioCreacion, FechaCreacion, Tiempo, IdProgramacionDetalle, IdSistema)
	VALUES
	(@IdFicha, @IdPregunta, null, @Comentario, GETDATE(), @IdActor, 1, GETDATE(), 'TRAMITEEVA', @IdTramiteSolicitud, 72)


UPDATE EVA_SAE_TramiteSolicitud SET idProgramacionDetalle=@IdTramiteSolicitud  WHERE IdTramiteSolicitud=@IdTramiteSolicitud
SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
END