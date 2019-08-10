-- This is the original setup.sql file, copied from https://github.com/CrunchyData/crunchy-containers/blob/4dcbbf676523e613a571c3f79bb844d03643866f/bin/postgres-gis/setup.sql,
-- with commands currently not needed for OEREB commented out.

SET application_name="container_setup";

--create extension postgis;
--create extension postgis_topology;
--create extension fuzzystrmatch;
--create extension postgis_tiger_geocoder;
create extension pg_stat_statements;
create extension pgaudit;
--create extension plr;

alter user postgres password 'PG_ROOT_PASSWORD';

create user PG_PRIMARY_USER with REPLICATION  PASSWORD 'PG_PRIMARY_PASSWORD';
create user PG_USER with password 'PG_PASSWORD';

create table primarytable (key varchar(20), value varchar(20));
grant all on primarytable to PG_PRIMARY_USER;

create database PG_DATABASE;

grant all privileges on database PG_DATABASE to PG_USER;

\c PG_DATABASE

create extension postgis;
create extension "uuid-ossp";
--create extension postgis_topology;
create extension fuzzystrmatch;
--create extension postgis_tiger_geocoder;
create extension pg_stat_statements;
create extension pgaudit;
--create extension plr;

\c PG_DATABASE PG_USER;

create schema PG_USER;

create table PG_USER.testtable (
	name varchar(30) primary key,
	value varchar(50) not null,
	updatedt timestamp not null
);



insert into PG_USER.testtable (name, value, updatedt) values ('CPU', '256', now());
insert into PG_USER.testtable (name, value, updatedt) values ('MEM', '512m', now());

