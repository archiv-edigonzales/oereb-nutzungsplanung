/*
* bfsnr = NULL bedeutet, dass keine Geometrie mit dem Objekt (Typ) verknüpft ist. Das ist auch gemäss
* ÖREB-Modell erlaubt. Für Endkunden m.E. aber sinnlos.
*/


SELECT
    DISTINCT ON (typ_grundnutzung.t_ili_tid)
    typ_grundnutzung.t_id,
    typ_grundnutzung.t_ili_tid,
    grundnutzung.t_datasetname::int AS bfsnr,        
    typ_grundnutzung.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'NutzungsplanungGrundnutzung' AS subthema,
    typ_grundnutzung.code_kommunal AS artcode,
    grundnutzung.rechtsstatus,
    grundnutzung.publiziertab
FROM
    arp_npl.nutzungsplanung_typ_grundnutzung AS typ_grundnutzung
    LEFT JOIN arp_npl.nutzungsplanung_grundnutzung AS grundnutzung
    ON typ_grundnutzung.t_id = grundnutzung.typ_grundnutzung

WHERE
    -- Zonentypen, die in den ÖREB-Kataster aufgenommen werden.
typ_kt NOT IN 
(
    'N180_Verkehrszone_Strasse',
    'N181_Verkehrszone_Bahnareal',
    'N182_Verkehrszone_Flugplatzareal',
    'N189_weitere_Verkehrszonen',
    'N210_Landwirtschaftszone',
    'N320_Gewaesser',
    'N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer',
    'N420_Verkehrsflaeche_Strasse', 
    'N421_Verkehrsflaeche_Bahnareal', 
    'N422_Verkehrsflaeche_Flugplatzareal', 
    'N429_weitere_Verkehrsflaechen', 
    'N430_Reservezone_Wohnzone_Mischzone_Kernzone_Zentrumszone',
    'N431_Reservezone_Arbeiten',
    'N432_Reservezone_OeBA',
    'N439_Reservezone',
    'N440_Wald'
)
AND
-- Keine Verknüpfung mit einem Dokument.
typ_grundnutzung.t_id NOT IN 
(
    SELECT
        DISTINCT ON (typ_grundnutzung) 
        typ_grundnutzung
    FROM
        arp_npl.nutzungsplanung_typ_grundnutzung_dokument
)  

UNION ALL

SELECT
    DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
    typ_ueberlagernd_flaeche.t_id,
    typ_ueberlagernd_flaeche.t_ili_tid,
    ueberlagernd_flaeche.t_datasetname::int AS bfsnr,                
    typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'NutzungsplanungUeberlagernd' AS subthema,
    typ_ueberlagernd_flaeche.code_kommunal AS artcode,
    ueberlagernd_flaeche.rechtsstatus,
    ueberlagernd_flaeche.publiziertab
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
    LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
    ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche
WHERE
    typ_kt IN 
    (
        'N510_ueberlagernde_Ortsbildschutzzone',
        'N523_Landschaftsschutzzone',
        'N526_kantonale_Landwirtschafts_und_Schutzzone_Witi',
        'N527_kantonale_Uferschutzzone',
        'N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen',
        'N529_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften',
        'N590_Hofstattzone_Freihaltezone',
        'N591_Bauliche_Einschraenkungen',
        'N599_weitere_ueberlagernde_Nutzungszonen',
        'N690_kantonales_Vorranggebiet_Natur_und_Landschaft',
        'N691_kommunales_Vorranggebiet_Natur_und_Landschaft',
        'N692_Planungszone',
        'N699_weitere_flaechenbezogene_Festlegungen_NP',
        'N812_geologisches_Objekt',
        'N813_Naturobjekt',
        'N822_schuetzenswertes_Kulturobjekt',
        'N823_erhaltenswertes_Kulturobjekt'
    )
    AND
    typ_ueberlagernd_flaeche.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_ueberlagernd_flaeche) 
            typ_ueberlagernd_flaeche
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument
    )  
        
UNION ALL

SELECT
    DISTINCT ON (typ_ueberlagernd_linie.t_ili_tid)
    typ_ueberlagernd_linie.t_id,
    typ_ueberlagernd_linie.t_ili_tid,   
    ueberlagernd_linie.t_datasetname::int AS bfsnr,                
    typ_ueberlagernd_linie.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'NutzungsplanungUeberlagernd' AS subthema,
    typ_ueberlagernd_linie.code_kommunal AS artcode,
    ueberlagernd_linie.rechtsstatus,
    ueberlagernd_linie.publiziertab
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_linie AS typ_ueberlagernd_linie
    LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_linie AS ueberlagernd_linie
    ON typ_ueberlagernd_linie.t_id = ueberlagernd_linie.typ_ueberlagernd_linie
WHERE
    typ_kt IN 
    (
        'N799_weitere_linienbezogene_Festlegungen_NP'
    )
    AND
    typ_ueberlagernd_linie.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_ueberlagernd_linie) 
            typ_ueberlagernd_linie
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument
    )  

UNION ALL

