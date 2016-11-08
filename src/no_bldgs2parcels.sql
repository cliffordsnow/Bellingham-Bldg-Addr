update bellingham_parcels set no_bldgs = subquery.count from ( select p.gid, count(*) as count from bellingham_bldg b,
bellingham_parcels p where p.parcel_cod = b.parcel_cod group by p.gid) as subquery 
where subquery.gid is not null and bellingham_parcels.gid = subquery.gid
