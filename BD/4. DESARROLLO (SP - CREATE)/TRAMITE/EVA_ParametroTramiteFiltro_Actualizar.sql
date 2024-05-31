IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_ParametroTramiteFiltro_Actualizar') DROP PROCEDURE EVA_ParametroTramiteFiltro_Actualizar
GO 
-------------------------------------------------------------------------------    
--Creado por      : ahurtado (30/05/2022)
--Revisado por    :    
--Funcionalidad   : Describir a detalle lo que realiza el SP
--Utilizado por   : EVA    
-------------------------------------------------------------------------------    
/*    
-----------------------------------------------------------------------------    
Nro   FECHA     USUARIO    DESCRIPCION      
-----------------------------------------------------------------------------                          

Ejemplo:

	DECLARE @Output VARCHAR(MAX)
	EXEC [EVA_ParametroTramiteFiltro_Actualizar] @Output OUTPUT
	SELECT @Output

*/ 

CREATE PROCEDURE [EVA_ParametroTramiteFiltro_Actualizar]      
	-- PARAMETROS AQUI
	@RetVal	VARCHAR(MAX) OUTPUT
AS          
BEGIN    
	SET NOCOUNT ON
	-- TU CODIGO
	BEGIN TRY  
	IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('#TempTramites')) DROP TABLE #TempTramites

			select IDENTITY (INT, 1, 1) AS Id,T.IdTramite,COUNT(IdCaso) as CantidadCasos,MAX(IdCaso) as UltimoCaso,MIN(IdCaso) as PrimerCaso into #TempTramites from EVA_SAE_Tramite T
			left join EVA_SAE_TramiteCaso TC ON T.IdTramite =TC.IdTramite
			where T.EsActivo = 1 and TC.EsActivo=1
			group by T.IdTramite

			select IDENTITY (INT, 1, 1) AS Id, T.IdTramite,IdCaso,IdFiltro,Nivel,IdFiltroPadre,Operador,Columna,Valor into #TempFiltros
			from EVA_SAE_Tramite T
			LEFT JOIN EVA_SAE_TramiteFiltro TF On T.IdTramite=TF.IdTramite
			where  T.EsActivo = 1 and TF.IdFiltro is not null

			DECLARE @CursorTramites int = 0, @filtro varchar(max) =''

			DECLARE @CantidadTramites int
			select  @CantidadTramites = COUNT(*) from #TempTramites


			WHILE @CursorTramites < @CantidadTramites
			BEGIN
				SET @CursorTramites = @CursorTramites + 1
				-- 1. CAPTURAR DATOS INICIALES
				DECLARE @IdTramite varchar(100)

				DECLARE @CantidadCasos int, @PrimerCaso int, @UltimoCaso int,@CursorCasos int = 0
				select @IdTramite=IdTramite ,@CantidadCasos=CantidadCasos,@PrimerCaso = PrimerCaso, @UltimoCaso=UltimoCaso from #TempTramites where Id=@CursorTramites

				-- 2. Definir el trámite actual en el filtro 
				set @filtro = @filtro + '(T.IdTramite=' + @IdTramite + ' ' 

				-- 3. Recorrer los casos del trámite
				WHILE @CursorCasos < @UltimoCaso
				BEGIN
					SET @CursorCasos = @CursorCasos + 1

					DECLARE @IdCaso int = null,
							@FiltroMin int,
							@FiltroMax int,
							@CursorFiltro int = 0
					select @IdCaso= IdCaso,@CursorFiltro =MIN(IdFiltro),  @FiltroMin= MIN(IdFiltro),@FiltroMax=MAX(IdFiltro) from #TempFiltros where IdCaso=@CursorCasos and IdTramite=@IdTramite
					Group by IdCaso
		
					IF (@IdCaso is not null)
					BEGIN
						--SE AGREGA EL "and" al primer caso y el parentesis + id caso de cada caso
						set @filtro = @filtro + IIF (@PrimerCaso = @IdCaso, ' and (', '') + ' (TC.IdCaso='+ CONVERT(varchar,@IdCaso) + ' and ('

						DECLARE @OperadorPrincipal1 varchar(100), @NivelPrincipal1 int

						-- GUARDAMOS EL PRIMER OPERADOR ENCONTRADO (AND o OR)
						select @OperadorPrincipal1=Operador, @NivelPrincipal1 = Nivel from #TempFiltros where IdCaso=@IdCaso and IdFiltro= @CursorFiltro

						-- SALTAMOS A LA SIGUIENTE FILA
						SET @CursorFiltro = @CursorFiltro + 1

						WHILE @CursorFiltro <= @FiltroMax
						BEGIN
							DECLARE @Nivel1 int,
									@IdFiltroPadre1 int,
									@Operador1 varchar(100),
									@Columna1 varchar(1000),
									@Valor1 varchar(1000)
							-- PASAMOS LOS DATOS DE LA FILA A LAS VARIABLES CORRESPONDIENTES
							select @Nivel1=Nivel,@IdFiltroPadre1=IdFiltroPadre,@Operador1=Operador,@Columna1=Columna,@Valor1=Valor from #TempFiltros where IdCaso=@IdCaso and IdFiltro= @CursorFiltro
							IF (@Operador1 in ('AND', 'OR'))
							BEGIN
								-- ACA DEBEMOS RECORRER UN NIVEL MÁS (Nivel 2)
									--Agregar el parentesis de inicio del nivel 2
									set @filtro = @filtro + ' ('
									DECLARE @IdFiltroPrincipal2 int , @OperadorPrincipal2 varchar(100), @NivelPrincipal2 int,@FinPrincipal2 bit = 0

									-- GUARDAMOS EL PRIMER OPERADOR ENCONTRADO (AND o OR)
									select @OperadorPrincipal2=Operador, @NivelPrincipal2 = Nivel, @IdFiltroPrincipal2 = IdFiltro from #TempFiltros where IdCaso=@IdCaso and IdFiltro= @CursorFiltro

									-- SALTAMOS A LA SIGUIENTE FILA
									SET @CursorFiltro = @CursorFiltro + 1

									WHILE @CursorFiltro <= @FiltroMax
									BEGIN
										DECLARE @Nivel2 int,
												@IdFiltroPadre2 int,
												@Operador2 varchar(100),
												@Columna2 varchar(1000),
												@Valor2 varchar(1000)
										-- PASAMOS LOS DATOS DE LA FILA A LAS VARIABLES CORRESPONDIENTES
										select @Nivel2=Nivel,@IdFiltroPadre2=IdFiltroPadre,@Operador2=Operador,@Columna2=Columna,@Valor2=Valor from #TempFiltros where IdCaso=@IdCaso and IdFiltro= @CursorFiltro

										IF (@IdFiltroPrincipal2 <> @IdFiltroPadre2)
										BEGIN
											SET @filtro = SUBSTRING(@filtro, 1, LEN(@filtro) - 4)
											select @Nivel1=Nivel,@IdFiltroPadre1=IdFiltroPadre,@Operador1=Operador,@Columna1=Columna,@Valor1=Valor from #TempFiltros where IdCaso=@IdCaso and IdFiltro= @CursorFiltro
											SET @FinPrincipal2 = 1
											BREAK;
										END
										IF (@Operador2 in ('AND', 'OR'))
										BEGIN
											-- ACA DEBEMOS RECORRER UN NIVEL MÁS
											SET @filtro = @filtro
										END
										ELSE 
										BEGIN
											SET @filtro = @filtro + 'HPD.' + @Columna2 + ' ' + @Operador2 + ' (SELECT DATA FROM Split(''' + @Valor2  + ''', '','')) ' + IIF(@CursorFiltro < @FiltroMax, @OperadorPrincipal2 + ' ', '')
										END
										SET @CursorFiltro = @CursorFiltro+1
									END
									set @filtro = @filtro + ') ' + IIF(@FinPrincipal2 = 1, @OperadorPrincipal1 + ' ', '')
							END
							--ELSE 
							--BEGIN
								SET @filtro = @filtro + 'HPD.' + @Columna1 + ' ' + @Operador1 + ' (SELECT DATA FROM Split(''' + @Valor1  + ''', '','')) ' + IIF(@CursorFiltro < @FiltroMax, @OperadorPrincipal1 + ' ', '')
							--END
							SET @CursorFiltro = @CursorFiltro+1
						END

						-- CERRAR EL CASO Y CONCATENAR CON un "or" EL SIGUIENTE (SI HAY MAS CASOS)
						set @filtro = @filtro + ')) ' + IIF(@CursorCasos < @UltimoCaso, 'or ', ') ')
					END
				END

				set @filtro = @filtro + ') ' + IIF(@CursorTramites < @CantidadTramites,'or ','')

	

			END

			-- Actualizar parametro tramiteFiltro
			--select @filtro

			UPDATE Parametro SET Valor = @filtro WHERE Nombre = 'EVA_TRAMITEFILTRO'

			SET @RetVal = @filtro
	END TRY  
	BEGIN CATCH  
			-- Actualizar parametro tramiteFiltro
	END CATCH 

	IF (OBJECT_ID(N'tempdb..#TempTramites') IS NOT NULL) DROP TABLE #TempTramites
	IF (OBJECT_ID(N'tempdb..#TempFiltros') IS NOT NULL) DROP TABLE #TempFiltros
END

