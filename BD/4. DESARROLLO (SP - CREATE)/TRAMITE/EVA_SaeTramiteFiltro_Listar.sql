IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteFiltro_Listar') DROP PROCEDURE EVA_SaeTramiteFiltro_Listar
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (18.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Lista la configuración de filtros de un caso en un trámite
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*
Ejemplo:
EXEC EVA_SaeTramiteFiltro_Listar 1, 1
*/

CREATE PROCEDURE EVA_SaeTramiteFiltro_Listar
@IdTramite	INT,
@IdCaso		INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
	MT.Codigo,
	MTR.Disponible1,
	MTR.Nombre
	FROM MaestroTabla MT WITH(NOLOCK)
	INNER JOIN MaestroTablaRegistro MTR WITH(NOLOCK)
	ON MT.IdMaestroTabla = MTR.IdMaestroTabla
	WHERE
	MT.Codigo IN ('EvaSaeTramiteFilOper', 'EvaSaeTramiteFilColu')
	AND MT.Activo = 1
	AND MTR.Activo = 1
	ORDER BY
	MT.Codigo ASC,
	MTR.Codigo ASC

	SELECT TF.IdFiltro, TF.IdFiltroPadre, TF.Nivel, TF.Operador, TF.Columna, TF.Valor
	FROM EVA_SAE_TramiteFiltro TF WITH (NOLOCK)
	WHERE
	TF.IdTramite = @IdTramite
	AND TF.IdCaso = @IdCaso
	AND TF.EsActivo = 1
END