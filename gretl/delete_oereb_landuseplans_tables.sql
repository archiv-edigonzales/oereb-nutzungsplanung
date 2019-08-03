DELETE FROM
    arp_npl_grundnutzung_oereb.transferstruktur_legendeeintrag
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.localiseduri 
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.multilingualuri
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM
    arp_npl_grundnutzung_oereb.vorschriften_hinweisweiteredokumente
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.transferstruktur_hinweisvorschrift
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.vorschriften_dokument
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.transferstruktur_geometrie
WHERE 
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;
DELETE FROM 
    arp_npl_grundnutzung_oereb.transferstruktur_eigentumsbeschraenkung
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'    
;
DELETE FROM
    arp_npl_grundnutzung_oereb.transferstruktur_darstellungsdienst
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'
;




-- DELETE FROM arp_npl_grundnutzung_oereb.transferstruktur_geometrie; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';  
-- DELETE FROM arp_npl_grundnutzung_oereb.transferstruktur_hinweisvorschrift; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
-- DELETE FROM arp_npl_grundnutzung_oereb.transferstruktur_legendeeintrag; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'; 
-- DELETE FROM arp_npl_grundnutzung_oereb.transferstruktur_darstellungsdienst; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung'; 
-- DELETE FROM arp_npl_grundnutzung_oereb.transferstruktur_eigentumsbeschraenkung; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
-- DELETE FROM arp_npl_grundnutzung_oereb.vorschriften_hinweisweiteredokumente; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
-- DELETE FROM arp_npl_grundnutzung_oereb.localiseduri; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
-- DELETE FROM arp_npl_grundnutzung_oereb.multilingualuri; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
-- DELETE FROM arp_npl_grundnutzung_oereb.vorschriften_dokument; -- WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
--DELETE FROM arp_npl_grundnutzung_oereb.vorschriften_amt WHERE t_datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';
--DELETE FROM arp_npl_grundnutzung_oereb.t_ili2db_basket WHERE topic = 'OeREBKRMtrsfr_V1_1.Transferstruktur';
--DELETE FROM arp_npl_grundnutzung_oereb.t_ili2db_dataset WHERE datasetname = 'ch.so.arp.nutzungsplanung.grundnutzung';

