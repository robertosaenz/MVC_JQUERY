IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE TYPE = 'FN'
  AND NAME = 'EVA_FN_RestarDiasHabiles')
  DROP FUNCTION EVA_FN_RestarDiasHabiles
GO
--------------------------------------------------------------------------------      
--Creado por      : Almendra Laureano (01/06/2022)
--Revisado por    : 
--Funcionalidad   : Funcion para calcular la diferencia de dias habiles entre una fecha y la de hoy
--Utilizado por   : EVA
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro    FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------

*/

/*  
	Ejemplo: 	 	
	SELECT [dbo].[EVA_FN_RestarDiasHabiles]('2022-07-20',7,GETDATE())
*/

CREATE FUNCTION [dbo].[EVA_FN_RestarDiasHabiles] (@FechaInicio date,
@DiasHabiles int,
@FechaFin date = NULL)
RETURNS int
AS
BEGIN

  DECLARE @FechaHoy date = IIF(@FechaFin IS NULL, GETDATE(),@FechaFin)
  DECLARE @FechaInicioDate date = @FechaInicio
  DECLARE @DiasTranscurridosAlaFecha int = DATEDIFF(DAY, @FechaInicio, @FechaHoy)
  DECLARE @IdSedeCentral varchar(4) = (SELECT
    valor
  FROM parametro
  WHERE nombre = 'EVA_ID_SEDECENTRAL'
  AND Activo = 1)
  DECLARE @DiasNoHabilesAlaFecha int = 0
  DECLARE @DiasRestantes int = 0

  --1) Guardamos todos los feriados en el rango de fechaInicio y fechaHoy
  DECLARE @Feriado AS TABLE (
    Fecha datetime
  )

  INSERT INTO @Feriado
    SELECT
      Fecha
    FROM Feriado WITH (NOLOCK)
    WHERE Fecha BETWEEN @FechaInicio AND @FechaHoy
    AND Descripcion NOT LIKE '%VACACIONES%'
    AND IdSede = @IdSedeCentral

  --2) Obtenemos el total de dias no laborables
  WHILE @FechaInicioDate < @FechaHoy
  BEGIN

    SET @FechaInicioDate = DATEADD(dd, 1, @FechaInicioDate) --Se cuenta un día a partir del dia siguiente

    IF ((SELECT
        DATENAME(WEEKDAY, @FechaInicioDate))
      IN ('Sábado', 'Domingo', 'Saturday', 'Sunday'))
    BEGIN
      SET @DiasNoHabilesAlaFecha = @DiasNoHabilesAlaFecha + 1

    END
    ELSE
    IF EXISTS (SELECT
        Fecha
      FROM @Feriado
      WHERE Fecha = @FechaInicioDate)
    BEGIN
      SET @DiasNoHabilesAlaFecha = @DiasNoHabilesAlaFecha + 1

    END

  END

  --3) Retornamos los dias restantes
  SET @DiasRestantes = @DiasHabiles - @DiasTranscurridosAlaFecha + @DiasNoHabilesAlaFecha

  RETURN (@DiasRestantes)

END