#!/bin/bash

function printBashUsage {
  echo "Usage:"
  echo "-h | --help: display this message"
  echo "-o | --osm-file: OSM file to use for the initial import (must be download here: https://download.geofabrik.de/). Default: None"
  echo "-t | --tiger: folder where the zip files are located for TIGER. Default: None"
  echo "-u | --update: url used for conitnuously updating the OSM data in the postgresql db. Default: None"
}

while [ ! -z $1 ]; do
  case $1 in
    -h|--help) printBashUsage
      exit 0;;
    -o|--osm-file) OSM_FILE=$2; shift 2;;
    -t|--tiger) TIGER=$2; shift 2;;
    -u|--update) UPDATE_URL=$2; shift 2;;
    -*|--*) echo "Option unknown: $1"
      printBashUsage
      exit 2;;
    *) echo "Cannot parse this argument: $1"
      printBashUsage
      exit 2;;
  esac
done

# move to the util folder
cd /nominatim/build/utils

# import data if needed
if [ ! -z $OSM_FILE ]; then
  echo "Importing OSM file $OSM_FILE ..."
  ./setup.php --osm-file $OSM_FILE --all
  echo "OSM file $OSM_FILE imported."
fi

# check if can connect to postgis database
if ! psql; then
  echo "Cannot connect to postgis"
  exit 1;
fi

# import tiger data
LOCAL_SETTINGS="/nominatim/build/settings/local.php"
if [ ! -z $TIGER ]; then
  echo "Importing TIGER data ..."
  ./imports.php --parse-tiger $TIGER
  ./setup.php --import-tiger-data
  # add use tiger option in needed
  if [ -z $(grep "'CONST_Use_US_Tiger_Data', true" $LOCAL_SETTINGS) ]; then
    echo "@define('CONST_Use_US_Tiger_Data', true);" >> $LOCAL_SETTINGS
  fi
  ./setup.php --create-functions --enable-diff-updates --create-partition-functions
  echo "TIGER data imported."
fi

# add auto updates
if [ ! -z $UPDATE_URL ]; then
  echo "Starting conitnuous updates ..."
  # add a new line
  if [ -z $(grep "'CONST_Replication_Url'" $LOCAL_SETTINGS) ]; then
    echo "@define('CONST_Replication_Url', '$UPDATE_URL');" >> $LOCAL_SETTINGS
  # replace the current url
  else
    sed -i "s~.*CONST_Replication_Url.*~@define('CONST_Replication_Url', '$UPDATE_URL');~g" $LOCAL_SETTINGS
  fi
  ./update.php --init-updates
  ./update.php --import-osmosis-all &
  echo "Conitnuous updates started."
fi

# start the apache server
apachectl -DFOREGROUND
