IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EVA_SaeHistorialProductos_Agregar') DROP PROCEDURE EVA_SaeHistorialProductos_Agregar
GO
--------------------------------------------------------------------------------
--Creado por		: Rsaenz (18.11.2021)
--Revisado por		: SCAYCHO
--Funcionalidad		: Retorna los productos asociados a un alumno, muestra tambi�n la �ltima matricula de cada uno.
--Utilizado por		: SAE
--------------------------------------------------------------------------------
/*
--------------------------------------------------------------------------------
Nro		FECHA		USUARIO			DESCRIPCION
--------------------------------------------------------------------------------
*/

/*  
Ejemplo:
DECLARE @Output INT = 0
EXEC [EVA_SaeHistorialProductos_Agregar] 1421457, @Output OUTPUT
SELECT @Output

DECLARE @Output INT = 0
EXEC [EVA_SaeHistorialProductos_Agregar] 1556951, @Output OUTPUT
SELECT @Output

DECLARE @Output INT = 0
EXEC [EVA_SaeHistorialProductos_Agregar] 1536972, @Output OUTPUT
SELECT @Output

DECLARE @Output INT = 0
EXEC [EVA_SaeHistorialProductos_Agregar] 1569679, @Output OUTPUT
SELECT @Output

-- ZEGEL

DECLARE @Output INT = 0
EXEC [EVA_SaeHistorialProductos_Agregar] 678211, @Output OUTPUT
SELECT @Output
*/

