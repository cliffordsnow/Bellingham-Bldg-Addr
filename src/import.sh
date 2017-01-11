#!/bin/bash

cd ~/OSM/Whatcom/Bellingham

# Drop existing tables if they exist
psql -U postgres -d mygis -f drop.sql

# import addresses, buildings and parcels into postgresql -- transform into EPSG 4326
SRID1=`/home/clifford/bin/get_epsg.py COB_Shps/COB_land_TaxParcelPolys.shp`
/usr/bin/shp2pgsql -s ${SRID1}:4326 COB_Shps/COB_land_TaxParcelPolys public.bellingham_parcels | psql -d mygis -U postgres >/dev/null
SRID2=`/home/clifford/bin/get_epsg.py COB_Shps/COB_land_AddressPoints.shp`
/usr/bin/shp2pgsql -s ${SRID2}:4326 COB_Shps/COB_land_AddressPoints public.bellingham_addr | psql -d mygis -U postgres >/dev/null
SRID3=`/home/clifford/bin/get_epsg.py COB_Shps/COB_struc_Buildings.shp`
/usr/bin/shp2pgsql -s ${SRID3}:4326 COB_Shps/COB_struc_Buildings public.bellingham_bldg | psql -d mygis -U postgres >/dev/null


# This section adds fields to the new tables
psql -d mygis -U postgres -f add_columns.sql

# Add unit number to new column unit from main_addre
psql -d mygis -U postgres -f add_unit.sql

# Fixes no longer needed. CoB fixed the error.
# psql -d mygis -U postgres -f fix_garfied.sql

# Add full street name to address
psql -d mygis -U postgres -f add_full_street.sql

# add the parcel_cod to buildings completely inside of parcel
psql -d mygis -U postgres -f add_parcel_id2bldgs.sql
# This second query captures the buildings that lie just over a parcel boundary
psql -d mygis -U postgres -f add_parcelid2partial_bldg.sql


# Count the number of buildings in a parcel
psql -d mygis -U postgres -f no_bldgs2parcels.sql

# Add Building id to address
psql -d mygis -U postgres -f add_bldg_id2addr.sql
psql -d mygis -U postgres -f add_bldg_id2addr_not_in_bldg.sql


# Add count of addresses in buildings and parcels - slow query - 15 minutes on my workstation
psql -d mygis -U postgres -f add_no2bldg.sql
psql -d mygis -U postgres -f add_no2parcel.sql

# Create two views, one with all buildings and their addresses
# the other with just standalone addresses. These will be merged when creating the .osm import file.

psql -d mygis -U postgres -f bellingham_ab.sql
psql -d mygis -U postgres -f bellingham_ao.sql
