#!/usr/bin/python

import os.path
import sys
import sys
from osgeo import osr
import urllib
import json

shp_file = sys.argv[1]
prj_file = shp_file[0:-4] + '.prj'

#Try detecting the SRID

if os.path.isfile(prj_file):
    prj_filef = open(prj_file, 'r')
    prj_txt = prj_filef.read()
    prj_filef.close()
    srs = osr.SpatialReference()
    srs.ImportFromESRI([prj_txt])
    srs.AutoIdentifyEPSG()
    code = srs.GetAuthorityCode(None)
    if code:
        srid = code
    else:
        #Ok, no luck, lets try with the OpenGeo service
        query = urllib.urlencode({
            'exact' : True,
            'error' : True,
            'mode' : 'wkt',
            'terms' : prj_txt})
        webres = urllib.urlopen('http://prj2epsg.org/search.json', query)
        jres = json.loads(webres.read())
        if jres['codes']:
            srid = int(jres['codes'][0]['code'])

else:
    print "Unable to open ", prj_file
    sys.exit(1)

if srid:
    print srid
    sys.exit(0)
else:
    sys.exit(1)
