#!/bin/bash

if [ ! -d /home/clifford/OSM/Whatcom/Bellingham/osm/ ]
then
	mkdir /home/clifford/OSM/Whatcom/Bellingham/osm/ 
fi
	

while read line
do
    id=`echo $line |awk '{print $1}'`

    if [ -e /tmp/${id}a.shp ]
    then
      echo "Removing old files"
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

    if [ -e ~/OSM/Whatcom/Bellingham/osm/${id}.osm.gz ]
    then
      rm ~/OSM/Whatcom/Bellingham/osm/${id}.osm.gz
    fi

    pgsql2shp -f /tmp/${id}b -h localhost -u postgres mygis "SELECT b.* FROM bellingham_ba b, whatcom_votdst v WHERE ST_CONTAINS(v.geom, st_centroid(b.geom)) AND vtdst10 = '${id}'"
    pgsql2shp -f /tmp/${id}a -h localhost -u postgres mygis "SELECT a.* FROM bellingham_ao a, whatcom_votdst v WHERE ST_CONTAINS(v.geom, a.geom) AND vtdst10 = '${id}'"
    ~/Development/ogr2osm/ogr2osm.py -f -t ~/OSM/Whatcom/Bellingham/bellingham_bldg.py /tmp/${id}b.shp -o /tmp/${id}b.osm
    ~/Development/ogr2osm/ogr2osm.py -f -t ~/OSM/Whatcom/Bellingham/bellingham_addr.py /tmp/${id}a.shp -o /tmp/${id}a.osm
    python ~/OSM/Whatcom/Bellingham/merge_osm2.py /tmp/${id}b.osm /tmp/${id}a.osm ${id}.osm
    mv ${id}.osm ~/OSM/Whatcom/Bellingham/osm
    gzip ~/OSM/Whatcom/Bellingham/osm/${id}.osm
done < votdst.lst
