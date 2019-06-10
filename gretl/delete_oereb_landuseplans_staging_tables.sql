DELETE FROM 
    agi_oereb_npl_staging.localiseduri 
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung'
;
DELETE FROM 
    agi_oereb_npl_staging.multilingualuri
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung'
;
DELETE FROM 
    agi_oereb_npl_staging.transferstruktur_eigentumsbeschraenkung
;
DELETE FROM 
    agi_oereb_npl_staging.vorschriften_dokument
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung'
;
DELETE FROM 
    agi_oereb_npl_staging.transferstruktur_hinweisvorschrift
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung'
;
DELETE FROM 
    agi_oereb_npl_staging.transferstruktur_geometrie
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung'
;



-- DELETE FROM agi_oereb_npl_staging.transferstruktur_geometrie; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';  
-- DELETE FROM agi_oereb_npl_staging.transferstruktur_hinweisvorschrift; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
-- DELETE FROM agi_oereb_npl_staging.transferstruktur_legendeeintrag; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung'; 
-- DELETE FROM agi_oereb_npl_staging.transferstruktur_darstellungsdienst; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung'; 
-- DELETE FROM agi_oereb_npl_staging.transferstruktur_eigentumsbeschraenkung; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
-- DELETE FROM agi_oereb_npl_staging.vorschriften_hinweisweiteredokumente; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
-- DELETE FROM agi_oereb_npl_staging.localiseduri; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
-- DELETE FROM agi_oereb_npl_staging.multilingualuri; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
-- DELETE FROM agi_oereb_npl_staging.vorschriften_dokument; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
--DELETE FROM agi_oereb_npl_staging.vorschriften_amt WHERE t_datasetname = 'ch.so.arp.nutzungsplanung';
--DELETE FROM agi_oereb_npl_staging.t_ili2db_basket WHERE topic = 'OeREBKRMtrsfr_V1_1.Transferstruktur';
--DELETE FROM agi_oereb_npl_staging.t_ili2db_dataset WHERE datasetname = 'ch.so.arp.nutzungsplanung';

