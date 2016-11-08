update bellingham_bldg b set parcel_cod = p.parcel_cod from bellingham_parcels p where st_contains(p.geom, b.geom)
