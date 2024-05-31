IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeConstancia_Verificar') DROP PROCEDURE EVA_SaeConstancia_Verificar
GO
--------------------------------------------------------------------------------      
--Creado por      : SCAYCHO (01/01/2022)
--Revisado por    : ahurtado (03/05/2022)
--Funcionalidad   : Valida la existencia de una constancia o cetitificado emitido, mediante el código publico del mismo.
--Utilizado por   : SAE
-------------------------------------------------------------------------------   
/*  
-----------------------------------------------------------------------------
Nro		FECHA			USUARIO			  DESCRIPCION
-----------------------------------------------------------------------------
*/ 

/*  
Ejemplo:
	EXEC EVA_SaeConstancia_Verificar 'AQUICODIGO'
*/ 
CREATE PROCEDURE EVA_SaeConstancia_Verificar
@CodigoPublico	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON
	SELECT
		C.CodigoPublico,
		A.Nombres,
		A.Paterno + ' ' + A.Materno AS 'Apellidos',
		A.NumeroIdentidad,
		T.Nombre,
		dbo.toMiliseconds(C.FechaCreacion) AS 'FechaCreacion'
	FROM EVA_SAE_Constancias AS C WITH (NOLOCK)
	INNER JOIN EVA_SAE_TramiteSolicitud AS TS WITH (NOLOCK)
	ON TS.IdTramiteSolicitud = C.IdTramiteSolicitud
	INNER JOIN Actor AS A WITH (NOLOCK)
	ON A.IdActor = C.IdAlumno
	INNER JOIN EVA_SAE_Tramite AS T WITH (NOLOCK)
	ON T.IdTramite = TS.IdTramite
	WHERE C.CodigoPublico = @CodigoPublico
END
