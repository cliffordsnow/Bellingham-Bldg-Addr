update bellingham_parcel set no_bldgs = subquery.count from ( select p.gid, count(*) as count from bellingham_bldg b,
bellingham_parcel p where p.parcel_code = b.parcel_code group by p.gid) as subquery 
where subquery.gid is not null and bellingham_parcel.gid = subquery.gid
