# TODO
* Import Bundesgesetze/-vorschriften und Verlinkung im Umbau.
* Pro Subthema ein Umbau (Schema)?
* `updateSymbols` soll das Starten und Stoppen des WMS-Containers steuern. Warum manchmal der WMS-Server nicht mehr erreichbar ist, ist mir ein Rätsel. Im Browser geht der SLD-Aufruf auch nicht mehr. Container läuft aber noch.

# oereb-datenumbau-npl

Prototyp für den Datenumbau der Nutzungsplanung im kantonalen Datenmodell in das ÖREB-Rahmenmodell mit GRETL. 

Im `gretl-dev`-Ordner sind die Tasks für das Aufsetzen der Entwicklungsumgebung. Mit diesen Tasks wird mit Docker eine Datenbank erstellt mit den benötigten zwei Schemen: `arp_npl` (kantonales Datenmodell, Quellenschema) und `arp_npl_grundnutzung_oereb` (ÖREB-Rahmenmodell, Zielschema). Mit folgendem Befehl wird die das Docker-Image erstellt, der Container gestartet, Daten im kantonalen Modell importiert und zu guter Letzt die kantonalen Gesetze und die zuständigen Stellen importiert:

```
gradle gretl-dev:db:startAndWaitOnHealthyContainer gretl-dev:data:replaceLandUsePlansData gretl:importFederalLegalBasisToOereb gretl:importCantonalLegalBasisToOereb gretl:importResponsibleOfficesToOereb
```

Die kantonalen Gesetzen sind "externe" Assoziationen und werden **nicht** in die INTERLIS-Transferdatei exportiert. Sie sind in der ÖREB-Datenbank bereits vorhanden. Im Gegensatz dazu die zuständigen Stellen. Diese sind Bestandteil der exportierten Nutzungsplanungsdaten im ÖREB-Rahmenmodell. 

Der eigentliche Datenumbau steckt in den Tasks im `gretl`-Ordner. Aufgrund neuer Features in der ili2db-Version > 4.1 ist der Datenumbau "einfacher" und nachvollziehbarer/transparenter. In der vorliegenden Variante wird versucht relativ rasch die Daten im Zielschema zu persistieren, um anschliessend in weiteren Queries den Datenumbau zu vervollständigen. Technisch im Zentrum steht die Klasse/Tabelle `Eigentumsbeschränkung`. Abhängig davon werden die Dokumente und Geometrien abgehandelt.

Die Symbole werden mit einem GRETL OerebIconizerQgis3-Task erzeugt und während des Datenumbaus in die Tabelle geschrieben. Dazu wird ein WMS-Server benötigt, der die notwendigen Symbole via GetLegendGraphics-Request ausliefern kann. Der WMS-Server ist ein Docker-Image mit eingebrannten Dummy-Daten aber korrektem QML (welches dann die korrekten Symbole rendert).

Datenumbau:
```
gradle gretl:startWMSDockerContainer gretl:deleteFromOereb gretl:insertToOereb gretl:updateSymbols
```

Datenexport (beding GRETL mit ili2pg 4.1.1-Snapshot wegen [#290](https://github.com/claeis/ili2db/issues/290)):
```
gradle gretl:exportLandUsePlansOereb
```

## Hinweise 
Trotz der ili2db-Erweiterungen in der Version 4.1, welche den Datenumbau vor allem hinsichtlich Assoziationen vereinfacht, kann es zu Problemen mit Sequenzen resp. zu Primary Keys Kollisionen kommen. Weil neben den eigentlichen Nutzungsplanungsdaten vorgängig noch die Gesetze und die zuständigen Stellen importiert werden, wird für die Primary Keys (`t_id`) die Sequenz "angezapft". Falls jetzt durch den Datenumbau identische Primary Keys geliefert werden (was eben den Datenumbau massiv vereinfacht), kann es zu Kollisionen kommen. Das kann ziemlich robust umgangen werden, wenn der Startwert der Sequenz im Schema `arp_npl_oereb` sehr hoch angesetzt wird (es handelt sich um einen int8-Datentyp). Dazu wird die `--idSeqMin` Option von ili2pg beim Erzeugen des Schemas verwendet.

## ilivalidator
Damit die externen Objekte geprüft werden können, muss die Option `--allObjectsAccessible` verwendet werden. Damit die fehlenden gesetzlichen Grundlagen nicht als Fehler gemeldet werden, muss eine config-File (siehe Ordner `ilivalidator`) verwendet werden:

```
java -jar /Users/stefan/apps/ilivalidator-1.11.0/ilivalidator-1.11.0.jar --allObjectsAccessible --config ilivalidator/config.toml ch.so.arp.nutzungsplanung.oereb.xtf
```


## Fragen

* Können die Queries (für GRETL) parametriesiert werden, damit für Grundnutzung und überlagernden Objekte die gleichen SQL-Dateien verwendet werden können?
* Definitiv Inbetriebnahme noch nicht geregelt.
* Welches Docker-Image für Iconizer? Am ehesten zukünftig das offizielle ÖREB-WMS-Image. Achtung: das jetzt vorhandene ist eher quick 'n' dirty. Oder soll zukünftig der Live-WMS verwendet werden? Gut wäre wahrscheinlich schon ein Base-Image und/oder nur noch das Mounten der Daten und nicht das Dockerfile, das gebuildet werden muss. Sonst liegen plötzlich ein Haufen Dockerfile irgendwo rum in den Repos, die man ggf. auch wieder nachführen muss.


