#!/bin/bash

WORKINGDIR=/home/clifford/OSM/Whatcom/Bellingham
PGDATABASE=mygis
PGUSER=postgres
SHP2PGSQL=`which shp2pgsql`
ORG2OGR=/home/clifford/bin/ogr2osm.py

cd ${WORKINGDIR}

wget https://www.cob.org/data/gis/FGDB_Files/COB_Land_public.gdb.zip
wget https://www.cob.org/data/gis/FGDB_Files/COB_Structures.gdb.zip
wget https://www.cob.org/data/gis/FGDB_Files/COB_Transportation.gdb.zip

unzip -o  COB_Structures.gdb.zip
unzip -o  COB_Land_public.gdb.zip
unzip -o  COB_Transportation.gdb.zip

rm *.zip

echo "Drop existing tables - we'll recreate"
# Drop existing tables if they exist
psql -U ${PGUSER} -d ${PGDATABASE} -f drop.sql

# Import Precincts just once. We don't really care if they change.
if [ ! -f precincts.lst ]
then
	wget https://www.cob.org/data/gis/FGDB_Files/COB_Planning.gdb.zip
	unzip -o  COB_Planning.gdb.zip
	echo "Importing Precincts"
        ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Planning.gdb" "plan_Precincts" -nln bellingham_precinct -lco GEOMETRY_NAME=geom -select precinct_number
	psql ${PGDATABASE} -Atc "SELECT precinct_number FROM bellingham_precinct;" > precincts.lst
fi

# import Buildings 

echo "Import buildings into Postgresql"
# uncomment the following when COB fixes problem with getting updates to their download service
#ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Structures.gdb" "struc_Buildings" -nln bellingham_bldg -lco GEOMETRY_NAME=geom -select year,type,name,num_floors,bldgtype,yrbuilt,ruleid,created_user,created_date,last_edited_user,last_edited_date

# remove the following when COB fixes problem with getting updates to their download service.
ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Buildings.gdb" "struc_Buildings" -nln bellingham_bldg -lco GEOMETRY_NAME=geom -select year,type,name,num_floors,bldgtype,yrbuilt,ruleid,created_user,created_date,last_edited_user,last_edited_date

echo "Import parcels into Postgresql"
# import parcels into ${PGUSER}ql -- transform into EPSG 4326
ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Land_public.gdb" "land_TaxParcelPolys" -nln bellingham_parcel -lco GEOMETRY_NAME=geom -select parcel_code,created_date,last_edited_date

echo "Import addresses into Postgresql"
ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Land_public.gdb" "land_AddressPoints" -nln bellingham_addr -lco GEOMETRY_NAME=geom -select addr_num,street_name,st_nameid,address_id,main_address_display,zip,plus4,status,parcel_code,created_date,last_edited_date,unittype,unitid,municipality,pointtype,floor,parcel_unitid

echo "Import Roads into Postgresql"
ogr2ogr -overwrite -a_srs "EPSG:2285" -t_srs "EPSG:4326" -skipfailures -f "PostgreSQL" PG:"host=localhost user=${PGUSER} dbname=${PGDATABASE}" "COB_Data/COB_Transportation.gdb" "tran_WhatcomRoads" -nln whatcom_roads -lco GEOMETRY_NAME=geom -select name,st_prefix,st_name,st_type,st_suffix,nameid,jurisdiction,st_class,oneway,speedlimit,busroute,alt_name,centerlineid,hwy_number,last_edited_date,nameidaddr,truckroute,hierarchy,truckrouteclass

echo "change yrbuilt from 0 to NULL"
psql -d ${PGDATABASE} -U ${PGUSER} -c "UPDATE bellingham_bldg SET yrbuilt = NULL where yrbuilt = 0;"

echo "start configuring tables"
# rename objectid to id
psql -d ${PGDATABASE} -U ${PGUSER} -f rename_objectid2gid.sql


# This section adds fields to the new tables
psql -d ${PGDATABASE} -U ${PGUSER} -f add_columns.sql

# Add unit number to new column unit from main_addre
psql -d ${PGDATABASE} -U ${PGUSER} -f add_unit.sql

psql -d ${PGDATABASE} -U ${PGUSER} -f add_indexes.sql
echo "complete configuring tables"

echo "Starting adding information to tables to speed execution later"
# Add full street name to address
psql -d ${PGDATABASE} -U ${PGUSER} -f add_full_street.sql

# add the parcel_cod to buildings completely inside of parcel
psql -d ${PGDATABASE} -U ${PGUSER} -f add_parcel_id2bldgs.sql
# This second query captures the buildings that lie just over a parcel boundary
psql -d ${PGDATABASE} -U ${PGUSER} -f add_parcelid2partial_bldg.sql


# Count the number of buildings in a parcel
psql -d ${PGDATABASE} -U ${PGUSER} -f no_bldgs2parcels.sql

# Add Building id to address
psql -d ${PGDATABASE} -U ${PGUSER} -f add_bldg_id2addr.sql
psql -d ${PGDATABASE} -U ${PGUSER} -f add_bldg_id2addr_not_in_bldg.sql


# Add count of addresses in buildings and parcels - slow query - 15 minutes on my workstation
psql -d ${PGDATABASE} -U ${PGUSER} -f add_no2bldg.sql
psql -d ${PGDATABASE} -U ${PGUSER} -f add_no2parcel.sql

# Create two views, one with all buildings and their addresses
# the other with just standalone addresses. These will be merged when creating the .osm import file.

psql -d ${PGDATABASE} -U ${PGUSER} -f bellingham_ab.sql
psql -d ${PGDATABASE} -U ${PGUSER} -f bellingham_ao.sql

echo "Done"
