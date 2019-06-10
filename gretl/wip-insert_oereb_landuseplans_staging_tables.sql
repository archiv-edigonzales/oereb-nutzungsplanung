/*
 * Die korrekte Reihenfolge der Queries ist zwingend. 
 * 
 * Es wird versucht möglichst rasch die Daten in den Tabellen zu speichern. So
 * können die Queries gekapselt werden und/oder in nachvollziehbareren 
 * Teilschritten durchgeführt werden. Alternativ kann man (fast) alles in einer sehr
 * langen CTE umbauen.
 * 
 * Es wird versucht wenn immer möglich die Original-TID (resp. der PK aus der 
 * Quelltabelle) in der Zieltabelle beizubehalten. Damit bleiben Beziehungen
 * 'bestehen' und sind einfacher zu behandeln.
 */


/*
 * Die Eigentumsbeschränkungen können als erstes persistiert werden. Der Umbau der anderen Objekte erfolgt anschliessend.
 * Verschiedene Herausforderungen / Spezialitäten müssen behandelt werden:
 * 
 * (1) basket und dataset müssen eruiert und als FK gespeichert werden. Beide werden
 * werden in einer Subquery ermittelt. Dies ist möglich, da bereits die zuständigen Stellen
 * vorhanden sein müssen. Die zuständigen Stellen werden mitexportiert und teilen sich daher
 * das gleiche Dataset wie die übrigen Daten (im Gegensatz dazu die Gesetze).
 * 
 * (2) Die Grundnutzung wird nicht flächendeckend in den ÖREB-Kataster überführt, d.h. es
 * gibt Grundnutzungen, die nicht Bestandteil des Katasters sind. Dieser Filter ist eine
 * einfache WHERE-Clause.
 * 
 * (3) Die Attribute 'publiziertab' und 'rechtsstatus' sind im kantonalen Modell nicht in
 * der Typ-Klasse vorhanden, sondern werden hier ebenfalls von der Geometrie-Klasse 
 * verwendet. Der Join führt dazu, dass ein unschönes Distinct notwendig wird.
 * 
 * (4) Momentan geht man von der Annahme aus, dass bei den diesen Eigentumsbeschränkungen
 * die Gemeinde die zuständige Stelle ist. Falls das nicht mehr zutrifft, muss man die
 * zuständigen Stellen eventuell in einem nachgelagerten Schritt abhandeln.
 */

INSERT INTO 
    agi_oereb_npl_staging.transferstruktur_eigentumsbeschraenkung
    (
        t_id,
        t_basket,
        t_datasetname,
        aussage_de,
        thema,
        subthema,
        artcode,
        artcodeliste,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
    SELECT
        DISTINCT ON (typ_grundnutzung.t_ili_tid)
        typ_grundnutzung.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_grundnutzung.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'Grundnutzung_Zonenflaeche' AS subthema,
        substring(typ_grundnutzung.typ_kt FROM 1 FOR 4) AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Grundnutzung' AS artcodeliste,
        CASE 
            WHEN grundnutzung.rechtsstatus IS NULL THEN 'inKraft' /* TODO: tbd */
            ELSE grundnutzung.rechtsstatus
        END AS rechtsstatus,
        grundnutzung.publiziertab, /* TODO: tbd */
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_grundnutzung AS typ_grundnutzung
        LEFT JOIN agi_oereb_npl_staging.vorschriften_amt AS amt
        ON typ_grundnutzung.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_grundnutzung AS grundnutzung
        ON typ_grundnutzung.t_id = grundnutzung.typ_grundnutzung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                agi_oereb_npl_staging.t_ili2db_dataset AS dataset
                LEFT JOIN agi_oereb_npl_staging.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
    WHERE
        typ_kt NOT IN ('N180_Verkehrszone_Strasse', 'N420_Verkehrsflaeche_Strasse', 'N421_Verkehrsflaeche_Bahnareal', 'N422_Verkehrsflaeche_Flugplatzareal', 'N429_weitere_Verkehrsflaechen', 'N440_Wald')
;