CREATE PROCEDURE [dbo].[EVA_SaeHistorialProductos_Agregar]
@IdActor	INT,
@RetVal		INT OUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @FechaC VARCHAR(10)  
	DECLARE @FechaM VARCHAR(10)  
	DECLARE @Actual VARCHAR(10)		
	BEGIN TRY
		IF EXISTS( SELECT * FROM EVA_AlumnoHistorialProductos HP WITH(NOLOCK) WHERE HP.IdAlumno = @IdActor)  
		BEGIN  
			SELECT   
			@FechaC = CONVERT(varchar(10), HP.FechaCreacion, 126),   
			@FechaM = CONVERT(varchar(10),HP.FechaModificacion, 126),    
			@Actual = CONVERT(varchar(10), GETDATE(), 126)   
			FROM EVA_AlumnoHistorialProductos HP WITH(NOLOCK)   
			WHERE HP.IdAlumno = @IdActor  
			IF @FechaM IS NULL  
			BEGIN
				IF @FechaC <> @Actual  
				BEGIN
					UPDATE EVA_AlumnoHistorialProductos  
					SET FechaModificacion = GETDATE()  
					WHERE IdAlumno = @IdActor  

					DELETE FROM EVA_AlumnoHistorialProductosDetalle WHERE IdAlumno = @IdActor  

					INSERT [EVA_AlumnoHistorialProductosDetalle]
					(
						IdAlumno,
						IdRegistro,
						IdProducto,
						IdPromocion,
						IdUltimaMatricula,
						IdPeriodo,
						FechaFinUltimaMatricula,
						EstadoUltimaMatricula,
						IdModulo,
						IdUnidadnegocio,
						IdUnidadacademica,
						IdCurricula,
						EstadoAlumno,
						TieneCertificadoModular,
						Idsede
					)
					SELECT 
					@IdActor,
					R.IdRegistro,
					R.IdProducto,
					M.IdPromocion,
					MULTIMO.IdMatricula,
					P.IdPeriodo,
					ISNULL(PE.Fin,ISNULL(P.FechaFinPeriodo,ISNULL(PE.FechaFinExtMat,ISNULL(PE.FechaFinMat,PE.FechaCreacion)))) as Fin,
					M.Estado,
					M.IdModulo,
					P.IdUnidadNegocio,
					P.IdUnidadAcademica,
					M.IdCurricula,
					CASE WHEN EG.IdAlumno IS NOT NULL 
						THEN 'EGR' 
						ELSE 
							CASE WHEN M.Estado = 'N' AND (GETDATE() BETWEEN M.MatriculaFecha AND IIF(UN.IdUnidadNegocio = 1, PE.Fin,P.FechaFinPeriodo))
								THEN 'ACT' 
								ELSE 'INA'  
							END
					END 
					AS EstadoPeriodo,
					CASE WHEN COUNT(C.IdCurricula) > 0 OR C.IdCurricula IS NOT NULL 
						THEN 1
						ELSE 0
					END
					AS TieneCertificadoModular,
					P.IdSede
					FROM Registro R WITH(NOLOCK)
					INNER JOIN 
					(
						SELECT 
						M.IdRegistro, MAX(IdMatricula) AS IdMatricula
						FROM 
						Matricula M WITH (NOLOCK)
						WHERE M.IdActor = @IdActor AND M.Estado IN ('N','R') AND M.EsMatricula=1 and IdModulo is not null GROUP BY M.IdRegistro
					) MULTIMO ON MULTIMO.IdRegistro = R.IdRegistro 
					INNER JOIN Matricula M WITH(NOLOCK)			ON M.IdMatricula = MULTIMO.IdMatricula
					INNER JOIN Promocion P WITH(NOLOCK)			ON M.IdPromocion = P.IdPromocion
					INNER JOIN UnidadNegocio UN WITH(NOLOCK)	ON UN.IdUnidadNegocio = P.IdUnidadNegocio
					INNER JOIN Periodo PE WITH(NOLOCK)			ON P.IdPeriodo = PE.IdPeriodo    
					LEFT JOIN Egresados EG WITH(NOLOCK)			ON EG.IdAlumno = @IdActor AND EG.IdUnidadAcademica = P.IdUnidadAcademica AND EG.IdRegistro=M.IdRegistro and EG.IdCurricula=M.IdCurricula
					LEFT JOIN Certificado C WITH(NOLOCK)		ON C.IdCurricula = M.IdCurricula
					WHERE 
					R.IdActor = @IdActor
					AND R.Estado='N'
					GROUP BY 
					R.IdRegistro,R.IdProducto,M.IdPromocion,MULTIMO.IdMatricula,M.MatriculaFecha,P.IdPeriodo,
					M.Estado,M.IdModulo,P.IdUnidadNegocio,P.IdUnidadAcademica,M.IdCurricula,
					EG.IdAlumno,UN.IdUnidadNegocio,PE.Fin,
					P.FechaFinPeriodo,C.IdCurricula,PE.FechaFinExtMat,PE.FechaFinMat,PE.FechaCreacion,P.IdSede
				END
			END
			ELSE 
			BEGIN
				IF @FechaM <> @Actual  
				BEGIN
					UPDATE EVA_AlumnoHistorialProductos  
					SET FechaModificacion = GETDATE()  
					WHERE IdAlumno = @IdActor  

					DELETE FROM EVA_AlumnoHistorialProductosDetalle WHERE IdAlumno = @IdActor  

					INSERT [EVA_AlumnoHistorialProductosDetalle]
					(
						IdAlumno,
						IdRegistro,
						IdProducto,
						IdPromocion,
						IdUltimaMatricula,
						IdPeriodo,
						FechaFinUltimaMatricula,
						EstadoUltimaMatricula,
						IdModulo,
						IdUnidadnegocio,
						IdUnidadacademica,
						IdCurricula,
						EstadoAlumno,
						TieneCertificadoModular,
						Idsede
					)
					SELECT 
					@IdActor,
					R.IdRegistro,
					R.IdProducto,
					M.IdPromocion,
					MULTIMO.IdMatricula,
					P.IdPeriodo,
					ISNULL(PE.Fin,ISNULL(P.FechaFinPeriodo,ISNULL(PE.FechaFinExtMat,ISNULL(PE.FechaFinMat,PE.FechaCreacion)))) as Fin,
					M.Estado,
					M.IdModulo,
					P.IdUnidadNegocio,
					P.IdUnidadAcademica,
					M.IdCurricula,
					CASE WHEN EG.IdAlumno IS NOT NULL 
						THEN 'EGR' 
						ELSE 
							CASE WHEN M.Estado = 'N' AND (GETDATE() BETWEEN M.MatriculaFecha AND IIF(UN.IdUnidadNegocio = 1, PE.Fin,P.FechaFinPeriodo))
								THEN 'ACT' 
								ELSE 'INA'  
							END
					END AS EstadoPeriodo,
					CASE WHEN COUNT(C.IdCurricula) > 0 OR C.IdCurricula IS NOT NULL 
						THEN 1
						ELSE 0
					END
					AS TieneCertificadoModular,
					P.IdSede
					FROM Registro R WITH(NOLOCK)
					INNER JOIN 
					(
						SELECT 
						M.IdRegistro, MAX(IdMatricula) AS IdMatricula
						FROM 
						Matricula M WITH (NOLOCK)
						WHERE M.IdActor = @IdActor AND M.Estado IN ('N','R') AND M.EsMatricula=1 and IdModulo is not null GROUP BY M.IdRegistro
					) MULTIMO ON MULTIMO.IdRegistro = R.IdRegistro 
					INNER JOIN Matricula M WITH(NOLOCK)			ON M.IdMatricula = MULTIMO.IdMatricula
					INNER JOIN Promocion P WITH(NOLOCK)			ON M.IdPromocion = P.IdPromocion
					INNER JOIN UnidadNegocio UN WITH(NOLOCK)	ON UN.IdUnidadNegocio = P.IdUnidadNegocio
					INNER JOIN Periodo PE WITH(NOLOCK)			ON P.IdPeriodo = PE.IdPeriodo    
					LEFT JOIN Egresados EG WIth(NOLOCK)		ON EG.IdAlumno = @IdActor AND EG.IdUnidadAcademica = P.IdUnidadAcademica AND EG.IdRegistro=M.IdRegistro and EG.IdCurricula=M.IdCurricula
					LEFT JOIN Certificado C WITH(NOLOCK)		ON C.IdCurricula = M.IdCurricula
					WHERE 
					R.IdActor = @IdActor
					AND R.Estado='N'
					GROUP BY 
					R.IdRegistro,R.IdProducto,M.IdPromocion,MULTIMO.IdMatricula,M.MatriculaFecha,P.IdPeriodo,
					M.Estado,M.IdModulo,P.IdUnidadNegocio,P.IdUnidadAcademica,M.IdCurricula,
					EG.IdAlumno,UN.IdUnidadNegocio,PE.Fin,
					P.FechaFinPeriodo,C.IdCurricula,PE.FechaFinExtMat,PE.FechaFinMat,PE.FechaCreacion,P.IdSede
				END
			END
		END
		ELSE 
		BEGIN
			INSERT [EVA_AlumnoHistorialProductos]  
			(IdAlumno,UsuarioCreacion,FechaCreacion)  
			VALUES  
			(@IdActor,1,GETDATE())  

			INSERT [EVA_AlumnoHistorialProductosDetalle]
			(
				IdAlumno,
				IdRegistro,
				IdProducto,
				IdPromocion,
				IdUltimaMatricula,
				IdPeriodo,
				FechaFinUltimaMatricula,
				EstadoUltimaMatricula,
				IdModulo,
				IdUnidadnegocio,
				IdUnidadacademica,
				IdCurricula,
				EstadoAlumno,
				TieneCertificadoModular,
				IdSede
			)
			SELECT 
			@IdActor,
			R.IdRegistro,
			R.IdProducto,
			M.IdPromocion,
			MULTIMO.IdMatricula,
			P.IdPeriodo,
			ISNULL(PE.Fin,ISNULL(P.FechaFinPeriodo,ISNULL(PE.FechaFinExtMat,ISNULL(PE.FechaFinMat,PE.FechaCreacion)))) as Fin,
			M.Estado,
			M.IdModulo,
			P.IdUnidadNegocio,
			P.IdUnidadAcademica,
			M.IdCurricula,
			CASE WHEN EG.IdAlumno IS NOT NULL 
				THEN 'EGR' 
			ELSE 
				CASE WHEN M.Estado = 'N' AND (GETDATE() BETWEEN M.MatriculaFecha AND IIF(UN.IdUnidadNegocio = 1, PE.Fin,P.FechaFinPeriodo))
					THEN 'ACT' 
					ELSE 'INA'  
				END
			END 
			AS EstadoPeriodo,
			CASE WHEN COUNT(C.IdCurricula) > 0 OR C.IdCurricula IS NOT NULL 
				THEN 1
				ELSE 0
			END
			AS TieneCertificadoModular,
			P.IdSede
			FROM Registro R WITH(NOLOCK)
			INNER JOIN 
			(
				SELECT 
				M.IdRegistro, MAX(IdMatricula) AS IdMatricula
				FROM 
				Matricula M WITH (NOLOCK)
				WHERE M.IdActor = @IdActor AND M.Estado IN ('N','R') AND M.EsMatricula=1  and IdModulo is not null GROUP BY M.IdRegistro
			) MULTIMO ON MULTIMO.IdRegistro = R.IdRegistro 
			INNER JOIN Matricula M WITH(NOLOCK)			ON M.IdMatricula = MULTIMO.IdMatricula
			INNER JOIN Promocion P WITH(NOLOCK)			ON M.IdPromocion = P.IdPromocion
			INNER JOIN UnidadNegocio UN WITH(NOLOCK)	ON UN.IdUnidadNegocio = P.IdUnidadNegocio
			INNER JOIN Periodo PE WITH(NOLOCK)			ON P.IdPeriodo = PE.IdPeriodo 
			LEFT JOIN Egresados EG WIth(NOLOCK)		ON EG.IdAlumno = @IdActor AND EG.IdUnidadAcademica = P.IdUnidadAcademica AND EG.IdRegistro=M.IdRegistro and EG.IdCurricula=M.IdCurricula
			LEFT JOIN Certificado C WITH(NOLOCK)		ON C.IdCurricula = M.IdCurricula
			WHERE 
			R.IdActor = @IdActor
			AND R.Estado='N'
			GROUP BY 
			R.IdRegistro,R.IdProducto,M.IdPromocion,MULTIMO.IdMatricula,M.MatriculaFecha,P.IdPeriodo,
			M.Estado,M.IdModulo,P.IdUnidadNegocio,P.IdUnidadAcademica,M.IdCurricula,
			EG.IdAlumno,UN.IdUnidadNegocio,PE.Fin,
			P.FechaFinPeriodo,C.IdCurricula,PE.FechaFinExtMat,PE.FechaFinMat,PE.FechaCreacion,P.IdSede
		END

		SET @RetVal = -1
	END TRY 
	BEGIN CATCH
		SET @RetVal = -51
	END CATCH
END