SELECT
    DISTINCT ON (typ_ueberlagernd_punkt.t_ili_tid)
    typ_ueberlagernd_punkt.t_id,
    typ_ueberlagernd_punkt.t_ili_tid, 
    ueberlagernd_punkt.t_datasetname::int AS bfsnr,                    
    typ_ueberlagernd_punkt.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'NutzungsplanungUeberlagernd' AS subthema,
    typ_ueberlagernd_punkt.code_kommunal AS artcode,
    ueberlagernd_punkt.rechtsstatus,
    ueberlagernd_punkt.publiziertab 
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_punkt AS typ_ueberlagernd_punkt
    LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_punkt AS ueberlagernd_punkt
    ON typ_ueberlagernd_punkt.t_id = ueberlagernd_punkt.typ_ueberlagernd_punkt
WHERE
    typ_kt IN 
    (
    'N811_erhaltenswerter_Einzelbaum',
    'N820_kantonal_geschuetztes_Kulturobjekt',
    'N821_kommunal_geschuetztes_Kulturobjekt',
    'N822_schuetzenswertes_Kulturobjekt',
    'N823_erhaltenswertes_Kulturobjekt',
    'N899_weitere_punktbezogene_Festlegungen_NP'
    )
    AND
    typ_ueberlagernd_punkt.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_ueberlagernd_punkt) 
            typ_ueberlagernd_punkt
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument
    )  

UNION ALL

SELECT
    DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
    typ_ueberlagernd_flaeche.t_id,
    typ_ueberlagernd_flaeche.t_ili_tid,
    ueberlagernd_flaeche.t_datasetname::int AS bfsnr,                
    typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'NutzungsplanungSondernutzungsplaene' AS subthema,
    typ_ueberlagernd_flaeche.code_kommunal AS artcode,
    ueberlagernd_flaeche.rechtsstatus,
    ueberlagernd_flaeche.publiziertab
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
    LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
    ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche
WHERE
    typ_kt IN 
    (
            'N610_Perimeter_kantonaler_Nutzungsplan',
            'N611_Perimeter_kommunaler_Gestaltungsplan',
            'N620_Perimeter_Gestaltungsplanpflicht'
    )
    AND
    typ_ueberlagernd_flaeche.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_ueberlagernd_flaeche) 
            typ_ueberlagernd_flaeche
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument
    )  

UNION ALL    
    
SELECT
    DISTINCT ON (typ_erschliessung_linienobjekt.t_ili_tid)
    typ_erschliessung_linienobjekt.t_id,
    typ_erschliessung_linienobjekt.t_ili_tid,  
    erschliessung_linienobjekt.t_datasetname::int AS bfsnr,                
    typ_erschliessung_linienobjekt.bezeichnung AS aussage_de,
    'Nutzungsplanung' AS thema,
    'Baulinien' AS subthema,
    typ_erschliessung_linienobjekt.code_kommunal AS artcode,
    erschliessung_linienobjekt.rechtsstatus,
    erschliessung_linienobjekt.publiziertab
FROM
    arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt AS typ_erschliessung_linienobjekt
    LEFT JOIN arp_npl.erschlssngsplnung_erschliessung_linienobjekt AS erschliessung_linienobjekt
    ON typ_erschliessung_linienobjekt.t_id = erschliessung_linienobjekt.typ_erschliessung_linienobjekt
WHERE
    typ_kt IN 
    (
        'E711_Baulinie_Strasse_kantonal',
        'E712_Vorbaulinie_kantonal',
        'E713_Gestaltungsbaulinie_kantonal',
        'E714_Rueckwaertige_Baulinie_kantonal',
        'E715_Baulinie_Infrastruktur_kantonal',
        'E719_weitere_nationale_und_kantonale_Baulinien',
        'E720_Baulinie_Strasse',
        'E721_Vorbaulinie',
        'E722_Gestaltungsbaulinie',
        'E723_Rueckwaertige_Baulinie',
        'E724_Baulinie_Infrastruktur',
        'E726_Baulinie_Hecke',
        'E727_Baulinie_Gewaesser',
        'E728_Immissionsstreifen',
        'E729_weitere_kommunale_Baulinien'
    )
    AND
    typ_erschliessung_linienobjekt.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_erschliessung_linienobjekt) 
            typ_erschliessung_linienobjekt
        FROM
            arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument
    )  
    
UNION ALL

SELECT
    DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
    typ_ueberlagernd_flaeche.t_id,
    typ_ueberlagernd_flaeche.t_ili_tid,
    ueberlagernd_flaeche.t_datasetname::int AS bfsnr,                
    typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
    'Laermemfindlichkeitsstufen' AS thema,
    ''::text AS subthema,
    typ_ueberlagernd_flaeche.code_kommunal AS artcode,
    ueberlagernd_flaeche.rechtsstatus,
    ueberlagernd_flaeche.publiziertab
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
    LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
    ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche
WHERE
    typ_kt IN 
    (
            'N680_Empfindlichkeitsstufe_I',
            'N681_Empfindlichkeitsstufe_II',
            'N682_Empfindlichkeitsstufe_II_aufgestuft',
            'N683_Empfindlichkeitsstufe_III',
            'N684_Empfindlichkeitsstufe_III_aufgestuft',
            'N685_Empfindlichkeitsstufe_IV',
            'N686_keine_Empfindlichkeitsstufe'
    )
    AND
    typ_ueberlagernd_flaeche.t_id NOT IN 
    (
        SELECT
            DISTINCT ON (typ_ueberlagernd_flaeche) 
            typ_ueberlagernd_flaeche
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument
    )  
;

