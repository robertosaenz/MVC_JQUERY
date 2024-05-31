IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeDetalleTramiteCONSESP_Insertar') DROP PROCEDURE EVA_SaeDetalleTramiteCONSESP_Insertar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (20.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Inserta información complementaria para el trámite Constancias especiales
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
EXEC EVA_SaeDetalleTramiteCONSESP_Insertar 'IDAT S.A.C', 'FullStack', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteCONSESP_Insertar
@IdTramiteSolicitud	INT,
@Dirigido			VARCHAR(120),
@Detalle			VARCHAR(500),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT EVA_SAE_DetalleTramite_CONSESP
	(IdTramiteSolicitud, Dirigido, Detalle)
	VALUES
	(@IdTramiteSolicitud, @Dirigido, @Detalle)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END