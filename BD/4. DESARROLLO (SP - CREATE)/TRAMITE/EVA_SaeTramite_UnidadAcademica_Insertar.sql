--IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'EVA_SaeTramite_UnidadAcademica_Insertar') DROP PROCEDURE EVA_SaeTramite_UnidadAcademica_Insertar
--GO 
---------------------------------------------------------------------------------    
----Creado por      : TuCodigoUsuario (10/05/2022)
----Revisado por    :    
----Funcionalidad   : Describir a detalle lo que realiza el SP
----Utilizado por   : EVA    
---------------------------------------------------------------------------------    
--/*    
-------------------------------------------------------------------------------    
--Nro   FECHA     USUARIO    DESCRIPCION      
-------------------------------------------------------------------------------                          

--Ejemplo:

--	EXEC [EVA_SaeTramite_UnidadAcademica_Insertar] 1228624,1

--*/ 

--CREATE PROCEDURE [EVA_SaeTramite_UnidadAcademica_Insertar]      
--	@IdTramite							INT,
--	@IdUsuario							INT,
--	@IdUnidadesAcademicas			    EVA_SAE_Tramite_UnidadAcademicaTemp READONLY,
--	@RetVal								INT OUT  
--AS          
--BEGIN    
--	SET NOCOUNT ON

	
--	DELETE FROM EVA_SAE_Tramite_UnidadAcademica WHERE IdTramite = @IdTramite

--	INSERT INTO EVA_SAE_Tramite_UnidadAcademica (IdTramite, IdUnidadAcademica, FechaCreacion, UsuarioCreacion)
--		SELECT IdTramite, IdUnidadesAcademicas, GETDATE(), IdUsuario FROM @IdUnidadesAcademicas

--	SET @RetVal = IIF(@@ROWCOUNT<>0,-1,-50)
--END

