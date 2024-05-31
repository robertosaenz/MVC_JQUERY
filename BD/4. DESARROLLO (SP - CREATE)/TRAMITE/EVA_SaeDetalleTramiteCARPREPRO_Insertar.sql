IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeDetalleTramiteCARPREPRO_Insertar') DROP PROCEDURE EVA_SaeDetalleTramiteCARPREPRO_Insertar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (04.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Inserta información complementaria para el trámite Carta de presentación - preprofesional.
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
EXEC EVA_SaeDetalleTramiteCARPREPRO_Insertar 1, '20605391738', 'IDAT S.A.C', 'Salvador', 'FullStack', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteCARPREPRO_Insertar
@IdTramiteSolicitud	INT,
@NroRuc				VARCHAR(11),
@RazonSocial		VARCHAR(250),
@Dirigido			VARCHAR(120),
@Cargo				VARCHAR(80),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT EVA_SAE_DetalleTramite_CARPREPRO
	(IdTramiteSolicitud, NroRuc, RazonSocial, Dirigido, Cargo)
	VALUES
	(@IdTramiteSolicitud, @NroRuc, @RazonSocial, @Dirigido, @Cargo)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END