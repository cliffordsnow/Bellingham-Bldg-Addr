-- add new columns into bellingham addr, bldg and parcel tables

CREATE INDEX bellingham_addr_gist ON bellingham_addr USING GIST(geom);

CREATE INDEX bellingham_bldg_gist ON bellingham_bldg USING GIST(geom);

CREATE INDEX bellingham_parcels_gist ON bellingham_parcels USING GIST(geom);
