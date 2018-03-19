NOMINATIN DOCKER
===================

This image contains a nominatim apache server (https://wiki.openstreetmap.org/wiki/Nominatim).
However, to be able to use the nominatim service, you must connect this image to a postgis database.
You can refer to this repository to build a fully operational service: https://github.com/legraina/osm-servers.

Supported Tags
---------------
- latest
- 9.5

The version corresponds to the postgresql database version that needs to be used with this image.

Usage
-------------

You must connect a volume with the data you wish to import and then run:
````bash
docker run -p 8080:80 --name nominatim -v /your/path/to/data:/data legraina/nominatim -o /data/district-of-columbia-latest.osm.pbf
````

Environment Variables
---------------------
There are four environment variables that can be overridden:
- PGHOST: name of the postgis host. Default: postgis.
- PGUSER: name of the postgis user. Default: www-data.
- PGPASSWORD: password associated to the user. Default: password.
- PGDATABASE: name of the database used in postgis. Default: nominatim.

Flags
------
Available flags in the command:
- -h | --help: display the help message.
- -o | --osm-file: OSM file in the input to use for the initial import (can be download here: https://download.geofabrik.de/). Default: None.
- -t | --tiger: folder where the zip files are located for TIGER (can be found here: https://www.census.gov/cgi-bin/geo/shapefiles/index.php). Default: None.
- -u | --update: url used for conitnuously updating the OSM data in the postgresql db (can also be found here: https://download.geofabrik.de/). Default: None.
