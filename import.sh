#! /bin/bash

#! /bin/bash

# Description:
#   Imports and partitions a Quattroshapes shapefile into GeoJSON extracts.
#   Configuration variables are stored in `./config.sh`.
#
# Use:
#   # update the configuration variables in config.sh, if you wish.
#
#   ./import.sh

import(){
	echo "Partionioning '$shapefile' in '$dest_dir/'."

	echo "Downloading $shapefile.zip."
	wget --quiet http://static.quattroshapes.com/$shapefile.zip
	mkdir $dest_dir
	mv $shapefile.zip $dest_dir
	cd $dest_dir

	echo "Unzipping $shapefile.zip."
	unzip $shapefile.zip > /dev/null

	echo "Partionining/converting $shapefile.shp."
	mapshaper $shapefile.shp encoding=utf8 \
		-split $field_to_split_on -o format=$output_format . 2> /dev/null

	echo "Cleaning up."
	rm $shapefile.*
	rm $shapefile.zip

	for file in *.json; do
		mv $file ${file%.json}.geojson
	done
}

source config.sh
import
