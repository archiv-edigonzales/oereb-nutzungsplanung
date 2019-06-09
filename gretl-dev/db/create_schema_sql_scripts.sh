#!/usr/bin/env bash

java -jar $ILI2PG_PATH/ili2pg-4.1.0.jar \
--dbschema arp_npl --models SO_Nutzungsplanung_20171118 \
--defaultSrsCode 2056 --strokeArcs --createGeomIdx --createFk --createFkIdx --createEnumTabs --beautifyEnumDispName --createMetaInfo --createUnique --createNumChecks --nameByTopic \
--createBasketCol --createDatasetCol \
--createImportTabs --createscript sql/arp_npl.sql

java -jar $ILI2PG_PATH/ili2pg-4.1.0.jar \
--idSeqMin 1000000000000 \
--dbschema agi_oereb_npl_staging --models "OeREBKRMvs_V1_1;OeREBKRMtrsfr_V1_1" \
--defaultSrsCode 2056 --strokeArcs --createGeomIdx --createFk --createFkIdx --createEnumTabs --beautifyEnumDispName --createMetaInfo --createUnique --createNumChecks --nameByTopic \
--createBasketCol --createDatasetCol \
--createImportTabs --createscript sql/agi_oereb_npl_staging.sql
