
--IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('ParametroEmpresa'))
--BEGIN
--	UPDATE ParametroEmpresa 
--	SET Descripcion= '456879852|IDAT|SpringProduccionSEE|90|001|03|1|001|IDAT|#87189D'
--	WHERE Nombre= 'EVA_NIUBIZ'
--END
--GO

-- AGREGAR CODIGO COMPAŅIASOCIO
IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('ParametroEmpresa'))
BEGIN
	UPDATE ParametroEmpresa 
	SET Descripcion= '456879852|IPAE|SpringProduccionSEE|90|004|03|1|001|ZEGEL IPAE|#C41E3A'
	WHERE Nombre= 'EVA_NIUBIZ'

	UPDATE ParametroEmpresa 
	SET Descripcion= '456879852|IPAE|SpringProduccionSEE|90|004|03|1|001|ZEGEL IPAE|#C41E3A'
	WHERE Nombre= 'EVA_NIUBIZ_IQ'
END
GO

--IF EXISTS (SELECT C.NAME AS COLUMN_NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID=OBJECT_ID('ParametroEmpresa'))
--BEGIN
--	UPDATE ParametroEmpresa 
--	SET Descripcion= '456879852|CA|SpringProduccionSEE|90|002|03|1|001|CA|#0000'
--	WHERE Nombre= 'EVA_NIUBIZ'
--END

