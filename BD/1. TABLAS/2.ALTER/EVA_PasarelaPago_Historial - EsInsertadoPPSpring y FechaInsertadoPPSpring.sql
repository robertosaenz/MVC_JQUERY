IF EXISTS (SELECT C.NAME FROM SYS.COLUMNS C WHERE C.OBJECT_ID = OBJECT_ID('EVA_PasarelaPago_Historial'))
BEGIN
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_PasarelaPago_Historial' AND COLUMN_NAME = 'EsInsertadoPPSpring')
	BEGIN
		ALTER TABLE EVA_PasarelaPago_Historial
		ADD EsInsertadoPPSpring  BIT NOT NULL DEFAULT 0
	END
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'EVA_PasarelaPago_Historial' AND COLUMN_NAME = 'FechaInsertadoPPSpring')
	BEGIN
		ALTER TABLE EVA_PasarelaPago_Historial
		ADD FechaInsertadoPPSpring  DATETIME NULL
	END
END
