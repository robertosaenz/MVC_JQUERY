
--DECLARE @Compania varchar(8)
--Select @Compania= CompaniaSocio from Empresa where Activo=1

--IF (@Compania='00002500')
--BEGIN
	DECLARE @servidor VARCHAR(50)
	SELECT @servidor=@@SERVERNAME

	IF(@servidor='CA-DB-TES')
	BEGIN
		UPDATE Parametro SET valor='PLDBTEST02', Valor2='SpringPruebaSEE_Diario' WHERE Nombre = 'ServidorVinculadoSpring'
		UPDATE Parametro SET valor='PLDBTEST02', Valor2='SpringUnidoASOC' WHERE Nombre = 'ServidorVinculadoSpringASOC'
		RETURN;
	END
	ELSE IF(@servidor='PREPROD-DB')
	BEGIN
		UPDATE Parametro SET valor='PLDB01', Valor2='SpringPruebaSEE_Diario' WHERE Nombre = 'ServidorVinculadoSpring'
		UPDATE Parametro SET valor='PLDB01', Valor2='SpringUnidoASOC' WHERE Nombre = 'ServidorVinculadoSpringASOC'
		RETURN;
	END
--END

--Select * from Parametro where Nombre like '%spring%'