#!/usr/bin/env bash

declare -A schemas
schemas[arp_npl]="SO_Nutzungsplanung_20171118"
schemas[agi_oereb_npl_staging]="OeREBKRMvs_V1_1;OeREBKRMtrsfr_V1_1"

for schema in ${!schemas[@]}; do
  java -jar $ILI2PG_PATH/ili2pg-4.1.0.jar \
  --dbschema ${schema} --models ${schemas[${schema}]} \
  --defaultSrsCode 2056 --strokeArcs --createGeomIdx --createFk --createFkIdx --createEnumTabs --beautifyEnumDispName --createMetaInfo --createUnique --createNumChecks --nameByTopic \
  --createBasketCol --createDatasetCol \
  --createImportTabs --createscript sql/${schema}.sql
done

