# openpolygons

A collection of all the [Quattroshapes](http://quattroshapes.com/)
[neighborhoods](http://static.quattroshapes.com/qs_neighborhoods.zip) polygons split at the international state
(`qs_adm1`, or administrative level 1) level and exported in GeoJSON format. The files are located in `polygons/`, and
are named after the state whose neighborhoods they contain. The process of generating them is contained in full in
`import.sh`, with various configuration variables in `config.sh`; note that the script relies on the
[Mapshaper](https://github.com/mbloch/mapshaper) tool.
