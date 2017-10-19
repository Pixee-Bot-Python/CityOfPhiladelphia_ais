#!/usr/bin/env bash

postgis_dsn=$1
oracle_dsn_gis_ais=$2

# ADDRESS_SUMMARY
echo "updating address_summary"
echo "adding spatial columns"
psql -U ais_engine -h localhost -d ais_engine << EOF
ALTER TABLE address_summary_transformed ADD COLUMN objectid serial;
ALTER TABLE address_summary_transformed ADD COLUMN shape geometry(Point,2272);
UPDATE address_summary_transformed SET shape = st_setsrid(st_makepoint(geocode_x, geocode_y), 2272);
EOF
echo "reading address_summary"
the_el read address_summary_transformed --connection-string $postgis_dsn --output-file address_summary.csv --geometry-support postgis --from-srid 2272 --to-srid 2272
echo "cleaning address_summary"
python remove_special_characters.py "address_summary.csv" "address_summary_cleaned.csv"
echo "describing address_summary"
the_el describe_table address_summary_transformed --connection-string $postgis_dsn --output-file address_summary_schema.json --geometry-support postgis
>>>>>>> Read/describe transformed address_summary table.
echo "creating temp table"
python create_table_from_schema.py "address_summary"
echo "writing to temp table"
the_el write t_address_summary --connection-string $oracle_dsn_gis_ais --table-schema-path address_summary_schema.json --geometry-support sde --input-file address_summary_cleaned.csv --skip-headers
if [ $? -ne 0 ]
then
  echo "Writing to temp address_summary table failed. Exiting."
  psql -U ais_engine -h localhost -d ais_engine -c "ALTER TABLE address_summary_transformed DROP COLUMN objectid;"
  psql -U ais_engine -h localhost -d ais_engine -c "ALTER TABLE address_summary_transformed DROP COLUMN shape;"
  exit 1;
fi
echo "swapping table"
the_el swap_table t_address_summary test_address_summary --connection-string $oracle_dsn_gis_ais
echo "removing extra columns"
psql -U ais_engine -h localhost -d ais_engine -c "ALTER TABLE address_summary_transformed DROP COLUMN objectid;"
psql -U ais_engine -h localhost -d ais_engine -c "ALTER TABLE address_summary_transformed DROP COLUMN shape;"
echo "finished updating address_summary"

#DOR_PARCEL_ADDRESS_COMP_ANALYSIS
echo "Updating dor_parcel_address_analysis"
the_el read dor_parcel_address_analysis --connection-string $postgis_dsn --output-file dor_parcel_address_analysis.csv --geometry-support postgis --from-srid 2272 --to-srid 2272
the_el describe_table dor_parcel_address_analysis --connection-string $postgis_dsn --output-file dor_parcel_address_analysis_schema.json --geometry-support postgis
python create_table_from_schema.py "dor_parcel_address_analysis"
the_el write t_dor_parcel_address_analysis --connection-string $oracle_dsn_gis_ais --table-schema-path dor_parcel_address_analysis_schema.json --geometry-support sde --input-file dor_parcel_address_analysis.csv --skip-headers
if [ $? -ne 0 ]
then
  echo "Writing to temp dor_parcel_address_analysis table failed. Exiting."
  exit 1;
fi
the_el swap_table t_dor_parcel_address_analysis dor_parcel_address_analysis --connection-string $oracle_dsn_gis_ais

