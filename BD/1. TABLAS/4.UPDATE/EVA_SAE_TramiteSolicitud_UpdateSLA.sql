UPDATE TS SET SLA = dbo.EVA_FN_RestarDiasHabiles(TS.FechaPGA,T.DiasAtencion,ES.FechaCreacion)
from EVA_SAE_TramiteSolicitud TS
INNER JOIN EVA_SAE_TramiteSolicitudHistorialEstados es on es.IdTramiteSolicitud=TS.IdTramiteSolicitud
INNER JOIN EVA_SAE_Tramite T ON T.IdTramite=TS.IdTramite
WHERE ES.IdEstado IN (5,8) AND TS.EsAutomatico=0 AND T.DiasAtencion>0