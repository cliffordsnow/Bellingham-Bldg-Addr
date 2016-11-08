# Bellingham-Bldg-Addr
*Not ready for import*

#### Building and Address Import
This project will import data from the City of [Bellingham](cob.org), WA. Bellingham provides a wide array of data from their website, including docks, sidewalks, trees, fire hydrants, roads, and of course addresses and building outlines. Please feel free to offer suggestions and PR to improve the process.

#### License
The City of Bellingham offer open data with no strings attached.

#### Process
This process is built on using PostGIS and Python. It has been developed using Fedora 24. It should work on MacOS.

#### Requirements
* PostGIS
* Python

#### Notes
This is my first attempt using parcel data to help identify address nodes to building outlines. One of the problems that needed to be overcome was buildings that covered more than one parcel. In some cases it appeared that either the building outline was shifted or that the parcel outline was incorrect.

[Just Over](images/just_over.png)

Below is an example of a building in the middle of two parcels

[Middle](middle.png)

Query to select the correct parcel. The percentage, I used 80% seem right for this use.

```
UPDATE bellingham_bldg SET parcel_cod = b.gid
FROM bellingham_parcels p join bellingham_bldg b ON ST_INTERSECTS(b.geom,p.geom)
WHERE b.parcel_cod IS NULL AND ST_AREA(ST_INTERSECTION(p.geom, b.geom)::geometry)/ST_AREA(b.geom::geometry) > .8;
```
