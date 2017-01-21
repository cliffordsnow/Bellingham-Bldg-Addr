#!/bin/bash

WORKINGDIR=/Users/cliffordsnow/OSM/Whatcom/Bellingham
OGR2OSM=/Users/cliffordsnow/bin/ogr2osm.py
PGUSER=postgres
PGDATABASE=cliffordsnow

cd ${WORKINGDIR}

if [ ! -d ${WORKINGDIR}/osm/ ]
then
	mkdir ${WORKINGDIR}/osm/ 
fi
	
if [ ! -d ${WORKINGDIR}/tmp/ ]
then
	mkdir ${WORKINGDIR}/tmp/ 
fi
	

while read line
do
    id=`echo $line |awk '{print $1}'`

    if [ -e ${WORKINGDIR}/tmp/${id}a.shp ]
    then
      echo "Removing old files"
      rm ${WORKINGDIR}/tmp/${id}a.shp
      rm ${WORKINGDIR}/tmp/${id}a.shx
      rm ${WORKINGDIR}/tmp/${id}a.prj
      rm ${WORKINGDIR}/tmp/${id}a.dbf
      rm ${WORKINGDIR}/tmp/${id}a.osm
      rm ${WORKINGDIR}/tmp/${id}b.shp
      rm ${WORKINGDIR}/tmp/${id}b.shx
      rm ${WORKINGDIR}/tmp/${id}b.prj
      rm ${WORKINGDIR}/tmp/${id}b.dbf
      rm ${WORKINGDIR}/tmp/${id}b.osm
    fi

    if [ -e ${WORKINGDIR}/osm/${id}.osm.gz ]
    then
      rm ${WORKINGDIR}/osm/${id}.osm.gz
    fi

    pgsql2shp -f ${WORKINGDIR}/tmp/${id}b -h localhost -u ${PGUSER} ${PGDATABASE} "SELECT b.* FROM bellingham_ba b, bellingham_precinct p WHERE ST_CONTAINS(p.geom, st_centroid(b.geom)) AND precinct_number = '${id}' and reason(st_isvaliddetail(b.geom)) is null"
    pgsql2shp -f ${WORKINGDIR}/tmp/${id}a -h localhost -u ${PGUSER} ${PGDATABASE} "SELECT a.* FROM bellingham_ao a, bellingham_precinct p WHERE ST_CONTAINS(p.geom, a.geom) AND precinct_number  = '${id}'"
    ${OGR2OSM} -f -t ${WORKINGDIR}/bellingham_bldg.py ${WORKINGDIR}/tmp/${id}b.shp -o ${WORKINGDIR}/tmp/${id}b.osm
    ${OGR2OSM} -f -t ${WORKINGDIR}/bellingham_addr.py ${WORKINGDIR}/tmp/${id}a.shp -o ${WORKINGDIR}/tmp/${id}a.osm
    python ${WORKINGDIR}/merge_osm2.py ${WORKINGDIR}/tmp/${id}b.osm ${WORKINGDIR}/tmp/${id}a.osm ${id}.osm
    mv ${id}.osm ${WORKINGDIR}/osm
    gzip ${WORKINGDIR}/osm/${id}.osm
done < precincts.lst
