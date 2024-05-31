USE BDSMTP
GO
IF EXISTS (SELECT * FROM sys.objects WHERE TYPE = 'P' AND NAME = 'WS_Email_ListarMasivo') DROP PROCEDURE WS_Email_ListarMasivo
GO 
-------------------------------------------------------------------------------  
--Creado por      : Rsaenz (23/09/2021)      
--Revisado por    :  
--Funcionalidad   : 
--Utilizado por   : EMAIL  
-------------------------------------------------------------------------------  
/*  
-----------------------------------------------------------------------------  
Nro  	FECHA  			USUARIO  		DESCRIPCION    
-----------------------------------------------------------------------------   
*/ 

/*
Ejemplo:
EXEC [WS_Email_ListarMasivo] 2
*/  
CREATE PROCEDURE [dbo].[WS_Email_ListarMasivo]
@Limite INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TablaRequerimiento TABLE (CodigoRemitente VARCHAR(20),Requerimiento INT)
  DECLARE @TablaEnviados TABLE (IdRemitenteCorreo INT,CodigoRemitente VARCHAR(20),Email VARCHAR(100),Enviado INT)
  
  INSERT INTO @TablaRequerimiento
  SELECT
  ECA.CodigoRemitente,
  Count(ECA.CodigoRemitente) 
  FROM WS_EnvioCorreoAutomatico ECA WITH(NOLOCK)
  WHERE (ECA.Estado=0 OR ECA.Estado=2) AND (UsuarioEnvio=0 OR UsuarioEnvio=99)
  GROUP BY ECA.CodigoRemitente
  
 INSERT INTO @TablaEnviados
  SELECT
  RC.IdRemitenteCorreo,
  RC.CodigoRemitente,
  RC.email AS Email,
  COUNT(ECA.IdCorreo) AS Enviado
  FROM WS_RemitenteCorreo RC WITH(NOLOCK)
  LEFT JOIN WS_EnvioCorreoAutomatico ECA ON RC.IdRemitenteCorreo = ECA.usuarioenvio AND DAY(ECA.FechaEnvio) = DATEPART(DAY, CURRENT_TIMESTAMP) AND ECA.Estado=1
  GROUP BY RC.IdRemitenteCorreo,RC.CodigoRemitente,RC.email
  ORDER BY RC.CodigoRemitente,COUNT(ECA.IdCorreo) ASC

  UPDATE ECA
  SET 
  --ECA.Estado = CASE WHEN TE.IdRemitenteCorreo IS NULL THEN 2 ELSE 0 END,
  ECA.UsuarioEnvio = ISNULL(TE.IdRemitenteCorreo,99)
  FROM WS_EnvioCorreoAutomatico ECA
  LEFT JOIN @TablaRequerimiento TR ON TR.CodigoRemitente = ECA.CodigoRemitente 
  LEFT JOIN @TablaEnviados TE ON TE.CodigoRemitente = ECA.CodigoRemitente AND (TR.Requerimiento + TE.Enviado) < @Limite
  WHERE (ECA.Estado=0 OR ECA.Estado=2) AND (ECA.UsuarioEnvio=0 OR ECA.UsuarioEnvio=99)
  
  SELECT
  ECA.IdCorreo,
  ECA.Estado,
  ECA.UsuarioEnvio,
  ECA.CodigoRemitente,
  ECA.Destinatario,
  ECA.Asunto,
  ECA.Mensaje,
  R.Alias,
  R.Copia,
  R.CopiaOculta,
  RC.Email,
  RC.Password,
  CS.HostCorreoServidor,
  CS.PortCorreoServidor,
  CS.SslCorreoServidor,
  R.Prioridad 
  FROM WS_EnvioCorreoAutomatico ECA WITH(NOLOCK)
  LEFT JOIN WS_RemitenteCorreo RC ON RC.IdRemitenteCorreo = ECA.UsuarioEnvio
  LEFT JOIN WS_CorreoServidor CS ON CS.IdCorreoServidor = RC.IdCorreoServidor
  LEFT JOIN WS_Remitente R ON R.CodigoRemitente = ECA.CodigoRemitente
  WHERE ECA.Estado=0 OR ECA.Estado=2
  ORDER BY R.Prioridad ASC
  END


