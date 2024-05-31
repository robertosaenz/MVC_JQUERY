IF NOT EXISTS (SELECT Codigo FROM EVA_PlantillasCorreos WHERE Codigo= 'CONCERANU')
BEGIN
	INSERT INTO EVA_PlantillasCorreos
	(CodigoRemitente, Codigo, Descripcion, AsuntoMensaje, CuerpoMensaje, EsActivo, UsuarioCreacion, FechaCreacion)
	VALUES
	(
		'TRAMITES',
		'CONCERANU',
		'Constancias y certificados - Anulado',
		'[NombreTramite] - Tr�mite Anulado',
		'<html><head> <meta http-equiv="Content-type" content="text/html; charset=utf-8"> <meta http-equiv="X-UA-Compatible" content="IE=Edge"> <base target="_blank"> <style type="text/css" class="existing-message-styles"> .ql-video{display: block; max-width: 100%;}.ql-video.ql-align-center{margin: 0 auto;}.ql-video.ql-align-right{margin: 0 0 0 auto;}.ql-bg-black{background-color: #000;}.ql-bg-red{background-color: #e60000;}.ql-bg-orange{background-color: #f90;}.ql-bg-yellow{background-color: #ff0;}.ql-bg-green{background-color: #008a00;}.ql-bg-blue{background-color: #06c;}.ql-bg-purple{background-color: #93f;}.ql-color-white{color: #fff;}.ql-color-red{color: #e60000;}.ql-color-orange{color: #f90;}.ql-color-yellow{color: #ff0;}.ql-color-green{color: #008a00;}.ql-color-blue{color: #06c;}.ql-color-purple{color: #93f;}.ql-font-serif{font-family: Georgia, Times New Roman, serif;}.ql-font-monospace{font-family: Monaco, Courier New, monospace;}.ql-size-small{font-size: 0.75em;}.ql-size-large{font-size: 1.5em;}.ql-size-huge{font-size: 2em;}.ql-direction-rtl{direction: rtl; text-align: inherit;}.ql-align-center{text-align: center;}.ql-align-justify{text-align: justify;}.ql-align-right{text-align: right;}.ql-editor.ql-blank::before{color: rgba(0, 0, 0, 0.6); content: attr(data-placeholder); font-style: italic; left: 15px; pointer-events: none; position: absolute; right: 15px;}</style></head><body style="background:#e8ebee;background-color:#e8ebee;padding:0;font:15px ''Montserrat'', ''Helvetica Neue'', Helvetica, sans-serif;font-weight:300;line-height:1.4;margin:0;overflow:hidden;word-wrap:break-word;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;"> <div style="background-color:#e8ebee;"> <div data-v-1b5f7c58="" style="margin: 0px auto; padding: 0px 0px 0px; max-width: 600px; background: rgb(255, 255, 255); color: rgb(0, 0, 0); font-family: Arial, Helvetica, sans-serif; font-size: 14px;"> <table data-v-1b5f7c58="" border="0" cellspacing="0" cellpadding="0" align="center" style="background: rgb(255, 255, 255); border-collapse: collapse;"> <tbody data-v-1b5f7c58=""> <tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" align="left" style="overflow-wrap: break-word; padding: 0px; border-collapse: collapse; text-align: center;"> <table data-v-1b5f7c58="" cellpadding="0" cellspacing="0" align="left" border="0" style="background-color: #722AE9; border-collapse: collapse; border-spacing: 0px; width: 100%;"> <tbody data-v-1b5f7c58=""> <tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" style="border-collapse: collapse; padding-left: 35px; padding-top: 46px;"> <img data-v-1b5f7c58="" src="https://cdn.idat.edu.pe/eva/email/logo-eva.png" width="72" height="21.74" style="border: 0px; border-radius: 0px; display: block; font-size: 13px; outline: none; text-decoration: none; width: 72px; height: auto; line-height: 100%;"> </td><td data-v-1b5f7c58="" style="border-collapse: collapse; padding-right: 35px; padding-top: 35px; text-align: right;"> <img data-v-1b5f7c58="" src="https://cdn.idat.edu.pe/eva/email/logo-idat.png" width="26" height="43.65" style="border: 0px; border-radius: 0px; display: block; font-size: 13px; outline: none; text-decoration: none; width: 26px; height: auto; line-height: 100%; margin-left: auto;"> </td></tr><tr> <td colspan="2" style="width: 100%; padding: 20px 35px 0px;"> <div style="height: 1px; background: rgb(255, 255, 255); background-color: #fff; width: 100%;"> </div></td></tr><tr> <td colspan="2" style="width: 100%; padding: 30px 0px;"> <p style="color: rgb(255, 255, 255); font-family: ''Montserrat'', ''Helvetica Neue'', Helvetica, sans-serif; font-size: 20px; font-weight: 700; line-height: 24.38px; text-transform: uppercase; text-align: center;"> TR�MITE EN PROCESO </p></td></tr></tbody> </table> </td></tr><tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" style="overflow-wrap: break-word; padding: 30px 44px 40px; border-collapse: collapse; text-align: center;"> <div data-v-1b5f7c58="" align="center" style="cursor: auto; font-family: Montserrat, Helvetica, &quot;Helvetica Neue&quot;, sans-serif;"> <div data-v-1b5f7c58=""> <p> <img data-v-1b5f7c58="" src="https://cdn.idat.edu.pe/eva/email/mailing-tramites.png" width="100%" height="205" style="border: 0px; border-radius: 0px; display: block; font-size: 13px; outline: none; text-decoration: none; width: 100%; max-width: 512.5px; height: auto; line-height: 100%;"> </p></div></div></td></tr><tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" style="overflow-wrap: break-word; padding: 0px 35px; border-collapse: collapse; text-align: center;"> <div data-v-1b5f7c58="" align="center" style="cursor: auto; color: rgb(0, 0, 0); font-family: ''Montserrat'', Helvetica, ''Helvetica'', sans-serif;"> <div data-v-1b5f7c58=""> <p style="font-size: 20px; line-height: 24.38px; margin: 0px;"><span style="font-weight: 700;">�Hola [Nombre]!</span></p><p style="margin: 10px 0px 7px; font-size: 14px; line-height: 17.07px;"> Tu tr�mite <span style="font-weight: 700;">[NombreTramite]</span>, c�digo <span style="font-weight: 700;">[Codigo]</span> est� en <span style="font-weight: 700;">proceso</span> <br/> Puedes ver el detalle de tu tr�mite en <span style="font-weight: 700;">Tr�mites en proceso.</span> </p></div></div></td></tr><tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" align="center" style="padding: 40px 0px; text-align: center; font-size: 0px; overflow-wrap: break-word;"> <table data-v-1b5f7c58="" cellpadding="0" cellspacing="0" align="center" border="0" style="border-collapse: separate; width: 100%; max-width: 342px;"> <tbody data-v-1b5f7c58=""> <tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" align="center" valign="middle" bgcolor="#722AE9" style="border: 1px solid #722AE9; border-radius: 5px; color: rgb(255, 255, 255); cursor: auto; background-color: #722AE9; display: inline-block; font-family: Montserrat, ''Montserrat'', Helvetica, ''Helvetica'', sans-serif; font-weight: 500; letter-spacing: 0px; line-height: 16px; text-align: center; text-decoration: none; width: 100%; padding: 15px 0px;"> <a data-v-1b5f7c58="" target="_blank" href="http://localhost:3000/estudiantes/tramites?tab=en-proceso" rel="noreferrer" style="text-decoration: none; color: white; font-family: ''Montserrat'', Montserrat, Helvetica, sans-serif; font-size: 16px; font-weight: 500; line-height: 100%; text-transform: none; margin: 0px;"> Tr�mites en proceso</a> </td></tr></tbody> </table> </td></tr><tr data-v-1b5f7c58=""> <td data-v-1b5f7c58="" align="center" valign="middle" style="border-collapse: collapse; width: 100%; padding: 0px 35px 54px; text-align: center;"> <p data-v-1b5f7c58="" style="margin: 0px auto; font-family: ''Montserrat'', Montserrat, Helvetica, ''Helvetica'', sans-serif; font-size: 10px; font-weight: 400; max-width: 480px; text-align: left;"> Este email es solo para tu informaci�n y no es necesario que lo respondas. Si necesitas ayuda o tienes alguna sugerencia cont�ctate con nuestro servicio de atenci�n al cliente. Todos los derechos reservados. </p></td></tr></tbody> </table> </div></div></body></html>',
		1,
		1,
		GETDATE()
	)
END

UPDATE EVA_SAE_TramiteEventoEstado
SET CorreoSolicitante = 'CONCERANU'
WHERE IdEstado=7