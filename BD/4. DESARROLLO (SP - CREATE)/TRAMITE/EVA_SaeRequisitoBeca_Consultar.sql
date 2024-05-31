IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeRequisitoBeca_Consultar') DROP PROCEDURE  EVA_SaeRequisitoBeca_Consultar
GO 
--------------------------------------------------------------------------------      
--Creado por      : Rsaenz (2/12/2021)
--Revisado por    : Rsaenz (29/04/2022)
--Funcionalidad   : Determinar si el Alumno(Actor) pertenece a un programa de becas
--Utilizado por   : EVA
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
ESCENARIO 1: No tiene beca activa
DECLARE @out INT
EXEC [EVA_SaeRequisitoBeca_Consultar] 1229912,@out out     
SELECT @out

ESCENARIO 2: Si tiene beca activa 
DECLARE @out INT
EXEC [EVA_SaeRequisitoBeca_Consultar] 1334684,@out out  
SELECT @out
*/ 

CREATE PROCEDURE [dbo].[EVA_SaeRequisitoBeca_Consultar]
@IdActor			INT,
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS 
	(
		SELECT IdPromocionBeca  
		FROM PromocionBeca WITH(NOLOCK)  
		WHERE IdActor =@IdActor AND 
		(
			dbo.toMiliseconds(getdate()) >= dbo.toMiliseconds(FechaInicioVigencia) AND
			dbo.toMiliseconds(getdate()) <= dbo.toMiliseconds(FechaFinVigencia)
		)
	)  
		SET @RetVal=-1 -- SI TIENE BECA ACTIVA / Consultar nuevo codigo para esta excepción
	ELSE 
		SET @RetVal=-100 --NO TIENE BECA ACTIVA / Consultar nuevo codigo para esta excepción
END
