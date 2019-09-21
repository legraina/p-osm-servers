# !/bin/sh

########################
# retrieve info
########################

function printBashUsage {
  echo "This script preprocesses osrm data. You need to first download the osm.pbf file on http://download.geofabrik.de/."
  echo "Usage:"
  echo "-h | --help: display this message"
  echo "-i | --instance: name of the osm.pbf file to process (without extansion). Default: district-of-columbia-latest."
  echo "-d | --data: path to the local directory used for the data. Default: ./data/dc."
}

# load arguments
instance="district-of-columbia-latest"
data="./data/dc"
while [ ! -z $1 ]; do
  case $1 in
    -h|--help) printBashUsage
      exit 1;;
    -i | --instance) instance=$2; shift 2;;
		-d | --data) data=$2; shift 2;;
    -*|--*) echo "Option unknown: $1"; shift 2;;
    *) echo "Cannot parse this argument: $1"
      printBashUsage
      exit 2;;
  esac
done

# check if data directory and file exist
if test ! -d $data ; then
	echo "Directory \"$data\" doest nos exist."
	exit 2;
fi
if test ! -f "$data/$instance.osm.pbf" ; then
	echo "File \"$data/$instance.osm.pbf\" doest nos exist."
	exit 2;
fi

# check if any osrm file exists
osrm_files=`find "$data" -name "$instance".osrm* -print -quit`
if [ ! -z $osrm_files ]; then
  echo "Directory \"$data\" already contains some osrm files. Please remove them."
	exit 2;
fi

# check if absolute path
if [[ $data != /* ]]; then
  data="$(pwd)/$data"
  echo "Rewrite data directory as an absolute path: $data"
fi

# run docker commands
docker run -t -v "${data}:/data" osrm/osrm-backend osrm-extract -p /opt/car.lua /data/$instance.osm.pbf
docker run -t -v "${data}:/data" osrm/osrm-backend osrm-partition /data/$instance.osrm
docker run -t -v "${data}:/data" osrm/osrm-backend osrm-customize /data/$instance.osrm
