IF EXISTS (SELECT C.NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID = OBJECT_ID('EVA_SAE_Tramite'))
BEGIN
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_SAE_Tramite' AND COLUMN_NAME = 'TodosUnidadesDeNegocio')
	BEGIN		
		DECLARE @ConstraintTodosUnidadesDeNegocio NVARCHAR(200)
		SELECT @ConstraintTodosUnidadesDeNegocio = Name FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID('EVA_SAE_Tramite')
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
								WHERE NAME = N'TodosUnidadesDeNegocio'
								AND object_id = OBJECT_ID(N'EVA_SAE_Tramite'))
		IF @ConstraintTodosUnidadesDeNegocio IS NOT NULL
		EXEC
		(
			'ALTER TABLE EVA_SAE_Tramite DROP CONSTRAINT ' + @ConstraintTodosUnidadesDeNegocio + ';'+
			'ALTER TABLE EVA_SAE_Tramite DROP COLUMN TodosUnidadesDeNegocio;;'
		)
	END
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_SAE_Tramite' AND COLUMN_NAME = 'TodosUnidadesAcademicas')
	BEGIN
		DECLARE @ConstraintTodosUnidadesAcademicas NVARCHAR(200)
		SELECT @ConstraintTodosUnidadesAcademicas = Name FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID('EVA_SAE_Tramite')
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
								WHERE NAME = N'TodosUnidadesAcademicas'
								AND object_id = OBJECT_ID(N'EVA_SAE_Tramite'))
		IF @ConstraintTodosUnidadesAcademicas IS NOT NULL
		EXEC
		(
			'ALTER TABLE EVA_SAE_Tramite DROP CONSTRAINT ' + @ConstraintTodosUnidadesAcademicas + ';'+
			'ALTER TABLE EVA_SAE_Tramite DROP COLUMN TodosUnidadesAcademicas;;'
		)
	END
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_SAE_Tramite' AND COLUMN_NAME = 'TodosProductos')
	BEGIN
		DECLARE @ConstraintTodosProductos NVARCHAR(200)
		SELECT @ConstraintTodosProductos = Name FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID('EVA_SAE_Tramite')
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
								WHERE NAME = N'TodosProductos'
								AND object_id = OBJECT_ID(N'EVA_SAE_Tramite'))
		IF @ConstraintTodosProductos IS NOT NULL
		EXEC
		(
			'ALTER TABLE EVA_SAE_Tramite DROP CONSTRAINT ' + @ConstraintTodosProductos + ';'+
			'ALTER TABLE EVA_SAE_Tramite DROP COLUMN TodosProductos;'
		)
	END
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_SAE_Tramite' AND COLUMN_NAME = 'TodosModulos')
	BEGIN		
		DECLARE @ConstraintTodosModulos NVARCHAR(200)
		SELECT @ConstraintTodosModulos = Name FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID('EVA_SAE_Tramite')
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
								WHERE NAME = N'TodosModulos'
								AND object_id = OBJECT_ID(N'EVA_SAE_Tramite'))
		IF @ConstraintTodosModulos IS NOT NULL
		EXEC
		(
			'ALTER TABLE EVA_SAE_Tramite DROP CONSTRAINT ' + @ConstraintTodosModulos + ';'+
			'ALTER TABLE EVA_SAE_Tramite DROP COLUMN TodosModulos;'
		)
	END
END