# oereb-nutzungsplanung

Gretljobs für die Entwicklung des Datenumbaus der Nutzungsplanung (Kanton Solothurn) in die Transferstruktur des Rahmenmodelles.

## Prozessschritte

### (1) Starten der lokalen Edit-DB:

```
gradle -I $PWD/init.gradle -b initdb/build.gradle startAndWaitOnHealthyContainer
```

Startet einen Docker-Container mit einer PostgreSQL/PostGIS-DB, welche die Edit-DB simuliert. Es werden keine Daten peristiert, alles wird nur im Docker-Container gespeichert und sind nach dem Stoppen des Containers verloren. Die DB startet mit zwei leeren Schemen:

- arp_npl: Nutzungsplanung im kantonalen Modell
- arp_npl_oereb: Rahmenmodell (Transferstruktur)

### (2) Import der notwendigen Daten:
Es müssen folgende Daten in die Edit-DB importiert werden, damit der Datenumbau durchgeführt werden kann und Daten modellkonform in die Transferstruktur exportiert werden können:

- Bundesgesetze und -Verordnungen
- Kantonale Gesetzt und Verordnungen
- Zuständige Stellen
- Nutzungsplanung im kantonalen Modell

```
gradle -I $PWD/init.gradle -b initdb/build.gradle importFederalLegalBasisToOereb importCantonalLegalBasisToOereb importResponsibleOfficesToOereb replaceLandUsePlansData
```

oder

```
gradle -I $PWD/init.gradle -b initdb/build.gradle importData
```

### (3) Datenumbau und -export
Die Daten werden mit einem `SQLExecutor`-Task umgebaut und anschliessend in die Transferstruktur exportiert, geprüft und auf S3 hochgeladen. 

```
gradle -I $PWD/init.gradle -b transfer/build.gradle insertToOereb updateSymbols exportLandUsePlansOereb validateLandUsePlansExport uploadToS3
```

## ÖREB-Datenbank mit Daten

```
gradle -I $PWD/init.gradle -b fat_data_container/build.gradle createOerebDbDockerContainer

```

## Bemerkungen

- Gradle wird ohne Daemon gestartet. Gefühlt immer noch bessere Erfahrungen bezüglich "out of memory" v.a. wenn das XTF gross wird. Ausgeschaltet wird der Daemon in der `gradle.properties`-Datei, die dort liegen muss wo Gradle ausgeführt wird.

