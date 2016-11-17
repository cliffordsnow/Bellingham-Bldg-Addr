#!/bin/bash

cd ~/OSM/Whatcom/Bellingham

if [ ! -d osm ]
then
	mkdir osm 
fi

psql -t -d mygis -U postgres -c "Select precinct_n from bellingham_precincts" | gawk '/[0-9][0-9][0-9]/ {print $1 }' > precincts.lst

	

while read line
do
    id=`echo $line |awk '{print $1}'`

    if [ -e /tmp/${id}a.shp ]
    then
#      echo "Removing old files"
      rm /tmp/${id}a.shp
      rm /tmp/${id}a.shx
      rm /tmp/${id}a.prj
      rm /tmp/${id}a.dbf
      rm /tmp/${id}a.osm
      rm /tmp/${id}b.shp
      rm /tmp/${id}b.shx
      rm /tmp/${id}b.prj
      rm /tmp/${id}b.dbf
      rm /tmp/${id}b.osm
    fi

    if [ -e osm/${id}.osm.gz ]
    then
      rm osm/${id}.osm.gz
    fi

    pgsql2shp -f /tmp/${id}b -h localhost -u postgres mygis "SELECT b.* FROM bellingham_ba b, bellingham_precincts v WHERE ST_CONTAINS(v.geom, st_centroid(b.geom)) AND precinct_n = '${id}'"
    pgsql2shp -f /tmp/${id}a -h localhost -u postgres mygis "SELECT a.* FROM bellingham_ao a, bellingham_precincts v WHERE ST_CONTAINS(v.geom, a.geom) AND precinct_n = '${id}'"
    ~/Development/ogr2osm/ogr2osm.py -f -t bellingham_bldg.py /tmp/${id}b.shp -o /tmp/${id}b.osm
    ~/Development/ogr2osm/ogr2osm.py -f -t bellingham_addr.py /tmp/${id}a.shp -o /tmp/${id}a.osm

# merge_osm2 merges two .osm files, one containing polygons the other points. 
    python merge_osm2.py /tmp/${id}b.osm /tmp/${id}a.osm ${id}.osm
    mv ${id}.osm osm
    gzip osm/${id}.osm
done< precincts.lst
