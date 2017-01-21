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
    if 'FLOORS' in attrs and attrs['FLOORS'] != '':
        tags['building:levels'] = attrs['FLOORS']
    if 'NAME' in attrs and attrs['NAME'] != '':
        name = attrs['NAME'].title()  # Probably shouldn't titlecase everything
        if name[-3:] == ' Es': name = name[:-3] + ' Elementary School'
        if name[-3:] == ' Ms': name = name[:-3] + ' Middle School'
        if name[-3:] == ' Hs': name = name[:-3] + ' High School'
        if name[:3] == 'Bfd':  name = 'BFD' + name[3:]
        if name[:3] == 'Bsd':  name = 'BSD' + name[3:]
        if name[:2] == 'Cp':   name = 'CP'  + name[2:]
        if name[:2] == 'Fd':   name = 'FD'  + name[2:]
        if name[:3] == 'Us ':  name = 'US ' + name[3:]
        if name[:3] == 'Wsu':  name = 'WSU' + name[3:]
        if name[:3] == 'Wta':  name = 'WTA' + name[3:]
        if name[:3] == 'Wwu':  name = 'WWU' + name[3:]
        if name[:4] == 'Ymca': name = 'YMCA' + name[4:]
        # if name ends with a 2-letter WWU bldg appreviation, fix that w/ a regex?
        tags['name'] = name
    if 'YRBUILT' in attrs and attrs['YRBUILT'] != '':
        tags['start_date'] = attrs['YRBUILT']

    return tags

