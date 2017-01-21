update bellingham_addr a set bldg_id = b.gid from bellingham_bldg b, bellingham_parcel p
where a.parcel_code =  b.parcel_code and b.parcel_code = p.parcel_code and a.bldg_id is null and p.no_bldgs = 1 and b.no_addr is null