grant all on PG_USER.testtable to PG_PRIMARY_USER;
-- Here starts the section creating schemas and tables needed in the database
SET ROLE PG_USER;
BEGIN;
CREATE SCHEMA IF NOT EXISTS arp_npl;
CREATE SEQUENCE arp_npl.t_ili2db_seq;;
-- SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument
CREATE TABLE arp_npl.rechtsvorschrften_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,dokumentid varchar(16) NULL
  ,titel varchar(80) NOT NULL
  ,offiziellertitel varchar(240) NULL
  ,abkuerzung varchar(10) NULL
  ,offiziellenr varchar(20) NOT NULL
  ,kanton varchar(255) NULL
  ,gemeinde integer NULL
  ,publiziertab date NOT NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,textimweb varchar(1023) NULL
  ,bemerkungen varchar(240) NULL
  ,rechtsvorschrift boolean NULL
)
;
CREATE INDEX rechtsvorschrften_dokument_t_basket_idx ON arp_npl.rechtsvorschrften_dokument ( t_basket );
CREATE INDEX rechtsvorschrften_dokument_t_datasetname_idx ON arp_npl.rechtsvorschrften_dokument ( t_datasetname );
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.dokumentid IS 'leer lassen';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.titel IS 'Dokumentart z.B. Regierungsratsbeschluss, Zonenreglement, Sonderbauvorschriften, Erschliessungsplan, Gestaltungsplan.';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.offiziellertitel IS 'Vollst�ndiger Titel des Dokuments, wenn der OffiziellerTitel gleich lautet wie der Titel, so ist die Planbezeichnung aus der Planliste zu �bernehmen.';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.abkuerzung IS 'Abk�rzung der Dokumentart RRB, ZR, SBV';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.offiziellenr IS 'Eindeutiger Identifikator gem�ss Planregister. Die ID setzt sich folgendermassen zusammen:
Sonderbauvorschriften: Gemeindennummer �-� Plannummer nach Planregister �-� S (f�r Sonderbauvorschriften)z.B. 109-31-S
Reglemente: Gemeindenummer �-� und K�rzel Reglementart (ZR Zonenereglement, BR Baureglement und BZR Bau- und Zonenreglement z.B. 109-BR
Gestaltungsplan: Gemeindennummer �-� Plannummer nach Planregister �-� P (f�r Plan) z.B. 109-31-P
Bei RRB ist die RRB Nr. aufzuf�hren (YYYY/RRB Nr.) z.B. 2001/1585';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.kanton IS 'Abk�rzung Kanton';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.gemeinde IS 'Gemeindenummer vom schweizerischen Bundesamt f�r Statistik (BFS-Nr.)';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.rechtsstatus IS 'Rechtsstatus des Dokuments.';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.textimweb IS 'Relative Internetadresse des Dokuments auf Planregister. D.h. stabiler Teil, ohne https://geoweb.so.ch/zonenplaene/Zonenplaene_pdf/ z.B. 109-Wissen/Entscheide/109-31-E.pdf';
COMMENT ON COLUMN arp_npl.rechtsvorschrften_dokument.bemerkungen IS 'Erl�uternder Text oder Bemerkungen zum Dokument.';
-- SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente
CREATE TABLE arp_npl.rechtsvorschrften_hinweisweiteredokumente (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,ursprung bigint NOT NULL
  ,hinweis bigint NOT NULL
)
;
CREATE INDEX rechtsvrschrfhnwswtrdkmnte_t_basket_idx ON arp_npl.rechtsvorschrften_hinweisweiteredokumente ( t_basket );
CREATE INDEX rechtsvrschrfhnwswtrdkmnte_t_datasetname_idx ON arp_npl.rechtsvorschrften_hinweisweiteredokumente ( t_datasetname );
CREATE INDEX rechtsvrschrfhnwswtrdkmnte_ursprung_idx ON arp_npl.rechtsvorschrften_hinweisweiteredokumente ( ursprung );
CREATE INDEX rechtsvrschrfhnwswtrdkmnte_hinweis_idx ON arp_npl.rechtsvorschrften_hinweisweiteredokumente ( hinweis );
COMMENT ON TABLE arp_npl.rechtsvorschrften_hinweisweiteredokumente IS 'Eine Hierarchie der Dokumente kann erfasst werden. Als prim�res Dokument (Ursprung) gilt immer die Rechtsvorschrift (Baureglement, Zonenreglement, Sonderbauvorschrift, Gestaltungsplan etc.), dort wo die eigentumsbeschr�nkten Informationen festgehalten sind. Die RRBs (Hinweis) werden diesen Rechtsvorschriften zugewiesen. Ist keine Rechtsvorschrift vorhanden, so wird der Typ_Grundnutzung direkt mit dem RRB verkn�pft';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung
CREATE TABLE arp_npl.nutzungsplanung_typ_grundnutzung (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,nutzungsziffer decimal(3,2) NULL
  ,nutzungsziffer_art varchar(255) NULL
  ,geschosszahl integer NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX nutzngsplnng_yp_grndntzung_t_basket_idx ON arp_npl.nutzungsplanung_typ_grundnutzung ( t_basket );
CREATE INDEX nutzngsplnng_yp_grndntzung_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_grundnutzung ( t_datasetname );
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.nutzungsziffer IS 'Zahlenwert nach Zonenreglement der Gemeinde (0.05 = 5%).';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.geschosszahl IS 'Maximal zul�ssige Anzahl Geschosse';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_grundnutzung.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX nutzngsplnng_brlgrnd_flche_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche ( t_basket );
CREATE INDEX nutzngsplnng_brlgrnd_flche_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche ( t_datasetname );
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX nutzngsplnng__brlgrnd_lnie_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie ( t_basket );
CREATE INDEX nutzngsplnng__brlgrnd_lnie_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie ( t_datasetname );
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_linie.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_linie.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_linie.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_linie.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX nutzngsplnng__brlgrnd_pnkt_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt ( t_basket );
CREATE INDEX nutzngsplnng__brlgrnd_pnkt_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt ( t_datasetname );
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_punkt.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_punkt.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_punkt.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_typ_ueberlagernd_punkt.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument
CREATE TABLE arp_npl.nutzungsplanung_typ_grundnutzung_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_grundnutzung bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX nutzngsplnng_dntzng_dkment_t_basket_idx ON arp_npl.nutzungsplanung_typ_grundnutzung_dokument ( t_basket );
CREATE INDEX nutzngsplnng_dntzng_dkment_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_grundnutzung_dokument ( t_datasetname );
CREATE INDEX nutzngsplnng_dntzng_dkment_typ_grundnutzung_idx ON arp_npl.nutzungsplanung_typ_grundnutzung_dokument ( typ_grundnutzung );
CREATE INDEX nutzngsplnng_dntzng_dkment_dokument_idx ON arp_npl.nutzungsplanung_typ_grundnutzung_dokument ( dokument );
COMMENT ON TABLE arp_npl.nutzungsplanung_typ_grundnutzung_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_ueberlagernd_flaeche bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX nutzngsplnng_d_flch_dkment_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ( t_basket );
CREATE INDEX nutzngsplnng_d_flch_dkment_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ( t_datasetname );
CREATE INDEX nutzngsplnng_d_flch_dkment_typ_ueberlagernd_flaeche_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ( typ_ueberlagernd_flaeche );
CREATE INDEX nutzngsplnng_d_flch_dkment_dokument_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ( dokument );
COMMENT ON TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_ueberlagernd_linie bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX nutzngsplnng_rnd_ln_dkment_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ( t_basket );
CREATE INDEX nutzngsplnng_rnd_ln_dkment_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ( t_datasetname );
CREATE INDEX nutzngsplnng_rnd_ln_dkment_typ_ueberlagernd_linie_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ( typ_ueberlagernd_linie );
CREATE INDEX nutzngsplnng_rnd_ln_dkment_dokument_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ( dokument );
COMMENT ON TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument
CREATE TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_ueberlagernd_punkt bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX nutzngsplnng_d_pnkt_dkment_t_basket_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ( t_basket );
CREATE INDEX nutzngsplnng_d_pnkt_dkment_t_datasetname_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ( t_datasetname );
CREATE INDEX nutzngsplnng_d_pnkt_dkment_typ_ueberlagernd_punkt_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ( typ_ueberlagernd_punkt );
CREATE INDEX nutzngsplnng_d_pnkt_dkment_dokument_idx ON arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ( dokument );
COMMENT ON TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung
CREATE TABLE arp_npl.nutzungsplanung_grundnutzung (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POLYGON,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_grundnutzung bigint NOT NULL
)
;
CREATE INDEX nutzungsplanung_grndntzung_t_basket_idx ON arp_npl.nutzungsplanung_grundnutzung ( t_basket );
CREATE INDEX nutzungsplanung_grndntzung_t_datasetname_idx ON arp_npl.nutzungsplanung_grundnutzung ( t_datasetname );
CREATE INDEX nutzungsplanung_grndntzung_geometrie_idx ON arp_npl.nutzungsplanung_grundnutzung USING GIST ( geometrie );
CREATE INDEX nutzungsplanung_grndntzung_typ_grundnutzung_idx ON arp_npl.nutzungsplanung_grundnutzung ( typ_grundnutzung );
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.geometrie IS 'Geometrie als Gebietseinteilung. �berlappungen bei Radien mit einer
Pfeilh�he <1 mm werden toleriert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.name_nummer IS 'Leer lassen';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.bemerkungen IS 'Bemerkung zu der einzelnen Grundnutzungsgeometrie.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POLYGON,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_ueberlagernd_flaeche bigint NOT NULL
)
;
CREATE INDEX nutzngsplnng_brlgrnd_flche_t_basket_idx1 ON arp_npl.nutzungsplanung_ueberlagernd_flaeche ( t_basket );
CREATE INDEX nutzngsplnng_brlgrnd_flche_t_datasetname_idx1 ON arp_npl.nutzungsplanung_ueberlagernd_flaeche ( t_datasetname );
CREATE INDEX nutzngsplnng_brlgrnd_flche_geometrie_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche USING GIST ( geometrie );
CREATE INDEX nutzngsplnng_brlgrnd_flche_typ_ueberlagernd_flaeche_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche ( typ_ueberlagernd_flaeche );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.geometrie IS 'Fl�che, welche die Grundnutzung �berlagert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.bemerkungen IS 'Bemerkung zu der einzelnen �berlagernden Objekte.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_linie (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(LINESTRING,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_ueberlagernd_linie bigint NOT NULL
)
;
CREATE INDEX nutzungsplnng_brlgrnd_lnie_t_basket_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie ( t_basket );
CREATE INDEX nutzungsplnng_brlgrnd_lnie_t_datasetname_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie ( t_datasetname );
CREATE INDEX nutzungsplnng_brlgrnd_lnie_geometrie_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie USING GIST ( geometrie );
CREATE INDEX nutzungsplnng_brlgrnd_lnie_typ_ueberlagernd_linie_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie ( typ_ueberlagernd_linie );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.geometrie IS 'Linie, welche die Grundnutzung �berlagert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.bemerkungen IS 'Bemerkung zu der einzelnen �berlagernden Objekte.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_ueberlagernd_punkt bigint NOT NULL
)
;
CREATE INDEX nutzungsplnng_brlgrnd_pnkt_t_basket_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt ( t_basket );
CREATE INDEX nutzungsplnng_brlgrnd_pnkt_t_datasetname_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt ( t_datasetname );
CREATE INDEX nutzungsplnng_brlgrnd_pnkt_geometrie_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt USING GIST ( geometrie );
CREATE INDEX nutzungsplnng_brlgrnd_pnkt_typ_ueberlagernd_punkt_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt ( typ_ueberlagernd_punkt );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.geometrie IS 'Punkt, welche die Grundnutzung �berlagert.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.bemerkungen IS 'Bemerkung zu der einzelnen �berlagernden Objekte.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Pos
CREATE TABLE arp_npl.nutzungsplanung_grundnutzung_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,grundnutzung bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX nutzngsplnng_grndntzng_pos_t_basket_idx ON arp_npl.nutzungsplanung_grundnutzung_pos ( t_basket );
CREATE INDEX nutzngsplnng_grndntzng_pos_t_datasetname_idx ON arp_npl.nutzungsplanung_grundnutzung_pos ( t_datasetname );
CREATE INDEX nutzngsplnng_grndntzng_pos_grundnutzung_idx ON arp_npl.nutzungsplanung_grundnutzung_pos ( grundnutzung );
CREATE INDEX nutzngsplnng_grndntzng_pos_pos_idx ON arp_npl.nutzungsplanung_grundnutzung_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_grundnutzung_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Pos
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,ueberlagernd_flaeche bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX nutzngsplnng_grnd_flch_pos_t_basket_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ( t_basket );
CREATE INDEX nutzngsplnng_grnd_flch_pos_t_datasetname_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ( t_datasetname );
CREATE INDEX nutzngsplnng_grnd_flch_pos_ueberlagernd_flaeche_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ( ueberlagernd_flaeche );
CREATE INDEX nutzngsplnng_grnd_flch_pos_pos_idx ON arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Pos
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_linie_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,ueberlagernd_linie bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX nutzngsplnng_rlgrnd_ln_pos_t_basket_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie_pos ( t_basket );
CREATE INDEX nutzngsplnng_rlgrnd_ln_pos_t_datasetname_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie_pos ( t_datasetname );
CREATE INDEX nutzngsplnng_rlgrnd_ln_pos_ueberlagernd_linie_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie_pos ( ueberlagernd_linie );
CREATE INDEX nutzngsplnng_rlgrnd_ln_pos_pos_idx ON arp_npl.nutzungsplanung_ueberlagernd_linie_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_linie_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Pos
CREATE TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,ueberlagernd_punkt bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX nutzngsplnng_grnd_pnkt_pos_t_basket_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ( t_basket );
CREATE INDEX nutzngsplnng_grnd_pnkt_pos_t_datasetname_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ( t_datasetname );
CREATE INDEX nutzngsplnng_grnd_pnkt_pos_ueberlagernd_punkt_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ( ueberlagernd_punkt );
CREATE INDEX nutzngsplnng_grnd_pnkt_pos_pos_idx ON arp_npl.nutzungsplanung_ueberlagernd_punkt_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.nutzungsplanung_ueberlagernd_punkt_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX erschlssngsplng_flchnbjekt_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt ( t_basket );
CREATE INDEX erschlssngsplng_flchnbjekt_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt ( t_datasetname );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_erschliessung_flaechenobjekt bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX erschlssngsplhnbjkt_dkment_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ( t_basket );
CREATE INDEX erschlssngsplhnbjkt_dkment_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ( t_datasetname );
CREATE INDEX erschlssngsplhnbjkt_dkment_typ_erschlissng_flchnbjekt_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ( typ_erschliessung_flaechenobjekt );
CREATE INDEX erschlssngsplhnbjkt_dkment_dokument_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ( dokument );
COMMENT ON TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POLYGON,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_erschliessung_flaechenobjekt bigint NOT NULL
)
;
CREATE INDEX erschlssngsplng_flchnbjekt_t_basket_idx1 ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt ( t_basket );
CREATE INDEX erschlssngsplng_flchnbjekt_t_datasetname_idx1 ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt ( t_datasetname );
CREATE INDEX erschlssngsplng_flchnbjekt_geometrie_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt USING GIST ( geometrie );
CREATE INDEX erschlssngsplng_flchnbjekt_typ_erschlissng_flchnbjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt ( typ_erschliessung_flaechenobjekt );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt.bemerkungen IS 'Bemerkung zu den einzelnen Erschliessungsobjekten.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Pos
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,erschliessung_flaechenobjekt bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX erschlssngsplflchnbjkt_pos_t_basket_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ( t_basket );
CREATE INDEX erschlssngsplflchnbjkt_pos_t_datasetname_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ( t_datasetname );
CREATE INDEX erschlssngsplflchnbjkt_pos_erschliessung_flaechnbjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ( erschliessung_flaechenobjekt );
CREATE INDEX erschlssngsplflchnbjkt_pos_pos_idx ON arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX erschlssngsplssng_lnnbjekt_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt ( t_basket );
CREATE INDEX erschlssngsplssng_lnnbjekt_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt ( t_datasetname );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_erschliessung_linienobjekt bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX erschlssngsplnnbjkt_dkment_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ( t_basket );
CREATE INDEX erschlssngsplnnbjkt_dkment_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ( t_datasetname );
CREATE INDEX erschlssngsplnnbjkt_dkment_typ_erschliessung_lnnbjekt_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ( typ_erschliessung_linienobjekt );
CREATE INDEX erschlssngsplnnbjkt_dkment_dokument_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ( dokument );
COMMENT ON TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(LINESTRING,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_erschliessung_linienobjekt bigint NOT NULL
)
;
CREATE INDEX erschlssngsplssng_lnnbjekt_t_basket_idx1 ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt ( t_basket );
CREATE INDEX erschlssngsplssng_lnnbjekt_t_datasetname_idx1 ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt ( t_datasetname );
CREATE INDEX erschlssngsplssng_lnnbjekt_geometrie_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt USING GIST ( geometrie );
CREATE INDEX erschlssngsplssng_lnnbjekt_typ_erschliessung_lnnbjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt ( typ_erschliessung_linienobjekt );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt.bemerkungen IS 'Bemerkung zu den einzelnen Erschliessungsobjekten.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Pos
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,erschliessung_linienobjekt bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX erschlssngsplg_lnnbjkt_pos_t_basket_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ( t_basket );
CREATE INDEX erschlssngsplg_lnnbjkt_pos_t_datasetname_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ( t_datasetname );
CREATE INDEX erschlssngsplg_lnnbjkt_pos_erschliessung_linienobjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ( erschliessung_linienobjekt );
CREATE INDEX erschlssngsplg_lnnbjkt_pos_pos_idx ON arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,typ_kt varchar(255) NOT NULL
  ,code_kommunal varchar(12) NOT NULL
  ,bezeichnung varchar(80) NOT NULL
  ,abkuerzung varchar(12) NULL
  ,verbindlichkeit varchar(255) NOT NULL
  ,bemerkungen varchar(240) NULL
)
;
CREATE INDEX erschlssngsplsng_pnktbjekt_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt ( t_basket );
CREATE INDEX erschlssngsplsng_pnktbjekt_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt ( t_datasetname );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt.code_kommunal IS '4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt.bezeichnung IS 'Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt.abkuerzung IS 'Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt.bemerkungen IS 'Erl�uternder Text zum Typ';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument
CREATE TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,typ_erschliessung_punktobjekt bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX erschlssngsplktbjkt_dkment_t_basket_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ( t_basket );
CREATE INDEX erschlssngsplktbjkt_dkment_t_datasetname_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ( t_datasetname );
CREATE INDEX erschlssngsplktbjkt_dkment_typ_erschliessng_pnktbjekt_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ( typ_erschliessung_punktobjekt );
CREATE INDEX erschlssngsplktbjkt_dkment_dokument_idx ON arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ( dokument );
COMMENT ON TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument IS 'Siehe in der Arbeitshilfe';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,name_nummer varchar(20) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
  ,typ_erschliessung_punktobjekt bigint NOT NULL
)
;
CREATE INDEX erschlssngsplsng_pnktbjekt_t_basket_idx1 ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt ( t_basket );
CREATE INDEX erschlssngsplsng_pnktbjekt_t_datasetname_idx1 ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt ( t_datasetname );
CREATE INDEX erschlssngsplsng_pnktbjekt_geometrie_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt USING GIST ( geometrie );
CREATE INDEX erschlssngsplsng_pnktbjekt_typ_erschliessng_pnktbjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt ( typ_erschliessung_punktobjekt );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt.name_nummer IS 'leer lassen';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt.publiziertab IS 'Datum des Regierungsratsbeschlusses';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt.bemerkungen IS 'Bemerkung zu den einzelnen Erschliessungsobjekten.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt.erfasser IS 'Name der Firma die die Daten erfasst hat.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt.datum IS 'Datum der Erfassung';
-- SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Pos
CREATE TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,erschliessung_punktobjekt bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX erschlssngspl_pnktbjkt_pos_t_basket_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ( t_basket );
CREATE INDEX erschlssngspl_pnktbjkt_pos_t_datasetname_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ( t_datasetname );
CREATE INDEX erschlssngspl_pnktbjkt_pos_erschliessung_punktobjekt_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ( erschliessung_punktobjekt );
CREATE INDEX erschlssngspl_pnktbjkt_pos_pos_idx ON arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand
CREATE TABLE arp_npl.verfahrenstand_vs_perimeter_verfahrensstand (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POLYGON,2056) NOT NULL
  ,planungsart varchar(255) NOT NULL
  ,verfahrensstufe varchar(255) NOT NULL
  ,name_nummer varchar(20) NULL
  ,bemerkungen varchar(240) NULL
  ,erfasser varchar(80) NULL
  ,datum date NOT NULL
)
;
CREATE INDEX verfhrnstnd_v_vrfhrnsstand_t_basket_idx ON arp_npl.verfahrenstand_vs_perimeter_verfahrensstand ( t_basket );
CREATE INDEX verfhrnstnd_v_vrfhrnsstand_t_datasetname_idx ON arp_npl.verfahrenstand_vs_perimeter_verfahrensstand ( t_datasetname );
CREATE INDEX verfhrnstnd_v_vrfhrnsstand_geometrie_idx ON arp_npl.verfahrenstand_vs_perimeter_verfahrensstand USING GIST ( geometrie );
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_verfahrensstand.geometrie IS 'Geltungsbereich f�r die Mutation';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_verfahrensstand.name_nummer IS 'Leer lassen';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_verfahrensstand.bemerkungen IS 'Erl�uternder Text oder Bemerkungen zum Verfahrenstand.';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_verfahrensstand.erfasser IS 'Name des der Firma';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_verfahrensstand.datum IS 'Datum Verfahrensbeginn';
-- SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos
CREATE TABLE arp_npl.verfahrenstand_vs_perimeter_pos (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,vs_perimeter_verfahrensstand bigint NOT NULL
  ,pos geometry(POINT,2056) NOT NULL
  ,ori integer NULL
  ,hali varchar(255) NULL
  ,vali varchar(255) NULL
  ,groesse varchar(255) NOT NULL
)
;
CREATE INDEX verfahrenstnd_vs_prmtr_pos_t_basket_idx ON arp_npl.verfahrenstand_vs_perimeter_pos ( t_basket );
CREATE INDEX verfahrenstnd_vs_prmtr_pos_t_datasetname_idx ON arp_npl.verfahrenstand_vs_perimeter_pos ( t_datasetname );
CREATE INDEX verfahrenstnd_vs_prmtr_pos_vs_perimeter_verfhrnsstand_idx ON arp_npl.verfahrenstand_vs_perimeter_pos ( vs_perimeter_verfahrensstand );
CREATE INDEX verfahrenstnd_vs_prmtr_pos_pos_idx ON arp_npl.verfahrenstand_vs_perimeter_pos USING GIST ( pos );
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_pos.pos IS 'Position f�r die Beschriftung';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_pos.ori IS 'Orientierung der Beschriftung in Gon. 0 gon = Horizontal';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_pos.hali IS 'Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
Textmitte liegt.';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_pos.vali IS 'Das vertikale Alignment legt die Position in Richtung der Texth�he fest.';
COMMENT ON COLUMN arp_npl.verfahrenstand_vs_perimeter_pos.groesse IS 'Gr�sse der Beschriftung';
-- SO_Nutzungsplanung_20171118.TransferMetadaten.Amt
CREATE TABLE arp_npl.transfermetadaten_amt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,aname varchar(80) NOT NULL
  ,amtimweb varchar(1023) NULL
)
;
CREATE INDEX transfermetadaten_amt_t_basket_idx ON arp_npl.transfermetadaten_amt ( t_basket );
CREATE INDEX transfermetadaten_amt_t_datasetname_idx ON arp_npl.transfermetadaten_amt ( t_datasetname );
COMMENT ON COLUMN arp_npl.transfermetadaten_amt.aname IS 'Firmenname des Erfassers';
COMMENT ON COLUMN arp_npl.transfermetadaten_amt.amtimweb IS 'Verweis auf die Webseite';
-- SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand
CREATE TABLE arp_npl.transfermetadaten_datenbestand (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,stand date NOT NULL
  ,lieferdatum date NULL
  ,bemerkungen varchar(240) NULL
  ,amt bigint NOT NULL
)
;
CREATE INDEX transfermetadatn_dtnbstand_t_basket_idx ON arp_npl.transfermetadaten_datenbestand ( t_basket );
CREATE INDEX transfermetadatn_dtnbstand_t_datasetname_idx ON arp_npl.transfermetadaten_datenbestand ( t_datasetname );
CREATE INDEX transfermetadatn_dtnbstand_amt_idx ON arp_npl.transfermetadaten_datenbestand ( amt );
COMMENT ON COLUMN arp_npl.transfermetadaten_datenbestand.stand IS 'Datum des Datenstandes, z.B. Gemeinderatsbeschluss oder bereinigte Daten nach RRB';
COMMENT ON COLUMN arp_npl.transfermetadaten_datenbestand.lieferdatum IS 'Datum der Datenlieferung';
COMMENT ON COLUMN arp_npl.transfermetadaten_datenbestand.bemerkungen IS 'Erl�uternder Text oder Bemerkungen zum Datenbestand.';
CREATE TABLE arp_npl.T_ILI2DB_BASKET (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NULL
  ,topic varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,attachmentKey varchar(200) NOT NULL
  ,domains varchar(1024) NULL
)
;
CREATE INDEX T_ILI2DB_BASKET_dataset_idx ON arp_npl.t_ili2db_basket ( dataset );
CREATE TABLE arp_npl.T_ILI2DB_DATASET (
  T_Id bigint PRIMARY KEY
  ,datasetName varchar(200) NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_IMPORT (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NOT NULL
  ,importDate timestamp NOT NULL
  ,importUser varchar(40) NOT NULL
  ,importFile varchar(200) NULL
)
;
CREATE INDEX T_ILI2DB_IMPORT_dataset_idx ON arp_npl.t_ili2db_import ( dataset );
CREATE TABLE arp_npl.T_ILI2DB_IMPORT_BASKET (
  T_Id bigint PRIMARY KEY
  ,importrun bigint NOT NULL
  ,basket bigint NOT NULL
  ,objectCount integer NULL
)
;
CREATE INDEX T_ILI2DB_IMPORT_BASKET_importrun_idx ON arp_npl.t_ili2db_import_basket ( importrun );
CREATE INDEX T_ILI2DB_IMPORT_BASKET_basket_idx ON arp_npl.t_ili2db_import_basket ( basket );
CREATE TABLE arp_npl.T_ILI2DB_INHERITANCE (
  thisClass varchar(1024) PRIMARY KEY
  ,baseClass varchar(1024) NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_SETTINGS (
  tag varchar(60) PRIMARY KEY
  ,setting varchar(1024) NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_TRAFO (
  iliname varchar(1024) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_MODEL (
  filename varchar(250) NOT NULL
  ,iliversion varchar(3) NOT NULL
  ,modelName text NOT NULL
  ,content text NOT NULL
  ,importDate timestamp NOT NULL
  ,PRIMARY KEY (iliversion,modelName)
)
;
CREATE TABLE arp_npl.verfahrenstand_planungsart (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.verbindlichkeit (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.verfahrenstand_verfahrensstufe (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_punktobjekt (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.halignment (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.rechtsstatus (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.nutzungsplanung_typ_grundnutzung_nutzungsziffer_art (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.schriftgroesse (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.chcantoncode (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.valignment (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_CLASSNAME (
  IliName varchar(1024) PRIMARY KEY
  ,SqlName varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_ATTRNAME (
  IliName varchar(1024) NOT NULL
  ,SqlName varchar(1024) NOT NULL
  ,ColOwner varchar(1024) NOT NULL
  ,Target varchar(1024) NULL
  ,PRIMARY KEY (SqlName,ColOwner)
)
;
CREATE TABLE arp_npl.T_ILI2DB_COLUMN_PROP (
  tablename varchar(255) NOT NULL
  ,subtype varchar(255) NULL
  ,columnname varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_TABLE_PROP (
  tablename varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl.T_ILI2DB_META_ATTRS (
  ilielement varchar(255) NOT NULL
  ,attr_name varchar(1024) NOT NULL
  ,attr_value varchar(1024) NOT NULL
)
;
ALTER TABLE arp_npl.rechtsvorschrften_dokument ADD CONSTRAINT rechtsvorschrften_dokument_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.rechtsvorschrften_dokument ADD CONSTRAINT rechtsvorschrften_dokment_gemeinde_check CHECK( gemeinde BETWEEN 1 AND 9999);
ALTER TABLE arp_npl.rechtsvorschrften_hinweisweiteredokumente ADD CONSTRAINT rechtsvrschrfhnwswtrdkmnte_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.rechtsvorschrften_hinweisweiteredokumente ADD CONSTRAINT rechtsvrschrfhnwswtrdkmnte_ursprung_fkey FOREIGN KEY ( ursprung ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.rechtsvorschrften_hinweisweiteredokumente ADD CONSTRAINT rechtsvrschrfhnwswtrdkmnte_hinweis_fkey FOREIGN KEY ( hinweis ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung ADD CONSTRAINT nutzngsplnng_yp_grndntzung_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung ADD CONSTRAINT nutzngsplnngyp_grndntzung_nutzungsziffer_check CHECK( nutzungsziffer BETWEEN 0.0 AND 9.0);
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung ADD CONSTRAINT nutzngsplnngyp_grndntzung_geschosszahl_check CHECK( geschosszahl BETWEEN 0 AND 50);
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche ADD CONSTRAINT nutzngsplnng_brlgrnd_flche_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie ADD CONSTRAINT nutzngsplnng__brlgrnd_lnie_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt ADD CONSTRAINT nutzngsplnng__brlgrnd_pnkt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung_dokument ADD CONSTRAINT nutzngsplnng_dntzng_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung_dokument ADD CONSTRAINT nutzngsplnng_dntzng_dkment_typ_grundnutzung_fkey FOREIGN KEY ( typ_grundnutzung ) REFERENCES arp_npl.nutzungsplanung_typ_grundnutzung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_grundnutzung_dokument ADD CONSTRAINT nutzngsplnng_dntzng_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ADD CONSTRAINT nutzngsplnng_d_flch_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ADD CONSTRAINT nutzngsplnng_d_flch_dkment_typ_ueberlagernd_flaeche_fkey FOREIGN KEY ( typ_ueberlagernd_flaeche ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument ADD CONSTRAINT nutzngsplnng_d_flch_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ADD CONSTRAINT nutzngsplnng_rnd_ln_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ADD CONSTRAINT nutzngsplnng_rnd_ln_dkment_typ_ueberlagernd_linie_fkey FOREIGN KEY ( typ_ueberlagernd_linie ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_linie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument ADD CONSTRAINT nutzngsplnng_rnd_ln_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ADD CONSTRAINT nutzngsplnng_d_pnkt_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ADD CONSTRAINT nutzngsplnng_d_pnkt_dkment_typ_ueberlagernd_punkt_fkey FOREIGN KEY ( typ_ueberlagernd_punkt ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_punkt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument ADD CONSTRAINT nutzngsplnng_d_pnkt_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_grundnutzung ADD CONSTRAINT nutzungsplanung_grndntzung_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_grundnutzung ADD CONSTRAINT nutzungsplanung_grndntzung_typ_grundnutzung_fkey FOREIGN KEY ( typ_grundnutzung ) REFERENCES arp_npl.nutzungsplanung_typ_grundnutzung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche ADD CONSTRAINT nutzngsplnng_brlgrnd_flche_T_basket_fkey1 FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche ADD CONSTRAINT nutzngsplnng_brlgrnd_flche_typ_ueberlagernd_flaeche_fkey FOREIGN KEY ( typ_ueberlagernd_flaeche ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_linie ADD CONSTRAINT nutzungsplnng_brlgrnd_lnie_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_linie ADD CONSTRAINT nutzungsplnng_brlgrnd_lnie_typ_ueberlagernd_linie_fkey FOREIGN KEY ( typ_ueberlagernd_linie ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_linie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt ADD CONSTRAINT nutzungsplnng_brlgrnd_pnkt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt ADD CONSTRAINT nutzungsplnng_brlgrnd_pnkt_typ_ueberlagernd_punkt_fkey FOREIGN KEY ( typ_ueberlagernd_punkt ) REFERENCES arp_npl.nutzungsplanung_typ_ueberlagernd_punkt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_grundnutzung_pos ADD CONSTRAINT nutzngsplnng_grndntzng_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_grundnutzung_pos ADD CONSTRAINT nutzngsplnng_grndntzng_pos_grundnutzung_fkey FOREIGN KEY ( grundnutzung ) REFERENCES arp_npl.nutzungsplanung_grundnutzung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_grundnutzung_pos ADD CONSTRAINT nutzngsplnnggrndntzng_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ADD CONSTRAINT nutzngsplnng_grnd_flch_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ADD CONSTRAINT nutzngsplnng_grnd_flch_pos_ueberlagernd_flaeche_fkey FOREIGN KEY ( ueberlagernd_flaeche ) REFERENCES arp_npl.nutzungsplanung_ueberlagernd_flaeche DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_flaeche_pos ADD CONSTRAINT nutzngsplnnggrnd_flch_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_linie_pos ADD CONSTRAINT nutzngsplnng_rlgrnd_ln_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_linie_pos ADD CONSTRAINT nutzngsplnng_rlgrnd_ln_pos_ueberlagernd_linie_fkey FOREIGN KEY ( ueberlagernd_linie ) REFERENCES arp_npl.nutzungsplanung_ueberlagernd_linie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_linie_pos ADD CONSTRAINT nutzngsplnngrlgrnd_ln_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ADD CONSTRAINT nutzngsplnng_grnd_pnkt_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ADD CONSTRAINT nutzngsplnng_grnd_pnkt_pos_ueberlagernd_punkt_fkey FOREIGN KEY ( ueberlagernd_punkt ) REFERENCES arp_npl.nutzungsplanung_ueberlagernd_punkt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.nutzungsplanung_ueberlagernd_punkt_pos ADD CONSTRAINT nutzngsplnnggrnd_pnkt_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt ADD CONSTRAINT erschlssngsplng_flchnbjekt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ADD CONSTRAINT erschlssngsplhnbjkt_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ADD CONSTRAINT erschlssngsplhnbjkt_dkment_typ_erschlissng_flchnbjekt_fkey FOREIGN KEY ( typ_erschliessung_flaechenobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument ADD CONSTRAINT erschlssngsplhnbjkt_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt ADD CONSTRAINT erschlssngsplng_flchnbjekt_T_basket_fkey1 FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt ADD CONSTRAINT erschlssngsplng_flchnbjekt_typ_erschlissng_flchnbjekt_fkey FOREIGN KEY ( typ_erschliessung_flaechenobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_flaechenobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ADD CONSTRAINT erschlssngsplflchnbjkt_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ADD CONSTRAINT erschlssngsplflchnbjkt_pos_erschliessung_flaechnbjekt_fkey FOREIGN KEY ( erschliessung_flaechenobjekt ) REFERENCES arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_flaechenobjekt_pos ADD CONSTRAINT erschlssngspflchnbjkt_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt ADD CONSTRAINT erschlssngsplssng_lnnbjekt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ADD CONSTRAINT erschlssngsplnnbjkt_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ADD CONSTRAINT erschlssngsplnnbjkt_dkment_typ_erschliessung_lnnbjekt_fkey FOREIGN KEY ( typ_erschliessung_linienobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument ADD CONSTRAINT erschlssngsplnnbjkt_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt ADD CONSTRAINT erschlssngsplssng_lnnbjekt_T_basket_fkey1 FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt ADD CONSTRAINT erschlssngsplssng_lnnbjekt_typ_erschliessung_lnnbjekt_fkey FOREIGN KEY ( typ_erschliessung_linienobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ADD CONSTRAINT erschlssngsplg_lnnbjkt_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ADD CONSTRAINT erschlssngsplg_lnnbjkt_pos_erschliessung_linienobjekt_fkey FOREIGN KEY ( erschliessung_linienobjekt ) REFERENCES arp_npl.erschlssngsplnung_erschliessung_linienobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_linienobjekt_pos ADD CONSTRAINT erschlssngspg_lnnbjkt_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt ADD CONSTRAINT erschlssngsplsng_pnktbjekt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ADD CONSTRAINT erschlssngsplktbjkt_dkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ADD CONSTRAINT erschlssngsplktbjkt_dkment_typ_erschliessng_pnktbjekt_fkey FOREIGN KEY ( typ_erschliessung_punktobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument ADD CONSTRAINT erschlssngsplktbjkt_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl.rechtsvorschrften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt ADD CONSTRAINT erschlssngsplsng_pnktbjekt_T_basket_fkey1 FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt ADD CONSTRAINT erschlssngsplsng_pnktbjekt_typ_erschliessng_pnktbjekt_fkey FOREIGN KEY ( typ_erschliessung_punktobjekt ) REFERENCES arp_npl.erschlssngsplnung_typ_erschliessung_punktobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ADD CONSTRAINT erschlssngspl_pnktbjkt_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ADD CONSTRAINT erschlssngspl_pnktbjkt_pos_erschliessung_punktobjekt_fkey FOREIGN KEY ( erschliessung_punktobjekt ) REFERENCES arp_npl.erschlssngsplnung_erschliessung_punktobjekt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.erschlssngsplnung_erschliessung_punktobjekt_pos ADD CONSTRAINT erschlssngsp_pnktbjkt_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.verfahrenstand_vs_perimeter_verfahrensstand ADD CONSTRAINT verfhrnstnd_v_vrfhrnsstand_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.verfahrenstand_vs_perimeter_pos ADD CONSTRAINT verfahrenstnd_vs_prmtr_pos_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.verfahrenstand_vs_perimeter_pos ADD CONSTRAINT verfahrenstnd_vs_prmtr_pos_vs_perimeter_verfhrnsstand_fkey FOREIGN KEY ( vs_perimeter_verfahrensstand ) REFERENCES arp_npl.verfahrenstand_vs_perimeter_verfahrensstand DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.verfahrenstand_vs_perimeter_pos ADD CONSTRAINT verfahrnstnd_vs_prmtr_pos_ori_check CHECK( ori BETWEEN 0 AND 399);
ALTER TABLE arp_npl.transfermetadaten_amt ADD CONSTRAINT transfermetadaten_amt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.transfermetadaten_datenbestand ADD CONSTRAINT transfermetadatn_dtnbstand_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.transfermetadaten_datenbestand ADD CONSTRAINT transfermetadatn_dtnbstand_amt_fkey FOREIGN KEY ( amt ) REFERENCES arp_npl.transfermetadaten_amt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.T_ILI2DB_BASKET ADD CONSTRAINT T_ILI2DB_BASKET_dataset_fkey FOREIGN KEY ( dataset ) REFERENCES arp_npl.T_ILI2DB_DATASET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_DATASET_datasetName_key ON arp_npl.T_ILI2DB_DATASET (datasetName)
;
ALTER TABLE arp_npl.T_ILI2DB_IMPORT_BASKET ADD CONSTRAINT T_ILI2DB_IMPORT_BASKET_importrun_fkey FOREIGN KEY ( importrun ) REFERENCES arp_npl.T_ILI2DB_IMPORT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl.T_ILI2DB_IMPORT_BASKET ADD CONSTRAINT T_ILI2DB_IMPORT_BASKET_basket_fkey FOREIGN KEY ( basket ) REFERENCES arp_npl.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_MODEL_iliversion_modelName_key ON arp_npl.T_ILI2DB_MODEL (iliversion,modelName)
;
CREATE UNIQUE INDEX T_ILI2DB_ATTRNAME_SqlName_ColOwner_key ON arp_npl.T_ILI2DB_ATTRNAME (SqlName,ColOwner)
;
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument','nutzungsplanung_typ_ueberlagernd_linie_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Pos','nutzungsplanung_ueberlagernd_linie_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument','erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('INTERLIS.VALIGNMENT','valignment');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Pos','erschlssngsplnung_erschliessung_punktobjekt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Flaeche','erschlssngsplnung_typ_erschliessung_flaechenobjekt_flaeche');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos_Verfahrensstand','verfahrenstand_vs_perimeter_pos_verfahrensstand');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Punkt_Pos','erschlssngsplnung_erschliessung_punktobjekt_punkt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt','nutzungsplanung_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Amt','transfermetadaten_amt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.Planungsart','verfahrenstand_planungsart');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument','nutzungsplanung_typ_grundnutzung_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Grundnutzung','nutzungsplanung_typ_grundnutzung_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.EP_Typ_Kanton_Erschliessung_Flaechenobjekt','erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie','nutzungsplanung_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche','nutzungsplanung_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt','erschlssngsplnung_typ_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Flaeche','nutzungsplanung_typ_ueberlagernd_flaeche_flaeche');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Pos','erschlssngsplnung_erschliessung_linienobjekt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Pos','nutzungsplanung_ueberlagernd_punkt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verbindlichkeit','verbindlichkeit');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Punkt','erschlssngsplnung_typ_erschliessung_punktobjekt_punkt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.NP_Typ_Kanton_Grundnutzung','nutzungsplanung_np_typ_kanton_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt','erschlssngsplnung_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Linie_Pos','erschlssngsplnung_erschliessung_linienobjekt_linie_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Flaeche_Pos','erschlssngsplnung_erschliessung_flaechenobjekt_flaeche_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt','erschlssngsplnung_typ_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt','erschlssngsplnung_typ_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Punkt','nutzungsplanung_typ_ueberlagernd_punkt_punkt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche','nutzungsplanung_typ_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Pos','nutzungsplanung_ueberlagernd_flaeche_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.EP_Typ_Kanton_Erschliessung_Punktobjekt','erschlssngsplnung_ep_typ_kanton_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Nutzungsziffer_Art','nutzungsplanung_typ_grundnutzung_nutzungsziffer_art');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung','nutzungsplanung_typ_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos','verfahrenstand_vs_perimeter_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('INTERLIS.HALIGNMENT','halignment');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos','nutzungsplanung_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Linie','erschlssngsplnung_typ_erschliessung_linienobjekt_linie');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand','transfermetadaten_datenbestand');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Flaeche_Pos','nutzungsplanung_ueberlagernd_flaeche_flaeche_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Linie_Pos','nutzungsplanung_ueberlagernd_linie_linie_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt','erschlssngsplnung_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt','nutzungsplanung_typ_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument','nutzungsplanung_typ_ueberlagernd_punkt_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Punkt_Pos','nutzungsplanung_ueberlagernd_punkt_punkt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.EP_Typ_Kanton_Erschliessung_Linienobjekt','erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie','nutzungsplanung_typ_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Schriftgroesse','schriftgroesse');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand','verfahrenstand_vs_perimeter_verfahrensstand');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung','nutzungsplanung_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.NP_Typ_Kanton_Ueberlagernd_Punkt','nutzungsplanung_np_typ_kanton_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Pos','nutzungsplanung_grundnutzung_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument','erschlssngsplnung_typ_erschliessung_linienobjekt_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.NP_Typ_Kanton_Ueberlagernd_Flaeche','nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente','rechtsvorschrften_hinweisweiteredokumente');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument','erschlssngsplnung_typ_erschliessung_punktobjekt_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Linie','nutzungsplanung_typ_ueberlagernd_linie_linie');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.Verfahrensstufe','verfahrenstand_verfahrensstufe');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument','nutzungsplanung_typ_ueberlagernd_flaeche_dokument');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ','nutzungsplanung_typ');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.NP_Typ_Kanton_Ueberlagernd_Linie','nutzungsplanung_np_typ_kanton_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Rechtsstatus','rechtsstatus');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt','erschlssngsplnung_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('CHAdminCodes_V1.CHCantonCode','chcantoncode');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Pos','erschlssngsplnung_erschliessung_flaechenobjekt_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Grundnutzung_Pos','nutzungsplanung_grundnutzung_grundnutzung_pos');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.zustStelle_Daten','transfermetadaten_zuststelle_daten');
INSERT INTO arp_npl.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Flaeche_Pos.Ueberlagernd_Flaeche','ueberlagernd_flaeche','nutzungsplanung_ueberlagernd_flaeche_pos','nutzungsplanung_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','nutzungsplanung_ueberlagernd_flaeche_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche.Code_kommunal','code_kommunal','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Amt.Name','aname','transfermetadaten_amt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Nutzungsziffer_Art','nutzungsziffer_art','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Datum','datum','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Typ_Kt','typ_kt','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','nutzungsplanung_ueberlagernd_punkt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Linie_Pos.Erschliessung_Linienobjekt','erschliessung_linienobjekt','erschlssngsplnung_erschliessung_linienobjekt_pos','erschlssngsplnung_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument.Typ_Erschliessung_Punktobjekt','typ_erschliessung_punktobjekt','erschlssngsplnung_typ_erschliessung_punktobjekt_dokument','erschlssngsplnung_typ_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Bemerkungen','bemerkungen','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument.Dokument','dokument','erschlssngsplnung_typ_erschliessung_linienobjekt_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument.Dokument','dokument','nutzungsplanung_typ_ueberlagernd_flaeche_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.zustStelle_Daten.Amt','amt','transfermetadaten_datenbestand','transfermetadaten_amt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Punkt.Typ_Ueberlagernd_Punkt','typ_ueberlagernd_punkt','nutzungsplanung_ueberlagernd_punkt','nutzungsplanung_typ_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Bemerkungen','bemerkungen','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Erfasser','erfasser','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','nutzungsplanung_grundnutzung_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','erschlssngsplnung_erschliessung_punktobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Datum','datum','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument.Typ_Ueberlagernd_Flaeche','typ_ueberlagernd_flaeche','nutzungsplanung_typ_ueberlagernd_flaeche_dokument','nutzungsplanung_typ_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Rechtsstatus','rechtsstatus','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Linie.Typ_Erschliessung_Linienobjekt','typ_erschliessung_linienobjekt','erschlssngsplnung_erschliessung_linienobjekt','erschlssngsplnung_typ_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Datum','datum','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Datum','datum','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Abkuerzung','abkuerzung','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','erschlssngsplnung_erschliessung_linienobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','erschlssngsplnung_erschliessung_punktobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche.Typ_Kt','typ_kt','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Geometrie','geometrie','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt.Code_kommunal','code_kommunal','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Name_Nummer','name_nummer','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Name_Nummer','name_nummer','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt.Code_kommunal','code_kommunal','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Bemerkungen','bemerkungen','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Erfasser','erfasser','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Rechtsvorschrift','rechtsvorschrift','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','nutzungsplanung_grundnutzung_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.DokumentID','dokumentid','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Titel','titel','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Planungsart','planungsart','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.publiziertAb','publiziertab','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.publiziertAb','publiziertab','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','nutzungsplanung_ueberlagernd_flaeche_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.publiziertAb','publiziertab','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','nutzungsplanung_ueberlagernd_flaeche_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Geometrie','geometrie','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','nutzungsplanung_ueberlagernd_flaeche_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Grundnutzung_Pos.Grundnutzung','grundnutzung','nutzungsplanung_grundnutzung_pos','nutzungsplanung_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos_Verfahrensstand.VS_Perimeter_Verfahrensstand','vs_perimeter_verfahrensstand','verfahrenstand_vs_perimeter_pos','verfahrenstand_vs_perimeter_verfahrensstand');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand.Bemerkungen','bemerkungen','transfermetadaten_datenbestand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Rechtsstatus','rechtsstatus','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Linie.Typ_Ueberlagernd_Linie','typ_ueberlagernd_linie','nutzungsplanung_ueberlagernd_linie','nutzungsplanung_typ_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Name_Nummer','name_nummer','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand.Lieferdatum','lieferdatum','transfermetadaten_datenbestand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument.Dokument','dokument','nutzungsplanung_typ_grundnutzung_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','nutzungsplanung_ueberlagernd_flaeche_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Punkt_Pos.Ueberlagernd_Punkt','ueberlagernd_punkt','nutzungsplanung_ueberlagernd_punkt_pos','nutzungsplanung_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Datum','datum','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Code_kommunal','code_kommunal','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Rechtsstatus','rechtsstatus','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Rechtsstatus','rechtsstatus','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente.Ursprung','ursprung','rechtsvorschrften_hinweisweiteredokumente','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument.Dokument','dokument','erschlssngsplnung_typ_erschliessung_punktobjekt_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt.Code_kommunal','code_kommunal','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Name_Nummer','name_nummer','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Punkt.Typ_Erschliessung_Punktobjekt','typ_erschliessung_punktobjekt','erschlssngsplnung_erschliessung_punktobjekt','erschlssngsplnung_typ_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.publiziertAb','publiziertab','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Name_Nummer','name_nummer','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Flaeche_Pos.Erschliessung_Flaechenobjekt','erschliessung_flaechenobjekt','erschlssngsplnung_erschliessung_flaechenobjekt_pos','erschlssngsplnung_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument.Dokument','dokument','nutzungsplanung_typ_ueberlagernd_linie_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Datum','datum','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Bemerkungen','bemerkungen','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','verfahrenstand_vs_perimeter_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Rechtsstatus','rechtsstatus','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente.Hinweis','hinweis','rechtsvorschrften_hinweisweiteredokumente','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Gemeinde','gemeinde','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie.Typ_Kt','typ_kt','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche.Erfasser','erfasser','nutzungsplanung_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Flaeche.Typ_Ueberlagernd_Flaeche','typ_ueberlagernd_flaeche','nutzungsplanung_ueberlagernd_flaeche','nutzungsplanung_typ_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.publiziertAb','publiziertab','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.publiziertAb','publiziertab','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Datum','datum','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Bemerkungen','bemerkungen','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt.Typ_Kt','typ_kt','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Erfasser','erfasser','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument.Typ_Erschliessung_Flaechenobjekt','typ_erschliessung_flaechenobjekt','erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument','erschlssngsplnung_typ_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie.Code_kommunal','code_kommunal','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument.Typ_Erschliessung_Linienobjekt','typ_erschliessung_linienobjekt','erschlssngsplnung_typ_erschliessung_linienobjekt_dokument','erschlssngsplnung_typ_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Name_Nummer','name_nummer','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Erfasser','erfasser','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','nutzungsplanung_ueberlagernd_punkt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Kanton','kanton','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','nutzungsplanung_typ_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Erfasser','erfasser','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument.Typ_Grundnutzung','typ_grundnutzung','nutzungsplanung_typ_grundnutzung_dokument','nutzungsplanung_typ_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.OffizielleNr','offiziellenr','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Bemerkungen','bemerkungen','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt.Typ_Kt','typ_kt','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Bemerkungen','bemerkungen','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.HAli','hali','nutzungsplanung_ueberlagernd_linie_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','verfahrenstand_vs_perimeter_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt.Geometrie','geometrie','erschlssngsplnung_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Rechtsstatus','rechtsstatus','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Geschosszahl','geschosszahl','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument.Dokument','dokument','nutzungsplanung_typ_ueberlagernd_punkt_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','erschlssngsplnung_erschliessung_punktobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','erschlssngsplnung_erschliessung_punktobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Verfahrensstufe','verfahrensstufe','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument.Typ_Ueberlagernd_Punkt','typ_ueberlagernd_punkt','nutzungsplanung_typ_ueberlagernd_punkt_dokument','nutzungsplanung_typ_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Bemerkungen','bemerkungen','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.publiziertAb','publiziertab','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Geometrie','geometrie','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt.Code_kommunal','code_kommunal','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument.Typ_Ueberlagernd_Linie','typ_ueberlagernd_linie','nutzungsplanung_typ_ueberlagernd_linie_dokument','nutzungsplanung_typ_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','nutzungsplanung_grundnutzung_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','nutzungsplanung_grundnutzung_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand.Stand','stand','transfermetadaten_datenbestand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.OffiziellerTitel','offiziellertitel','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Amt.AmtImWeb','amtimweb','transfermetadaten_amt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Grundnutzung.Typ_Grundnutzung','typ_grundnutzung','nutzungsplanung_grundnutzung','nutzungsplanung_typ_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Name_Nummer','name_nummer','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','erschlssngsplnung_erschliessung_punktobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.Rechtsstatus','rechtsstatus','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','nutzungsplanung_ueberlagernd_linie_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt.Typ_Kt','typ_kt','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Punkt_Pos.Erschliessung_Punktobjekt','erschliessung_punktobjekt','erschlssngsplnung_erschliessung_punktobjekt_pos','erschlssngsplnung_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','verfahrenstand_vs_perimeter_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','nutzungsplanung_ueberlagernd_linie_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung.Nutzungsziffer','nutzungsziffer','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','nutzungsplanung_grundnutzung_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','erschlssngsplnung_erschliessung_linienobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','erschlssngsplnung_typ_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','erschlssngsplnung_erschliessung_linienobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Geometrie','geometrie','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','erschlssngsplnung_erschliessung_linienobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument.TextImWeb','textimweb','rechtsvorschrften_dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt.Geometrie','geometrie','erschlssngsplnung_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','nutzungsplanung_ueberlagernd_linie_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Name_Nummer','name_nummer','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','nutzungsplanung_ueberlagernd_punkt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument.Dokument','dokument','erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Linie_Pos.Ueberlagernd_Linie','ueberlagernd_linie','nutzungsplanung_ueberlagernd_linie_pos','nutzungsplanung_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','nutzungsplanung_ueberlagernd_punkt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Flaeche.Typ_Erschliessung_Flaechenobjekt','typ_erschliessung_flaechenobjekt','erschlssngsplnung_erschliessung_flaechenobjekt','erschlssngsplnung_typ_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Datum','datum','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand.Geometrie','geometrie','verfahrenstand_vs_perimeter_verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','nutzungsplanung_ueberlagernd_linie_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bemerkungen','bemerkungen','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.Bemerkungen','bemerkungen','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Groesse','groesse','verfahrenstand_vs_perimeter_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.VAli','vali','erschlssngsplnung_erschliessung_linienobjekt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','nutzungsplanung_typ_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Ori','ori','verfahrenstand_vs_perimeter_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie.Rechtsstatus','rechtsstatus','nutzungsplanung_ueberlagernd_linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Abkuerzung','abkuerzung','nutzungsplanung_typ_ueberlagernd_flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt.Typ_Kt','typ_kt','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','erschlssngsplnung_typ_erschliessung_linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Erfasser','erfasser','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt.Erfasser','erfasser','nutzungsplanung_ueberlagernd_punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Verbindlichkeit','verbindlichkeit','erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung.Geometrie','geometrie','nutzungsplanung_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt.publiziertAb','publiziertab','erschlssngsplnung_erschliessung_punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ.Bezeichnung','bezeichnung','nutzungsplanung_typ_grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos.Pos','pos','nutzungsplanung_ueberlagernd_punkt_pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Flaeche','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos_Verfahrensstand','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Punkt_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Amt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Grundnutzung','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Flaeche','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Punkt','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Linie_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Flaeche_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Punkt','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos','ch.ehi.ili2db.inheritance','subClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Linie','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Flaeche_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Linie_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Punkt_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Linie','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ','ch.ehi.ili2db.inheritance','subClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Pos','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Grundnutzung_Pos','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.zustStelle_Daten','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt_Punkt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Flaeche','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.zustStelle_Daten',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Rechtsvorschriften.HinweisWeitereDokumente',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos_Verfahrensstand',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Punktobjekt_Punkt_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt_Linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Amt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Linie_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Verfahrenstand.VS_Perimeter_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Flaeche_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Linienobjekt','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Linie_Linie_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Punkt','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Punkt_Punkt_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Flaeche_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Ueberlagernd_Linie_Linie',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Punktobjekt_Dokument',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Grundnutzung_Grundnutzung_Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Ueberlagernd_Flaeche',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Grundnutzung',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Typ_Erschliessung_Flaechenobjekt','SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Linienobjekt',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Erschliessungsplanung.Erschliessung_Flaechenobjekt_Pos','SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos');
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.TransferMetadaten.Datenbestand',NULL);
INSERT INTO arp_npl.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ_Grundnutzung_Dokument',NULL);
INSERT INTO arp_npl.verfahrenstand_planungsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Nutzungsplanung',0,'Nutzungsplanung',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_planungsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Erschliessungsplanung',1,'Erschliessungsplanung',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_planungsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Waldfeststellung',2,'Waldfeststellung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N110_Wohnzone_1_G',0,'N110 Wohnzone 1 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N111_Wohnzone_2_G',1,'N111 Wohnzone 2 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N112_Wohnzone_3_G',2,'N112 Wohnzone 3 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N113_Wohnzone_4_G',3,'N113 Wohnzone 4 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N114_Wohnzone_5_G',4,'N114 Wohnzone 5 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N115_Wohnzone_6_G',5,'N115 Wohnzone 6 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N116_Wohnzone_7_G_und_groesser',6,'N116 Wohnzone 7 G und groesser',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N117_Zone_fuer_Terrassenhaeuser_Terrassensiedlung',7,'N117 Zone fuer Terrassenhaeuser Terrassensiedlung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N120_Gewerbezone_ohne_Wohnen',8,'N120 Gewerbezone ohne Wohnen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N121_Industriezone',9,'N121 Industriezone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N122_Arbeitszone',10,'N122 Arbeitszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N130_Gewerbezone_mit_Wohnen_Mischzone',11,'N130 Gewerbezone mit Wohnen Mischzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N131_Gewerbezone_mit_Wohnen_Mischzone_2_G',12,'N131 Gewerbezone mit Wohnen Mischzone 2 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N132_Gewerbezone_mit_Wohnen_Mischzone_3_G',13,'N132 Gewerbezone mit Wohnen Mischzone 3 G',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N133_Gewerbezone_mit_Wohnen_Mischzone_4_G_und_groesser',14,'N133 Gewerbezone mit Wohnen Mischzone 4 G und groesser',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N134_Zone_fuer_publikumsintensive_Anlagen',15,'N134 Zone fuer publikumsintensive Anlagen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N140_Kernzone',16,'N140 Kernzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N141_Zentrumszone',17,'N141 Zentrumszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N142_Erhaltungszone',18,'N142 Erhaltungszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N150_Zone_fuer_oeffentliche_Bauten',19,'N150 Zone fuer oeffentliche Bauten',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N151_Zone_fuer_oeffentliche_Anlagen',20,'N151 Zone fuer oeffentliche Anlagen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N160_Gruen_und_Freihaltezone_innerhalb_Bauzone',21,'N160 Gruen und Freihaltezone innerhalb Bauzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N161_kommunale_Uferschutzzone_innerhalb_Bauzone',22,'N161 kommunale Uferschutzzone innerhalb Bauzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N162_Landwirtschaftliche_Kernzone',23,'N162 Landwirtschaftliche Kernzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N163_Weilerzone',24,'N163 Weilerzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N169_weitere_eingeschraenkte_Bauzonen',25,'N169 weitere eingeschraenkte Bauzonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N170_Zone_fuer_Freizeit_und_Erholung',26,'N170 Zone fuer Freizeit und Erholung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N180_Verkehrszone_Strasse',27,'N180 Verkehrszone Strasse',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N181_Verkehrszone_Bahnareal',28,'N181 Verkehrszone Bahnareal',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N182_Verkehrszone_Flugplatzareal',29,'N182 Verkehrszone Flugplatzareal',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N189_weitere_Verkehrszonen',30,'N189 weitere Verkehrszonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N190_Spezialzone',31,'N190 Spezialzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N210_Landwirtschaftszone',32,'N210 Landwirtschaftszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N220_Spezielle_Landwirtschaftszone',33,'N220 Spezielle Landwirtschaftszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N230_Rebbauzone',34,'N230 Rebbauzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N290_weitere_Landwirtschaftszonen',35,'N290 weitere Landwirtschaftszonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N310_kommunale_Naturschutzzone',36,'N310 kommunale Naturschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N311_Waldrandschutzzone',37,'N311 Waldrandschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N319_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften',38,'N319 weitere Schutzzonen fuer Lebensraeume und Landschaften',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N320_Gewaesser',39,'N320 Gewaesser',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer',40,'N329 weitere Zonen fuer Gewaesser und ihre Ufer',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N390_weitere_Schutzzonen_ausserhalb_Bauzonen',41,'N390 weitere Schutzzonen ausserhalb Bauzonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N420_Verkehrsflaeche_Strasse',42,'N420 Verkehrsflaeche Strasse',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N421_Verkehrsflaeche_Bahnareal',43,'N421 Verkehrsflaeche Bahnareal',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N422_Verkehrsflaeche_Flugplatzareal',44,'N422 Verkehrsflaeche Flugplatzareal',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N429_weitere_Verkehrsflaechen',45,'N429 weitere Verkehrsflaechen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N430_Reservezone_Wohnzone_Mischzone_Kernzone_Zentrumszone',46,'N430 Reservezone Wohnzone Mischzone Kernzone Zentrumszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N431_Reservezone_Arbeiten',47,'N431 Reservezone Arbeiten',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N432_Reservezone_OeBA',48,'N432 Reservezone OeBA',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N439_Reservezone',49,'N439 Reservezone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N440_Wald',50,'N440 Wald',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N490_Golfzone',51,'N490 Golfzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N491_Abbauzone',52,'N491 Abbauzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N492_Deponiezone',53,'N492 Deponiezone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_grundnutzung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N499_weitere_Bauzonen_nach_Art18_RPG_ausserhalb_Bauzonen',54,'N499 weitere Bauzonen nach Art18 RPG ausserhalb Bauzonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N790_Wanderweg',0,'N790 Wanderweg',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N791_historischer_Verkehrsweg',1,'N791 historischer Verkehrsweg',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N792_Waldgrenze',2,'N792 Waldgrenze',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N793_negative_Waldfeststellung',3,'N793 negative Waldfeststellung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_linie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N799_weitere_linienbezogene_Festlegungen_NP',4,'N799 weitere linienbezogene Festlegungen NP',FALSE,NULL);
INSERT INTO arp_npl.verbindlichkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Nutzungsplanfestlegung',0,'Nutzungsplanfestlegung',FALSE,'Eigent�merverbindlich, im Verfahren der Nutzungsplanung festgelegt.');
INSERT INTO arp_npl.verbindlichkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'orientierend',1,'orientierend',FALSE,'Eigent�merverbindlich, in einem anderen Verfahren festgelegt.');
INSERT INTO arp_npl.verbindlichkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'hinweisend',2,'hinweisend',FALSE,'Nicht eigent�merverbindlich, Informationsinhalte.');
INSERT INTO arp_npl.verbindlichkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'wegleitend',3,'wegleitend',FALSE,'Nicht eigent�merverbindlich, sie umfassen Qualit�ten, Standards und dergleichen, die zu ber�cksichtigen sind.');
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N510_ueberlagernde_Ortsbildschutzzone',0,'N510 ueberlagernde Ortsbildschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N520_BLN_Gebiet',1,'N520 BLN Gebiet',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N521_Juraschutzzone',2,'N521 Juraschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N522_Naturreservat_inkl_Geotope',3,'N522 Naturreservat inkl Geotope',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N523_Landschaftsschutzzone',4,'N523 Landschaftsschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N524_Siedlungstrennguertel_von_kommunaler_Bedeutung',5,'N524 Siedlungstrennguertel von kommunaler Bedeutung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N525_Siedlungstrennguertel_von_kantonaler_Bedeutung',6,'N525 Siedlungstrennguertel von kantonaler Bedeutung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N526_kantonale_Landwirtschafts_und_Schutzzone_Witi',7,'N526 kantonale Landwirtschafts und Schutzzone Witi',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N527_kantonale_Uferschutzzone',8,'N527 kantonale Uferschutzzone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen',9,'N528 kommunale Uferschutzzone ausserhalb Bauzonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N529_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften',10,'N529 weitere Schutzzonen fuer Lebensraeume und Landschaften',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N530_Naturgefahren_erhebliche_Gefaehrdung',11,'N530 Naturgefahren erhebliche Gefaehrdung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N531_Naturgefahren_mittlere_Gefaehrdung',12,'N531 Naturgefahren mittlere Gefaehrdung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N532_Naturgefahren_geringe_Gefaehrdung',13,'N532 Naturgefahren geringe Gefaehrdung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N533_Naturgefahren_Restgefaehrdung',14,'N533 Naturgefahren Restgefaehrdung',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N590_Hofstattzone_Freihaltezone',15,'N590 Hofstattzone Freihaltezone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N591_Bauliche_Einschraenkungen',16,'N591 Bauliche Einschraenkungen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N592_Hecken_Feldgehoelz_Ufergehoelz',17,'N592 Hecken Feldgehoelz Ufergehoelz',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N593_Grundwasserschutzzone_S1',18,'N593 Grundwasserschutzzone S1',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N594_Grundwasserschutzzone_S2',19,'N594 Grundwasserschutzzone S2',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N595_Grundwasserschutzzone_S3',20,'N595 Grundwasserschutzzone S3',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N596_Grundwasserschutzareal',21,'N596 Grundwasserschutzareal',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N599_weitere_ueberlagernde_Nutzungszonen',22,'N599 weitere ueberlagernde Nutzungszonen',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N610_Perimeter_kantonaler_Nutzungsplan',23,'N610 Perimeter kantonaler Nutzungsplan',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N611_Perimeter_kommunaler_Gestaltungsplan',24,'N611 Perimeter kommunaler Gestaltungsplan',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N620_Perimeter_Gestaltungsplanpflicht',25,'N620 Perimeter Gestaltungsplanpflicht',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N680_Empfindlichkeitsstufe_I',26,'N680 Empfindlichkeitsstufe I',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N681_Empfindlichkeitsstufe_II',27,'N681 Empfindlichkeitsstufe II',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N682_Empfindlichkeitsstufe_II_aufgestuft',28,'N682 Empfindlichkeitsstufe II aufgestuft',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N683_Empfindlichkeitsstufe_III',29,'N683 Empfindlichkeitsstufe III',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N684_Empfindlichkeitsstufe_III_aufgestuft',30,'N684 Empfindlichkeitsstufe III aufgestuft',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N685_Empfindlichkeitsstufe_IV',31,'N685 Empfindlichkeitsstufe IV',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N686_keine_Empfindlichkeitsstufe',32,'N686 keine Empfindlichkeitsstufe',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N690_kantonales_Vorranggebiet_Natur_und_Landschaft',33,'N690 kantonales Vorranggebiet Natur und Landschaft',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N691_kommunales_Vorranggebiet_Natur_und_Landschaft',34,'N691 kommunales Vorranggebiet Natur und Landschaft',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N692_Planungszone',35,'N692 Planungszone',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N699_weitere_flaechenbezogene_Festlegungen_NP',36,'N699 weitere flaechenbezogene Festlegungen NP',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N812_geologisches_Objekt',37,'N812 geologisches Objekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N813_Naturobjekt',38,'N813 Naturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N820_kantonal_geschuetztes_Kulturobjekt',39,'N820 kantonal geschuetztes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N821_kommunal_geschuetztes_Kulturobjekt',40,'N821 kommunal geschuetztes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N822_schuetzenswertes_Kulturobjekt',41,'N822 schuetzenswertes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N823_erhaltenswertes_Kulturobjekt',42,'N823 erhaltenswertes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E560_Nationalstrasse',0,'E560 Nationalstrasse',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E561_Kantonsstrasse',1,'E561 Kantonsstrasse',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E562_Sammelstrasse_kommunal',2,'E562 Sammelstrasse kommunal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E563_Erschliessungsstrasse_kommunal',3,'E563 Erschliessungsstrasse kommunal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E564_Flurweg_mit_Erschliessungsfunktion',4,'E564 Flurweg mit Erschliessungsfunktion',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E565_Flurweg_ohne_Erschliessungsfunktion',5,'E565 Flurweg ohne Erschliessungsfunktion',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E566_private_Erschliessungsstrasse',6,'E566 private Erschliessungsstrasse',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E567_unklassierte_Strasse',7,'E567 unklassierte Strasse',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E568_Strassenbankett_Verkehrsinsel',8,'E568 Strassenbankett Verkehrsinsel',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E569_uebrige_Verkehrsflaechen',9,'E569 uebrige Verkehrsflaechen',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E570_Gehweg_Trottoir',10,'E570 Gehweg Trottoir',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E571_Fussweg',11,'E571 Fussweg',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E572_Radweg',12,'E572 Radweg',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E573_Fuss_und_Radweg',13,'E573 Fuss und Radweg',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E574_Gruenstreifen_Rabatte',14,'E574 Gruenstreifen Rabatte',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E579_uebrige_Flaechen_Langsamverkehr',15,'E579 uebrige Flaechen Langsamverkehr',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Vorpruefung',0,'Vorpruefung',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Planauflage',1,'Planauflage',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'zur_Genehmigung_beantragt',2,'zur Genehmigung beantragt',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'genehmigt_Beschwerde_haengig',3,'genehmigt Beschwerde haengig',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'rechtskraeftig',4,'rechtskraeftig',FALSE,NULL);
INSERT INTO arp_npl.verfahrenstand_verfahrensstufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'von_Genehmigung_ausgenommen',5,'von Genehmigung ausgenommen',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_punktobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E889_weitere_punktbezogene_Objekte_EP',0,'E889 weitere punktbezogene Objekte EP',FALSE,NULL);
INSERT INTO arp_npl.halignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (0,'Left',0,'Left',FALSE,NULL);
INSERT INTO arp_npl.halignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (1,'Center',1,'Center',FALSE,NULL);
INSERT INTO arp_npl.halignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (2,'Right',2,'Right',FALSE,NULL);
INSERT INTO arp_npl.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'inKraft',0,'inKraft',FALSE,'Ist in Kraft');
INSERT INTO arp_npl.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'laufendeAenderung',1,'laufendeAenderung',FALSE,'Noch nicht in Kraft, eine �nderung ist in Vorbereitung.');
INSERT INTO arp_npl.nutzungsplanung_typ_grundnutzung_nutzungsziffer_art (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Baumassenziffer',0,'Baumassenziffer',FALSE,'Bauvolumen �ber massgebendem Terrain / anrechenbare Grundst�cksfl�che (�37ter PBG)');
INSERT INTO arp_npl.nutzungsplanung_typ_grundnutzung_nutzungsziffer_art (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Geschossflaechen',1,'Geschossflaechen',FALSE,'Summe aller Geschossfl�chen / anrechenbare Grundst�cksfl�che (�37bis PBG)');
INSERT INTO arp_npl.nutzungsplanung_typ_grundnutzung_nutzungsziffer_art (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Ueberbauungsziffer',2,'Ueberbauungsziffer',FALSE,'Anrechenbare Geb�udefl�che / anrechenbare Grundst�cksfl�che (�35 PBG)');
INSERT INTO arp_npl.nutzungsplanung_typ_grundnutzung_nutzungsziffer_art (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Ausnuetzungsziffer',3,'Ausnuetzungsziffer',FALSE,'Anrechenbare Bruttogeschossfl�che / anrechenbare Grundst�cksfl�che ((�37 PBG, wurde gestrichen)');
INSERT INTO arp_npl.schriftgroesse (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'klein',0,'klein',FALSE,NULL);
INSERT INTO arp_npl.schriftgroesse (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mittel',1,'mittel',FALSE,NULL);
INSERT INTO arp_npl.schriftgroesse (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gross',2,'gross',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E710_nationale_Baulinie',0,'E710 nationale Baulinie',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E711_Baulinie_Strasse_kantonal',1,'E711 Baulinie Strasse kantonal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E712_Vorbaulinie_kantonal',2,'E712 Vorbaulinie kantonal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E713_Gestaltungsbaulinie_kantonal',3,'E713 Gestaltungsbaulinie kantonal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E714_Rueckwaertige_Baulinie_kantonal',4,'E714 Rueckwaertige Baulinie kantonal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E715_Baulinie_Infrastruktur_kantonal',5,'E715 Baulinie Infrastruktur kantonal',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E719_weitere_nationale_und_kantonale_Baulinien',6,'E719 weitere nationale und kantonale Baulinien',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E720_Baulinie_Strasse',7,'E720 Baulinie Strasse',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E721_Vorbaulinie',8,'E721 Vorbaulinie',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E722_Gestaltungsbaulinie',9,'E722 Gestaltungsbaulinie',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E723_Rueckwaertige_Baulinie',10,'E723 Rueckwaertige Baulinie',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E724_Baulinie_Infrastruktur',11,'E724 Baulinie Infrastruktur',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E725_Waldabstandslinie',12,'E725 Waldabstandslinie',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E726_Baulinie_Hecke',13,'E726 Baulinie Hecke',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E727_Baulinie_Gewaesser',14,'E727 Baulinie Gewaesser',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E728_Immissionsstreifen',15,'E728 Immissionsstreifen',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E729_weitere_kommunale_Baulinien',16,'E729 weitere kommunale Baulinien',FALSE,NULL);
INSERT INTO arp_npl.erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'E789_weitere_linienbezogene_Objekte_EP',17,'E789 weitere linienbezogene Objekte EP',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ZH',0,'ZH',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BE',1,'BE',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'LU',2,'LU',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'UR',3,'UR',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SZ',4,'SZ',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'OW',5,'OW',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'NW',6,'NW',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GL',7,'GL',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ZG',8,'ZG',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'FR',9,'FR',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SO',10,'SO',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BS',11,'BS',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BL',12,'BL',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SH',13,'SH',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AR',14,'AR',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AI',15,'AI',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SG',16,'SG',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GR',17,'GR',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AG',18,'AG',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'TG',19,'TG',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'TI',20,'TI',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'VD',21,'VD',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'VS',22,'VS',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'NE',23,'NE',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GE',24,'GE',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'JU',25,'JU',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'FL',26,'FL',FALSE,NULL);
INSERT INTO arp_npl.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'CH',27,'CH',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N810_geschuetzter_Einzelbaum',0,'N810 geschuetzter Einzelbaum',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N811_erhaltenswerter_Einzelbaum',1,'N811 erhaltenswerter Einzelbaum',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N812_geologisches_Objekt',2,'N812 geologisches Objekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N813_Naturobjekt',3,'N813 Naturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N820_kantonal_geschuetztes_Kulturobjekt',4,'N820 kantonal geschuetztes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N821_kommunal_geschuetztes_Kulturobjekt',5,'N821 kommunal geschuetztes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N822_schuetzenswertes_Kulturobjekt',6,'N822 schuetzenswertes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N823_erhaltenswertes_Kulturobjekt',7,'N823 erhaltenswertes Kulturobjekt',FALSE,NULL);
INSERT INTO arp_npl.nutzungsplanung_np_typ_kanton_ueberlagernd_punkt (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'N899_weitere_punktbezogene_Festlegungen_NP',8,'N899 weitere punktbezogene Festlegungen NP',FALSE,NULL);
INSERT INTO arp_npl.valignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (0,'Top',0,'Top',FALSE,NULL);
INSERT INTO arp_npl.valignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (1,'Cap',1,'Cap',FALSE,NULL);
INSERT INTO arp_npl.valignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (2,'Half',2,'Half',FALSE,NULL);
INSERT INTO arp_npl.valignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (3,'Base',3,'Base',FALSE,NULL);
INSERT INTO arp_npl.valignment (seq,iliCode,itfCode,dispName,inactive,description) VALUES (4,'Bottom',4,'Bottom',FALSE,NULL);
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('rechtsvorschrften_hinweisweiteredokumente',NULL,'ursprung','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'typ_ueberlagernd_punkt','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_grundnutzung_dokument',NULL,'typ_grundnutzung','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'erschliessung_flaechenobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_flaeche',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transfermetadaten_datenbestand',NULL,'amt','ch.ehi.ili2db.foreignKey','transfermetadaten_amt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'typ_ueberlagernd_flaeche','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_flaechenobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.geomType','LINESTRING');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'ueberlagernd_linie','ch.ehi.ili2db.foreignKey','nutzungsplanung_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_punkt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_linienobjekt_dokument',NULL,'typ_erschliessung_linienobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'vs_perimeter_verfahrensstand','ch.ehi.ili2db.foreignKey','verfahrenstand_vs_perimeter_verfahrensstand');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_linie',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_grundnutzung_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_linienobjekt_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'typ_ueberlagernd_linie','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_grundnutzung',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_linie_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_linienobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_punkt_dokument',NULL,'typ_ueberlagernd_punkt','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'ueberlagernd_flaeche','ch.ehi.ili2db.foreignKey','nutzungsplanung_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_flaeche_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('rechtsvorschrften_dokument',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'erschliessung_linienobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_flaeche_dokument',NULL,'typ_ueberlagernd_flaeche','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_flaeche');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'erschliessung_punktobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'ueberlagernd_punkt','ch.ehi.ili2db.foreignKey','nutzungsplanung_ueberlagernd_punkt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'typ_erschliessung_punktobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('rechtsvorschrften_hinweisweiteredokumente',NULL,'hinweis','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'pos','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'typ_erschliessung_linienobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_linienobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie',NULL,'geometrie','ch.ehi.ili2db.geomType','LINESTRING');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_punktobjekt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'typ_grundnutzung','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument',NULL,'typ_erschliessung_flaechenobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transfermetadaten_datenbestand',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_linie_dokument',NULL,'typ_ueberlagernd_linie','ch.ehi.ili2db.foreignKey','nutzungsplanung_typ_ueberlagernd_linie');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt_pos',NULL,'pos','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_punkt_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung_pos',NULL,'grundnutzung','ch.ehi.ili2db.foreignKey','nutzungsplanung_grundnutzung');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_grundnutzung',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_punktobjekt_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','rechtsvorschrften_dokument');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_punktobjekt',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_pos',NULL,'pos','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('verfahrenstand_vs_perimeter_verfahrensstand',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_flaechenobjekt',NULL,'typ_erschliessung_flaechenobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_flaechenobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_erschliessung_linienobjekt',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_punktobjekt_dokument',NULL,'typ_erschliessung_punktobjekt','ch.ehi.ili2db.foreignKey','erschlssngsplnung_typ_erschliessung_punktobjekt');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_linie_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_punkt_pos',NULL,'pos','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('nutzungsplanung_ueberlagernd_flaeche',NULL,'bemerkungen','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_typ_grundnutzung_nutzungsziffer_art','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_punkt_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('rechtsstatus','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_flaeche_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_ep_typ_kanton_erschliessung_punktobjekt','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_np_typ_kanton_ueberlagernd_punkt','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_punktobjekt_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_np_typ_kanton_ueberlagernd_flaeche','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('verfahrenstand_planungsart','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('rechtsvorschrften_hinweisweiteredokumente','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_typ_erschliessung_linienobjekt_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('verfahrenstand_verfahrensstufe','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('halignment','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_np_typ_kanton_ueberlagernd_linie','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('valignment','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_typ_ueberlagernd_linie_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('schriftgroesse','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_ep_typ_kanton_erschliessung_linienobjekt','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_np_typ_kanton_grundnutzung','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('verbindlichkeit','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('nutzungsplanung_typ_grundnutzung_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('chcantoncode','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('erschlssngsplnung_ep_typ_kanton_erschliessung_flaechenobjekt','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part4_ADMINISTRATIVEUNITS_20110830.ili','2.3','CHAdminCodes_V1 AdministrativeUnits_V1{ CHAdminCodes_V1 InternationalCodes_V1 Dictionaries_V1 Localisation_V1 INTERLIS} AdministrativeUnitsCH_V1{ CHAdminCodes_V1 InternationalCodes_V1 LocalisationCH_V1 AdministrativeUnits_V1 INTERLIS}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-08-30
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART IV -- ADMINISTRATIVE UNITS
   - Package CHAdminCodes
   - Package AdministrativeUnits
   - Package AdministrativeUnitsCH
*/

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2018-02-19 | KOGIS | CHCantonCode adapted (FL and CH added) (line 34)

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL CHAdminCodes_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2018-02-19" =

  DOMAIN
    CHCantonCode = (ZH,BE,LU,UR,SZ,OW,NW,GL,ZG,FR,SO,BS,BL,SH,AR,AI,SG,
                    GR,AG,TG,TI,VD,VS,NE,GE,JU,FL,CH);

    CHMunicipalityCode = 1..9999;  !! BFS-Nr

END CHAdminCodes_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL AdministrativeUnits_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS UNQUALIFIED CHAdminCodes_V1;
  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Localisation_V1;
  IMPORTS Dictionaries_V1;

  TOPIC AdministrativeUnits (ABSTRACT) =

    CLASS AdministrativeElement (ABSTRACT) =
    END AdministrativeElement;

    CLASS AdministrativeUnit (ABSTRACT) EXTENDS AdministrativeElement =
    END AdministrativeUnit;

    ASSOCIATION Hierarchy =
      UpperLevelUnit (EXTERNAL) -<> {0..1} AdministrativeUnit;
      LowerLevelUnit -- AdministrativeUnit;
    END Hierarchy;

    CLASS AdministrativeUnion (ABSTRACT) EXTENDS AdministrativeElement =
    END AdministrativeUnion;

    ASSOCIATION UnionMembers =
      Union -<> AdministrativeUnion;
      Member -- AdministrativeElement; 
    END UnionMembers;

  END AdministrativeUnits;

  TOPIC Countries EXTENDS AdministrativeUnits =

    CLASS Country EXTENDS AdministrativeUnit =
      Code: MANDATORY CountryCode_ISO3166_1;
    UNIQUE Code;
    END Country;

  END Countries;

  TOPIC CountryNames EXTENDS Dictionaries_V1.Dictionaries =
    DEPENDS ON AdministrativeUnits_V1.Countries;

    STRUCTURE CountryName EXTENDS Entry =
      Code: MANDATORY CountryCode_ISO3166_1;
    END CountryName;
      
    CLASS CountryNamesTranslation EXTENDS Dictionary  =
      Entries(EXTENDED): LIST OF CountryName;
    UNIQUE Entries->Code;
    EXISTENCE CONSTRAINT
      Entries->Code REQUIRED IN AdministrativeUnits_V1.Countries.Country: Code;
    END CountryNamesTranslation;

  END CountryNames;

  TOPIC Agencies (ABSTRACT) =
    DEPENDS ON AdministrativeUnits_V1.AdministrativeUnits;

    CLASS Agency (ABSTRACT) =
    END Agency;

    ASSOCIATION Authority =
      Supervisor (EXTERNAL) -<> {1..1} Agency OR AdministrativeUnits_V1.AdministrativeUnits.AdministrativeElement;
      Agency -- Agency;
    END Authority;

    ASSOCIATION Organisation =
      Orderer (EXTERNAL) -- Agency OR AdministrativeUnits_V1.AdministrativeUnits.AdministrativeElement;
      Executor -- Agency;
    END Organisation;

  END Agencies;

END AdministrativeUnits_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL AdministrativeUnitsCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS UNQUALIFIED CHAdminCodes_V1;
  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS LocalisationCH_V1;
  IMPORTS AdministrativeUnits_V1;

  TOPIC CHCantons EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnits_V1.Countries;

    CLASS CHCanton EXTENDS AdministrativeUnit =
      Code: MANDATORY CHCantonCode;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
    UNIQUE Code;
    END CHCanton;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnits_V1.Countries.Country;
      LowerLevelUnit (EXTENDED) -- CHCanton;
    MANDATORY CONSTRAINT
      UpperLevelUnit->Code == "CHE";
    END Hierarchy;

  END CHCantons;

  TOPIC CHDistricts EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;

    CLASS CHDistrict EXTENDS AdministrativeUnit =
      ShortName: MANDATORY TEXT*20;
      Name: LocalisationCH_V1.MultilingualText;
      Web: MANDATORY URI;
    END CHDistrict;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnitsCH_V1.CHCantons.CHCanton;
      LowerLevelUnit (EXTENDED) -- CHDistrict;
    UNIQUE UpperLevelUnit->Code, LowerLevelUnit->ShortName;
    END Hierarchy;

  END CHDistricts;

  TOPIC CHMunicipalities EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;

    CLASS CHMunicipality EXTENDS AdministrativeUnit =
      Code: MANDATORY CHMunicipalityCode;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
    UNIQUE Code;
    END CHMunicipality;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnitsCH_V1.CHCantons.CHCanton
      OR AdministrativeUnitsCH_V1.CHDistricts.CHDistrict;
      LowerLevelUnit (EXTENDED) -- CHMunicipality;
    END Hierarchy;

  END CHMunicipalities;

  TOPIC CHAdministrativeUnions EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnits_V1.Countries;
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;
    DEPENDS ON AdministrativeUnitsCH_V1.CHMunicipalities;

    CLASS AdministrativeUnion (EXTENDED) =
    OID AS UUIDOID;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
      Description: LocalisationCH_V1.MultilingualMText;
    END AdministrativeUnion;

  END CHAdministrativeUnions;

  TOPIC CHAgencies EXTENDS AdministrativeUnits_V1.Agencies =
    DEPENDS ON AdministrativeUnits_V1.Countries;
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;
    DEPENDS ON AdministrativeUnitsCH_V1.CHMunicipalities;

    CLASS Agency (EXTENDED) =
    OID AS UUIDOID;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
      Description: LocalisationCH_V1.MultilingualMText;
    END Agency;

  END CHAgencies;

END AdministrativeUnitsCH_V1.

!! ########################################################################
','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('SO_Nutzungsplanung_20171118.ili','2.3','SO_Nutzungsplanung_20171118{ GeometryCHLV95_V1 CHAdminCodes_V1}','INTERLIS 2.3;

!!==============================================================================
!!@ File = "SO_Nutzungsplanung_20171118.ili"; 
!!@ Title = "Nutzungsplanung"; 
!!@ shortDescription = "Nutzungsplanungsmodell des Kantons Solothurn. Umfasst 
!!@ die im MGDM des Bundes definierten Informationen (GeoIV_ID: 73, 145, 157, 159) 
!!@ sowie Erweiterungen des Kt. Solothurn"; 
!!@ Issuer = "http://arp.so.ch"; 
!!@ technicalContact = "http://agi.so.ch"; 
!!@ furtherInformation = "Arbeitshilfe";
!!  Erfassungsmodell;
!!  Compiler-Version = "4.7.3-20170524"; 
!!------------------------------------------------------------------------------
!! Version    | wer | �nderung 
!!------------------------------------------------------------------------------
!! 2015-05-13 | SK  | Modell (v26) f�r Pilot durch Stefan Keller (SK) erstellt 
!! 2016-11-11 | SK  | �berarbeitung auf Version 32 (dm_npl_ktso_v32_LV95_ili2.ili)
!! 2016-11-29 | OJ  | Tech. Review und Finalisierung durch Oliver Jeker (AGI)
!! 2017-01-05 | OJ  | Korrektur Beziehungsrollennamen = Klassennamen
!! 2017-09-01 | al  | - Lockerung der Beziehung Dokument <-> Geometrie
!!            |     | - NP_Typ_Kanton_Grundnutzung mit N134 erg�nzt
!!            |     | - NP_Typ_Kanton_Ueberlagernd_Flaeche mit N812,N813 und
!!            |     |   N820-823 erg�nzt
!!            |     | - Rechtschreibung bei Ueberbauungsziffer
!!            |     | - Modell mit Beschreibung erg�nzt
!! 2017-09-15 | al  | OID AS INTERLIS.UUIDOID wieder eingef�gt
!! 2017-11-18 | sz  | - OID AS INTERLIS.UUIDOID f�r s�mtliche Klassen
!!            |     | - Zus�tzliche Assoziation Geometrie <-> Dokument gel�scht
!!            |     | - Klasse Plandokument gel�scht
!! 2018-08-21 | al  | Bemerkungen an Arbeitshilfe angepasst.
!!==============================================================================

MODEL SO_Nutzungsplanung_20171118 (de)
AT "http://www.geo.so.ch"
VERSION "2017-11-18"  =
  IMPORTS GeometryCHLV95_V1,CHAdminCodes_V1;

  DOMAIN

    Einzelflaeche
    EXTENDS GeometryCHLV95_V1.Surface = SURFACE WITH (ARCS,STRAIGHTS) VERTEX GeometryCHLV95_V1.Coord2 WITHOUT OVERLAPS>0.001;

    Gebietseinteilung
    EXTENDS GeometryCHLV95_V1.Area = AREA WITH (ARCS,STRAIGHTS) VERTEX GeometryCHLV95_V1.Coord2 WITHOUT OVERLAPS>0.001;

    Rechtsstatus = (
      /** Ist in Kraft
       */
      inKraft,
      /** Noch nicht in Kraft, eine �nderung ist in Vorbereitung.
       */
      laufendeAenderung
    );

    Verbindlichkeit = (
      /** Eigent�merverbindlich, im Verfahren der Nutzungsplanung festgelegt.
       */
      Nutzungsplanfestlegung,
      /** Eigent�merverbindlich, in einem anderen Verfahren festgelegt.
       */
      orientierend,
      /** Nicht eigent�merverbindlich, Informationsinhalte.
       */
      hinweisend,
      /** Nicht eigent�merverbindlich, sie umfassen Qualit�ten, Standards und dergleichen, die zu ber�cksichtigen sind.
       */
      wegleitend
    );

    /** In Gon
     */
    Rotation = 0 .. 399;

    Schriftgroesse = (
      klein,
      mittel,
      gross
    );

    Bemerkungen_Typ = MTEXT*240;

  TOPIC Rechtsvorschriften =
    OID AS INTERLIS.UUIDOID;

    CLASS Dokument =
      /** leer lassen
       */
      DokumentID : TEXT*16;
      /** Dokumentart z.B. Regierungsratsbeschluss, Zonenreglement, Sonderbauvorschriften, Erschliessungsplan, Gestaltungsplan.
       */
      Titel : MANDATORY TEXT*80;
      /** Vollst�ndiger Titel des Dokuments, wenn der OffiziellerTitel gleich lautet wie der Titel, so ist die Planbezeichnung aus der Planliste zu �bernehmen.
       */
      OffiziellerTitel : TEXT*240;
      /** Abk�rzung der Dokumentart RRB, ZR, SBV
       */
      Abkuerzung : TEXT*10;
      /** Eindeutiger Identifikator gem�ss Planregister. Die ID setzt sich folgendermassen zusammen:
       * Sonderbauvorschriften: Gemeindennummer �-� Plannummer nach Planregister �-� S (f�r Sonderbauvorschriften)z.B. 109-31-S
       * Reglemente: Gemeindenummer �-� und K�rzel Reglementart (ZR Zonenereglement, BR Baureglement und BZR Bau- und Zonenreglement z.B. 109-BR
       * Gestaltungsplan: Gemeindennummer �-� Plannummer nach Planregister �-� P (f�r Plan) z.B. 109-31-P
       * Bei RRB ist die RRB Nr. aufzuf�hren (YYYY/RRB Nr.) z.B. 2001/1585
       */
      OffizielleNr : MANDATORY TEXT*20;
      /** Abk�rzung Kanton
       */
      Kanton : CHAdminCodes_V1.CHCantonCode;
      /** Gemeindenummer vom schweizerischen Bundesamt f�r Statistik (BFS-Nr.)
       */
      Gemeinde : CHAdminCodes_V1.CHMunicipalityCode;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Rechtsstatus des Dokuments.
       */
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Relative Internetadresse des Dokuments auf Planregister. D.h. stabiler Teil, ohne https://geoweb.so.ch/zonenplaene/Zonenplaene_pdf/ z.B. 109-Wissen/Entscheide/109-31-E.pdf
       */
      TextImWeb : URI;
      /** Erl�uternder Text oder Bemerkungen zum Dokument.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      Rechtsvorschrift : BOOLEAN;
    END Dokument;

    /** Eine Hierarchie der Dokumente kann erfasst werden. Als prim�res Dokument (Ursprung) gilt immer die Rechtsvorschrift (Baureglement, Zonenreglement, Sonderbauvorschrift, Gestaltungsplan etc.), dort wo die eigentumsbeschr�nkten Informationen festgehalten sind. Die RRBs (Hinweis) werden diesen Rechtsvorschriften zugewiesen. Ist keine Rechtsvorschrift vorhanden, so wird der Typ_Grundnutzung direkt mit dem RRB verkn�pft
     */
    ASSOCIATION HinweisWeitereDokumente =
      Ursprung -- {0..*} Dokument;
      Hinweis -- {0..*} Dokument;
    END HinweisWeitereDokumente;

  END Rechtsvorschriften;

  TOPIC Nutzungsplanung =
    OID AS INTERLIS.UUIDOID;
    DEPENDS ON SO_Nutzungsplanung_20171118.Rechtsvorschriften;

    DOMAIN

      NP_Typ_Kanton_Grundnutzung = (
        N110_Wohnzone_1_G,
        N111_Wohnzone_2_G,
        N112_Wohnzone_3_G,
        N113_Wohnzone_4_G,
        N114_Wohnzone_5_G,
        N115_Wohnzone_6_G,
        N116_Wohnzone_7_G_und_groesser,
        N117_Zone_fuer_Terrassenhaeuser_Terrassensiedlung,
        N120_Gewerbezone_ohne_Wohnen,
        N121_Industriezone,
        N122_Arbeitszone,
        N130_Gewerbezone_mit_Wohnen_Mischzone,
        N131_Gewerbezone_mit_Wohnen_Mischzone_2_G,
        N132_Gewerbezone_mit_Wohnen_Mischzone_3_G,
        N133_Gewerbezone_mit_Wohnen_Mischzone_4_G_und_groesser,
        N134_Zone_fuer_publikumsintensive_Anlagen,
        N140_Kernzone,
        N141_Zentrumszone,
        N142_Erhaltungszone,
        N150_Zone_fuer_oeffentliche_Bauten,
        N151_Zone_fuer_oeffentliche_Anlagen,
        N160_Gruen_und_Freihaltezone_innerhalb_Bauzone,
        N161_kommunale_Uferschutzzone_innerhalb_Bauzone,
        N162_Landwirtschaftliche_Kernzone,
        N163_Weilerzone,
        N169_weitere_eingeschraenkte_Bauzonen,
        N170_Zone_fuer_Freizeit_und_Erholung,
        N180_Verkehrszone_Strasse,
        N181_Verkehrszone_Bahnareal,
        N182_Verkehrszone_Flugplatzareal,
        N189_weitere_Verkehrszonen,
        N190_Spezialzone,
        N210_Landwirtschaftszone,
        N220_Spezielle_Landwirtschaftszone,
        N230_Rebbauzone,
        N290_weitere_Landwirtschaftszonen,
        N310_kommunale_Naturschutzzone,
        N311_Waldrandschutzzone,
        N319_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften,
        N320_Gewaesser,
        N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer,
        N390_weitere_Schutzzonen_ausserhalb_Bauzonen,
        N420_Verkehrsflaeche_Strasse,
        N421_Verkehrsflaeche_Bahnareal,
        N422_Verkehrsflaeche_Flugplatzareal,
        N429_weitere_Verkehrsflaechen,
        N430_Reservezone_Wohnzone_Mischzone_Kernzone_Zentrumszone,
        N431_Reservezone_Arbeiten,
        N432_Reservezone_OeBA,
        N439_Reservezone,
        N440_Wald,
        N490_Golfzone,
        N491_Abbauzone,
        N492_Deponiezone,
        N499_weitere_Bauzonen_nach_Art18_RPG_ausserhalb_Bauzonen
      );

      NP_Typ_Kanton_Ueberlagernd_Flaeche = (
        N510_ueberlagernde_Ortsbildschutzzone,
        N520_BLN_Gebiet,
        N521_Juraschutzzone,
        N522_Naturreservat_inkl_Geotope,
        N523_Landschaftsschutzzone,
        N524_Siedlungstrennguertel_von_kommunaler_Bedeutung,
        N525_Siedlungstrennguertel_von_kantonaler_Bedeutung,
        N526_kantonale_Landwirtschafts_und_Schutzzone_Witi,
        N527_kantonale_Uferschutzzone,
        N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen,
        N529_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften,
        N530_Naturgefahren_erhebliche_Gefaehrdung,
        N531_Naturgefahren_mittlere_Gefaehrdung,
        N532_Naturgefahren_geringe_Gefaehrdung,
        N533_Naturgefahren_Restgefaehrdung,
        N590_Hofstattzone_Freihaltezone,
        N591_Bauliche_Einschraenkungen,
        N592_Hecken_Feldgehoelz_Ufergehoelz,
        N593_Grundwasserschutzzone_S1,
        N594_Grundwasserschutzzone_S2,
        N595_Grundwasserschutzzone_S3,
        N596_Grundwasserschutzareal,
        N599_weitere_ueberlagernde_Nutzungszonen,
        N610_Perimeter_kantonaler_Nutzungsplan,
        N611_Perimeter_kommunaler_Gestaltungsplan,
        N620_Perimeter_Gestaltungsplanpflicht,
        N680_Empfindlichkeitsstufe_I,
        N681_Empfindlichkeitsstufe_II,
        N682_Empfindlichkeitsstufe_II_aufgestuft,
        N683_Empfindlichkeitsstufe_III,
        N684_Empfindlichkeitsstufe_III_aufgestuft,
        N685_Empfindlichkeitsstufe_IV,
        N686_keine_Empfindlichkeitsstufe,
        N690_kantonales_Vorranggebiet_Natur_und_Landschaft,
        N691_kommunales_Vorranggebiet_Natur_und_Landschaft,
        N692_Planungszone,
        N699_weitere_flaechenbezogene_Festlegungen_NP,
        N812_geologisches_Objekt,
        N813_Naturobjekt,
        N820_kantonal_geschuetztes_Kulturobjekt,
        N821_kommunal_geschuetztes_Kulturobjekt,
        N822_schuetzenswertes_Kulturobjekt,
        N823_erhaltenswertes_Kulturobjekt
      );

      NP_Typ_Kanton_Ueberlagernd_Linie = (
        N790_Wanderweg,
        N791_historischer_Verkehrsweg,
        N792_Waldgrenze,
        N793_negative_Waldfeststellung,
        N799_weitere_linienbezogene_Festlegungen_NP
      );

      NP_Typ_Kanton_Ueberlagernd_Punkt = (
        N810_geschuetzter_Einzelbaum,
        N811_erhaltenswerter_Einzelbaum,
        N812_geologisches_Objekt,
        N813_Naturobjekt,
        N820_kantonal_geschuetztes_Kulturobjekt,
        N821_kommunal_geschuetztes_Kulturobjekt,
        N822_schuetzenswertes_Kulturobjekt,
        N823_erhaltenswertes_Kulturobjekt,
        N899_weitere_punktbezogene_Festlegungen_NP
      );

    /** Orientierung der Beschriftung in Gon. 0 gon = Horizontal
     */
    CLASS Pos (ABSTRACT) =
      /** Position f�r die Beschriftung
       */
      Pos : MANDATORY GeometryCHLV95_V1.Coord2;
      /** Orientierung der Beschriftung in Gon. 0 gon = Horizontal
       */
      Ori : SO_Nutzungsplanung_20171118.Rotation;
      /** Mit dem horizontalen Alignment wird festgelegt, ob die Position auf dem linken oder rechten Rand des Textes oder in der
       * Textmitte liegt.
       */
      HAli : HALIGNMENT;
      /** Das vertikale Alignment legt die Position in Richtung der Texth�he fest.
       */
      VAli : VALIGNMENT;
      /** Gr�sse der Beschriftung
       */
      Groesse : MANDATORY SO_Nutzungsplanung_20171118.Schriftgroesse;
    END Pos;

    CLASS Typ (ABSTRACT) =
      /** Name der Grundnutzung, �berlagernden Objekts oder Erschliessung. Wird von der Gemeinde definiert.
       */
      Bezeichnung : MANDATORY TEXT*80;
      /** Abk�rzung der Bezeichung. Kann von der Gemeinde vergeben werden. Falls keine Abk�rzung vorhanden ist bleit das Feld leer.
       */
      Abkuerzung : TEXT*12;
      Verbindlichkeit : MANDATORY SO_Nutzungsplanung_20171118.Verbindlichkeit;
      /** Erl�uternder Text zum Typ
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
    END Typ;

    CLASS Typ_Grundnutzung
    EXTENDS Typ =
      Typ_Kt : MANDATORY NP_Typ_Kanton_Grundnutzung;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
      /** Zahlenwert nach Zonenreglement der Gemeinde (0.05 = 5%).
       */
      Nutzungsziffer : 0.00 .. 9.00;
      Nutzungsziffer_Art : (
        /** Bauvolumen �ber massgebendem Terrain / anrechenbare Grundst�cksfl�che (�37ter PBG)
         */
        Baumassenziffer,
        /** Summe aller Geschossfl�chen / anrechenbare Grundst�cksfl�che (�37bis PBG)
         */
        Geschossflaechen,
        /** Anrechenbare Geb�udefl�che / anrechenbare Grundst�cksfl�che (�35 PBG)
         */
        Ueberbauungsziffer,
        /** Anrechenbare Bruttogeschossfl�che / anrechenbare Grundst�cksfl�che ((�37 PBG, wurde gestrichen)
         */
        Ausnuetzungsziffer
      );
      /** Maximal zul�ssige Anzahl Geschosse
       */
      Geschosszahl : 0 .. 50;
    END Typ_Grundnutzung;

    CLASS Typ_Ueberlagernd_Flaeche
    EXTENDS Typ =
      Typ_Kt : MANDATORY NP_Typ_Kanton_Ueberlagernd_Flaeche;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Ueberlagernd_Flaeche;

    CLASS Typ_Ueberlagernd_Linie
    EXTENDS Typ =
      Typ_Kt : MANDATORY NP_Typ_Kanton_Ueberlagernd_Linie;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Ueberlagernd_Linie;

    CLASS Typ_Ueberlagernd_Punkt
    EXTENDS Typ =
      Typ_Kt : MANDATORY NP_Typ_Kanton_Ueberlagernd_Punkt;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Ueberlagernd_Punkt;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Grundnutzung_Dokument =
      Typ_Grundnutzung -- {0..*} Typ_Grundnutzung;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Grundnutzung_Dokument;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Ueberlagernd_Flaeche_Dokument =
      Typ_Ueberlagernd_Flaeche -- {0..*} Typ_Ueberlagernd_Flaeche;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Ueberlagernd_Flaeche_Dokument;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Ueberlagernd_Linie_Dokument =
      Typ_Ueberlagernd_Linie -- {0..*} Typ_Ueberlagernd_Linie;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Ueberlagernd_Linie_Dokument;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Ueberlagernd_Punkt_Dokument =
      Typ_Ueberlagernd_Punkt -- {0..*} Typ_Ueberlagernd_Punkt;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Ueberlagernd_Punkt_Dokument;

    CLASS Grundnutzung =
      /** Geometrie als Gebietseinteilung. �berlappungen bei Radien mit einer
       * Pfeilh�he <1 mm werden toleriert.
       */
      Geometrie : MANDATORY SO_Nutzungsplanung_20171118.Gebietseinteilung;
      /** Leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu der einzelnen Grundnutzungsgeometrie.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Grundnutzung;

    CLASS Ueberlagernd_Flaeche =
      /** Fl�che, welche die Grundnutzung �berlagert.
       */
      Geometrie : MANDATORY SO_Nutzungsplanung_20171118.Einzelflaeche;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu der einzelnen �berlagernden Objekte.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Ueberlagernd_Flaeche;

    CLASS Ueberlagernd_Linie =
      /** Linie, welche die Grundnutzung �berlagert.
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Line;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu der einzelnen �berlagernden Objekte.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Ueberlagernd_Linie;

    CLASS Ueberlagernd_Punkt =
      /** Punkt, welche die Grundnutzung �berlagert.
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu der einzelnen �berlagernden Objekte.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Ueberlagernd_Punkt;

    /** Ein Typ_Grundnutzung kann mehrere Grundnutzungsgeometrien haben
     */
    ASSOCIATION Typ_Grundnutzung_Grundnutzung =
      Typ_Grundnutzung -<> {1} Typ_Grundnutzung;
      Grundnutzung -- {0..*} Grundnutzung;
    END Typ_Grundnutzung_Grundnutzung;

    /** Ein Typ_Ueberlagernd_Flaeche kann mehrere �berlagernde Geometrien haben.
     */
    ASSOCIATION Typ_Ueberlagernd_Flaeche_Flaeche =
      Typ_Ueberlagernd_Flaeche -<> {1} Typ_Ueberlagernd_Flaeche;
      Ueberlagernd_Flaeche -- {0..*} Ueberlagernd_Flaeche;
    END Typ_Ueberlagernd_Flaeche_Flaeche;

    /** Ein Typ_Ueberlagernd_Linie kann mehrere �berlagernde Geometrien haben.
     */
    ASSOCIATION Typ_Ueberlagernd_Linie_Linie =
      Typ_Ueberlagernd_Linie -<> {1} Typ_Ueberlagernd_Linie;
      Ueberlagernd_Linie -- {0..*} Ueberlagernd_Linie;
    END Typ_Ueberlagernd_Linie_Linie;

    /** Ein Typ_Ueberlagernd_Punkt kann mehrere �berlagernde Geometrien haben.
     */
    ASSOCIATION Typ_Ueberlagernd_Punkt_Punkt =
      Typ_Ueberlagernd_Punkt -<> {1} Typ_Ueberlagernd_Punkt;
      Ueberlagernd_Punkt -- {0..*} Ueberlagernd_Punkt;
    END Typ_Ueberlagernd_Punkt_Punkt;

    CLASS Grundnutzung_Pos
    EXTENDS Pos =
    END Grundnutzung_Pos;

    CLASS Ueberlagernd_Flaeche_Pos
    EXTENDS Pos =
    END Ueberlagernd_Flaeche_Pos;

    CLASS Ueberlagernd_Linie_Pos
    EXTENDS Pos =
    END Ueberlagernd_Linie_Pos;

    CLASS Ueberlagernd_Punkt_Pos
    EXTENDS Pos =
    END Ueberlagernd_Punkt_Pos;

    /** Beschriftet wir die Abk�rzung welche in der Klasse Typ_Grundnutzung erfasst wird.
     */
    ASSOCIATION Grundnutzung_Grundnutzung_Pos =
      Grundnutzung -<> {1} Grundnutzung;
      Grundnutzung_Pos -- {0..*} Grundnutzung_Pos;
    END Grundnutzung_Grundnutzung_Pos;

    /** Beschriftet wir die Abk�rzung welche in der Klasse Typ_Ueberlagernd_Flaeche erfasst wird.
     */
    ASSOCIATION Ueberlagernd_Flaeche_Flaeche_Pos =
      Ueberlagernd_Flaeche -<> {1} Ueberlagernd_Flaeche;
      Ueberlagernd_Flaeche_Pos -- {0..*} Ueberlagernd_Flaeche_Pos;
    END Ueberlagernd_Flaeche_Flaeche_Pos;

    /** Beschriftet wir die Abk�rzung welche in der Klasse Typ_Ueberlagernd_Linie erfasst wird.
     */
    ASSOCIATION Ueberlagernd_Linie_Linie_Pos =
      Ueberlagernd_Linie -<> {1} Ueberlagernd_Linie;
      Ueberlagernd_Linie_Pos -- {0..*} Ueberlagernd_Linie_Pos;
    END Ueberlagernd_Linie_Linie_Pos;

    /** Beschriftet wir die Abk�rzung welche in der Klasse Typ_Ueberlagernd_Punkt erfasst wird.
     */
    ASSOCIATION Ueberlagernd_Punkt_Punkt_Pos =
      Ueberlagernd_Punkt -<> {1} Ueberlagernd_Punkt;
      Ueberlagernd_Punkt_Pos -- {0..*} Ueberlagernd_Punkt_Pos;
    END Ueberlagernd_Punkt_Punkt_Pos;

  END Nutzungsplanung;

  TOPIC Erschliessungsplanung =
    OID AS INTERLIS.UUIDOID;
    DEPENDS ON SO_Nutzungsplanung_20171118.Rechtsvorschriften;

    DOMAIN

      EP_Typ_Kanton_Erschliessung_Flaechenobjekt = (
        E560_Nationalstrasse,
        E561_Kantonsstrasse,
        E562_Sammelstrasse_kommunal,
        E563_Erschliessungsstrasse_kommunal,
        E564_Flurweg_mit_Erschliessungsfunktion,
        E565_Flurweg_ohne_Erschliessungsfunktion,
        E566_private_Erschliessungsstrasse,
        E567_unklassierte_Strasse,
        E568_Strassenbankett_Verkehrsinsel,
        E569_uebrige_Verkehrsflaechen,
        E570_Gehweg_Trottoir,
        E571_Fussweg,
        E572_Radweg,
        E573_Fuss_und_Radweg,
        E574_Gruenstreifen_Rabatte,
        E579_uebrige_Flaechen_Langsamverkehr
      );

      EP_Typ_Kanton_Erschliessung_Linienobjekt = (
        E710_nationale_Baulinie,
        E711_Baulinie_Strasse_kantonal,
        E712_Vorbaulinie_kantonal,
        E713_Gestaltungsbaulinie_kantonal,
        E714_Rueckwaertige_Baulinie_kantonal,
        E715_Baulinie_Infrastruktur_kantonal,
        E719_weitere_nationale_und_kantonale_Baulinien,
        E720_Baulinie_Strasse,
        E721_Vorbaulinie,
        E722_Gestaltungsbaulinie,
        E723_Rueckwaertige_Baulinie,
        E724_Baulinie_Infrastruktur,
        E725_Waldabstandslinie,
        E726_Baulinie_Hecke,
        E727_Baulinie_Gewaesser,
        E728_Immissionsstreifen,
        E729_weitere_kommunale_Baulinien,
        E789_weitere_linienbezogene_Objekte_EP
      );

      EP_Typ_Kanton_Erschliessung_Punktobjekt = (
        E889_weitere_punktbezogene_Objekte_EP
      );

    CLASS Typ_Erschliessung_Flaechenobjekt
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ =
      Typ_Kt : MANDATORY EP_Typ_Kanton_Erschliessung_Flaechenobjekt;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Erschliessung_Flaechenobjekt;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Erschliessung_Flaechenobjekt_Dokument =
      Typ_Erschliessung_Flaechenobjekt -- {0..*} Typ_Erschliessung_Flaechenobjekt;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Erschliessung_Flaechenobjekt_Dokument;

    CLASS Erschliessung_Flaechenobjekt =
      Geometrie : MANDATORY SO_Nutzungsplanung_20171118.Einzelflaeche;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu den einzelnen Erschliessungsobjekten.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Erschliessung_Flaechenobjekt;

    /** Typ_Erschliessung_Flaecheobjekt kann mehrere Erschliessung-Geometrien haben.
     */
    ASSOCIATION Typ_Erschliessung_Flaechenobjekt_Flaeche =
      Typ_Erschliessung_Flaechenobjekt -<> {1} Typ_Erschliessung_Flaechenobjekt;
      Erschliessung_Flaechenobjekt -- {0..*} Erschliessung_Flaechenobjekt;
    END Typ_Erschliessung_Flaechenobjekt_Flaeche;

    CLASS Erschliessung_Flaechenobjekt_Pos
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos =
    END Erschliessung_Flaechenobjekt_Pos;

    /** Beschriftet wir die Abk�rzung, welche in der Klasse Typ_Erschliessung_Flaecheobjekt erfasst wird.
     */
    ASSOCIATION Erschliessung_Flaechenobjekt_Flaeche_Pos =
      Erschliessung_Flaechenobjekt -<> {1} Erschliessung_Flaechenobjekt;
      Erschliessung_Flaechenobjekt_Pos -- {0..*} Erschliessung_Flaechenobjekt_Pos;
    END Erschliessung_Flaechenobjekt_Flaeche_Pos;

    CLASS Typ_Erschliessung_Linienobjekt
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ =
      Typ_Kt : MANDATORY EP_Typ_Kanton_Erschliessung_Linienobjekt;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Erschliessung_Linienobjekt;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Erschliessung_Linienobjekt_Dokument =
      Typ_Erschliessung_Linienobjekt -- {0..*} Typ_Erschliessung_Linienobjekt;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Erschliessung_Linienobjekt_Dokument;

    CLASS Erschliessung_Linienobjekt =
      Geometrie : MANDATORY GeometryCHLV95_V1.Line;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu den einzelnen Erschliessungsobjekten.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Erschliessung_Linienobjekt;

    /** Typ_Erschliessung_Linienobjekt kann mehrere Erschliessung-Geometrien haben
     */
    ASSOCIATION Typ_Erschliessung_Linienobjekt_Linie =
      Typ_Erschliessung_Linienobjekt -<> {1} Typ_Erschliessung_Linienobjekt;
      Erschliessung_Linienobjekt -- {0..*} Erschliessung_Linienobjekt;
    END Typ_Erschliessung_Linienobjekt_Linie;

    CLASS Erschliessung_Linienobjekt_Pos
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos =
    END Erschliessung_Linienobjekt_Pos;

    /** Beschriftet wir die Abk�rzung, welche in der Klasse Typ_Erschliessung_Linienobjekt  erfasst wird.
     */
    ASSOCIATION Erschliessung_Linienobjekt_Linie_Pos =
      Erschliessung_Linienobjekt -<> {1} Erschliessung_Linienobjekt;
      Erschliessung_Linienobjekt_Pos -- {0..*} Erschliessung_Linienobjekt_Pos;
    END Erschliessung_Linienobjekt_Linie_Pos;

    CLASS Typ_Erschliessung_Punktobjekt
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Typ =
      Typ_Kt : MANDATORY EP_Typ_Kanton_Erschliessung_Punktobjekt;
      /** 4-stelliger kommunaler Code. Wird durch die Gemeinde vergeben. Im Objektkatalog ist definiert, welche Werte des kommunalen Codes erlaubt sind.
       */
      Code_kommunal : MANDATORY TEXT*12;
    END Typ_Erschliessung_Punktobjekt;

    /** Siehe in der Arbeitshilfe
     */
    ASSOCIATION Typ_Erschliessung_Punktobjekt_Dokument =
      Typ_Erschliessung_Punktobjekt -- {0..*} Typ_Erschliessung_Punktobjekt;
      Dokument (EXTERNAL) -- {0..*} SO_Nutzungsplanung_20171118.Rechtsvorschriften.Dokument;
    END Typ_Erschliessung_Punktobjekt_Dokument;

    CLASS Erschliessung_Punktobjekt =
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
      /** leer lassen
       */
      Name_Nummer : TEXT*20;
      Rechtsstatus : MANDATORY SO_Nutzungsplanung_20171118.Rechtsstatus;
      /** Datum des Regierungsratsbeschlusses
       */
      publiziertAb : MANDATORY INTERLIS.XMLDate;
      /** Bemerkung zu den einzelnen Erschliessungsobjekten.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name der Firma die die Daten erfasst hat.
       */
      Erfasser : TEXT*80;
      /** Datum der Erfassung
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END Erschliessung_Punktobjekt;

    /** Typ_Erschliessung_Punktobjekt kann mehrere Erschliessung-Geometrien haben
     */
    ASSOCIATION Typ_Erschliessung_Punktobjekt_Punkt =
      Typ_Erschliessung_Punktobjekt -<> {1} Typ_Erschliessung_Punktobjekt;
      Erschliessung_Punktobjekt -- {0..*} Erschliessung_Punktobjekt;
    END Typ_Erschliessung_Punktobjekt_Punkt;

    CLASS Erschliessung_Punktobjekt_Pos
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos =
    END Erschliessung_Punktobjekt_Pos;

    /** Beschriftet wir die Abk�rzung, welche in der Klasse Typ_Erschliessung_Punktobjekt  erfasst wird.
     */
    ASSOCIATION Erschliessung_Punktobjekt_Punkt_Pos =
      Erschliessung_Punktobjekt -<> {1} Erschliessung_Punktobjekt;
      Erschliessung_Punktobjekt_Pos -- {0..*} Erschliessung_Punktobjekt_Pos;
    END Erschliessung_Punktobjekt_Punkt_Pos;

  END Erschliessungsplanung;

  TOPIC Verfahrenstand =
    OID AS INTERLIS.UUIDOID;

    DOMAIN

      Planungsart = (
        Nutzungsplanung,
        Erschliessungsplanung,
        Waldfeststellung
      );

      Verfahrensstufe = (
        Vorpruefung,
        Planauflage,
        zur_Genehmigung_beantragt,
        genehmigt_Beschwerde_haengig,
        rechtskraeftig,
        von_Genehmigung_ausgenommen
      );

    CLASS VS_Perimeter_Verfahrensstand =
      /** Geltungsbereich f�r die Mutation
       */
      Geometrie : MANDATORY SO_Nutzungsplanung_20171118.Einzelflaeche;
      Planungsart : MANDATORY Planungsart;
      Verfahrensstufe : MANDATORY Verfahrensstufe;
      /** Leer lassen
       */
      Name_Nummer : TEXT*20;
      /** Erl�uternder Text oder Bemerkungen zum Verfahrenstand.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
      /** Name des der Firma
       */
      Erfasser : TEXT*80;
      /** Datum Verfahrensbeginn
       */
      Datum : MANDATORY INTERLIS.XMLDate;
    END VS_Perimeter_Verfahrensstand;

    CLASS VS_Perimeter_Pos
    EXTENDS SO_Nutzungsplanung_20171118.Nutzungsplanung.Pos =
    END VS_Perimeter_Pos;

    ASSOCIATION VS_Perimeter_Pos_Verfahrensstand =
      VS_Perimeter_Verfahrensstand -<> {1} VS_Perimeter_Verfahrensstand;
      VS_Perimeter_Pos -- {0..*} VS_Perimeter_Pos;
    END VS_Perimeter_Pos_Verfahrensstand;

  END Verfahrenstand;

  TOPIC TransferMetadaten =
    OID AS INTERLIS.UUIDOID;
    DEPENDS ON SO_Nutzungsplanung_20171118.Nutzungsplanung;

    CLASS Amt =
      /** Firmenname des Erfassers
       */
      Name : MANDATORY TEXT*80;
      /** Verweis auf die Webseite
       */
      AmtImWeb : URI;
    END Amt;

    CLASS Datenbestand =
      /** Datum des Datenstandes, z.B. Gemeinderatsbeschluss oder bereinigte Daten nach RRB
       */
      Stand : MANDATORY INTERLIS.XMLDate;
      /** Datum der Datenlieferung
       */
      Lieferdatum : INTERLIS.XMLDate;
      /** Erl�uternder Text oder Bemerkungen zum Datenbestand.
       */
      Bemerkungen : SO_Nutzungsplanung_20171118.Bemerkungen_Typ;
    END Datenbestand;

    ASSOCIATION zustStelle_Daten =
      Amt -<> {1} Amt;
      Datenbestand -- {0..*} Datenbestand;
    END zustStelle_Daten;

  END TransferMetadaten;

END SO_Nutzungsplanung_20171118.
','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('Units-20120220.ili','2.3','Units','!! File Units.ili Release 2012-02-20

INTERLIS 2.3;

!! 2012-02-20 definition of "Bar [bar]" corrected
!!@precursorVersion = 2005-06-06

CONTRACTED TYPE MODEL Units (en) AT "http://www.interlis.ch/models"
  VERSION "2012-02-20" =

  UNIT
    !! abstract Units
    Area (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH);
    Volume (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH*INTERLIS.LENGTH);
    Velocity (ABSTRACT) = (INTERLIS.LENGTH/INTERLIS.TIME);
    Acceleration (ABSTRACT) = (Velocity/INTERLIS.TIME);
    Force (ABSTRACT) = (INTERLIS.MASS*INTERLIS.LENGTH/INTERLIS.TIME/INTERLIS.TIME);
    Pressure (ABSTRACT) = (Force/Area);
    Energy (ABSTRACT) = (Force*INTERLIS.LENGTH);
    Power (ABSTRACT) = (Energy/INTERLIS.TIME);
    Electric_Potential (ABSTRACT) = (Power/INTERLIS.ELECTRIC_CURRENT);
    Frequency (ABSTRACT) = (INTERLIS.DIMENSIONLESS/INTERLIS.TIME);

    Millimeter [mm] = 0.001 [INTERLIS.m];
    Centimeter [cm] = 0.01 [INTERLIS.m];
    Decimeter [dm] = 0.1 [INTERLIS.m];
    Kilometer [km] = 1000 [INTERLIS.m];

    Square_Meter [m2] EXTENDS Area = (INTERLIS.m*INTERLIS.m);
    Cubic_Meter [m3] EXTENDS Volume = (INTERLIS.m*INTERLIS.m*INTERLIS.m);

    Minute [min] = 60 [INTERLIS.s];
    Hour [h] = 60 [min];
    Day [d] = 24 [h];

    Kilometer_per_Hour [kmh] EXTENDS Velocity = (km/h);
    Meter_per_Second [ms] = 3.6 [kmh];
    Newton [N] EXTENDS Force = (INTERLIS.kg*INTERLIS.m/INTERLIS.s/INTERLIS.s);
    Pascal [Pa] EXTENDS Pressure = (N/m2);
    Joule [J] EXTENDS Energy = (N*INTERLIS.m);
    Watt [W] EXTENDS Power = (J/INTERLIS.s);
    Volt [V] EXTENDS Electric_Potential = (W/INTERLIS.A);

    Inch [in] = 2.54 [cm];
    Foot [ft] = 0.3048 [INTERLIS.m];
    Mile [mi] = 1.609344 [km];

    Are [a] = 100 [m2];
    Hectare [ha] = 100 [a];
    Square_Kilometer [km2] = 100 [ha];
    Acre [acre] = 4046.873 [m2];

    Liter [L] = 1 / 1000 [m3];
    US_Gallon [USgal] = 3.785412 [L];

    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

    Gon = 200 / PI [INTERLIS.rad];

    Gram [g] = 1 / 1000 [INTERLIS.kg];
    Ton [t] = 1000 [INTERLIS.kg];
    Pound [lb] = 0.4535924 [INTERLIS.kg];

    Calorie [cal] = 4.1868 [J];
    Kilowatt_Hour [kWh] = 0.36E7 [J];

    Horsepower = 746 [W];

    Techn_Atmosphere [at] = 98066.5 [Pa];
    Atmosphere [atm] = 101325 [Pa];
    Bar [bar] = 100000 [Pa];
    Millimeter_Mercury [mmHg] = 133.3224 [Pa];
    Torr = 133.3224 [Pa]; !! Torr = [mmHg]

    Decibel [dB] = FUNCTION // 10**(dB/20) * 0.00002 // [Pa];

    Degree_Celsius [oC] = FUNCTION // oC+273.15 // [INTERLIS.K];
    Degree_Fahrenheit [oF] = FUNCTION // (oF+459.67)/1.8 // [INTERLIS.K];

    CountedObjects EXTENDS INTERLIS.DIMENSIONLESS;

    Hertz [Hz] EXTENDS Frequency = (CountedObjects/INTERLIS.s);
    KiloHertz [KHz] = 1000 [Hz];
    MegaHertz [MHz] = 1000 [KHz];

    Percent = 0.01 [CountedObjects];
    Permille = 0.001 [CountedObjects];

    !! ISO 4217 Currency Abbreviation
    USDollar [USD] EXTENDS INTERLIS.MONEY;
    Euro [EUR] EXTENDS INTERLIS.MONEY;
    SwissFrancs [CHF] EXTENDS INTERLIS.MONEY;

END Units.

','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part2_LOCALISATION_20110830.ili','2.3','InternationalCodes_V1 Localisation_V1{ InternationalCodes_V1} LocalisationCH_V1{ InternationalCodes_V1 Localisation_V1} Dictionaries_V1{ InternationalCodes_V1} DictionariesCH_V1{ InternationalCodes_V1 Dictionaries_V1}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-08-30
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART II -- LOCALISATION
   - Package InternationalCodes
   - Packages Localisation, LocalisationCH
   - Packages Dictionaries, DictionariesCH
*/

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL InternationalCodes_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  DOMAIN
    LanguageCode_ISO639_1 = (de,fr,it,rm,en,
      aa,ab,af,am,ar,as,ay,az,ba,be,bg,bh,bi,bn,bo,br,ca,co,cs,cy,da,dz,el,
      eo,es,et,eu,fa,fi,fj,fo,fy,ga,gd,gl,gn,gu,ha,he,hi,hr,hu,hy,ia,id,ie,
      ik,is,iu,ja,jw,ka,kk,kl,km,kn,ko,ks,ku,ky,la,ln,lo,lt,lv,mg,mi,mk,ml,
      mn,mo,mr,ms,mt,my,na,ne,nl,no,oc,om,or,pa,pl,ps,pt,qu,rn,ro,ru,rw,sa,
      sd,sg,sh,si,sk,sl,sm,sn,so,sq,sr,ss,st,su,sv,sw,ta,te,tg,th,ti,tk,tl,
      tn,to,tr,ts,tt,tw,ug,uk,ur,uz,vi,vo,wo,xh,yi,yo,za,zh,zu);

    CountryCode_ISO3166_1 = (CHE,
      ABW,AFG,AGO,AIA,ALA,ALB,AND_,ANT,ARE,ARG,ARM,ASM,ATA,ATF,ATG,AUS,
      AUT,AZE,BDI,BEL,BEN,BFA,BGD,BGR,BHR,BHS,BIH,BLR,BLZ,BMU,BOL,BRA,
      BRB,BRN,BTN,BVT,BWA,CAF,CAN,CCK,CHL,CHN,CIV,CMR,COD,COG,COK,COL,
      COM,CPV,CRI,CUB,CXR,CYM,CYP,CZE,DEU,DJI,DMA,DNK,DOM,DZA,ECU,EGY,
      ERI,ESH,ESP,EST,ETH,FIN,FJI,FLK,FRA,FRO,FSM,GAB,GBR,GEO,GGY,GHA,
      GIB,GIN,GLP,GMB,GNB,GNQ,GRC,GRD,GRL,GTM,GUF,GUM,GUY,HKG,HMD,HND,
      HRV,HTI,HUN,IDN,IMN,IND,IOT,IRL,IRN,IRQ,ISL,ISR,ITA,JAM,JEY,JOR,
      JPN,KAZ,KEN,KGZ,KHM,KIR,KNA,KOR,KWT,LAO,LBN,LBR,LBY,LCA,LIE,LKA,
      LSO,LTU,LUX,LVA,MAC,MAR,MCO,MDA,MDG,MDV,MEX,MHL,MKD,MLI,MLT,MMR,
      MNE,MNG,MNP,MOZ,MRT,MSR,MTQ,MUS,MWI,MYS,MYT,NAM,NCL,NER,NFK,NGA,
      NIC,NIU,NLD,NOR,NPL,NRU,NZL,OMN,PAK,PAN,PCN,PER,PHL,PLW,PNG,POL,
      PRI,PRK,PRT,PRY,PSE,PYF,QAT,REU,ROU,RUS,RWA,SAU,SDN,SEN,SGP,SGS,
      SHN,SJM,SLB,SLE,SLV,SMR,SOM,SPM,SRB,STP,SUR,SVK,SVN,SWE,SWZ,SYC,
      SYR,TCA,TCD,TGO,THA,TJK,TKL,TKM,TLS,TON,TTO,TUN,TUR,TUV,TWN,TZA,
      UGA,UKR,UMI,URY,USA,UZB,VAT,VCT,VEN,VGB,VIR,VNM,VUT,WLF,WSM,YEM,
      ZAF,ZMB,ZWE);

END InternationalCodes_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL Localisation_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;

  STRUCTURE LocalisedText =
    Language: LanguageCode_ISO639_1;
    Text: MANDATORY TEXT;
  END LocalisedText;
  
  STRUCTURE LocalisedMText =
    Language: LanguageCode_ISO639_1;
    Text: MANDATORY MTEXT;
  END LocalisedMText;

  STRUCTURE MultilingualText =
    LocalisedText : BAG {1..*} OF LocalisedText;
    UNIQUE (LOCAL) LocalisedText:Language;
  END MultilingualText;  
  
  STRUCTURE MultilingualMText =
    LocalisedText : BAG {1..*} OF LocalisedMText;
    UNIQUE (LOCAL) LocalisedText:Language;
  END MultilingualMText;

END Localisation_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL LocalisationCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Localisation_V1;

  STRUCTURE LocalisedText EXTENDS Localisation_V1.LocalisedText =
  MANDATORY CONSTRAINT
    Language == #de OR
    Language == #fr OR
    Language == #it OR
    Language == #rm OR
    Language == #en;
  END LocalisedText;
  
  STRUCTURE LocalisedMText EXTENDS Localisation_V1.LocalisedMText =
  MANDATORY CONSTRAINT
    Language == #de OR
    Language == #fr OR
    Language == #it OR
    Language == #rm OR
    Language == #en;
  END LocalisedMText;

  STRUCTURE MultilingualText EXTENDS Localisation_V1.MultilingualText =
    LocalisedText(EXTENDED) : BAG {1..*} OF LocalisedText;
  END MultilingualText;  
  
  STRUCTURE MultilingualMText EXTENDS Localisation_V1.MultilingualMText =
    LocalisedText(EXTENDED) : BAG {1..*} OF LocalisedMText;
  END MultilingualMText;

END LocalisationCH_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL Dictionaries_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;

  TOPIC Dictionaries (ABSTRACT) =

    STRUCTURE Entry (ABSTRACT) =
      Text: MANDATORY TEXT;
    END Entry;
      
    CLASS Dictionary =
      Language: MANDATORY LanguageCode_ISO639_1;
      Entries: LIST OF Entry;
    END Dictionary;

  END Dictionaries;

END Dictionaries_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL DictionariesCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Dictionaries_V1;

  TOPIC Dictionaries (ABSTRACT) EXTENDS Dictionaries_V1.Dictionaries =

    CLASS Dictionary (EXTENDED) =
    MANDATORY CONSTRAINT
      Language == #de OR
      Language == #fr OR
      Language == #it OR
      Language == #rm OR
      Language == #en;
    END Dictionary;

  END Dictionaries;

END DictionariesCH_V1.

!! ########################################################################
','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CoordSys-20151124.ili','2.3','CoordSys','!! File CoordSys.ili Release 2015-11-24

INTERLIS 2.3;

!! 2015-11-24 Cardinalities adapted (line 122, 123, 124, 132, 133, 134, 142, 143,
!!                                   148, 149, 163, 164, 168, 169, 206 and 207)
!!@precursorVersion = 2005-06-16

REFSYSTEM MODEL CoordSys (en) AT "http://www.interlis.ch/models"
  VERSION "2015-11-24" =

  UNIT
    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

  STRUCTURE Angle_DMS_S =
    Degrees: -180 .. 180 CIRCULAR [Angle_Degree];
    CONTINUOUS SUBDIVISION Minutes: 0 .. 59 CIRCULAR [Angle_Minute];
    CONTINUOUS SUBDIVISION Seconds: 0.000 .. 59.999 CIRCULAR [Angle_Second];
  END Angle_DMS_S;

  DOMAIN
    Angle_DMS = FORMAT BASED ON Angle_DMS_S (Degrees ":" Minutes ":" Seconds);
    Angle_DMS_90 EXTENDS Angle_DMS = "-90:00:00.000" .. "90:00:00.000";


  TOPIC CoordsysTopic =

    !! Special space aspects to be referenced
    !! **************************************

    CLASS Ellipsoid EXTENDS INTERLIS.REFSYSTEM =
      EllipsoidAlias: TEXT*70;
      SemiMajorAxis: MANDATORY 6360000.0000 .. 6390000.0000 [INTERLIS.m];
      InverseFlattening: MANDATORY 0.00000000 .. 350.00000000;
      !! The inverse flattening 0 characterizes the 2-dim sphere
      Remarks: TEXT*70;
    END Ellipsoid;

    CLASS GravityModel EXTENDS INTERLIS.REFSYSTEM =
      GravityModAlias: TEXT*70;
      Definition: TEXT*70;
    END GravityModel;

    CLASS GeoidModel EXTENDS INTERLIS.REFSYSTEM =
      GeoidModAlias: TEXT*70;
      Definition: TEXT*70;
    END GeoidModel;


    !! Coordinate systems for geodetic purposes
    !! ****************************************

    STRUCTURE LengthAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.LENGTH];
    END LengthAXIS;

    STRUCTURE AngleAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.ANGLE];
    END AngleAXIS;

    CLASS GeoCartesian1D EXTENDS INTERLIS.COORDSYSTEM =
      Axis (EXTENDED): LIST {1} OF LengthAXIS;
    END GeoCartesian1D;

    CLASS GeoHeight EXTENDS GeoCartesian1D =
      System: MANDATORY (
        normal,
        orthometric,
        ellipsoidal,
        other);
      ReferenceHeight: MANDATORY -10000.000 .. +10000.000 [INTERLIS.m];
      ReferenceHeightDescr: TEXT*70;
    END GeoHeight;

    ASSOCIATION HeightEllips =
      GeoHeightRef -- {*} GeoHeight;
      EllipsoidRef -- {1} Ellipsoid;
    END HeightEllips;

    ASSOCIATION HeightGravit =
      GeoHeightRef -- {*} GeoHeight;
      GravityRef -- {1} GravityModel;
    END HeightGravit;

    ASSOCIATION HeightGeoid =
      GeoHeightRef -- {*} GeoHeight;
      GeoidRef -- {1} GeoidModel;
    END HeightGeoid;

    CLASS GeoCartesian2D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF LengthAXIS;
    END GeoCartesian2D;

    CLASS GeoCartesian3D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {3} OF LengthAXIS;
    END GeoCartesian3D;

    CLASS GeoEllipsoidal EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF AngleAXIS;
    END GeoEllipsoidal;

    ASSOCIATION EllCSEllips =
      GeoEllipsoidalRef -- {*} GeoEllipsoidal;
      EllipsoidRef -- {1} Ellipsoid;
    END EllCSEllips;


    !! Mappings between coordinate systems
    !! ***********************************

    ASSOCIATION ToGeoEllipsoidal =
      From -- {0..*} GeoCartesian3D;
      To -- {0..*} GeoEllipsoidal;
      ToHeight -- {0..*} GeoHeight;
    MANDATORY CONSTRAINT
      ToHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      To -> EllipsoidRef -> Name == ToHeight -> EllipsoidRef -> Name;
    END ToGeoEllipsoidal;

    ASSOCIATION ToGeoCartesian3D =
      From2 -- {0..*} GeoEllipsoidal;
      FromHeight-- {0..*} GeoHeight;
      To3 -- {0..*} GeoCartesian3D;
    MANDATORY CONSTRAINT
      FromHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      From2 -> EllipsoidRef -> Name == FromHeight -> EllipsoidRef -> Name;
    END ToGeoCartesian3D;

    ASSOCIATION BidirectGeoCartesian2D =
      From -- {0..*} GeoCartesian2D;
      To -- {0..*} GeoCartesian2D;
    END BidirectGeoCartesian2D;

    ASSOCIATION BidirectGeoCartesian3D =
      From -- {0..*} GeoCartesian3D;
      To2 -- {0..*} GeoCartesian3D;
      Precision: MANDATORY (
        exact,
        measure_based);
      ShiftAxis1: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis2: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis3: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      RotationAxis1: Angle_DMS_90;
      RotationAxis2: Angle_DMS_90;
      RotationAxis3: Angle_DMS_90;
      NewScale: 0.000001 .. 1000000.000000;
    END BidirectGeoCartesian3D;

    ASSOCIATION BidirectGeoEllipsoidal =
      From4 -- {0..*} GeoEllipsoidal;
      To4 -- {0..*} GeoEllipsoidal;
    END BidirectGeoEllipsoidal;

    ASSOCIATION MapProjection (ABSTRACT) =
      From5 -- {0..*} GeoEllipsoidal;
      To5 -- {0..*} GeoCartesian2D;
      FromCo1_FundPt: MANDATORY Angle_DMS_90;
      FromCo2_FundPt: MANDATORY Angle_DMS_90;
      ToCoord1_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
      ToCoord2_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
    END MapProjection;

    ASSOCIATION TransverseMercator EXTENDS MapProjection =
    END TransverseMercator;

    ASSOCIATION SwissProjection EXTENDS MapProjection =
      IntermFundP1: MANDATORY Angle_DMS_90;
      IntermFundP2: MANDATORY Angle_DMS_90;
    END SwissProjection;

    ASSOCIATION Mercator EXTENDS MapProjection =
    END Mercator;

    ASSOCIATION ObliqueMercator EXTENDS MapProjection =
    END ObliqueMercator;

    ASSOCIATION Lambert EXTENDS MapProjection =
    END Lambert;

    ASSOCIATION Polyconic EXTENDS MapProjection =
    END Polyconic;

    ASSOCIATION Albus EXTENDS MapProjection =
    END Albus;

    ASSOCIATION Azimutal EXTENDS MapProjection =
    END Azimutal;

    ASSOCIATION Stereographic EXTENDS MapProjection =
    END Stereographic;

    ASSOCIATION HeightConversion =
      FromHeight -- {0..*} GeoHeight;
      ToHeight -- {0..*} GeoHeight;
      Definition: TEXT*70;
    END HeightConversion;

  END CoordsysTopic;

END CoordSys.

','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part1_GEOMETRY_20110830.ili','2.3','GeometryCHLV03_V1{ CoordSys Units INTERLIS} GeometryCHLV95_V1{ CoordSys Units INTERLIS}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-0830
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART I -- GEOMETRY
   - Package GeometryCHLV03
   - Package GeometryCHLV95
*/

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 57, 58, 65 and 66)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 57 and 58)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 31, 44 and 50)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV03_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV03
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:21781
    Coord2 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:21781
    Coord3 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
        -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV03_V1.

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 135, 136, 143 and 144)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 135 and 136)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 109, 122 and 128)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV95_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV95
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:2056
    Coord2 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:2056
    Coord3 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
         -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV95_V1.

!! ########################################################################
','2019-06-09 17:29:21.966');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createMetaInfo','True');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.beautifyEnumDispName','underscore');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.arrayTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.nameOptimization','topic');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.numericCheckConstraints','create');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.sender','ili2pg-4.1.0-aa1d00a37ee431852bdee6b990f34b3620f9c1c1');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKey','yes');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.sqlgen.createGeomIndex','True');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsAuthority','EPSG');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsCode','2056');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uuidDefaultValue','uuid_generate_v4()');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.StrokeArcs','enable');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiLineTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.interlis.ili2c.ilidirs','%ILI_FROM_DB;%XTF_DIR;http://models.interlis.ch/;%JAR_DIR');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKeyIndex','yes');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.importTabs','simple');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createDatasetCols','addDatasetCol');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.jsonTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.BasketHandling','readWrite');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createEnumDefs','multiTable');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uniqueConstraints','create');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.maxSqlNameLength','60');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.inheritanceTrafo','smart1');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.catalogueRefTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiPointTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO arp_npl.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('Dictionaries_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('Dictionaries_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('DictionariesCH_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('DictionariesCH_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnits_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnits_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnitsCH_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnitsCH_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','furtherInformation','Arbeitshilfe');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','Issuer','http://arp.so.ch');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','Title','Nutzungsplanung');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','shortDescription','Nutzungsplanungsmodell des Kantons Solothurn. Umfasst;die im MGDM des Bundes definierten Informationen (GeoIV_ID: 73, 145, 157, 159);sowie Erweiterungen des Kt. Solothurn');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','File','SO_Nutzungsplanung_20171118.ili');
INSERT INTO arp_npl.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_Nutzungsplanung_20171118','technicalContact','http://agi.so.ch');
CREATE SCHEMA IF NOT EXISTS arp_npl_oereb;
CREATE SEQUENCE arp_npl_oereb.t_ili2db_seq MINVALUE 1000000000000;;
-- Localisation_V1.LocalisedText
CREATE TABLE arp_npl_oereb.localisedtext (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Type varchar(60) NOT NULL
  ,T_Seq bigint NULL
  ,alanguage varchar(255) NULL
  ,atext text NOT NULL
  ,multilingualtext_localisedtext bigint NULL
)
;
CREATE INDEX localisedtext_t_basket_idx ON arp_npl_oereb.localisedtext ( t_basket );
CREATE INDEX localisedtext_t_datasetname_idx ON arp_npl_oereb.localisedtext ( t_datasetname );
CREATE INDEX localisedtext_multilingualtext_lclsdtext_idx ON arp_npl_oereb.localisedtext ( multilingualtext_localisedtext );
-- Localisation_V1.LocalisedMText
CREATE TABLE arp_npl_oereb.localisedmtext (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Type varchar(60) NOT NULL
  ,T_Seq bigint NULL
  ,alanguage varchar(255) NULL
  ,atext text NOT NULL
  ,multilingualmtext_localisedtext bigint NULL
)
;
CREATE INDEX localisedmtext_t_basket_idx ON arp_npl_oereb.localisedmtext ( t_basket );
CREATE INDEX localisedmtext_t_datasetname_idx ON arp_npl_oereb.localisedmtext ( t_datasetname );
CREATE INDEX localisedmtext_multilingualmtxt_lclsdtext_idx ON arp_npl_oereb.localisedmtext ( multilingualmtext_localisedtext );
-- Localisation_V1.MultilingualText
CREATE TABLE arp_npl_oereb.multilingualtext (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Type varchar(60) NOT NULL
  ,T_Seq bigint NULL
)
;
CREATE INDEX multilingualtext_t_basket_idx ON arp_npl_oereb.multilingualtext ( t_basket );
CREATE INDEX multilingualtext_t_datasetname_idx ON arp_npl_oereb.multilingualtext ( t_datasetname );
-- Localisation_V1.MultilingualMText
CREATE TABLE arp_npl_oereb.multilingualmtext (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Type varchar(60) NOT NULL
  ,T_Seq bigint NULL
)
;
CREATE INDEX multilingualmtext_t_basket_idx ON arp_npl_oereb.multilingualmtext ( t_basket );
CREATE INDEX multilingualmtext_t_datasetname_idx ON arp_npl_oereb.multilingualmtext ( t_datasetname );
-- OeREBKRM_V1_1.ArtikelNummer_
CREATE TABLE arp_npl_oereb.artikelnummer_ (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Seq bigint NULL
  ,avalue varchar(20) NOT NULL
  ,vorschrftn_wswtrdkmnte_artikelnr bigint NULL
  ,transfrstrkwsvrschrift_artikelnr bigint NULL
)
;
CREATE INDEX artikelnummer__t_basket_idx ON arp_npl_oereb.artikelnummer_ ( t_basket );
CREATE INDEX artikelnummer__t_datasetname_idx ON arp_npl_oereb.artikelnummer_ ( t_datasetname );
CREATE INDEX artikelnummer__vorschrftn_wsrdkmnt_rtklnr_idx ON arp_npl_oereb.artikelnummer_ ( vorschrftn_wswtrdkmnte_artikelnr );
CREATE INDEX artikelnummer__transfrstrkwsschrft_rtklnr_idx ON arp_npl_oereb.artikelnummer_ ( transfrstrkwsvrschrift_artikelnr );
COMMENT ON COLUMN arp_npl_oereb.artikelnummer_.vorschrftn_wswtrdkmnte_artikelnr IS 'Hinweis auf spezifische Artikel.';
COMMENT ON COLUMN arp_npl_oereb.artikelnummer_.transfrstrkwsvrschrift_artikelnr IS 'Hinweis auf spezifische Artikel.';
-- OeREBKRM_V1_1.LocalisedUri
CREATE TABLE arp_npl_oereb.localiseduri (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Seq bigint NULL
  ,alanguage varchar(255) NULL
  ,atext varchar(1023) NOT NULL
  ,multilingualuri_localisedtext bigint NULL
)
;
CREATE INDEX localiseduri_t_basket_idx ON arp_npl_oereb.localiseduri ( t_basket );
CREATE INDEX localiseduri_t_datasetname_idx ON arp_npl_oereb.localiseduri ( t_datasetname );
CREATE INDEX localiseduri_multilingualuri_loclsdtext_idx ON arp_npl_oereb.localiseduri ( multilingualuri_localisedtext );
-- OeREBKRM_V1_1.MultilingualUri
CREATE TABLE arp_npl_oereb.multilingualuri (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Seq bigint NULL
  ,vorschriften_artikel_textimweb bigint NULL
  ,vorschriften_dokument_textimweb bigint NULL
)
;
CREATE INDEX multilingualuri_t_basket_idx ON arp_npl_oereb.multilingualuri ( t_basket );
CREATE INDEX multilingualuri_t_datasetname_idx ON arp_npl_oereb.multilingualuri ( t_datasetname );
CREATE INDEX multilingualuri_vorschriften_artkl_txtmweb_idx ON arp_npl_oereb.multilingualuri ( vorschriften_artikel_textimweb );
CREATE INDEX multilingualuri_vorschriften_dkmnt_txtmweb_idx ON arp_npl_oereb.multilingualuri ( vorschriften_dokument_textimweb );
COMMENT ON COLUMN arp_npl_oereb.multilingualuri.vorschriften_artikel_textimweb IS 'Verweis auf das Element im Web; z.B. "http://www.admin.ch/ch/d/sr/700/a18.html"';
COMMENT ON COLUMN arp_npl_oereb.multilingualuri.vorschriften_dokument_textimweb IS 'Verweis auf das Element im Web; z.B. "http://www.admin.ch/ch/d/sr/700/a18.html"';
-- OeREBKRMvs_V1_1.Vorschriften.Amt
CREATE TABLE arp_npl_oereb.vorschriften_amt (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,aname text NULL
  ,aname_de text NULL
  ,aname_fr text NULL
  ,aname_rm text NULL
  ,aname_it text NULL
  ,aname_en text NULL
  ,amtimweb varchar(1023) NULL
  ,auid varchar(12) NULL
)
;
CREATE INDEX vorschriften_amt_t_basket_idx ON arp_npl_oereb.vorschriften_amt ( t_basket );
CREATE INDEX vorschriften_amt_t_datasetname_idx ON arp_npl_oereb.vorschriften_amt ( t_datasetname );
COMMENT ON TABLE arp_npl_oereb.vorschriften_amt IS 'Eine organisatorische Einheit innerhalb der öffentlichen Verwaltung, z.B. eine für Geobasisdaten zuständige Stelle.';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_amt.amtimweb IS 'Verweis auf die Website des Amtes z.B. "http://www.jgk.be.ch/jgk/de/index/direktion/organisation/agr.html".';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_amt.auid IS 'UID der organisatorischen Einheit';
-- OeREBKRMvs_V1_1.Vorschriften.Artikel
CREATE TABLE arp_npl_oereb.vorschriften_artikel (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,nr varchar(20) NOT NULL
  ,atext text NULL
  ,atext_de text NULL
  ,atext_fr text NULL
  ,atext_rm text NULL
  ,atext_it text NULL
  ,atext_en text NULL
  ,dokument bigint NOT NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
)
;
CREATE INDEX vorschriften_artikel_t_basket_idx ON arp_npl_oereb.vorschriften_artikel ( t_basket );
CREATE INDEX vorschriften_artikel_t_datasetname_idx ON arp_npl_oereb.vorschriften_artikel ( t_datasetname );
CREATE INDEX vorschriften_artikel_dokument_idx ON arp_npl_oereb.vorschriften_artikel ( dokument );
COMMENT ON TABLE arp_npl_oereb.vorschriften_artikel IS 'Einzelner Artikel einer Rechtsvorschrift oder einer gesetzlichen Grundlage.';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_artikel.nr IS 'Nummer des Artikels innerhalb der gesetzlichen Grundlage oder der Rechtsvorschrift. z.B. "23"';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_artikel.rechtsstatus IS 'Status, ob dieses Element in Kraft ist';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_artikel.publiziertab IS 'Datum, ab dem dieses Element in Auszügen erscheint';
-- OeREBKRMvs_V1_1.Vorschriften.Dokument
CREATE TABLE arp_npl_oereb.vorschriften_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Type varchar(60) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,titel text NULL
  ,titel_de text NULL
  ,titel_fr text NULL
  ,titel_rm text NULL
  ,titel_it text NULL
  ,titel_en text NULL
  ,offiziellertitel text NULL
  ,offiziellertitel_de text NULL
  ,offiziellertitel_fr text NULL
  ,offiziellertitel_rm text NULL
  ,offiziellertitel_it text NULL
  ,offiziellertitel_en text NULL
  ,abkuerzung text NULL
  ,abkuerzung_de text NULL
  ,abkuerzung_fr text NULL
  ,abkuerzung_rm text NULL
  ,abkuerzung_it text NULL
  ,abkuerzung_en text NULL
  ,offiziellenr varchar(20) NULL
  ,kanton varchar(255) NULL
  ,gemeinde integer NULL
  ,dokument bytea NULL
  ,zustaendigestelle bigint NOT NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
)
;
CREATE INDEX vorschriften_dokument_t_basket_idx ON arp_npl_oereb.vorschriften_dokument ( t_basket );
CREATE INDEX vorschriften_dokument_t_datasetname_idx ON arp_npl_oereb.vorschriften_dokument ( t_datasetname );
CREATE INDEX vorschriften_dokument_zustaendigestelle_idx ON arp_npl_oereb.vorschriften_dokument ( zustaendigestelle );
COMMENT ON TABLE arp_npl_oereb.vorschriften_dokument IS 'Dokumente im allgemeinen (Gesetze, Verordnungen, Rechtsvorschriften)';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.offiziellenr IS 'Offizielle Nummer des Gesetzes; z.B. "SR 700"';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.kanton IS 'Kantonskürzel falls Vorschrift des Kantons oder der Gemeinde. Falls die Angabe fehlt, ist es eine Vorschrift des Bundes. z.B. "BE"';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.gemeinde IS 'Falls die Angabe fehlt, ist es ein Erlass des Kantons oder des Bundes. z.B. "942"';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.dokument IS 'Das Dokument als PDF-Datei';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.rechtsstatus IS 'Status, ob dieses Element in Kraft ist';
COMMENT ON COLUMN arp_npl_oereb.vorschriften_dokument.publiziertab IS 'Datum, ab dem dieses Element in Auszügen erscheint';
-- OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente
CREATE TABLE arp_npl_oereb.vorschriften_hinweisweiteredokumente (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,ursprung bigint NOT NULL
  ,hinweis bigint NOT NULL
)
;
CREATE INDEX vorschriften_hnwswtrdkmnte_t_basket_idx ON arp_npl_oereb.vorschriften_hinweisweiteredokumente ( t_basket );
CREATE INDEX vorschriften_hnwswtrdkmnte_t_datasetname_idx ON arp_npl_oereb.vorschriften_hinweisweiteredokumente ( t_datasetname );
CREATE INDEX vorschriften_hnwswtrdkmnte_ursprung_idx ON arp_npl_oereb.vorschriften_hinweisweiteredokumente ( ursprung );
CREATE INDEX vorschriften_hnwswtrdkmnte_hinweis_idx ON arp_npl_oereb.vorschriften_hinweisweiteredokumente ( hinweis );
-- OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung
CREATE TABLE arp_npl_oereb.transferstruktur_eigentumsbeschraenkung (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,aussage text NULL
  ,aussage_de text NULL
  ,aussage_fr text NULL
  ,aussage_rm text NULL
  ,aussage_it text NULL
  ,aussage_en text NULL
  ,thema varchar(255) NOT NULL
  ,subthema varchar(60) NULL
  ,weiteresthema varchar(120) NULL
  ,artcode varchar(40) NULL
  ,artcodeliste varchar(1023) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,darstellungsdienst bigint NULL
  ,zustaendigestelle bigint NOT NULL
)
;
CREATE INDEX transfrstrktrtmsbschrnkung_t_basket_idx ON arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ( t_basket );
CREATE INDEX transfrstrktrtmsbschrnkung_t_datasetname_idx ON arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ( t_datasetname );
CREATE INDEX transfrstrktrtmsbschrnkung_darstellungsdienst_idx ON arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ( darstellungsdienst );
CREATE INDEX transfrstrktrtmsbschrnkung_zustaendigestelle_idx ON arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ( zustaendigestelle );
COMMENT ON TABLE arp_npl_oereb.transferstruktur_eigentumsbeschraenkung IS 'Wurzelelement für Informationen über eine Beschränkung des Grundeigentums, die rechtskräftig, z.B. auf Grund einer Genehmigung oder eines richterlichen Entscheids, zustande gekommen ist.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.thema IS 'Einordnung der Eigentumsbeschränkung in ein ÖREBK-Thema';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.subthema IS 'z.B. Planungszonen innerhalb Nutzungsplanung';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.weiteresthema IS 'z.B. kantonale Themen. Der Code wird nach folgendem Muster gebildet: ch.{canton}.{topic}
fl.{topic}
ch.{bfsnr}.{topic}
Wobei {canton} das offizielle zwei-stellige Kürzel des Kantons ist, {to-pic} der Themenname und {bfsnr} die Gemeindenummer gem. BFS.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.artcode IS 'Themenspezifische, maschinen-lesbare Art gem. Originalmodell der Eigentumsbeschränkung';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.artcodeliste IS 'Identifikation der Codeliste bzw. des Wertebereichs für ArtCode';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.rechtsstatus IS 'Status, ob diese Eigentumsbeschränkung in Kraft ist';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.publiziertab IS 'Datum, ab dem diese Eigentumsbeschränkung in Auszügen erscheint';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.darstellungsdienst IS 'Darstellungsdienst, auf dem diese Eigentumsbeschränkung sichtbar, aber nicht hervorgehoben, ist.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung.zustaendigestelle IS 'Zuständige Stelle für die Geobasisdaten (Originaldaten) gem. GeoIG Art. 8 Abs. 1';
-- OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie
CREATE TABLE arp_npl_oereb.transferstruktur_geometrie (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,punkt_lv03 geometry(POINT,21781) NULL
  ,punkt_lv95 geometry(POINT,2056) NULL
  ,linie_lv03 geometry(LINESTRING,21781) NULL
  ,linie_lv95 geometry(LINESTRING,2056) NULL
  ,flaeche_lv03 geometry(POLYGON,21781) NULL
  ,flaeche_lv95 geometry(POLYGON,2056) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziertab date NOT NULL
  ,metadatengeobasisdaten varchar(1023) NULL
  ,eigentumsbeschraenkung bigint NOT NULL
  ,zustaendigestelle bigint NOT NULL
)
;
CREATE INDEX transferstruktur_geometrie_t_basket_idx ON arp_npl_oereb.transferstruktur_geometrie ( t_basket );
CREATE INDEX transferstruktur_geometrie_t_datasetname_idx ON arp_npl_oereb.transferstruktur_geometrie ( t_datasetname );
CREATE INDEX transferstruktur_geometrie_punkt_lv03_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( punkt_lv03 );
CREATE INDEX transferstruktur_geometrie_punkt_lv95_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( punkt_lv95 );
CREATE INDEX transferstruktur_geometrie_linie_lv03_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( linie_lv03 );
CREATE INDEX transferstruktur_geometrie_linie_lv95_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( linie_lv95 );
CREATE INDEX transferstruktur_geometrie_flaeche_lv03_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( flaeche_lv03 );
CREATE INDEX transferstruktur_geometrie_flaeche_lv95_idx ON arp_npl_oereb.transferstruktur_geometrie USING GIST ( flaeche_lv95 );
CREATE INDEX transferstruktur_geometrie_eigentumsbeschraenkung_idx ON arp_npl_oereb.transferstruktur_geometrie ( eigentumsbeschraenkung );
CREATE INDEX transferstruktur_geometrie_zustaendigestelle_idx ON arp_npl_oereb.transferstruktur_geometrie ( zustaendigestelle );
COMMENT ON TABLE arp_npl_oereb.transferstruktur_geometrie IS 'Punkt-, linien-, oder flächenförmige Geometrie. Neu zu definierende Eigentumsbeschränkungen sollten i.d.R. flächenförmig sein.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.punkt_lv03 IS 'Punktgeometrie';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.linie_lv03 IS 'Linienförmige Geometrie';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.flaeche_lv03 IS 'Flächenförmige Geometrie';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.rechtsstatus IS 'Status, ob diese Geometrie in Kraft ist';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.publiziertab IS 'Datum, ab dem diese Geometrie in Auszügen erscheint';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_geometrie.metadatengeobasisdaten IS 'Verweis auf maschinenlesbare Metadaten (XML) der zugrundeliegenden Geobasisdaten. z.B. http://www.geocat.ch/geonetwork/srv/deu/gm03.xml?id=705';
-- OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition
CREATE TABLE arp_npl_oereb.transferstruktur_hinweisdefinition (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,thema varchar(255) NULL
  ,kanton varchar(255) NULL
  ,gemeinde integer NULL
  ,zustaendigestelle bigint NOT NULL
)
;
CREATE INDEX transferstrktr_hnwsdfntion_t_basket_idx ON arp_npl_oereb.transferstruktur_hinweisdefinition ( t_basket );
CREATE INDEX transferstrktr_hnwsdfntion_t_datasetname_idx ON arp_npl_oereb.transferstruktur_hinweisdefinition ( t_datasetname );
CREATE INDEX transferstrktr_hnwsdfntion_zustaendigestelle_idx ON arp_npl_oereb.transferstruktur_hinweisdefinition ( zustaendigestelle );
COMMENT ON TABLE arp_npl_oereb.transferstruktur_hinweisdefinition IS 'Definition für Hinweise, die unabhängig von einer konkreten Eigentumsbeschränkung gelten (z.B. der Hinweis auf eine Systematische Rechtssammlung). Der Hinweis kann aber beschränkt werden auf eine bestimmtes ÖREB-Thema und/oder Kanton und/oder Gemeinde.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_hinweisdefinition.thema IS 'Thema falls der Hinweis für ein bestimmtes ÖREB-Thema gilt. Falls die Angabe fehlt, ist es ein Hinweis der für alle ÖREB-Themen gilt.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_hinweisdefinition.kanton IS 'Kantonskürzel falls der Hinweis für ein Kantons-oder Gemeindegebiet gilt. Falls die Angabe fehlt, ist es ein Hinweis der für alle Kantone gilt. z.B. "BE".';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_hinweisdefinition.gemeinde IS 'BFSNr falls der Hinweis für ein Gemeindegebiet gilt. Falls die Angabe fehlt, ist es ein Hinweis der für den Kanton oder die Schweiz gilt. z.B. "942".';
-- OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag
CREATE TABLE arp_npl_oereb.transferstruktur_legendeeintrag (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,T_Seq bigint NULL
  ,symbol bytea NOT NULL
  ,legendetext text NULL
  ,legendetext_de text NULL
  ,legendetext_fr text NULL
  ,legendetext_rm text NULL
  ,legendetext_it text NULL
  ,legendetext_en text NULL
  ,artcode varchar(40) NOT NULL
  ,artcodeliste varchar(1023) NOT NULL
  ,thema varchar(255) NOT NULL
  ,subthema varchar(60) NULL
  ,weiteresthema varchar(120) NULL
  ,transfrstrkstllngsdnst_legende bigint NULL
)
;
CREATE INDEX transferstruktur_lgndntrag_t_basket_idx ON arp_npl_oereb.transferstruktur_legendeeintrag ( t_basket );
CREATE INDEX transferstruktur_lgndntrag_t_datasetname_idx ON arp_npl_oereb.transferstruktur_legendeeintrag ( t_datasetname );
CREATE INDEX transferstruktur_lgndntrag_transfrstrkstngsdnst_lgnde_idx ON arp_npl_oereb.transferstruktur_legendeeintrag ( transfrstrkstllngsdnst_legende );
COMMENT ON TABLE arp_npl_oereb.transferstruktur_legendeeintrag IS 'Ein Eintrag in der Planlegende.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_legendeeintrag.symbol IS 'Grafischer Teil des Legendeneintrages für die Darstellung. Im PNG-Format mit 300dpi oder im SVG-Format';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_legendeeintrag.artcode IS 'Art der Eigentumsbeschränkung, die durch diesen Legendeneintrag dargestellt wird';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_legendeeintrag.artcodeliste IS 'Codeliste der Eigentumsbeschränkung, die durch diesen Legendeneintrag dargestellt wird';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_legendeeintrag.thema IS 'Zu welchem ÖREB-Thema der Legendeneintrag gehört';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_legendeeintrag.subthema IS 'z.B. Planungszonen innerhalb Nutzungsplanung';
-- OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst
CREATE TABLE arp_npl_oereb.transferstruktur_darstellungsdienst (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,verweiswms varchar(1023) NOT NULL
  ,legendeimweb varchar(1023) NULL
)
;
CREATE INDEX transfrstrktrdrstllngsdnst_t_basket_idx ON arp_npl_oereb.transferstruktur_darstellungsdienst ( t_basket );
CREATE INDEX transfrstrktrdrstllngsdnst_t_datasetname_idx ON arp_npl_oereb.transferstruktur_darstellungsdienst ( t_datasetname );
COMMENT ON TABLE arp_npl_oereb.transferstruktur_darstellungsdienst IS 'Angaben zum Darstellungsdienst.';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_darstellungsdienst.verweiswms IS 'WMS GetMap-Request (für Maschine-Maschine-Kommunikation) inkl. alle benötigten Parameter, z.B. "https://wms.geo.admin.ch/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&STYLES=default&SRS=EPSG:21781&BBOX=475000,60000,845000,310000&WIDTH=740&HEIGHT=500&FORMAT=image/png&LAYERS=ch.bazl.kataster-belasteter-standorte-zivilflugplaetze.oereb"';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_darstellungsdienst.legendeimweb IS 'Verweis auf ein Dokument das die Karte beschreibt; z.B. "https://wms.geo.admin.ch/?SERVICE=WMS&REQUEST=GetLegendGraphic&VERSION=1.1.1&FORMAT=image/png&LAYER=ch.bazl.kataster-belasteter-standorte-zivilflugplaetze.oereb"';
-- OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung
CREATE TABLE arp_npl_oereb.transferstruktur_grundlageverfeinerung (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,grundlage bigint NOT NULL
  ,verfeinerung bigint NOT NULL
)
;
CREATE INDEX transfrstrktrrndlgvrfnrung_t_basket_idx ON arp_npl_oereb.transferstruktur_grundlageverfeinerung ( t_basket );
CREATE INDEX transfrstrktrrndlgvrfnrung_t_datasetname_idx ON arp_npl_oereb.transferstruktur_grundlageverfeinerung ( t_datasetname );
CREATE INDEX transfrstrktrrndlgvrfnrung_grundlage_idx ON arp_npl_oereb.transferstruktur_grundlageverfeinerung ( grundlage );
CREATE INDEX transfrstrktrrndlgvrfnrung_verfeinerung_idx ON arp_npl_oereb.transferstruktur_grundlageverfeinerung ( verfeinerung );
-- OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument
CREATE TABLE arp_npl_oereb.transferstruktur_hinweisdefinitiondokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,hinweisdefinition bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX transfrstrktrwsdfntndkment_t_basket_idx ON arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ( t_basket );
CREATE INDEX transfrstrktrwsdfntndkment_t_datasetname_idx ON arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ( t_datasetname );
CREATE INDEX transfrstrktrwsdfntndkment_hinweisdefinition_idx ON arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ( hinweisdefinition );
CREATE INDEX transfrstrktrwsdfntndkment_dokument_idx ON arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ( dokument );
-- OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift
CREATE TABLE arp_npl_oereb.transferstruktur_hinweisvorschrift (
  T_Id bigint PRIMARY KEY DEFAULT nextval('arp_npl_oereb.t_ili2db_seq')
  ,T_basket bigint NOT NULL
  ,T_datasetname varchar(200) NOT NULL
  ,eigentumsbeschraenkung bigint NOT NULL
  ,vorschrift_vorschriften_artikel bigint NULL
  ,vorschrift_vorschriften_dokument bigint NULL
)
;
CREATE INDEX transfrstrktrhnwsvrschrift_t_basket_idx ON arp_npl_oereb.transferstruktur_hinweisvorschrift ( t_basket );
CREATE INDEX transfrstrktrhnwsvrschrift_t_datasetname_idx ON arp_npl_oereb.transferstruktur_hinweisvorschrift ( t_datasetname );
CREATE INDEX transfrstrktrhnwsvrschrift_eigentumsbeschraenkung_idx ON arp_npl_oereb.transferstruktur_hinweisvorschrift ( eigentumsbeschraenkung );
CREATE INDEX transfrstrktrhnwsvrschrift_vorschrift_vrschrftn_rtkel_idx ON arp_npl_oereb.transferstruktur_hinweisvorschrift ( vorschrift_vorschriften_artikel );
CREATE INDEX transfrstrktrhnwsvrschrift_vorschrft_vrschrftn_dkment_idx ON arp_npl_oereb.transferstruktur_hinweisvorschrift ( vorschrift_vorschriften_dokument );
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_hinweisvorschrift.vorschrift_vorschriften_artikel IS 'Rechtsvorschrift der Eigentumsbeschränkung';
COMMENT ON COLUMN arp_npl_oereb.transferstruktur_hinweisvorschrift.vorschrift_vorschriften_dokument IS 'Rechtsvorschrift der Eigentumsbeschränkung';
CREATE TABLE arp_npl_oereb.T_ILI2DB_BASKET (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NULL
  ,topic varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,attachmentKey varchar(200) NOT NULL
  ,domains varchar(1024) NULL
)
;
CREATE INDEX T_ILI2DB_BASKET_dataset_idx ON arp_npl_oereb.t_ili2db_basket ( dataset );
CREATE TABLE arp_npl_oereb.T_ILI2DB_DATASET (
  T_Id bigint PRIMARY KEY
  ,datasetName varchar(200) NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_IMPORT (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NOT NULL
  ,importDate timestamp NOT NULL
  ,importUser varchar(40) NOT NULL
  ,importFile varchar(200) NULL
)
;
CREATE INDEX T_ILI2DB_IMPORT_dataset_idx ON arp_npl_oereb.t_ili2db_import ( dataset );
CREATE TABLE arp_npl_oereb.T_ILI2DB_IMPORT_BASKET (
  T_Id bigint PRIMARY KEY
  ,importrun bigint NOT NULL
  ,basket bigint NOT NULL
  ,objectCount integer NULL
)
;
CREATE INDEX T_ILI2DB_IMPORT_BASKET_importrun_idx ON arp_npl_oereb.t_ili2db_import_basket ( importrun );
CREATE INDEX T_ILI2DB_IMPORT_BASKET_basket_idx ON arp_npl_oereb.t_ili2db_import_basket ( basket );
CREATE TABLE arp_npl_oereb.T_ILI2DB_INHERITANCE (
  thisClass varchar(1024) PRIMARY KEY
  ,baseClass varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_SETTINGS (
  tag varchar(60) PRIMARY KEY
  ,setting varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_TRAFO (
  iliname varchar(1024) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_MODEL (
  filename varchar(250) NOT NULL
  ,iliversion varchar(3) NOT NULL
  ,modelName text NOT NULL
  ,content text NOT NULL
  ,importDate timestamp NOT NULL
  ,PRIMARY KEY (modelName,iliversion)
)
;
CREATE TABLE arp_npl_oereb.thema (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.chcantoncode (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.rechtsstatus (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.languagecode_iso639_1 (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_CLASSNAME (
  IliName varchar(1024) PRIMARY KEY
  ,SqlName varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_ATTRNAME (
  IliName varchar(1024) NOT NULL
  ,SqlName varchar(1024) NOT NULL
  ,ColOwner varchar(1024) NOT NULL
  ,Target varchar(1024) NULL
  ,PRIMARY KEY (ColOwner,SqlName)
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_COLUMN_PROP (
  tablename varchar(255) NOT NULL
  ,subtype varchar(255) NULL
  ,columnname varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_TABLE_PROP (
  tablename varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE arp_npl_oereb.T_ILI2DB_META_ATTRS (
  ilielement varchar(255) NOT NULL
  ,attr_name varchar(1024) NOT NULL
  ,attr_value varchar(1024) NOT NULL
)
;
ALTER TABLE arp_npl_oereb.localisedtext ADD CONSTRAINT localisedtext_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.localisedtext ADD CONSTRAINT localisedtext_multilingualtext_lclsdtext_fkey FOREIGN KEY ( multilingualtext_localisedtext ) REFERENCES arp_npl_oereb.multilingualtext DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.localisedmtext ADD CONSTRAINT localisedmtext_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.localisedmtext ADD CONSTRAINT localisedmtext_multilingualmtxt_lclsdtext_fkey FOREIGN KEY ( multilingualmtext_localisedtext ) REFERENCES arp_npl_oereb.multilingualmtext DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.multilingualtext ADD CONSTRAINT multilingualtext_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.multilingualmtext ADD CONSTRAINT multilingualmtext_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.artikelnummer_ ADD CONSTRAINT artikelnummer__T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.artikelnummer_ ADD CONSTRAINT artikelnummer__vorschrftn_wsrdkmnt_rtklnr_fkey FOREIGN KEY ( vorschrftn_wswtrdkmnte_artikelnr ) REFERENCES arp_npl_oereb.vorschriften_hinweisweiteredokumente DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.artikelnummer_ ADD CONSTRAINT artikelnummer__transfrstrkwsschrft_rtklnr_fkey FOREIGN KEY ( transfrstrkwsvrschrift_artikelnr ) REFERENCES arp_npl_oereb.transferstruktur_hinweisvorschrift DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.localiseduri ADD CONSTRAINT localiseduri_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.localiseduri ADD CONSTRAINT localiseduri_multilingualuri_loclsdtext_fkey FOREIGN KEY ( multilingualuri_localisedtext ) REFERENCES arp_npl_oereb.multilingualuri DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.multilingualuri ADD CONSTRAINT multilingualuri_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.multilingualuri ADD CONSTRAINT multilingualuri_vorschriften_artkl_txtmweb_fkey FOREIGN KEY ( vorschriften_artikel_textimweb ) REFERENCES arp_npl_oereb.vorschriften_artikel DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.multilingualuri ADD CONSTRAINT multilingualuri_vorschriften_dkmnt_txtmweb_fkey FOREIGN KEY ( vorschriften_dokument_textimweb ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_amt ADD CONSTRAINT vorschriften_amt_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_artikel ADD CONSTRAINT vorschriften_artikel_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_artikel ADD CONSTRAINT vorschriften_artikel_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_dokument ADD CONSTRAINT vorschriften_dokument_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_dokument ADD CONSTRAINT vorschriften_dokument_gemeinde_check CHECK( gemeinde BETWEEN 1 AND 9999);
ALTER TABLE arp_npl_oereb.vorschriften_dokument ADD CONSTRAINT vorschriften_dokument_zustaendigestelle_fkey FOREIGN KEY ( zustaendigestelle ) REFERENCES arp_npl_oereb.vorschriften_amt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_hinweisweiteredokumente ADD CONSTRAINT vorschriften_hnwswtrdkmnte_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_hinweisweiteredokumente ADD CONSTRAINT vorschriften_hnwswtrdkmnte_ursprung_fkey FOREIGN KEY ( ursprung ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.vorschriften_hinweisweiteredokumente ADD CONSTRAINT vorschriften_hnwswtrdkmnte_hinweis_fkey FOREIGN KEY ( hinweis ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ADD CONSTRAINT transfrstrktrtmsbschrnkung_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ADD CONSTRAINT transfrstrktrtmsbschrnkung_darstellungsdienst_fkey FOREIGN KEY ( darstellungsdienst ) REFERENCES arp_npl_oereb.transferstruktur_darstellungsdienst DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_eigentumsbeschraenkung ADD CONSTRAINT transfrstrktrtmsbschrnkung_zustaendigestelle_fkey FOREIGN KEY ( zustaendigestelle ) REFERENCES arp_npl_oereb.vorschriften_amt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_geometrie ADD CONSTRAINT transferstruktur_geometrie_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_geometrie ADD CONSTRAINT transferstruktur_geometrie_eigentumsbeschraenkung_fkey FOREIGN KEY ( eigentumsbeschraenkung ) REFERENCES arp_npl_oereb.transferstruktur_eigentumsbeschraenkung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_geometrie ADD CONSTRAINT transferstruktur_geometrie_zustaendigestelle_fkey FOREIGN KEY ( zustaendigestelle ) REFERENCES arp_npl_oereb.vorschriften_amt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinition ADD CONSTRAINT transferstrktr_hnwsdfntion_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinition ADD CONSTRAINT transfrstrktr_hnwsdfntion_gemeinde_check CHECK( gemeinde BETWEEN 1 AND 9999);
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinition ADD CONSTRAINT transferstrktr_hnwsdfntion_zustaendigestelle_fkey FOREIGN KEY ( zustaendigestelle ) REFERENCES arp_npl_oereb.vorschriften_amt DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_legendeeintrag ADD CONSTRAINT transferstruktur_lgndntrag_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_legendeeintrag ADD CONSTRAINT transferstruktur_lgndntrag_transfrstrkstngsdnst_lgnde_fkey FOREIGN KEY ( transfrstrkstllngsdnst_legende ) REFERENCES arp_npl_oereb.transferstruktur_darstellungsdienst DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_darstellungsdienst ADD CONSTRAINT transfrstrktrdrstllngsdnst_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_grundlageverfeinerung ADD CONSTRAINT transfrstrktrrndlgvrfnrung_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_grundlageverfeinerung ADD CONSTRAINT transfrstrktrrndlgvrfnrung_grundlage_fkey FOREIGN KEY ( grundlage ) REFERENCES arp_npl_oereb.transferstruktur_eigentumsbeschraenkung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_grundlageverfeinerung ADD CONSTRAINT transfrstrktrrndlgvrfnrung_verfeinerung_fkey FOREIGN KEY ( verfeinerung ) REFERENCES arp_npl_oereb.transferstruktur_eigentumsbeschraenkung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ADD CONSTRAINT transfrstrktrwsdfntndkment_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ADD CONSTRAINT transfrstrktrwsdfntndkment_hinweisdefinition_fkey FOREIGN KEY ( hinweisdefinition ) REFERENCES arp_npl_oereb.transferstruktur_hinweisdefinition DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisdefinitiondokument ADD CONSTRAINT transfrstrktrwsdfntndkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisvorschrift ADD CONSTRAINT transfrstrktrhnwsvrschrift_T_basket_fkey FOREIGN KEY ( T_basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisvorschrift ADD CONSTRAINT transfrstrktrhnwsvrschrift_eigentumsbeschraenkung_fkey FOREIGN KEY ( eigentumsbeschraenkung ) REFERENCES arp_npl_oereb.transferstruktur_eigentumsbeschraenkung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisvorschrift ADD CONSTRAINT transfrstrktrhnwsvrschrift_vorschrift_vrschrftn_rtkel_fkey FOREIGN KEY ( vorschrift_vorschriften_artikel ) REFERENCES arp_npl_oereb.vorschriften_artikel DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.transferstruktur_hinweisvorschrift ADD CONSTRAINT transfrstrktrhnwsvrschrift_vorschrft_vrschrftn_dkment_fkey FOREIGN KEY ( vorschrift_vorschriften_dokument ) REFERENCES arp_npl_oereb.vorschriften_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.T_ILI2DB_BASKET ADD CONSTRAINT T_ILI2DB_BASKET_dataset_fkey FOREIGN KEY ( dataset ) REFERENCES arp_npl_oereb.T_ILI2DB_DATASET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_DATASET_datasetName_key ON arp_npl_oereb.T_ILI2DB_DATASET (datasetName)
;
ALTER TABLE arp_npl_oereb.T_ILI2DB_IMPORT_BASKET ADD CONSTRAINT T_ILI2DB_IMPORT_BASKET_importrun_fkey FOREIGN KEY ( importrun ) REFERENCES arp_npl_oereb.T_ILI2DB_IMPORT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE arp_npl_oereb.T_ILI2DB_IMPORT_BASKET ADD CONSTRAINT T_ILI2DB_IMPORT_BASKET_basket_fkey FOREIGN KEY ( basket ) REFERENCES arp_npl_oereb.T_ILI2DB_BASKET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_MODEL_modelName_iliversion_key ON arp_npl_oereb.T_ILI2DB_MODEL (modelName,iliversion)
;
CREATE UNIQUE INDEX T_ILI2DB_ATTRNAME_ColOwner_SqlName_key ON arp_npl_oereb.T_ILI2DB_ATTRNAME (ColOwner,SqlName)
;
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('Localisation_V1.MultilingualText','multilingualtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.ArtikelInhaltMehrsprachig','artikelinhaltmehrsprachig');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.ZustaendigeStelleDokument','vorschriften_zustaendigestelledokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleGeometrie','transferstruktur_zustaendigestellegeometrie');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('InternationalCodes_V1.LanguageCode_ISO639_1','languagecode_iso639_1');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst','transferstruktur_darstellungsdienst');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('LocalisationCH_V1.MultilingualMText','localisationch_v1_multilingualmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentArtikel','vorschriften_dokumentartikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleEigentumsbeschraenkung','transferstruktur_zustaendigestelleeigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('Localisation_V1.LocalisedText','localisedtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie','transferstruktur_geometrie');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente','vorschriften_hinweisweiteredokumente');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('Localisation_V1.LocalisedMText','localisedmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionZustaendigeStelle','transferstruktur_hinweisdefinitionzustaendigestelle');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel','vorschriften_artikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.RechtsStatus','rechtsstatus');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition','transferstruktur_hinweisdefinition');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.ArtikelNummer_','artikelnummer_');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung','transferstruktur_grundlageverfeinerung');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('LocalisationCH_V1.LocalisedMText','localisationch_v1_localisedmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.LocalisedUri','localiseduri');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Rechtsvorschrift','vorschriften_rechtsvorschrift');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument','transferstruktur_hinweisdefinitiondokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis','vorschriften_dokumentbasis');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.Thema','thema');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRM_V1_1.MultilingualUri','multilingualuri');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('LocalisationCH_V1.MultilingualText','localisationch_v1_multilingualtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('LocalisationCH_V1.LocalisedText','localisationch_v1_localisedtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienstEigentumsbeschraenkung','transferstruktur_darstellungsdiensteigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('Localisation_V1.MultilingualMText','multilingualmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag','transferstruktur_legendeeintrag');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('CHAdminCodes_V1.CHCantonCode','chcantoncode');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GeometrieEigentumsbeschraenkung','transferstruktur_geometrieeigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift','transferstruktur_hinweisvorschrift');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.TextImWeb','vorschriften_dokument_textimweb','multilingualuri','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.ZustaendigeStelleDokument.ZustaendigeStelle','zustaendigestelle','vorschriften_dokument','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Linie_LV03','linie_lv03','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.Thema','thema','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift.Eigentumsbeschraenkung','eigentumsbeschraenkung','transferstruktur_hinweisvorschrift','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt.UID','auid','vorschriften_amt',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.Aussage','aussage','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt.AmtImWeb','amtimweb','vorschriften_amt',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung.Verfeinerung','verfeinerung','transferstruktur_grundlageverfeinerung','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionZustaendigeStelle.ZustaendigeStelle','zustaendigestelle','transferstruktur_hinweisdefinition','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRM_V1_1.ArtikelNummer_.value','avalue','artikelnummer_',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.LegendeText','legendetext','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente.ArtikelNr','vorschrftn_wswtrdkmnte_artikelnr','artikelnummer_','vorschriften_hinweisweiteredokumente');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst.LegendeImWeb','legendeimweb','transferstruktur_darstellungsdienst',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.Rechtsstatus','rechtsstatus','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.ArtCodeliste','artcodeliste','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Titel','titel','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift.Vorschrift','vorschrift_vorschriften_artikel','transferstruktur_hinweisvorschrift','vorschriften_artikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.OffiziellerTitel','offiziellertitel','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument.HinweisDefinition','hinweisdefinition','transferstruktur_hinweisdefinitiondokument','transferstruktur_hinweisdefinition');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Gemeinde','gemeinde','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument.Dokument','dokument','transferstruktur_hinweisdefinitiondokument','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRM_V1_1.MultilingualUri.LocalisedText','multilingualuri_localisedtext','localiseduri','multilingualuri');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Punkt_LV03','punkt_lv03','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.publiziertAb','publiziertab','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift.Vorschrift','vorschrift_vorschriften_dokument','transferstruktur_hinweisvorschrift','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Abkuerzung','abkuerzung','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.ArtCode','artcode','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.LocalisedText.Text','atext','localisedtext',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleGeometrie.ZustaendigeStelle','zustaendigestelle','transferstruktur_geometrie','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRM_V1_1.LocalisedUri.Text','atext','localiseduri',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.publiziertAb','publiziertab','vorschriften_artikel',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst.VerweisWMS','verweiswms','transferstruktur_darstellungsdienst',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Flaeche_LV95','flaeche_lv95','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.MultilingualMText.LocalisedText','multilingualmtext_localisedtext','localisedmtext','multilingualmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Linie_LV95','linie_lv95','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.Rechtsstatus','rechtsstatus','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.WeiteresThema','weiteresthema','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GeometrieEigentumsbeschraenkung.Eigentumsbeschraenkung','eigentumsbeschraenkung','transferstruktur_geometrie','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.MultilingualText.LocalisedText','multilingualtext_localisedtext','localisedtext','multilingualtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.LocalisedMText.Language','alanguage','localisedmtext',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleEigentumsbeschraenkung.ZustaendigeStelle','zustaendigestelle','transferstruktur_eigentumsbeschraenkung','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Flaeche_LV03','flaeche_lv03','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst.Legende','transfrstrkstllngsdnst_legende','transferstruktur_legendeeintrag','transferstruktur_darstellungsdienst');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Punkt_LV95','punkt_lv95','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.ArtCode','artcode','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.SubThema','subthema','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift.ArtikelNr','transfrstrkwsvrschrift_artikelnr','artikelnummer_','transferstruktur_hinweisvorschrift');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.Rechtsstatus','rechtsstatus','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRM_V1_1.LocalisedUri.Language','alanguage','localiseduri',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.OffizielleNr','offiziellenr','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition.Gemeinde','gemeinde','transferstruktur_hinweisdefinition',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel.Nr','nr','vorschriften_artikel',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.Symbol','symbol','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.WeiteresThema','weiteresthema','transferstruktur_legendeeintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Dokument','dokument','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.ArtCodeliste','artcodeliste','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.publiziertAb','publiziertab','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.LocalisedMText.Text','atext','localisedmtext',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienstEigentumsbeschraenkung.DarstellungsDienst','darstellungsdienst','transferstruktur_eigentumsbeschraenkung','transferstruktur_darstellungsdienst');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt.Name','aname','vorschriften_amt',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.Rechtsstatus','rechtsstatus','vorschriften_artikel',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.Thema','thema','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel.Text','atext','vorschriften_artikel',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente.Hinweis','hinweis','vorschriften_hinweisweiteredokumente','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie.MetadatenGeobasisdaten','metadatengeobasisdaten','transferstruktur_geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition.Thema','thema','transferstruktur_hinweisdefinition',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.TextImWeb','vorschriften_artikel_textimweb','multilingualuri','vorschriften_artikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.SubThema','subthema','transferstruktur_eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentArtikel.Dokument','dokument','vorschriften_artikel','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition.Kanton','kanton','transferstruktur_hinweisdefinition',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente.Ursprung','ursprung','vorschriften_hinweisweiteredokumente','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Kanton','kanton','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis.publiziertAb','publiziertab','vorschriften_dokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('Localisation_V1.LocalisedText.Language','alanguage','localisedtext',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung.Grundlage','grundlage','transferstruktur_grundlageverfeinerung','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('Localisation_V1.MultilingualText','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRM_V1_1.ArtikelInhaltMehrsprachig','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.ZustaendigeStelleDokument','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleGeometrie','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('LocalisationCH_V1.MultilingualMText','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentArtikel','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleEigentumsbeschraenkung','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('Localisation_V1.LocalisedText','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('Localisation_V1.LocalisedMText','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionZustaendigeStelle','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRM_V1_1.ArtikelNummer_','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('LocalisationCH_V1.LocalisedMText','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRM_V1_1.LocalisedUri','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Rechtsvorschrift','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.OffiziellerTitel','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag.LegendeText','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis','ch.ehi.ili2db.inheritance','subClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt.Name','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRM_V1_1.MultilingualUri','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung.Aussage','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('LocalisationCH_V1.MultilingualText','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('LocalisationCH_V1.LocalisedText','ch.ehi.ili2db.inheritance','superClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Titel','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienstEigentumsbeschraenkung','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('Localisation_V1.MultilingualMText','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GeometrieEigentumsbeschraenkung','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel.Text','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument.Abkuerzung','ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('LocalisationCH_V1.MultilingualText','Localisation_V1.MultilingualText');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.HinweisWeitereDokumente',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleGeometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('Localisation_V1.LocalisedMText',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.LegendeEintrag',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienstEigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentBasis',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Geometrie',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRM_V1_1.ArtikelNummer_',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRM_V1_1.LocalisedUri',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.ZustaendigeStelleEigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.DarstellungsDienst',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('LocalisationCH_V1.LocalisedText','Localisation_V1.LocalisedText');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('Localisation_V1.MultilingualText',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinition',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Rechtsvorschrift','OeREBKRMvs_V1_1.Vorschriften.Dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisVorschrift',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Dokument','OeREBKRMvs_V1_1.Vorschriften.DokumentBasis');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GeometrieEigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRM_V1_1.ArtikelInhaltMehrsprachig','LocalisationCH_V1.MultilingualMText');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.ZustaendigeStelleDokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.DokumentArtikel',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.GrundlageVerfeinerung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionDokument',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('Localisation_V1.LocalisedText',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRM_V1_1.MultilingualUri',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Artikel','OeREBKRMvs_V1_1.Vorschriften.DokumentBasis');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('LocalisationCH_V1.MultilingualMText','Localisation_V1.MultilingualMText');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.Eigentumsbeschraenkung',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMtrsfr_V1_1.Transferstruktur.HinweisDefinitionZustaendigeStelle',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('Localisation_V1.MultilingualMText',NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('LocalisationCH_V1.LocalisedMText','Localisation_V1.LocalisedMText');
INSERT INTO arp_npl_oereb.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('OeREBKRMvs_V1_1.Vorschriften.Amt',NULL);
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Nutzungsplanung',0,'Nutzungsplanung',FALSE,'GeoIV Datensatz 73');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ProjektierungszonenNationalstrassen',1,'ProjektierungszonenNationalstrassen',FALSE,'87');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BaulinienNationalstrassen',2,'BaulinienNationalstrassen',FALSE,'88');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ProjektierungszonenEisenbahnanlagen',3,'ProjektierungszonenEisenbahnanlagen',FALSE,'96');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BaulinienEisenbahnanlagen',4,'BaulinienEisenbahnanlagen',FALSE,'97');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ProjektierungszonenFlughafenanlagen',5,'ProjektierungszonenFlughafenanlagen',FALSE,'103');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BaulinienFlughafenanlagen',6,'BaulinienFlughafenanlagen',FALSE,'104');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SicherheitszonenplanFlughafen',7,'SicherheitszonenplanFlughafen',FALSE,'108');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BelasteteStandorte',8,'BelasteteStandorte',FALSE,'116');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BelasteteStandorteMilitaer',9,'BelasteteStandorteMilitaer',FALSE,'117');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BelasteteStandorteZivileFlugplaetze',10,'BelasteteStandorteZivileFlugplaetze',FALSE,'118');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BelasteteStandorteOeffentlicherVerkehr',11,'BelasteteStandorteOeffentlicherVerkehr',FALSE,'119');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Grundwasserschutzzonen',12,'Grundwasserschutzzonen',FALSE,'131');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Grundwasserschutzareale',13,'Grundwasserschutzareale',FALSE,'132');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Laermemfindlichkeitsstufen',14,'Laermemfindlichkeitsstufen',FALSE,'145');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Waldgrenzen',15,'Waldgrenzen',FALSE,'157');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Waldabstandslinien',16,'Waldabstandslinien',FALSE,'159');
INSERT INTO arp_npl_oereb.thema (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'WeiteresThema',17,'WeiteresThema',FALSE,'Fuer weitere Themen');
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ZH',0,'ZH',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BE',1,'BE',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'LU',2,'LU',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'UR',3,'UR',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SZ',4,'SZ',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'OW',5,'OW',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'NW',6,'NW',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GL',7,'GL',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ZG',8,'ZG',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'FR',9,'FR',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SO',10,'SO',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BS',11,'BS',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'BL',12,'BL',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SH',13,'SH',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AR',14,'AR',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AI',15,'AI',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'SG',16,'SG',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GR',17,'GR',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'AG',18,'AG',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'TG',19,'TG',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'TI',20,'TI',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'VD',21,'VD',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'VS',22,'VS',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'NE',23,'NE',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'GE',24,'GE',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'JU',25,'JU',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'FL',26,'FL',FALSE,NULL);
INSERT INTO arp_npl_oereb.chcantoncode (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'CH',27,'CH',FALSE,NULL);
INSERT INTO arp_npl_oereb.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'inKraft',0,'inKraft',FALSE,'Die Eigentumsbeschränkung ist in Kraft.');
INSERT INTO arp_npl_oereb.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'laufendeAenderung',1,'laufendeAenderung',FALSE,'gem. OeREBKV Art. 12 Abs. 2');
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'de',0,'de',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fr',1,'fr',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'it',2,'it',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'rm',3,'rm',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'en',4,'en',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'aa',5,'aa',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ab',6,'ab',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'af',7,'af',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'am',8,'am',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ar',9,'ar',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'as',10,'as',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ay',11,'ay',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'az',12,'az',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ba',13,'ba',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'be',14,'be',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bg',15,'bg',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bh',16,'bh',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bi',17,'bi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bn',18,'bn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bo',19,'bo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'br',20,'br',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ca',21,'ca',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'co',22,'co',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'cs',23,'cs',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'cy',24,'cy',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'da',25,'da',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'dz',26,'dz',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'el',27,'el',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'eo',28,'eo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'es',29,'es',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'et',30,'et',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'eu',31,'eu',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fa',32,'fa',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fi',33,'fi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fj',34,'fj',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fo',35,'fo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'fy',36,'fy',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ga',37,'ga',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gd',38,'gd',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gl',39,'gl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gn',40,'gn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gu',41,'gu',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ha',42,'ha',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'he',43,'he',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'hi',44,'hi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'hr',45,'hr',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'hu',46,'hu',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'hy',47,'hy',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ia',48,'ia',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'id',49,'id',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ie',50,'ie',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ik',51,'ik',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'is',52,'is',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'iu',53,'iu',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ja',54,'ja',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'jw',55,'jw',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ka',56,'ka',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'kk',57,'kk',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'kl',58,'kl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'km',59,'km',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'kn',60,'kn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ko',61,'ko',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ks',62,'ks',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ku',63,'ku',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ky',64,'ky',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'la',65,'la',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ln',66,'ln',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'lo',67,'lo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'lt',68,'lt',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'lv',69,'lv',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mg',70,'mg',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mi',71,'mi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mk',72,'mk',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ml',73,'ml',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mn',74,'mn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mo',75,'mo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mr',76,'mr',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ms',77,'ms',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mt',78,'mt',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'my',79,'my',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'na',80,'na',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ne',81,'ne',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'nl',82,'nl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'no',83,'no',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'oc',84,'oc',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'om',85,'om',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'or',86,'or',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'pa',87,'pa',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'pl',88,'pl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ps',89,'ps',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'pt',90,'pt',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'qu',91,'qu',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'rn',92,'rn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ro',93,'ro',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ru',94,'ru',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'rw',95,'rw',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sa',96,'sa',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sd',97,'sd',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sg',98,'sg',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sh',99,'sh',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'si',100,'si',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sk',101,'sk',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sl',102,'sl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sm',103,'sm',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sn',104,'sn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'so',105,'so',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sq',106,'sq',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sr',107,'sr',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ss',108,'ss',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'st',109,'st',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'su',110,'su',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sv',111,'sv',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sw',112,'sw',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ta',113,'ta',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'te',114,'te',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tg',115,'tg',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'th',116,'th',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ti',117,'ti',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tk',118,'tk',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tl',119,'tl',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tn',120,'tn',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'to',121,'to',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tr',122,'tr',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ts',123,'ts',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tt',124,'tt',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tw',125,'tw',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ug',126,'ug',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'uk',127,'uk',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'ur',128,'ur',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'uz',129,'uz',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'vi',130,'vi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'vo',131,'vo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'wo',132,'wo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'xh',133,'xh',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'yi',134,'yi',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'yo',135,'yo',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'za',136,'za',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'zh',137,'zh',FALSE,NULL);
INSERT INTO arp_npl_oereb.languagecode_iso639_1 (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'zu',138,'zu',FALSE,NULL);
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('vorschriften_hinweisweiteredokumente',NULL,'hinweis','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisvorschrift',NULL,'vorschrift_vorschriften_dokument','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.c1Max','870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localisedtext',NULL,'multilingualtext_localisedtext','ch.ehi.ili2db.foreignKey','multilingualtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('artikelnummer_',NULL,'transfrstrkwsvrschrift_artikelnr','ch.ehi.ili2db.foreignKey','transferstruktur_hinweisvorschrift');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('vorschriften_dokument',NULL,'zustaendigestelle','ch.ehi.ili2db.foreignKey','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisdefinition',NULL,'zustaendigestelle','ch.ehi.ili2db.foreignKey','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.c1Max','870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('vorschriften_artikel',NULL,'dokument','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_eigentumsbeschraenkung',NULL,'darstellungsdienst','ch.ehi.ili2db.foreignKey','transferstruktur_darstellungsdienst');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.c2Max','310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.c1Min','460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'eigentumsbeschraenkung','ch.ehi.ili2db.foreignKey','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.srid','21781');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localisedmtext',NULL,'T_Type','ch.ehi.ili2db.types','["localisationch_v1_localisedmtext","localisedmtext"]');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.c1Min','460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.geomType','POINT');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisdefinitiondokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.geomType','LINESTRING');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('multilingualmtext',NULL,'T_Type','ch.ehi.ili2db.types','["artikelinhaltmehrsprachig","localisationch_v1_multilingualmtext","multilingualmtext"]');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_eigentumsbeschraenkung',NULL,'zustaendigestelle','ch.ehi.ili2db.foreignKey','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.srid','21781');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localiseduri',NULL,'multilingualuri_localisedtext','ch.ehi.ili2db.foreignKey','multilingualuri');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('multilingualuri',NULL,'vorschriften_dokument_textimweb','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisvorschrift',NULL,'vorschrift_vorschriften_artikel','ch.ehi.ili2db.foreignKey','vorschriften_artikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('vorschriften_dokument',NULL,'T_Type','ch.ehi.ili2db.types','["vorschriften_dokument","vorschriften_rechtsvorschrift"]');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('multilingualuri',NULL,'vorschriften_artikel_textimweb','ch.ehi.ili2db.foreignKey','vorschriften_artikel');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.c2Min','45000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.c2Max','310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('multilingualtext',NULL,'T_Type','ch.ehi.ili2db.types','["localisationch_v1_multilingualtext","multilingualtext"]');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_grundlageverfeinerung',NULL,'verfeinerung','ch.ehi.ili2db.foreignKey','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localisedmtext',NULL,'multilingualmtext_localisedtext','ch.ehi.ili2db.foreignKey','multilingualmtext');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localisedtext',NULL,'T_Type','ch.ehi.ili2db.types','["localisationch_v1_localisedtext","localisedtext"]');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.c1Min','460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.c2Max','310000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.c2Min','45000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('artikelnummer_',NULL,'vorschrftn_wswtrdkmnte_artikelnr','ch.ehi.ili2db.foreignKey','vorschriften_hinweisweiteredokumente');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv95','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.srid','21781');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv03','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_legendeeintrag',NULL,'transfrstrkstllngsdnst_legende','ch.ehi.ili2db.foreignKey','transferstruktur_darstellungsdienst');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'zustaendigestelle','ch.ehi.ili2db.foreignKey','vorschriften_amt');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv03','ch.ehi.ili2db.c1Max','870000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_grundlageverfeinerung',NULL,'grundlage','ch.ehi.ili2db.foreignKey','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisdefinitiondokument',NULL,'hinweisdefinition','ch.ehi.ili2db.foreignKey','transferstruktur_hinweisdefinition');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.srid','2056');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('localisedmtext',NULL,'atext','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'punkt_lv95','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'flaeche_lv03','ch.ehi.ili2db.c2Min','45000.000');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_hinweisvorschrift',NULL,'eigentumsbeschraenkung','ch.ehi.ili2db.foreignKey','transferstruktur_eigentumsbeschraenkung');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('vorschriften_hinweisweiteredokumente',NULL,'ursprung','ch.ehi.ili2db.foreignKey','vorschriften_dokument');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.coordDimension','2');
INSERT INTO arp_npl_oereb.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('transferstruktur_geometrie',NULL,'linie_lv95','ch.ehi.ili2db.geomType','LINESTRING');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('multilingualmtext','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('localiseduri','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('vorschriften_hinweisweiteredokumente','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('rechtsstatus','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('localisedmtext','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('multilingualuri','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('transferstruktur_hinweisdefinitiondokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('localisedtext','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('multilingualtext','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('transferstruktur_grundlageverfeinerung','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('thema','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('languagecode_iso639_1','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('artikelnummer_','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('transferstruktur_hinweisvorschrift','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('chcantoncode','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO arp_npl_oereb.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('transferstruktur_legendeeintrag','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part4_ADMINISTRATIVEUNITS_20110830.ili','2.3','CHAdminCodes_V1 AdministrativeUnits_V1{ CHAdminCodes_V1 InternationalCodes_V1 Dictionaries_V1 Localisation_V1 INTERLIS} AdministrativeUnitsCH_V1{ CHAdminCodes_V1 InternationalCodes_V1 LocalisationCH_V1 AdministrativeUnits_V1 INTERLIS}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-08-30
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART IV -- ADMINISTRATIVE UNITS
   - Package CHAdminCodes
   - Package AdministrativeUnits
   - Package AdministrativeUnitsCH
*/

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2018-02-19 | KOGIS | CHCantonCode adapted (FL and CH added) (line 34)

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL CHAdminCodes_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2018-02-19" =

  DOMAIN
    CHCantonCode = (ZH,BE,LU,UR,SZ,OW,NW,GL,ZG,FR,SO,BS,BL,SH,AR,AI,SG,
                    GR,AG,TG,TI,VD,VS,NE,GE,JU,FL,CH);

    CHMunicipalityCode = 1..9999;  !! BFS-Nr

END CHAdminCodes_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL AdministrativeUnits_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS UNQUALIFIED CHAdminCodes_V1;
  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Localisation_V1;
  IMPORTS Dictionaries_V1;

  TOPIC AdministrativeUnits (ABSTRACT) =

    CLASS AdministrativeElement (ABSTRACT) =
    END AdministrativeElement;

    CLASS AdministrativeUnit (ABSTRACT) EXTENDS AdministrativeElement =
    END AdministrativeUnit;

    ASSOCIATION Hierarchy =
      UpperLevelUnit (EXTERNAL) -<> {0..1} AdministrativeUnit;
      LowerLevelUnit -- AdministrativeUnit;
    END Hierarchy;

    CLASS AdministrativeUnion (ABSTRACT) EXTENDS AdministrativeElement =
    END AdministrativeUnion;

    ASSOCIATION UnionMembers =
      Union -<> AdministrativeUnion;
      Member -- AdministrativeElement; 
    END UnionMembers;

  END AdministrativeUnits;

  TOPIC Countries EXTENDS AdministrativeUnits =

    CLASS Country EXTENDS AdministrativeUnit =
      Code: MANDATORY CountryCode_ISO3166_1;
    UNIQUE Code;
    END Country;

  END Countries;

  TOPIC CountryNames EXTENDS Dictionaries_V1.Dictionaries =
    DEPENDS ON AdministrativeUnits_V1.Countries;

    STRUCTURE CountryName EXTENDS Entry =
      Code: MANDATORY CountryCode_ISO3166_1;
    END CountryName;
      
    CLASS CountryNamesTranslation EXTENDS Dictionary  =
      Entries(EXTENDED): LIST OF CountryName;
    UNIQUE Entries->Code;
    EXISTENCE CONSTRAINT
      Entries->Code REQUIRED IN AdministrativeUnits_V1.Countries.Country: Code;
    END CountryNamesTranslation;

  END CountryNames;

  TOPIC Agencies (ABSTRACT) =
    DEPENDS ON AdministrativeUnits_V1.AdministrativeUnits;

    CLASS Agency (ABSTRACT) =
    END Agency;

    ASSOCIATION Authority =
      Supervisor (EXTERNAL) -<> {1..1} Agency OR AdministrativeUnits_V1.AdministrativeUnits.AdministrativeElement;
      Agency -- Agency;
    END Authority;

    ASSOCIATION Organisation =
      Orderer (EXTERNAL) -- Agency OR AdministrativeUnits_V1.AdministrativeUnits.AdministrativeElement;
      Executor -- Agency;
    END Organisation;

  END Agencies;

END AdministrativeUnits_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL AdministrativeUnitsCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS UNQUALIFIED CHAdminCodes_V1;
  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS LocalisationCH_V1;
  IMPORTS AdministrativeUnits_V1;

  TOPIC CHCantons EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnits_V1.Countries;

    CLASS CHCanton EXTENDS AdministrativeUnit =
      Code: MANDATORY CHCantonCode;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
    UNIQUE Code;
    END CHCanton;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnits_V1.Countries.Country;
      LowerLevelUnit (EXTENDED) -- CHCanton;
    MANDATORY CONSTRAINT
      UpperLevelUnit->Code == "CHE";
    END Hierarchy;

  END CHCantons;

  TOPIC CHDistricts EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;

    CLASS CHDistrict EXTENDS AdministrativeUnit =
      ShortName: MANDATORY TEXT*20;
      Name: LocalisationCH_V1.MultilingualText;
      Web: MANDATORY URI;
    END CHDistrict;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnitsCH_V1.CHCantons.CHCanton;
      LowerLevelUnit (EXTENDED) -- CHDistrict;
    UNIQUE UpperLevelUnit->Code, LowerLevelUnit->ShortName;
    END Hierarchy;

  END CHDistricts;

  TOPIC CHMunicipalities EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;

    CLASS CHMunicipality EXTENDS AdministrativeUnit =
      Code: MANDATORY CHMunicipalityCode;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
    UNIQUE Code;
    END CHMunicipality;

    ASSOCIATION Hierarchy (EXTENDED) =
      UpperLevelUnit (EXTENDED, EXTERNAL) -<> {1..1} AdministrativeUnitsCH_V1.CHCantons.CHCanton
      OR AdministrativeUnitsCH_V1.CHDistricts.CHDistrict;
      LowerLevelUnit (EXTENDED) -- CHMunicipality;
    END Hierarchy;

  END CHMunicipalities;

  TOPIC CHAdministrativeUnions EXTENDS AdministrativeUnits_V1.AdministrativeUnits =
    DEPENDS ON AdministrativeUnits_V1.Countries;
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;
    DEPENDS ON AdministrativeUnitsCH_V1.CHMunicipalities;

    CLASS AdministrativeUnion (EXTENDED) =
    OID AS UUIDOID;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
      Description: LocalisationCH_V1.MultilingualMText;
    END AdministrativeUnion;

  END CHAdministrativeUnions;

  TOPIC CHAgencies EXTENDS AdministrativeUnits_V1.Agencies =
    DEPENDS ON AdministrativeUnits_V1.Countries;
    DEPENDS ON AdministrativeUnitsCH_V1.CHCantons;
    DEPENDS ON AdministrativeUnitsCH_V1.CHDistricts;
    DEPENDS ON AdministrativeUnitsCH_V1.CHMunicipalities;

    CLASS Agency (EXTENDED) =
    OID AS UUIDOID;
      Name: LocalisationCH_V1.MultilingualText;
      Web: URI;
      Description: LocalisationCH_V1.MultilingualMText;
    END Agency;

  END CHAgencies;

END AdministrativeUnitsCH_V1.

!! ########################################################################
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part3_CATALOGUEOBJECTS_20110830.ili','2.3','CatalogueObjects_V1{ INTERLIS} CatalogueObjectTrees_V1{ INTERLIS CatalogueObjects_V1}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-08-30
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART III -- CATALOGUE OBJECTS
   - Package CatalogueObjects
   - Package CatalogueObjectTrees
*/

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL CatalogueObjects_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;

  TOPIC Catalogues (ABSTRACT) =

    CLASS Item (ABSTRACT) =
    END Item;

    STRUCTURE CatalogueReference (ABSTRACT) =
      Reference: REFERENCE TO (EXTERNAL) Item;
    END CatalogueReference;
 
    STRUCTURE MandatoryCatalogueReference (ABSTRACT) =
      Reference: MANDATORY REFERENCE TO (EXTERNAL) Item;
    END MandatoryCatalogueReference;

  END Catalogues;

END CatalogueObjects_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL CatalogueObjectTrees_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS CatalogueObjects_V1;

  TOPIC Catalogues (ABSTRACT) EXTENDS CatalogueObjects_V1.Catalogues =

    CLASS Item (ABSTRACT,EXTENDED) = 
      IsSuperItem: MANDATORY BOOLEAN;
      IsUseable: MANDATORY BOOLEAN;
    MANDATORY CONSTRAINT
      IsSuperItem OR IsUseable;
    END Item;

    ASSOCIATION EntriesTree =
      Parent -<#> Item;
      Child -- Item;
    MANDATORY CONSTRAINT
      Parent->IsSuperItem;
    END EntriesTree;

    STRUCTURE CatalogueReference (ABSTRACT,EXTENDED) =
      Reference(EXTENDED): REFERENCE TO (EXTERNAL) Item;
    MANDATORY CONSTRAINT
      Reference->IsUseable;
    END CatalogueReference;
 
    STRUCTURE MandatoryCatalogueReference (ABSTRACT,EXTENDED) =
      Reference(EXTENDED): MANDATORY REFERENCE TO (EXTERNAL) Item;
    MANDATORY CONSTRAINT
      Reference->IsUseable;
    END MandatoryCatalogueReference;

  END Catalogues;

END CatalogueObjectTrees_V1.

!! ########################################################################
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('Units-20120220.ili','2.3','Units','!! File Units.ili Release 2012-02-20

INTERLIS 2.3;

!! 2012-02-20 definition of "Bar [bar]" corrected
!!@precursorVersion = 2005-06-06

CONTRACTED TYPE MODEL Units (en) AT "http://www.interlis.ch/models"
  VERSION "2012-02-20" =

  UNIT
    !! abstract Units
    Area (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH);
    Volume (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH*INTERLIS.LENGTH);
    Velocity (ABSTRACT) = (INTERLIS.LENGTH/INTERLIS.TIME);
    Acceleration (ABSTRACT) = (Velocity/INTERLIS.TIME);
    Force (ABSTRACT) = (INTERLIS.MASS*INTERLIS.LENGTH/INTERLIS.TIME/INTERLIS.TIME);
    Pressure (ABSTRACT) = (Force/Area);
    Energy (ABSTRACT) = (Force*INTERLIS.LENGTH);
    Power (ABSTRACT) = (Energy/INTERLIS.TIME);
    Electric_Potential (ABSTRACT) = (Power/INTERLIS.ELECTRIC_CURRENT);
    Frequency (ABSTRACT) = (INTERLIS.DIMENSIONLESS/INTERLIS.TIME);

    Millimeter [mm] = 0.001 [INTERLIS.m];
    Centimeter [cm] = 0.01 [INTERLIS.m];
    Decimeter [dm] = 0.1 [INTERLIS.m];
    Kilometer [km] = 1000 [INTERLIS.m];

    Square_Meter [m2] EXTENDS Area = (INTERLIS.m*INTERLIS.m);
    Cubic_Meter [m3] EXTENDS Volume = (INTERLIS.m*INTERLIS.m*INTERLIS.m);

    Minute [min] = 60 [INTERLIS.s];
    Hour [h] = 60 [min];
    Day [d] = 24 [h];

    Kilometer_per_Hour [kmh] EXTENDS Velocity = (km/h);
    Meter_per_Second [ms] = 3.6 [kmh];
    Newton [N] EXTENDS Force = (INTERLIS.kg*INTERLIS.m/INTERLIS.s/INTERLIS.s);
    Pascal [Pa] EXTENDS Pressure = (N/m2);
    Joule [J] EXTENDS Energy = (N*INTERLIS.m);
    Watt [W] EXTENDS Power = (J/INTERLIS.s);
    Volt [V] EXTENDS Electric_Potential = (W/INTERLIS.A);

    Inch [in] = 2.54 [cm];
    Foot [ft] = 0.3048 [INTERLIS.m];
    Mile [mi] = 1.609344 [km];

    Are [a] = 100 [m2];
    Hectare [ha] = 100 [a];
    Square_Kilometer [km2] = 100 [ha];
    Acre [acre] = 4046.873 [m2];

    Liter [L] = 1 / 1000 [m3];
    US_Gallon [USgal] = 3.785412 [L];

    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

    Gon = 200 / PI [INTERLIS.rad];

    Gram [g] = 1 / 1000 [INTERLIS.kg];
    Ton [t] = 1000 [INTERLIS.kg];
    Pound [lb] = 0.4535924 [INTERLIS.kg];

    Calorie [cal] = 4.1868 [J];
    Kilowatt_Hour [kWh] = 0.36E7 [J];

    Horsepower = 746 [W];

    Techn_Atmosphere [at] = 98066.5 [Pa];
    Atmosphere [atm] = 101325 [Pa];
    Bar [bar] = 100000 [Pa];
    Millimeter_Mercury [mmHg] = 133.3224 [Pa];
    Torr = 133.3224 [Pa]; !! Torr = [mmHg]

    Decibel [dB] = FUNCTION // 10**(dB/20) * 0.00002 // [Pa];

    Degree_Celsius [oC] = FUNCTION // oC+273.15 // [INTERLIS.K];
    Degree_Fahrenheit [oF] = FUNCTION // (oF+459.67)/1.8 // [INTERLIS.K];

    CountedObjects EXTENDS INTERLIS.DIMENSIONLESS;

    Hertz [Hz] EXTENDS Frequency = (CountedObjects/INTERLIS.s);
    KiloHertz [KHz] = 1000 [Hz];
    MegaHertz [MHz] = 1000 [KHz];

    Percent = 0.01 [CountedObjects];
    Permille = 0.001 [CountedObjects];

    !! ISO 4217 Currency Abbreviation
    USDollar [USD] EXTENDS INTERLIS.MONEY;
    Euro [EUR] EXTENDS INTERLIS.MONEY;
    SwissFrancs [CHF] EXTENDS INTERLIS.MONEY;

END Units.

','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('OeREBKRMtrsfr_V1_1.ili','2.3','OeREBKRMtrsfr_V1_1{ GeometryCHLV95_V1 CHAdminCodes_V1 LocalisationCH_V1 GeometryCHLV03_V1 OeREBKRM_V1_1 OeREBKRMvs_V1_1}','INTERLIS 2.3;

/** Schnittstelle zwischen zuständiger Stelle für die Geobasisdaten und Katasterorganisation des Kantons.
 */
!!@ furtherInformation=http://www.cadastre.ch/oereb-public
!!@ technicalContact=mailto:infovd@swisstopo.ch
MODEL OeREBKRMtrsfr_V1_1 (de)
AT "http://models.geo.admin.ch/V_D/OeREB/"
VERSION "2016-08-15"  =
  IMPORTS OeREBKRM_V1_1,OeREBKRMvs_V1_1,CHAdminCodes_V1,LocalisationCH_V1,GeometryCHLV03_V1,GeometryCHLV95_V1;

  /** Dieses Teilmodell definiert die Struktur der Daten, wie sie von der zuständigen Stelle für die Geobasisdaten an die Abgabestelle des ÖREB-Kataster-Auszugs geliefert werden müssen. Dieses Datenmodell definiert somit, welche Daten ein minimales Datenmodell enthalten muss, um als ÖREB-Kataster fähiges Datenmodell zu gelten.
   */
  TOPIC Transferstruktur
  EXTENDS OeREBKRMvs_V1_1.Vorschriften =
    DEPENDS ON OeREBKRMvs_V1_1.HinweiseGesetzlicheGrundlagen;

    /** Wurzelelement für Informationen über eine Beschränkung des Grundeigentums, die rechtskräftig, z.B. auf Grund einer Genehmigung oder eines richterlichen Entscheids, zustande gekommen ist.
     */
    CLASS Eigentumsbeschraenkung =
      /** Textliche Beschreibung der Beschränkung; z.B. "Wohnen W3"
       */
      Aussage : MANDATORY LocalisationCH_V1.MultilingualMText;
      /** Einordnung der Eigentumsbeschränkung in ein ÖREBK-Thema
       */
      Thema : MANDATORY OeREBKRM_V1_1.Thema;
      /** z.B. Planungszonen innerhalb Nutzungsplanung
       */
      SubThema : OeREBKRM_V1_1.SubThema;
      /** z.B. kantonale Themen. Der Code wird nach folgendem Muster gebildet: ch.{canton}.{topic}
       * fl.{topic}
       * ch.{bfsnr}.{topic}
       * Wobei {canton} das offizielle zwei-stellige Kürzel des Kantons ist, {to-pic} der Themenname und {bfsnr} die Gemeindenummer gem. BFS.
       */
      WeiteresThema : OeREBKRM_V1_1.WeiteresThema;
      /** Themenspezifische, maschinen-lesbare Art gem. Originalmodell der Eigentumsbeschränkung
       */
      ArtCode : OeREBKRM_V1_1.ArtEigentumsbeschraenkung;
      /** Identifikation der Codeliste bzw. des Wertebereichs für ArtCode
       */
      ArtCodeliste : URI;
      /** Status, ob diese Eigentumsbeschränkung in Kraft ist
       */
      Rechtsstatus : MANDATORY OeREBKRM_V1_1.RechtsStatus;
      /** Datum, ab dem diese Eigentumsbeschränkung in Auszügen erscheint
       */
      publiziertAb : MANDATORY OeREBKRM_V1_1.Datum;
      MANDATORY CONSTRAINT Thema!=#WeiteresThema OR DEFINED(WeiteresThema);
    END Eigentumsbeschraenkung;

    /** Punkt-, linien-, oder flächenförmige Geometrie. Neu zu definierende Eigentumsbeschränkungen sollten i.d.R. flächenförmig sein.
     */
    CLASS Geometrie =
      /** Punktgeometrie
       */
      Punkt_LV03 : GeometryCHLV03_V1.Coord2;
      Punkt_LV95 : GeometryCHLV95_V1.Coord2;
      /** Linienförmige Geometrie
       */
      Linie_LV03 : GeometryCHLV03_V1.Line;
      Linie_LV95 : GeometryCHLV95_V1.Line;
      /** Flächenförmige Geometrie
       */
      Flaeche_LV03 : GeometryCHLV03_V1.Surface;
      Flaeche_LV95 : GeometryCHLV95_V1.Surface;
      /** Status, ob diese Geometrie in Kraft ist
       */
      Rechtsstatus : MANDATORY OeREBKRM_V1_1.RechtsStatus;
      /** Datum, ab dem diese Geometrie in Auszügen erscheint
       */
      publiziertAb : MANDATORY OeREBKRM_V1_1.Datum;
      /** Verweis auf maschinenlesbare Metadaten (XML) der zugrundeliegenden Geobasisdaten. z.B. http://www.geocat.ch/geonetwork/srv/deu/gm03.xml?id=705
       */
      MetadatenGeobasisdaten : URI;
      MANDATORY CONSTRAINT DEFINED(Punkt_LV03) OR DEFINED(Linie_LV03) OR DEFINED(Flaeche_LV03) OR DEFINED(Punkt_LV95) OR DEFINED(Linie_LV95) OR DEFINED(Flaeche_LV95);
    END Geometrie;

    /** Definition für Hinweise, die unabhängig von einer konkreten Eigentumsbeschränkung gelten (z.B. der Hinweis auf eine Systematische Rechtssammlung). Der Hinweis kann aber beschränkt werden auf eine bestimmtes ÖREB-Thema und/oder Kanton und/oder Gemeinde.
     */
    CLASS HinweisDefinition =
      /** Thema falls der Hinweis für ein bestimmtes ÖREB-Thema gilt. Falls die Angabe fehlt, ist es ein Hinweis der für alle ÖREB-Themen gilt.
       */
      Thema : OeREBKRM_V1_1.Thema;
      /** Kantonskürzel falls der Hinweis für ein Kantons-oder Gemeindegebiet gilt. Falls die Angabe fehlt, ist es ein Hinweis der für alle Kantone gilt. z.B. "BE".
       */
      Kanton : CHAdminCodes_V1.CHCantonCode;
      /** BFSNr falls der Hinweis für ein Gemeindegebiet gilt. Falls die Angabe fehlt, ist es ein Hinweis der für den Kanton oder die Schweiz gilt. z.B. "942".
       */
      Gemeinde : CHAdminCodes_V1.CHMunicipalityCode;
    END HinweisDefinition;

    /** Ein Eintrag in der Planlegende.
     */
    STRUCTURE LegendeEintrag =
      /** Grafischer Teil des Legendeneintrages für die Darstellung. Im PNG-Format mit 300dpi oder im SVG-Format
       */
      Symbol : MANDATORY BLACKBOX BINARY;
      /** Text des Legendeneintrages
       */
      LegendeText : MANDATORY LocalisationCH_V1.MultilingualText;
      /** Art der Eigentumsbeschränkung, die durch diesen Legendeneintrag dargestellt wird
       */
      ArtCode : MANDATORY OeREBKRM_V1_1.ArtEigentumsbeschraenkung;
      /** Codeliste der Eigentumsbeschränkung, die durch diesen Legendeneintrag dargestellt wird
       */
      ArtCodeliste : MANDATORY URI;
      /** Zu welchem ÖREB-Thema der Legendeneintrag gehört
       */
      Thema : MANDATORY OeREBKRM_V1_1.Thema;
      /** z.B. Planungszonen innerhalb Nutzungsplanung
       */
      SubThema : OeREBKRM_V1_1.SubThema;
      WeiteresThema : OeREBKRM_V1_1.WeiteresThema;
      MANDATORY CONSTRAINT Thema!=#WeiteresThema OR DEFINED(WeiteresThema);
    END LegendeEintrag;

    /** Angaben zum Darstellungsdienst.
     */
    CLASS DarstellungsDienst =
      /** WMS GetMap-Request (für Maschine-Maschine-Kommunikation) inkl. alle benötigten Parameter, z.B. "https://wms.geo.admin.ch/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&STYLES=default&SRS=EPSG:21781&BBOX=475000,60000,845000,310000&WIDTH=740&HEIGHT=500&FORMAT=image/png&LAYERS=ch.bazl.kataster-belasteter-standorte-zivilflugplaetze.oereb"
       */
      VerweisWMS : MANDATORY URI;
      /** Verweis auf ein Dokument das die Karte beschreibt; z.B. "https://wms.geo.admin.ch/?SERVICE=WMS&REQUEST=GetLegendGraphic&VERSION=1.1.1&FORMAT=image/png&LAYER=ch.bazl.kataster-belasteter-standorte-zivilflugplaetze.oereb"
       */
      LegendeImWeb : OeREBKRM_V1_1.WebReferenz;
      Legende : BAG {0..*} OF LegendeEintrag;
      MANDATORY CONSTRAINT DEFINED(LegendeImWeb) OR INTERLIS.elementCount(Legende)>0;
    END DarstellungsDienst;

    ASSOCIATION GeometrieEigentumsbeschraenkung =
      /** Geometrie der Eigentumsbeschränkung, die Rechtswirkung hat (als Basis für den Verschnitt mit den Liegenschaften)
       */
      Geometrie -- {0..*} Geometrie;
      Eigentumsbeschraenkung -<#> {1} Eigentumsbeschraenkung;
    END GeometrieEigentumsbeschraenkung;

    ASSOCIATION GrundlageVerfeinerung =
      Grundlage (EXTERNAL) -- {0..*} Eigentumsbeschraenkung;
      Verfeinerung -- {0..*} Eigentumsbeschraenkung;
    END GrundlageVerfeinerung;

    ASSOCIATION HinweisDefinitionDokument =
      HinweisDefinition -- {0..*} HinweisDefinition;
      Dokument -- {1..*} OeREBKRMvs_V1_1.Vorschriften.Dokument;
    END HinweisDefinitionDokument;

    ASSOCIATION HinweisDefinitionZustaendigeStelle =
      HinweisDefinition -<> {0..*} HinweisDefinition;
      ZustaendigeStelle -- {1} OeREBKRMvs_V1_1.Vorschriften.Amt;
    END HinweisDefinitionZustaendigeStelle;

    ASSOCIATION HinweisVorschrift =
      Eigentumsbeschraenkung -- {0..*} Eigentumsbeschraenkung;
      /** Rechtsvorschrift der Eigentumsbeschränkung
       */
      Vorschrift -- {1..*} OeREBKRMvs_V1_1.Vorschriften.DokumentBasis;
      /** Hinweis auf spezifische Artikel.
       */
      ArtikelNr : BAG {0..*} OF OeREBKRM_V1_1.ArtikelNummer_;
    END HinweisVorschrift;

    ASSOCIATION ZustaendigeStelleEigentumsbeschraenkung =
      /** Zuständige Stelle für die Geobasisdaten (Originaldaten) gem. GeoIG Art. 8 Abs. 1
       */
      ZustaendigeStelle -- {1} OeREBKRMvs_V1_1.Vorschriften.Amt;
      Eigentumsbeschraenkung -<> {0..*} Eigentumsbeschraenkung;
    END ZustaendigeStelleEigentumsbeschraenkung;

    ASSOCIATION ZustaendigeStelleGeometrie =
      ZustaendigeStelle -- {1} OeREBKRMvs_V1_1.Vorschriften.Amt;
      Geometrie -<> {0..*} Geometrie;
    END ZustaendigeStelleGeometrie;

    ASSOCIATION DarstellungsDienstEigentumsbeschraenkung =
      /** Darstellungsdienst, auf dem diese Eigentumsbeschränkung sichtbar, aber nicht hervorgehoben, ist.
       */
      DarstellungsDienst -- {0..1} DarstellungsDienst;
      Eigentumsbeschraenkung -<> {1..*} Eigentumsbeschraenkung;
    END DarstellungsDienstEigentumsbeschraenkung;

  END Transferstruktur;

END OeREBKRMtrsfr_V1_1.
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('OeREBKRM_V1_1.ili','2.3','OeREBKRM_V1_1{ InternationalCodes_V1 LocalisationCH_V1 CatalogueObjects_V1}','INTERLIS 2.3;

/** Basisdefinitionen für das OEREB-Katasterrahmenmodell
 */
!!@ furtherInformation=http://www.cadastre.ch/oereb-public
!!@ technicalContact=mailto:infovd@swisstopo.ch
MODEL OeREBKRM_V1_1 (de)
AT "http://models.geo.admin.ch/V_D/OeREB/"
VERSION "2016-08-15"  =
  IMPORTS LocalisationCH_V1,InternationalCodes_V1,CatalogueObjects_V1;

  DOMAIN

    /** Themenspezifische, maschinen-lesbare Art der Eigentumsbeschränkung
     */
    ArtEigentumsbeschraenkung = TEXT*40;

    /** Wertebereich für den Artikeltext einer Rechtsvorschrift oder einer gesetzlichen Grundlage.
     */
    ArtikelInhalt = MTEXT;

    /** Nummer eines Artikels in einer Rechtsvorschrift oder gesetzlichen Grundlage.
     */
    ArtikelNummer = TEXT*20;

    Datum = FORMAT INTERLIS.XMLDate "1848-1-1" .. "2100-12-31";

    /** Wertebereich für Objektidentifikatoren. Der Wert soll mit einem gültigen Internet Domain-Name anfangen, z.B. "ch.admin.sr.720"
     */
    OEREBOID = OID TEXT;

    /** Werteliste zur Unterscheidung ob eine Eigentumsbeschränkung in Kraft ist oder nicht.
     */
    RechtsStatus = (
      /** Die Eigentumsbeschränkung ist in Kraft.
       */
      inKraft,
      /** gem. OeREBKV Art. 12 Abs. 2
       */
      laufendeAenderung
    );

    SubThema = TEXT*60;

    /** Liste der Geobasisdaten die ÖREB-Themen sind (Wird durch den Bundesrat definiert). Die Liste kann durch Kantone erweitert werden.
     */
    Thema = (
      /** GeoIV Datensatz 73
       */
      Nutzungsplanung,
      /** 87
       */
      ProjektierungszonenNationalstrassen,
      /** 88
       */
      BaulinienNationalstrassen,
      /** 96
       */
      ProjektierungszonenEisenbahnanlagen,
      /** 97
       */
      BaulinienEisenbahnanlagen,
      /** 103
       */
      ProjektierungszonenFlughafenanlagen,
      /** 104
       */
      BaulinienFlughafenanlagen,
      /** 108
       */
      SicherheitszonenplanFlughafen,
      /** 116
       */
      BelasteteStandorte,
      /** 117
       */
      BelasteteStandorteMilitaer,
      /** 118
       */
      BelasteteStandorteZivileFlugplaetze,
      /** 119
       */
      BelasteteStandorteOeffentlicherVerkehr,
      /** 131
       */
      Grundwasserschutzzonen,
      /** 132
       */
      Grundwasserschutzareale,
      /** 145
       */
      Laermemfindlichkeitsstufen,
      /** 157
       */
      Waldgrenzen,
      /** 159
       */
      Waldabstandslinien,
      /** Fuer weitere Themen
       */
      WeiteresThema
    );

    /** Unternehmensindentifikation (gemäss. Bundesgesetz über die Unternehmens-Identifikationsnummer SR 431.03) ohne Formatierung z.B. CHE116068369
     */
    UID = TEXT*12;

    /** Verweis auf ein Dokument im Web (z.B. eine HTML Seite oder ein PDF-Dokument)
     */
    WebReferenz = URI;

    /** z.B. kantonale Themen. Der Code wird nach folgendem Muster gebildet: ch.{canton}.{topic}
     * fl.{topic}
     * ch.{bfsnr}.{topic}
     * Wobei {canton} das offizielle zwei-stellige Kürzel des Kantons ist, {to-pic} der Themenname und {bfsnr} die Gemeindenummer gem. BFS.
     */
    WeiteresThema = TEXT*120;
  STRUCTURE ArtikelNummer_ = value : MANDATORY ArtikelNummer; END ArtikelNummer_;
  STRUCTURE Datum_ = value : MANDATORY Datum; END Datum_;
  STRUCTURE Thema_ = value : MANDATORY Thema; END Thema_;
  STRUCTURE WebReferenz_ = value : MANDATORY WebReferenz; END WebReferenz_;

  /** Wertebereich für den Artikeltext einer Rechtsvorschrift oder einer gesetzlichen Grundlage.
   */
  STRUCTURE ArtikelInhaltMehrsprachig
  EXTENDS LocalisationCH_V1.MultilingualMText =
  END ArtikelInhaltMehrsprachig;

  STRUCTURE LocalisedUri =
    Language : InternationalCodes_V1.LanguageCode_ISO639_1;
    Text : MANDATORY URI;
  END LocalisedUri;

  STRUCTURE MultilingualUri =
    LocalisedText : BAG {1..*} OF OeREBKRM_V1_1.LocalisedUri;
    UNIQUE (LOCAL) LocalisedText:Language;
  END MultilingualUri;

  /** Anzeigetexte für Aufzählungen des Rahmenmodells
   */
  TOPIC CodelistenText =

    /** Anzeigetexte für die Aufzählung RechtsStatus
     */
    CLASS RechtsStatusTxt
    EXTENDS CatalogueObjects_V1.Catalogues.Item =
      Code : MANDATORY OeREBKRM_V1_1.RechtsStatus;
      Titel : MANDATORY LocalisationCH_V1.MultilingualText;
      UNIQUE Code;
    END RechtsStatusTxt;

    /** Anzeigetexte für die Aufzählung Thema
     */
    CLASS ThemaTxt
    EXTENDS CatalogueObjects_V1.Catalogues.Item =
      Code : MANDATORY OeREBKRM_V1_1.Thema;
      Titel : MANDATORY LocalisationCH_V1.MultilingualText;
      UNIQUE Code;
    END ThemaTxt;

  END CodelistenText;

END OeREBKRM_V1_1.
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part2_LOCALISATION_20110830.ili','2.3','InternationalCodes_V1 Localisation_V1{ InternationalCodes_V1} LocalisationCH_V1{ InternationalCodes_V1 Localisation_V1} Dictionaries_V1{ InternationalCodes_V1} DictionariesCH_V1{ InternationalCodes_V1 Dictionaries_V1}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-08-30
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART II -- LOCALISATION
   - Package InternationalCodes
   - Packages Localisation, LocalisationCH
   - Packages Dictionaries, DictionariesCH
*/

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL InternationalCodes_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  DOMAIN
    LanguageCode_ISO639_1 = (de,fr,it,rm,en,
      aa,ab,af,am,ar,as,ay,az,ba,be,bg,bh,bi,bn,bo,br,ca,co,cs,cy,da,dz,el,
      eo,es,et,eu,fa,fi,fj,fo,fy,ga,gd,gl,gn,gu,ha,he,hi,hr,hu,hy,ia,id,ie,
      ik,is,iu,ja,jw,ka,kk,kl,km,kn,ko,ks,ku,ky,la,ln,lo,lt,lv,mg,mi,mk,ml,
      mn,mo,mr,ms,mt,my,na,ne,nl,no,oc,om,or,pa,pl,ps,pt,qu,rn,ro,ru,rw,sa,
      sd,sg,sh,si,sk,sl,sm,sn,so,sq,sr,ss,st,su,sv,sw,ta,te,tg,th,ti,tk,tl,
      tn,to,tr,ts,tt,tw,ug,uk,ur,uz,vi,vo,wo,xh,yi,yo,za,zh,zu);

    CountryCode_ISO3166_1 = (CHE,
      ABW,AFG,AGO,AIA,ALA,ALB,AND_,ANT,ARE,ARG,ARM,ASM,ATA,ATF,ATG,AUS,
      AUT,AZE,BDI,BEL,BEN,BFA,BGD,BGR,BHR,BHS,BIH,BLR,BLZ,BMU,BOL,BRA,
      BRB,BRN,BTN,BVT,BWA,CAF,CAN,CCK,CHL,CHN,CIV,CMR,COD,COG,COK,COL,
      COM,CPV,CRI,CUB,CXR,CYM,CYP,CZE,DEU,DJI,DMA,DNK,DOM,DZA,ECU,EGY,
      ERI,ESH,ESP,EST,ETH,FIN,FJI,FLK,FRA,FRO,FSM,GAB,GBR,GEO,GGY,GHA,
      GIB,GIN,GLP,GMB,GNB,GNQ,GRC,GRD,GRL,GTM,GUF,GUM,GUY,HKG,HMD,HND,
      HRV,HTI,HUN,IDN,IMN,IND,IOT,IRL,IRN,IRQ,ISL,ISR,ITA,JAM,JEY,JOR,
      JPN,KAZ,KEN,KGZ,KHM,KIR,KNA,KOR,KWT,LAO,LBN,LBR,LBY,LCA,LIE,LKA,
      LSO,LTU,LUX,LVA,MAC,MAR,MCO,MDA,MDG,MDV,MEX,MHL,MKD,MLI,MLT,MMR,
      MNE,MNG,MNP,MOZ,MRT,MSR,MTQ,MUS,MWI,MYS,MYT,NAM,NCL,NER,NFK,NGA,
      NIC,NIU,NLD,NOR,NPL,NRU,NZL,OMN,PAK,PAN,PCN,PER,PHL,PLW,PNG,POL,
      PRI,PRK,PRT,PRY,PSE,PYF,QAT,REU,ROU,RUS,RWA,SAU,SDN,SEN,SGP,SGS,
      SHN,SJM,SLB,SLE,SLV,SMR,SOM,SPM,SRB,STP,SUR,SVK,SVN,SWE,SWZ,SYC,
      SYR,TCA,TCD,TGO,THA,TJK,TKL,TKM,TLS,TON,TTO,TUN,TUR,TUV,TWN,TZA,
      UGA,UKR,UMI,URY,USA,UZB,VAT,VCT,VEN,VGB,VIR,VNM,VUT,WLF,WSM,YEM,
      ZAF,ZMB,ZWE);

END InternationalCodes_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL Localisation_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;

  STRUCTURE LocalisedText =
    Language: LanguageCode_ISO639_1;
    Text: MANDATORY TEXT;
  END LocalisedText;
  
  STRUCTURE LocalisedMText =
    Language: LanguageCode_ISO639_1;
    Text: MANDATORY MTEXT;
  END LocalisedMText;

  STRUCTURE MultilingualText =
    LocalisedText : BAG {1..*} OF LocalisedText;
    UNIQUE (LOCAL) LocalisedText:Language;
  END MultilingualText;  
  
  STRUCTURE MultilingualMText =
    LocalisedText : BAG {1..*} OF LocalisedMText;
    UNIQUE (LOCAL) LocalisedText:Language;
  END MultilingualMText;

END Localisation_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
TYPE MODEL LocalisationCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Localisation_V1;

  STRUCTURE LocalisedText EXTENDS Localisation_V1.LocalisedText =
  MANDATORY CONSTRAINT
    Language == #de OR
    Language == #fr OR
    Language == #it OR
    Language == #rm OR
    Language == #en;
  END LocalisedText;
  
  STRUCTURE LocalisedMText EXTENDS Localisation_V1.LocalisedMText =
  MANDATORY CONSTRAINT
    Language == #de OR
    Language == #fr OR
    Language == #it OR
    Language == #rm OR
    Language == #en;
  END LocalisedMText;

  STRUCTURE MultilingualText EXTENDS Localisation_V1.MultilingualText =
    LocalisedText(EXTENDED) : BAG {1..*} OF LocalisedText;
  END MultilingualText;  
  
  STRUCTURE MultilingualMText EXTENDS Localisation_V1.MultilingualMText =
    LocalisedText(EXTENDED) : BAG {1..*} OF LocalisedMText;
  END MultilingualMText;

END LocalisationCH_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL Dictionaries_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;

  TOPIC Dictionaries (ABSTRACT) =

    STRUCTURE Entry (ABSTRACT) =
      Text: MANDATORY TEXT;
    END Entry;
      
    CLASS Dictionary =
      Language: MANDATORY LanguageCode_ISO639_1;
      Entries: LIST OF Entry;
    END Dictionary;

  END Dictionaries;

END Dictionaries_V1.

!! ########################################################################
!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html
MODEL DictionariesCH_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2011-08-30" =

  IMPORTS UNQUALIFIED InternationalCodes_V1;
  IMPORTS Dictionaries_V1;

  TOPIC Dictionaries (ABSTRACT) EXTENDS Dictionaries_V1.Dictionaries =

    CLASS Dictionary (EXTENDED) =
    MANDATORY CONSTRAINT
      Language == #de OR
      Language == #fr OR
      Language == #it OR
      Language == #rm OR
      Language == #en;
    END Dictionary;

  END Dictionaries;

END DictionariesCH_V1.

!! ########################################################################
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CoordSys-20151124.ili','2.3','CoordSys','!! File CoordSys.ili Release 2015-11-24

INTERLIS 2.3;

!! 2015-11-24 Cardinalities adapted (line 122, 123, 124, 132, 133, 134, 142, 143,
!!                                   148, 149, 163, 164, 168, 169, 206 and 207)
!!@precursorVersion = 2005-06-16

REFSYSTEM MODEL CoordSys (en) AT "http://www.interlis.ch/models"
  VERSION "2015-11-24" =

  UNIT
    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

  STRUCTURE Angle_DMS_S =
    Degrees: -180 .. 180 CIRCULAR [Angle_Degree];
    CONTINUOUS SUBDIVISION Minutes: 0 .. 59 CIRCULAR [Angle_Minute];
    CONTINUOUS SUBDIVISION Seconds: 0.000 .. 59.999 CIRCULAR [Angle_Second];
  END Angle_DMS_S;

  DOMAIN
    Angle_DMS = FORMAT BASED ON Angle_DMS_S (Degrees ":" Minutes ":" Seconds);
    Angle_DMS_90 EXTENDS Angle_DMS = "-90:00:00.000" .. "90:00:00.000";


  TOPIC CoordsysTopic =

    !! Special space aspects to be referenced
    !! **************************************

    CLASS Ellipsoid EXTENDS INTERLIS.REFSYSTEM =
      EllipsoidAlias: TEXT*70;
      SemiMajorAxis: MANDATORY 6360000.0000 .. 6390000.0000 [INTERLIS.m];
      InverseFlattening: MANDATORY 0.00000000 .. 350.00000000;
      !! The inverse flattening 0 characterizes the 2-dim sphere
      Remarks: TEXT*70;
    END Ellipsoid;

    CLASS GravityModel EXTENDS INTERLIS.REFSYSTEM =
      GravityModAlias: TEXT*70;
      Definition: TEXT*70;
    END GravityModel;

    CLASS GeoidModel EXTENDS INTERLIS.REFSYSTEM =
      GeoidModAlias: TEXT*70;
      Definition: TEXT*70;
    END GeoidModel;


    !! Coordinate systems for geodetic purposes
    !! ****************************************

    STRUCTURE LengthAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.LENGTH];
    END LengthAXIS;

    STRUCTURE AngleAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.ANGLE];
    END AngleAXIS;

    CLASS GeoCartesian1D EXTENDS INTERLIS.COORDSYSTEM =
      Axis (EXTENDED): LIST {1} OF LengthAXIS;
    END GeoCartesian1D;

    CLASS GeoHeight EXTENDS GeoCartesian1D =
      System: MANDATORY (
        normal,
        orthometric,
        ellipsoidal,
        other);
      ReferenceHeight: MANDATORY -10000.000 .. +10000.000 [INTERLIS.m];
      ReferenceHeightDescr: TEXT*70;
    END GeoHeight;

    ASSOCIATION HeightEllips =
      GeoHeightRef -- {*} GeoHeight;
      EllipsoidRef -- {1} Ellipsoid;
    END HeightEllips;

    ASSOCIATION HeightGravit =
      GeoHeightRef -- {*} GeoHeight;
      GravityRef -- {1} GravityModel;
    END HeightGravit;

    ASSOCIATION HeightGeoid =
      GeoHeightRef -- {*} GeoHeight;
      GeoidRef -- {1} GeoidModel;
    END HeightGeoid;

    CLASS GeoCartesian2D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF LengthAXIS;
    END GeoCartesian2D;

    CLASS GeoCartesian3D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {3} OF LengthAXIS;
    END GeoCartesian3D;

    CLASS GeoEllipsoidal EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF AngleAXIS;
    END GeoEllipsoidal;

    ASSOCIATION EllCSEllips =
      GeoEllipsoidalRef -- {*} GeoEllipsoidal;
      EllipsoidRef -- {1} Ellipsoid;
    END EllCSEllips;


    !! Mappings between coordinate systems
    !! ***********************************

    ASSOCIATION ToGeoEllipsoidal =
      From -- {0..*} GeoCartesian3D;
      To -- {0..*} GeoEllipsoidal;
      ToHeight -- {0..*} GeoHeight;
    MANDATORY CONSTRAINT
      ToHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      To -> EllipsoidRef -> Name == ToHeight -> EllipsoidRef -> Name;
    END ToGeoEllipsoidal;

    ASSOCIATION ToGeoCartesian3D =
      From2 -- {0..*} GeoEllipsoidal;
      FromHeight-- {0..*} GeoHeight;
      To3 -- {0..*} GeoCartesian3D;
    MANDATORY CONSTRAINT
      FromHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      From2 -> EllipsoidRef -> Name == FromHeight -> EllipsoidRef -> Name;
    END ToGeoCartesian3D;

    ASSOCIATION BidirectGeoCartesian2D =
      From -- {0..*} GeoCartesian2D;
      To -- {0..*} GeoCartesian2D;
    END BidirectGeoCartesian2D;

    ASSOCIATION BidirectGeoCartesian3D =
      From -- {0..*} GeoCartesian3D;
      To2 -- {0..*} GeoCartesian3D;
      Precision: MANDATORY (
        exact,
        measure_based);
      ShiftAxis1: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis2: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis3: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      RotationAxis1: Angle_DMS_90;
      RotationAxis2: Angle_DMS_90;
      RotationAxis3: Angle_DMS_90;
      NewScale: 0.000001 .. 1000000.000000;
    END BidirectGeoCartesian3D;

    ASSOCIATION BidirectGeoEllipsoidal =
      From4 -- {0..*} GeoEllipsoidal;
      To4 -- {0..*} GeoEllipsoidal;
    END BidirectGeoEllipsoidal;

    ASSOCIATION MapProjection (ABSTRACT) =
      From5 -- {0..*} GeoEllipsoidal;
      To5 -- {0..*} GeoCartesian2D;
      FromCo1_FundPt: MANDATORY Angle_DMS_90;
      FromCo2_FundPt: MANDATORY Angle_DMS_90;
      ToCoord1_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
      ToCoord2_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
    END MapProjection;

    ASSOCIATION TransverseMercator EXTENDS MapProjection =
    END TransverseMercator;

    ASSOCIATION SwissProjection EXTENDS MapProjection =
      IntermFundP1: MANDATORY Angle_DMS_90;
      IntermFundP2: MANDATORY Angle_DMS_90;
    END SwissProjection;

    ASSOCIATION Mercator EXTENDS MapProjection =
    END Mercator;

    ASSOCIATION ObliqueMercator EXTENDS MapProjection =
    END ObliqueMercator;

    ASSOCIATION Lambert EXTENDS MapProjection =
    END Lambert;

    ASSOCIATION Polyconic EXTENDS MapProjection =
    END Polyconic;

    ASSOCIATION Albus EXTENDS MapProjection =
    END Albus;

    ASSOCIATION Azimutal EXTENDS MapProjection =
    END Azimutal;

    ASSOCIATION Stereographic EXTENDS MapProjection =
    END Stereographic;

    ASSOCIATION HeightConversion =
      FromHeight -- {0..*} GeoHeight;
      ToHeight -- {0..*} GeoHeight;
      Definition: TEXT*70;
    END HeightConversion;

  END CoordsysTopic;

END CoordSys.

','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('OeREBKRMvs_V1_1.ili','2.3','OeREBKRMvs_V1_1{ CHAdminCodes_V1 LocalisationCH_V1 OeREBKRM_V1_1}','INTERLIS 2.3;

/** Basisdefinition für Erlasse (Rechtsvorschriften, Hinweise auf Gesetzliche Grundlagen)
 */
!!@ furtherInformation=http://www.cadastre.ch/oereb-public
!!@ technicalContact=mailto:infovd@swisstopo.ch
MODEL OeREBKRMvs_V1_1 (de)
AT "http://models.geo.admin.ch/V_D/OeREB/"
VERSION "2016-08-15"  =
  IMPORTS OeREBKRM_V1_1,CHAdminCodes_V1,LocalisationCH_V1;

  /** Dieses Teilmodell definiert die Struktur für die Erlasse im Allgemeinen.
   * OID als URIs damit der Verweis auf Grundlagenerlasse (z.B. Kantonale Gesetze auf Bundesgesetze) in einem anderen Behälter (da durch eine andere Stelle erfasst/nachgeführt) verweisen können.
   */
  TOPIC Vorschriften =
    OID AS OeREBKRM_V1_1.OEREBOID;

    /** Eine organisatorische Einheit innerhalb der öffentlichen Verwaltung, z.B. eine für Geobasisdaten zuständige Stelle.
     */
    CLASS Amt =
      /** Name des Amtes z.B. "Amt für Gemeinden und Raumordnung des Kantons Bern".
       */
      Name : MANDATORY LocalisationCH_V1.MultilingualText;
      /** Verweis auf die Website des Amtes z.B. "http://www.jgk.be.ch/jgk/de/index/direktion/organisation/agr.html".
       */
      AmtImWeb : OeREBKRM_V1_1.WebReferenz;
      /** UID der organisatorischen Einheit
       */
      UID : OeREBKRM_V1_1.UID;
    END Amt;

    /** Vorschriften (Gesetze, Verordnungen, Rechtsvorschriften) oder einzelne Artikel davon.
     */
    CLASS DokumentBasis (ABSTRACT) =
      /** Verweis auf das Element im Web; z.B. "http://www.admin.ch/ch/d/sr/700/a18.html"
       */
      TextImWeb : OeREBKRM_V1_1.MultilingualUri;
      /** Status, ob dieses Element in Kraft ist
       */
      Rechtsstatus : MANDATORY OeREBKRM_V1_1.RechtsStatus;
      /** Datum, ab dem dieses Element in Auszügen erscheint
       */
      publiziertAb : MANDATORY OeREBKRM_V1_1.Datum;
    END DokumentBasis;

    /** Einzelner Artikel einer Rechtsvorschrift oder einer gesetzlichen Grundlage.
     */
    CLASS Artikel
    EXTENDS DokumentBasis =
      /** Nummer des Artikels innerhalb der gesetzlichen Grundlage oder der Rechtsvorschrift. z.B. "23"
       */
      Nr : MANDATORY OeREBKRM_V1_1.ArtikelNummer;
      /** z.B. "Ausnahmen innerhalb der Bauzonen regelt das kantonale Recht."
       */
      Text : OeREBKRM_V1_1.ArtikelInhaltMehrsprachig;
    END Artikel;

    /** Dokumente im allgemeinen (Gesetze, Verordnungen, Rechtsvorschriften)
     */
    CLASS Dokument
    EXTENDS DokumentBasis =
      /** Titel (oder falls vorhanden Kurztitel) des Dokuments; z.B. "Raumplanungsgesetz"
       */
      Titel : MANDATORY LocalisationCH_V1.MultilingualText;
      /** Offizieller Titel des Dokuments; z.B.  "Bundesgesetz über die Raumplanung"
       */
      OffiziellerTitel : LocalisationCH_V1.MultilingualText;
      /** Abkürzung des Gesetzes; z.B. "RPG"
       */
      Abkuerzung : LocalisationCH_V1.MultilingualText;
      /** Offizielle Nummer des Gesetzes; z.B. "SR 700"
       */
      OffizielleNr : TEXT*20;
      /** Kantonskürzel falls Vorschrift des Kantons oder der Gemeinde. Falls die Angabe fehlt, ist es eine Vorschrift des Bundes. z.B. "BE"
       */
      Kanton : CHAdminCodes_V1.CHCantonCode;
      /** Falls die Angabe fehlt, ist es ein Erlass des Kantons oder des Bundes. z.B. "942"
       */
      Gemeinde : CHAdminCodes_V1.CHMunicipalityCode;
      /** Das Dokument als PDF-Datei
       */
      Dokument : BLACKBOX BINARY;
    END Dokument;

    /** Reglemente, Vorschriften etc. die generell konkret sind (generell für die Person, die nicht bekannt ist, konkret für dass der Raumbezug mit Karte definiert ist), die zusammen mit der exakten geometrischen Definition als Einheit die Eigentumsbeschränkung unmittelbar beschreiben und innerhalb desselben Verfahrens verabschiedet worden sind.
     */
    CLASS Rechtsvorschrift
    EXTENDS Dokument =
    END Rechtsvorschrift;

    ASSOCIATION DokumentArtikel =
      Dokument -<#> {1} Dokument;
      /** OPTIONAL: Artikel zu diesem Dokument
       */
      Artikel -- {0..*} Artikel;
    END DokumentArtikel;

    ASSOCIATION HinweisWeitereDokumente =
      Ursprung -- {0..*} Dokument;
      Hinweis (EXTERNAL) -- {0..*} Dokument;
      /** Hinweis auf spezifische Artikel.
       */
      ArtikelNr : BAG {0..*} OF OeREBKRM_V1_1.ArtikelNummer_;
    END HinweisWeitereDokumente;

    ASSOCIATION ZustaendigeStelleDokument =
      ZustaendigeStelle -- {1} Amt;
      Dokument -<> {0..*} Dokument;
    END ZustaendigeStelleDokument;

  END Vorschriften;

  /** Dieses Teilmodell definiert die Struktur für die Hinweise auf die gesetzlichen Grundlagen, die als solche nicht Teil des ÖREB-Katasters sind, von diesem aber referenziert werden können.
   * OID als URIs damit der Verweis auf Grundlagengesetze (z.B. Kantonale Gesetze auf Bundesgesetze) in einem anderen Behälter (da durch eine andere Stelle erfasst/nachgeführt) verweisen können.
   */
  TOPIC HinweiseGesetzlicheGrundlagen
  EXTENDS OeREBKRMvs_V1_1.Vorschriften =

  END HinweiseGesetzlicheGrundlagen;

END OeREBKRMvs_V1_1.
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part1_GEOMETRY_20110830.ili','2.3','GeometryCHLV03_V1{ CoordSys Units INTERLIS} GeometryCHLV95_V1{ CoordSys Units INTERLIS}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-0830
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART I -- GEOMETRY
   - Package GeometryCHLV03
   - Package GeometryCHLV95
*/

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 57, 58, 65 and 66)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 57 and 58)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 31, 44 and 50)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV03_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV03
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:21781
    Coord2 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:21781
    Coord3 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
        -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV03_V1.

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 135, 136, 143 and 144)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 135 and 136)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 109, 122 and 128)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV95_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV95
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:2056
    Coord2 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:2056
    Coord3 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
         -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV95_V1.

!! ########################################################################
','2019-06-09 17:29:22.964');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createMetaInfo','True');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.beautifyEnumDispName','underscore');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.arrayTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.nameOptimization','topic');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.numericCheckConstraints','create');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.sender','ili2pg-4.1.0-aa1d00a37ee431852bdee6b990f34b3620f9c1c1');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKey','yes');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.sqlgen.createGeomIndex','True');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsAuthority','EPSG');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsCode','2056');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uuidDefaultValue','uuid_generate_v4()');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.StrokeArcs','enable');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiLineTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.interlis.ili2c.ilidirs','%ILI_FROM_DB;%XTF_DIR;http://models.interlis.ch/;%JAR_DIR');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKeyIndex','yes');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.importTabs','simple');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createDatasetCols','addDatasetCol');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.jsonTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.BasketHandling','readWrite');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createEnumDefs','multiTable');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uniqueConstraints','create');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.maxSqlNameLength','60');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.inheritanceTrafo','smart1');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.catalogueRefTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiPointTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO arp_npl_oereb.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('Dictionaries_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('Dictionaries_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('DictionariesCH_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('DictionariesCH_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('CatalogueObjects_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('CatalogueObjects_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('CatalogueObjectTrees_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('CatalogueObjectTrees_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnits_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnits_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnitsCH_V1','furtherInformation','http://www.geo.admin.ch/internet/geoportal/de/home/topics/geobasedata/models.html');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('AdministrativeUnitsCH_V1','technicalContact','models@geo.admin.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRM_V1_1','furtherInformation','http://www.cadastre.ch/oereb-public');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRM_V1_1','technicalContact','mailto:infovd@swisstopo.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRMvs_V1_1','furtherInformation','http://www.cadastre.ch/oereb-public');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRMvs_V1_1','technicalContact','mailto:infovd@swisstopo.ch');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRMtrsfr_V1_1','furtherInformation','http://www.cadastre.ch/oereb-public');
INSERT INTO arp_npl_oereb.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('OeREBKRMtrsfr_V1_1','technicalContact','mailto:infovd@swisstopo.ch');
COMMIT;
