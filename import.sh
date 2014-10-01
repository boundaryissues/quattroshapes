#! /bin/bash

download_dir=downloads

download_shapefile(){
	echo "Downloading shapefile $1."
	local zip_name=$1.zip
	cd $download_dir
	wget --quiet http://static.quattroshapes.com/$zip_name
	unzip $zip_name > /dev/null
	rm $zip_name
	cd ..
}

split_shapefile(){
	echo "Processing shapefile $1."
	mkdir $1
	mapshaper $download_dir/$1.shp \
		encoding=utf8 -split $2 -o format=$output_format $1 2> /dev/null
}

fix_localities(){
	printf "\xff" |\
		dd of=$download_dir/qs_localities.dbf \
		bs=1 seek=144 count=1 conv=notrunc 2> /dev/null
}

import(){
	local poly_dir=quattroshapes
	mkdir $poly_dir
	cd $poly_dir
	mkdir $download_dir

	for level in adm0 adm1 adm2 localadmin localities neighborhoods; do
		download_shapefile qs_$level
	done

	fix_localities

	for level in adm0 adm1 adm2 localadmin localities; do
		local qs_name=qs_$level
		split_shapefile $qs_name qs_adm0
	done
	split_shapefile qs_neighborhoods name_adm0
}

source config.sh
import
