OSM SERVERS
---------------------
The configuration proposed here allows to run graphhopper and nominatim on the same machine. There are four containers:
- nginx: this container is simply used to redirect nominatim requests to the nominatim container, and the other requests to graphhopper.
- graphhopper: this container returns the route associated to two gps positions. See https://www.graphhopper.com/open-source/ for more information.
- nominatim: this container encodes and decodes places to gps positions. See https://wiki.openstreetmap.org/wiki/Nominatim for more information.
- postgis: this container is a postgresql database with postgis loaded. We need also to add the nominatim library to the container with a volume.

Configuration
--------------------
https://download.geofabrik.de/ proposes packages of openstreetmap data. Find the part of the world that interests you and download the pbf. This file will be used by graphhopper and nominatim.
For graphhopper, you must give the path to the file in the command.
For nominatim, you must also give the path to the file with the flag -o or --osm-file.

For the US, you may also have more accurate data for nominatim with Tiger.
Add the flag -t or --tiger with the path to the TIGER folder with all the zip files to your command for nominatim.
You may download the tiger data that you need here: https://www.census.gov/cgi-bin/geo/shapefiles/index.php.

Once, the osm files and tiger have been imported, you do not need these flags anymore.
You may remove them from the command (especially tiger, as you don't want to reimport these files everytime).

If you want to run continuous updates for nominatim, you should find the path to the osh files in geofabrik and pass this url to nominatim with the flag -u or --update.

Finally, you can load different map in both server and switch between them.
For graphhopper, just change the input files. For nominatim, you must change the environment variable for the database (PGDATABASE) to point to the right database.

Note, that git lfs is used for storing the data. You need to use git-lfs pull to download the data repository.

Usage
-------------------
First start all the services with:
```bash
docker-compose up -d
```

Then, when all the imports are finished, you may connect to nominatim with:
```bash
curl - s "http://localhost/nominatim/search/?q=White+House&format=json&addressdetails=1&limit=1"
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

and graphhopper with:
```bash
curl -s "http://localhost/route?point=38.900236,-77.036558&point=38.889866,-77.012499"
```
```json
{
    "hints": {
        "visited_nodes.average": "142.0",
        "visited_nodes.sum": "142"
    },
    "paths": [{
        "instructions": [{
            "distance": 256.223,
            "heading": 180.3,
            "sign": 0,
            "interval": [0, 2],
            "text": "Continue onto 16th Street Northwest",
            "time": 14206,
            "street_name": "16th Street Northwest"
        }, {
            "distance": 523.419,
            "sign": 2,
            "interval": [2, 4],
            "text": "Turn right onto 15th Street Northwest",
            "time": 28987,
            "street_name": "15th Street Northwest"
        }, {
            "distance": 1558.922,
            "sign": -2,
            "interval": [4, 20],
            "text": "Turn left onto Pennsylvania Avenue Northwest",
            "time": 86327,
            "street_name": "Pennsylvania Avenue Northwest"
        }, {
            "distance": 366.355,
            "sign": 2,
            "interval": [20, 27],
            "text": "Turn right onto I 395 Alternate",
            "time": 24829,
            "street_name": "I 395 Alternate"
        }, {
            "distance": 81.255,
            "sign": 2,
            "interval": [27, 29],
            "text": "Turn right onto 1st Street Northwest",
            "time": 5849,
            "street_name": "1st Street Northwest"
        }, {
            "distance": 0.0,
            "sign": 4,
            "last_heading": 182.42976196965412,
            "interval": [29, 29],
            "text": "Arrive at destination",
            "time": 0,
            "street_name": ""
        }],
        "descend": 0.0,
        "ascend": 0.0,
        "distance": 2786.175,
        "bbox": [-77.036554, 38.889866, -77.012481, 38.900236],
        "weight": 160.20588,
        "points_encoded": true,
        "points": "mullFneeuMD??gQxJBpPKH[@eOE}@@qAHeA|@cF\\aBpFwZfBgJfDkRPq@t@wDB[@]f@uCFg@L?L{@z@}ELaAfBuJPi@FMfBGh@@",
        "transfers": 0,
        "legs": [],
        "details": {},
        "time": 160198,
        "snapped_waypoints": "mullFneeuMx_AkuC"
    }],
    "info": {
        "took": 82,
        "copyrights": ["GraphHopper", "OpenStreetMap contributors"]
    }
}
```
