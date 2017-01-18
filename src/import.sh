#!/bin/bash

PGDATABASE=mygis
PGUSER=postgres
SHP2PGSQL=/usr/bin/shp2pgsql

cd ~/OSM/Whatcom/Bellingham

# Drop existing tables if they exist
psql -U ${PGUSER} -d ${PGDATABASE} -f drop.sql

# import addresses, buildings and parcels into postgresql -- transform into EPSG 4326
SRID1=`/home/clifford/bin/get_epsg.py COB_Shps/COB_land_TaxParcelPolys.shp`
${SHP2PGSQL} -s ${SRID1}:4326 COB_Shps/COB_land_TaxParcelPolys public.bellingham_parcels | psql -d ${PGDATABASE} -U ${PGUSER} >/dev/null
SRID2=`/home/clifford/bin/get_epsg.py COB_Shps/COB_land_AddressPoints.shp`
${SHP2PGSQL} -s ${SRID2}:4326 COB_Shps/COB_land_AddressPoints public.bellingham_addr | psql -d ${PGDATABASE} -U ${PGUSER} >/dev/null
SRID3=`/home/clifford/bin/get_epsg.py COB_Shps/COB_struc_Buildings.shp`
${SHP2PGSQL} -s ${SRID3}:4326 COB_Shps/COB_struc_Buildings public.bellingham_bldg | psql -d ${PGDATABASE} -U ${PGUSER} >/dev/null


# This section adds fields to the new tables
psql -d ${PGDATABASE} -U ${PGUSER} -f add_columns.sql

# Add spatial indexes for faster intersection queries
psql -d ${PGDATABASE} -U ${PGUSER} -f add_indexes.sql

# Add unit number to new column unit from main_addre
psql -d ${PGDATABASE} -U ${PGUSER} -f add_unit.sql

# Fixes no longer needed. CoB fixed the error.
# psql -d ${PGDATABASE} -U ${PGUSER} -f fix_garfied.sql

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
