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

get_shapefiles(){
	# Download and unzip shapefiles.

	echo "Downloading $shapefile.zip."
	wget --quiet http://static.quattroshapes.com/$shapefile.zip
	mkdir $dest_dir
	mv $shapefile.zip $dest_dir
	cd $dest_dir

	echo "Unzipping $shapefile.zip."
	unzip $shapefile.zip > /dev/null
	rm $shapefile.zip
}

import(){
	# Download and partition Quattroshapes shapefiles.

	check_dep
	get_shapefiles

	# cd $dest_dir # TMP!
	echo "Partionioning '$shapefile' in '$dest_dir/'."

	echo "Partionining/converting $shapefile.shp."
	mapshaper $shapefile.shp encoding=utf8 \
		-split gn_adm0_cc -o format=shapefile . 2> /dev/null

	IFS=$'\n'
	for country_file in $(find . -name "qs_neighborhoods-*.shp"); do
		local country="${country_file%.shp}"
		country="${country##./qs_neighborhoods-}"

		local country_dir="$country"
		if [ "$country_dir" = "" ]; then
			country_dir="null"
		fi

		mkdir "$country_dir"

		find . -name "qs_neighborhoods-$country.*" -type f \
			| xargs -i mv "{}" "$country_dir"
		cd "$country_dir"

		mapshaper $country_file encoding=utf8 \
			-split $field_to_split_on -o format=$output_format . 2> /dev/null

		IFS=$'\n'
		for sub_file in $(find . -name "*.json"); do
			local filename=${sub_file%.json}
			filename=${filename##./qs_neighborhoods-}
			mv $sub_file $filename.geojson
		done

		find . -name "qs_neighborhoods-$country.*" -type f -print0 \
			| xargs -0 rm
		cd ..
	done

	echo "Cleaning up."
	# rm $shapefile.*
}

source config.sh
import
