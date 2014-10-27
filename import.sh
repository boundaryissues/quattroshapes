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

check_dep(){
	# Check whether the `mapshaper` tool is installed, and install it via npm
	# if it's not.

	if [ ! -d node_modules/mapshaper ]; then
		which npm > /dev/null
		if [ $? -ne 0 ]; then
			echo "npm not found; required to install \`mapshaper\`."
		fi

		echo "Installing mapshaper."
		npm install mapshaper > /dev/null
	fi
}

import(){
	# Download and partition Quattroshapes shapefiles.

	check_dep
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

	for file in *.geojson; do
		local filename=${file%.geojson}
		filename=${filename##qs_neighborhoods-}
		git mv $file $filename.geojson
	done
}

source config.sh
import
