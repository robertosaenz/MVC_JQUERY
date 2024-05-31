
-- Activar los trámites en Desarrollo
update EVA_SAE_Tramite set EsActivo=1

-- Activar el pago con tarjeta

update parametro set Activo=1 where nombre like 'EVA_PAGARTARJETA'

