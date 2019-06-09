# oereb-datenumbau-npl

* Was geht hier ab? Warum? Wie? Testing - Prototyping...
* Wie kann das dann in Betrieb genommen werden? 
* Muss Repo getrennt werden? Oder ist das ok so? Oder leicht anders aufgebaut?


## Hinweise

* nein, noch nicht (sqlEnableNull beim Erstellen des Staging-Scheams während der Entwicklung, ggf. (resp. falls möglich) wieder ausschalten.)
* --idSeqMin: Vorhandende Dokumente (Gesetzte etc.) "verbrauchen" die Sequenz. Das kann zu Kollisionen mit Primary Keys führen, die aus einer anderen Tabelle reinkopiert werden.

## Starting from scratch

1. Buildet Datenbank-Docker-Image
2. Startet die Datenbank als Docker-Container:
   - Erstellt `edit`-Datenbank
   - Erstellt `arp_npl`-Schema
   - Erstellt `agi_oereb_npl_staging`-Schema
3. Importiert kantonale NPL-Daten in das `arp_npl`-Schema.
4. Importiert die kantonalen gesetzlichen Grundlagen und die zuständigen Stellen für die NPL in das `agi_oereb_npl_staging`-Schema.

Schritt 1 - 3 sind "nur" dazu gedacht eine Entwicklungsumgebung aufzubauen, damit man die gleichen Rahmenbedingungen wie in der Produktion hat. Schritt 4 gehört eher zum Produktionsprozess, wobei dieser nicht tagtäglich gemacht werden muss. Nur bei einer Änderung dieser Daten. Diese Nachführungsprozesse sind noch zu definieren.

```
gradle gretl-dev:db:startAndWaitOnHealthyContainer gretl-dev:data:replaceLandUsePlansData gretl:importCantonalLegalBasisToStaging gretl:importResponsibleOfficesToStaging
```



