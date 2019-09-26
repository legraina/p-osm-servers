OSM SERVERS
=====================
The configuration proposed here allows to run osrm and nominatim on the same machine. There are four containers:
- nginx: this container is simply used to redirect nominatim requests to the nominatim container, and the other requests to osrm.
- osrm: this container returns the route associated to two gps positions. See http://project-osrm.org/ for more information.
- nominatim: this container encodes and decodes places to gps positions. See https://wiki.openstreetmap.org/wiki/Nominatim for more information.
- postgis: this container is a postgresql database with postgis loaded. We need also to add the nominatim library to the container with a volume.

Configuration
--------------------
https://download.geofabrik.de/ proposes packages of openstreetmap data. Find the part of the world that interests you and download the pbf. This file will be used by osrm and nominatim.
For osrm, you must give the path to the file in the command.
For nominatim, you must also give the path to the file with the flag -o or --osm-file.

For the US, you may also have more accurate data for nominatim with Tiger.
Add the flag -t or --tiger with the path to the TIGER folder with all the zip files to your command for nominatim.
You may download the tiger data that you need here and look for the edges folder once the year chosen: ftp://ftp2.census.gov/geo/tiger. If you want to download only a specific state, you just need to select all the zip files starting with the same Census state FIPS code. For DC 2019 (FIPS code 11), you need to get: ```wget -r ftp://ftp2.census.gov/geo/tiger/TIGER2019/EDGES/tl_2019_11*```

Once, the osm files and tiger have been imported, you do not need these flags anymore.
You may remove them from the command (especially tiger, as you don't want to reimport these files everytime).

If you want to run continuous updates for nominatim, you should find the path to the osh files in geofabrik and pass this url to nominatim with the flag -u or --update.

Finally, you can load different map in both server and switch between them.
For osrm, just change the input files. For nominatim, you must change the environment variable for the database (PGDATABASE) to point to the right database.

Note, that git lfs is used for storing the data. You need to use git-lfs pull to download the data repository.

Usage
-------------------
First start all the services with:
```bash
docker-compose up -d
```

Then, when all the imports are finished, you may connect to nominatim with:
```bash
curl "http://localhost/nominatim/search/?q=White+House&format=json&addressdetails=1&limit=1"
```
```json
[{
    "place_id": "211368",
    "licence": "Data © OpenStreetMap contributors, ODbL 1.0. https:\/\/www.openstreetmap.org\/copyright",
    "osm_type": "way",
    "osm_id": "238241022",
    "boundingbox": ["38.8974898", "38.897911", "-77.0368542", "-77.0362526"],
    "lat": "38.8976998",
    "lon": "-77.0365534886228",
    "display_name": "White House, 1600, Pennsylvania Avenue Northwest, Golden Triangle, Washington, District of Columbia, 20500, United States of America",
    "class": "office",
    "type": "government",
    "importance": 0.201,
    "address": {
        "address29": "White House",
        "house_number": "1600",
        "pedestrian": "Pennsylvania Avenue Northwest",
        "neighbourhood": "Golden Triangle",
        "city": "Washington",
        "state": "District of Columbia",
        "postcode": "20500",
        "country": "United States of America",
        "country_code": "us"
    }
}]
```

and osrm with:
```bash
curl "http://localhost/route/v1/driving/-77.0365534886228,38.8976998;-77.012499,38.889866"
```
```json
{
  "code": "Ok",
  "routes": [
    {
      "geometry": "agllFnneuM@dHjc@@Dq_Ck@cAzHkc@Rk@rCE",
      "legs": [
        {
          "steps": [

          ],
          "distance": 3234.9,
          "duration": 295.2,
          "summary": "",
          "weight": 295.2
        }
      ],
      "distance": 3234.9,
      "duration": 295.2,
      "weight_name": "routability",
      "weight": 295.2
    }
  ],
  "waypoints": [
    {
      "hint": "nr0AgOwZAIB4AAAAAAAAALoAAAAAAAAAg_xIQgAAAAB6h5tCAAAAAHgAAAAAAAAAugAAAAAAAACLAAAAVX5o-wiJUQL3g2j7JIhRAgQAnwVczNwP",
      "distance": 127.671968,
      "name": "",
      "location": [
        -77.037995,
        38.897928
      ]
    },
    {
      "hint": "CyAAgHAfAIAGAAAAAQAAAA8AAAAfAAAAcSvnQHjuRj_Uy4NBMxAJQgYAAAABAAAADwAAAB8AAACLAAAA7eFo-4ppUQLt4Wj7imlRAgIAbwtczNwP",
      "distance": 0,
      "name": "1st Street Northwest",
      "location": [
        -77.012499,
        38.889866
      ]
    }
  ]
}
```
