IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisito_Validar') DROP PROCEDURE EVA_SaeRequisito_Validar
GO
--------------------------------------------------------------------------------      
--Creado por      : ALAUREANO (30/06/2022)
--Revisado por    : 
--Funcionalidad   : Valida los requisitos para tramites especiales como 'RECINASIS'
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 
/*  
Ejemplo:
Declare @x int
EXEC [EVA_SaeRequisito_Validar] 1569679,18, 9790, 507930, 12,1, @x out
Select @x
*/ 
CREATE PROCEDURE [EVA_SaeRequisito_Validar]
@IdActor				INT,
@IdRequisito			VARCHAR(20),
@IdCurso				VARCHAR(20),
@IdSeccion				VARCHAR(20),
@IdHorario				VARCHAR(20),
@IdSesion				VARCHAR(20),
@RetVal					INT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	Declare @Periodo varchar (4), @Tiempo VARCHAR(20), @SqlTemp varchar(MAX)

	Select @Periodo = Periodo, @Tiempo = ValorPeriodo from EVA_SAE_Requisito WHERE IdRequisito = @IdRequisito

	Declare @IdActorTexto VARCHAR(20) = CONVERT(varchar(20),@IdActor)

	Set @SqlTemp = '
	SELECT
	CASE
		WHEN R.CodigoInterno = ''XDiasPost''
		THEN
		(
			SELECT -1
				FROM AlumnoCurso AC WITH(NOLOCK)
				INNER JOIN AlumnoCursoAsistencia ACA WITH(NOLOCK) ON ACA.IdSeccion=AC.IdSeccion AND AC.IdAlumno=ACA.IdAlumno
				WHERE AC.Idalumno = '+@IdActorTexto+'
				AND ACA.Valor=''F''
				AND DATEDIFF('+@Periodo+', ACA.FechaModificacion,GETDATE())<='+@Tiempo+'
				AND AC.IdCurso='+@IdCurso+'
				AND ACA.IdSeccion = '+@IdSeccion+'
				AND ACA.IdHorario = '+@IdHorario+'
				AND ACA.IdSesion = '+@IdSesion+'
		)
	ELSE -51
	END
 	FROM EVA_SAE_Requisito R WITH(NOLOCK)
	WHERE R.IdRequisito = '+@IdRequisito
	
	Declare @Resp As Table (resultado int)
	Insert into @Resp
	exec (@SqlTemp)

	SELECT @RetVal = resultado FROM @Resp

END
