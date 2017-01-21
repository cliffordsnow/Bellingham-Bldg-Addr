update bellingham_bldg b set parcel_code = p.parcel_code from bellingham_parcel p where st_contains(p.geom, b.geom)
