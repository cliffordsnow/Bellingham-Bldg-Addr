CREATE OR REPLACE VIEW  bellingham_ao AS(
SELECT gid, addr_num, unit, street, INITCAP(municipality) AS city, zip, geom 
FROM bellingham_addr WHERE bldg_id IS NULL
UNION
SELECT a.gid, addr_num, unit ,street, INITCAP(municipality) AS city, zip, a.geom
FROM bellingham_addr a, bellingham_bldg b
WHERE bldg_id = b.gid AND no_addr > 1)
