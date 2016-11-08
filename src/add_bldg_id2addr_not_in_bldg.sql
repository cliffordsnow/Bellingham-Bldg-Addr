update bellingham_addr a set bldg_id = b.gid from bellingham_bldg b, bellingham_parcels p
where a.parcel_cod =  b.parcel_cod and b.parcel_cod = p.parcel_cod and a.bldg_id is null and p.no_bldgs = 1 and b.no_addr is null
