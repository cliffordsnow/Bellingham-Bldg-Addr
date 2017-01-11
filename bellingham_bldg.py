"""
Translation rules for Bellingham Buildings

Copyright 2016 Clifford Snow

"""

def filterTags(attrs):
    if not attrs: 
        return

    tags = {}
    tags['building'] = 'yes'
    if 'ADDR_NUM' in attrs and attrs['ADDR_NUM'] != '':
        tags['addr:housenumber'] = attrs['ADDR_NUM']
    if 'UNIT' in attrs and attrs['UNIT'] != '':
        tags['addr:unit'] = attrs['UNIT']
    if 'STREET' in attrs and attrs['STREET'] != '':
        tags['addr:street'] = attrs['STREET']
    if 'CITY' in attrs and attrs['CITY'] != '':
        tags['addr:city'] = attrs['CITY']
    if 'ZIP' in attrs and attrs['ZIP'] != '':
        tags['addr:postcode'] = attrs['ZIP']
    if 'BLDGTYPE' in attrs and attrs['BLDGTYPE'] != '':
        if attrs['BLDGTYPE'] == 'CABIN':
            tags['building'] = 'yes'
        if attrs['BLDGTYPE'] == 'DUPLX':
            tags['building'] = 'house'
        if attrs['BLDGTYPE'] == 'HOUSE':
            tags['building'] = 'house'
        if attrs['BLDGTYPE'] == 'MOBIL':
            tags['building'] = 'mobile_home'
    if 'FLOORS' in attrs and attrs['FLOORS'] != '0.0':
        tags['building:levels'] = attrs['FLOORS']
    if 'NAME' in attrs and attrs['NAME'] != '':
        tags['name'] = attrs['NAME']


    return tags

