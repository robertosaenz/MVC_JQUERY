IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeTramiteEncargado_Mantener') DROP PROCEDURE EVA_SaeTramiteEncargado_Mantener
GO
--------------------------------------------------------------------------------
--Creado por		: SCAYCHO (13.05.22)
--Revisado por		: SCAYCHO
--Funcionalidad		: Realiza la inserción y eliminación masiva de encargados del trámite
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
EXEC EVA_SaeTramiteEncargado_Mantener '', '', '', 1, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE EVA_SaeTramiteEncargado_Mantener
@IdEncargadoNuevos		VARCHAR(MAX) = '',
@IdEncargadoEliminados	VARCHAR(MAX) = '',
@Accion					VARCHAR(15),
@IdUsuario				INT,
@RetVal					INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	IF (@Accion = 'agregar')
	BEGIN
		IF (@IdEncargadoNuevos <> '')
		BEGIN
			INSERT INTO EVA_SAE_TramiteEncargado
			(IdTramite, IdActor, EsActivo, FechaCreacion, UsuarioCreacion)
			SELECT
			PARSENAME(REPLACE(items, ',', '.'), 2),
			PARSENAME(REPLACE(items, ',', '.'), 1),
			1,
			GETDATE(),
			@IdUsuario
			FROM dbo.udf_Split(@IdEncargadoNuevos, '|')

			SET @RetVal = @@ROWCOUNT RETURN
		END
		ELSE
		BEGIN
			SET @RetVal = 0 RETURN
		END
	END

	IF(@Accion = 'eliminar')
	BEGIN
		IF (@IdEncargadoEliminados <> '')
		BEGIN
			DECLARE @Eliminados TABLE (Idtramite INT, IdActor INT)

			INSERT INTO @Eliminados
			SELECT
			PARSENAME(REPLACE(items, ',', '.'), 2),
			PARSENAME(REPLACE(items, ',', '.'), 1)
			FROM dbo.udf_Split(@IdEncargadoEliminados, '|')

			DELETE EVA_SAE_TramiteEncargado
			FROM EVA_SAE_TramiteEncargado TE
			INNER JOIN @Eliminados E
			ON E.Idtramite = TE.IdTramite AND E.IdActor = TE.IdActor

			SET @RetVal = @@ROWCOUNT RETURN
		END
		ELSE
		BEGIN
			SET @RetVal = 0 RETURN
		END
	END
END