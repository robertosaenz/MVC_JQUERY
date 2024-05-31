IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisitoDeuda_Consultar') DROP PROCEDURE EVA_SaeRequisitoDeuda_Consultar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (2/12/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Determinar si el Alumno(Actor) tiene una deuda pendiente
--Utilizado por   : EVA
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
ESCENARIO 1: No tiene deuda
DECLARE @out INT
EXEC [EVA_Requisito_ConsultarDeuda] 1229912,@out out     
SELECT @out

ESCENARIO 2: Si tiene deuda 
DECLARE @out INT
EXEC [EVA_SaeRequisitoDeuda_Consultar] 1373436,@out out  
SELECT @out
*/ 

CREATE PROCEDURE [dbo].[EVA_SaeRequisitoDeuda_Consultar]
@IdActor			INT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @idTipoUsuario INT
	SELECT @idTipoUsuario=IIF(ISNULL(idTipoUsuario, 0) = 0 ,0,idTipoUsuario) FROM Usuario WITH(NOLOCK) WHERE IdActor=@IdActor

	IF(@idTipoUsuario = 0)
		SET @RetVal=12 --USUARIO NO ENCONTRADO / Consultar nuevo codigo para esta excepción
	ELSE IF (@idTipoUsuario = 1)
		BEGIN 
			IF EXISTS (SELECT Personaant  
			FROM Vw_Deudas WITH(NOLOCK)  
			WHERE PersonaAnt=CONVERT(VARCHAR,@IdActor)                   
			and CONVERT(VARCHAR,FechaVencimiento,112) < CONVERT(VARCHAR,getdate(),112) )
				SET @RetVal=-1 -- SI TIENE DEUDA / Consultar nuevo codigo para esta excepción
			ELSE 
				SET @RetVal=-100 -- NO TIENE DEUDA / Consultar nuevo codigo para esta excepción
		END
	ELSE
		SET @RetVal=11 --USUARIO NO ES ALUMNO / Consultar nuevo codigo para esta excepción
END
