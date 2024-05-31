IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisitoActivo_Consultar') DROP PROCEDURE EVA_SaeRequisitoActivo_Consultar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (2/12/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Determinar si el Alumno(Actor) esta matriculado en el periodo actual
--Utilizado por   : EVA
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
ESCENARIO 1: No está activo en el periodo actual(2021)
DECLARE @out INT
EXEC [EVA_SaeRequisitoActivo_Consultar] 1229912,@out out     
SELECT @out

ESCENARIO 2: Si está activo en el periodo actual(2021)
DECLARE @out INT
EXEC [EVA_SaeRequisitoActivo_Consultar] 1304854,@out out     
SELECT @out
*/ 

CREATE PROCEDURE [dbo].[EVA_SaeRequisitoActivo_Consultar]
@IdActor			INT,
@RetVal				INT OUTPUT
AS
BEGIN 
	SET NOCOUNT ON;

	DECLARE 
	@IdPeriodo INT,
	@EsActual INT

	SELECT TOP 1 @IdPeriodo=P.IdPeriodo
	FROM Matricula M WITH(NOLOCK)
	INNER JOIN Promocion P WITH(NOLOCK) ON P.IdPromocion = M.IdPromocion
	WHERE M.IdActor = @IdActor
	ORDER BY M.IdMatricula DESC

	SELECT 
	@EsActual = P.EsActual 
	FROM Periodo P WITH(NOLOCK) 
	WHERE P.IdPeriodo = @idPeriodo

	IF(@EsActual = 1)
		SET @RetVal= -1
	ELSE 
		SET @RetVal= -100 -- Consultar nuevo codigo para esta excepción
END
