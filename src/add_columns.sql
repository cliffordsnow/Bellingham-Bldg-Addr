-- add new columns into bellingham addr, bldg and parcel tables

ALTER TABLE bellingham_addr 
	ADD COLUMN unit VARCHAR(10),
	ADD COLUMN bldg_id BIGINT,
	ADD COLUMN street VARCHAR(80);

ALTER TABLE bellingham_bldg
	ADD COLUMN parcel_code VARCHAR(12),
	ADD COLUMN no_addr INTEGER;

ALTER TABLE bellingham_parcel 
	ADD COLUMN no_bldgs INTEGER,
	ADD COLUMN no_addr INTEGER;
