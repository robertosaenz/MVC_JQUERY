IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteFiltro_Agregar') DROP PROCEDURE EVA_SaeTramiteFiltro_Agregar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (19.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Agrega la configuración de filtros de un caso en un trámite
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
EXEC EVA_SaeTramiteFiltro_Agregar 1, NULL, 1, 'AND', NULL, NULL, 1, 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteFiltro_Agregar
@IdFiltro		INT,
@IdFiltroPadre	INT,
@Nivel			INT,
@Operador		VARCHAR(50),
@Columna		VARCHAR(50),
@Valor			VARCHAR(2000),
@IdTramite		INT,
@IdCaso			INT,
@RetVal			INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO EVA_SAE_TramiteFiltro
	(IdFiltro, IdFiltroPadre, Nivel, Operador, Columna, Valor, IdTramite, IdCaso)
	VALUES
	(@IdFiltro, @IdFiltroPadre, @Nivel, @Operador, @Columna, @Valor, @IdTramite, @IdCaso)

	SET @RetVal = IIF(@@ROWCOUNT = 0, -50, -1)
END