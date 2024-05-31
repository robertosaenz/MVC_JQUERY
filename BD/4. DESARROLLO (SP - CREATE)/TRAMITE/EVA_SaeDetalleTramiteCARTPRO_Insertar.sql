IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeDetalleTramiteCARTPRO_Insertar') DROP PROCEDURE EVA_SaeDetalleTramiteCARTPRO_Insertar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (04.04.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Inserta información complementaria para el trámite Carta de presentación - profesional.
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
EXEC EVA_SaeDetalleTramiteCARTPRO_Insertar 1, '20605391738', 'IDAT S.A.C', 'Salvador', 'FullStack', @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeDetalleTramiteCARTPRO_Insertar
@IdTramiteSolicitud	INT,
@NroRuc				VARCHAR(11),
@RazonSocial		VARCHAR(250),
@Dirigido			VARCHAR(120),
@Cargo				VARCHAR(80),
@RetVal				INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT EVA_SAE_DetalleTramite_CARTPRO
	(IdTramiteSolicitud, NroRuc, RazonSocial, Dirigido, Cargo)
	VALUES
	(@IdTramiteSolicitud, @NroRuc, @RazonSocial, @Dirigido, @Cargo)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END