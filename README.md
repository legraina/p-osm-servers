OSM SERVERS
---------------------

The configuration proposed here allows to run graphhopper and nominatim on the same machine. There are four containers:
- nginx: this container is simply used to redirect nominatim request to the nominatim container, and the other request to graphhopper.
- graphhopper: this container returns the route associated to two gps positions. See https://www.graphhopper.com/open-source/ for more information.
- nominatim: this container encode and decode places to gps positions. See https://wiki.openstreetmap.org/wiki/Nominatim for more information.
- postgis: this container is a postgresql database with postgis loaded. We need also to add the nominatim library to the container with a volume.

Configuration
--------------------

https://download.geofabrik.de/ proposes packages of openstreetmap data. Find the part of the world that interests you and download the pbf. This file will be used by graphhopper and nominatim.
For graphhopper, you must give in the command the path to the file.
For nominatim, you must give only the file name with the flag -o or --osm-file.

For the US, you may also have more accurate data for nominatim with Tiger.
Add all the zip files in the tiger directory in your data, and add the flag -t or --tiger to your command for nominatim. You may download the tiger data that you need here: https://www.census.gov/cgi-bin/geo/shapefiles/index.php.

Once, the osm files and tiger have been imported, you do not need these flags anymore.
You may remove them from the command (especially tiger, as you don't want to reimport these files everytime).

If you want to run continuous updates for nominatim, you should find the path to the osh files in geofabrik and pass this url to nominatim with the flag -u or --update.

Finally, you can load different map in both server and switch between them.
For graphhopper, just change the input files. For nominatim, you must change the environment variable for the database (PGDATABASE) to point to the right database.


Usage
-------------------
First start all the service with:
```bash
docker-compose up -d
````

Then, when all the imports are finished, you may connect to nominatim with:
````bash
curl -s "http://localhost/nominatim/search/?q=White+House&format=json&addressdetails=1&limit=1" | jq
````

and graphhopper with:
````bash
curl -s "http://localhost/route?point=38.900236,-77.036558&point=38.889866,-77.012499" | jq
````
