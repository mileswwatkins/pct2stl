#! /bin/sh

set -e

mkdir -p data

# Manually download GeoTIFF DEMs from https://earthexplorer.usgs.gov
# - Washington through Redding, CA is in entity `GT30W140N90`
# - The remainder of California is in entity `GT30W140N40`
# Place both of these files in the `data` directory
echo "Did you manually download the GeoTIFF DEMs first?"
read -r REPLY

gdal_merge.py \
    -o data/pct-dem.tif \
    data/gt30w140n40.tif \
    data/gt30w140n90.tif

wget \
    --quiet \
    --timestamping \
    --directory-prefix data \
    https://www.fs.usda.gov/Internet/FSE_DOCUMENTS/stelprdb5332131.zip
unzip \
    -oq \
    -d data \
    data/stelprdb5332131.zip

# For whatever reason, dissolving the geometry must take place
# separately from the SpatiaLite buffering of the line geometry;
# otherwise the line's tips are not buffered to the desired length.
# (Shapefile unit is meters.)
ogr2ogr \
    data/pct-buffered.shp \
    data/PacificCrestTrail.shp \
    -dialect sqlite \
    -sql "
        WITH \"pct-unioned\" AS (
            SELECT ST_UNARYUNION(ST_COLLECT(geometry)) AS geometry
            FROM PacificCrestTrail
        )
        SELECT ST_BUFFER(geometry, 25000)
        FROM \"pct-unioned\"
    "

# This doesn't actually use the `PacificCrestTrail.shp` file, but
# _an_ input file is needed for any `ogr2ogr` invocation. Also,
# the "right" way to do this is with the `BuildCircleMbr` SpatiaLite
# function, but that is currently resulting in rectangles instead.
ogr2ogr \
    data/pct-terminus-holes-mask.shp \
    data/PacificCrestTrail.shp \
    -a_srs EPSG:4326 \
    -dialect sqlite \
    -sql "
        SELECT ST_DIFFERENCE(
            ST_POLYGONFROMTEXT(
                'POLYGON((
                    -125.0011 24.9493,
                    -125.0011 49.5904,
                    -66.9326 49.5904,
                    -66.9326 24.9493,
                    -125.0011 24.9493
                ))'
            ),
            ST_UNION(
                BUFFER(ST_POINT(-120.799, 49.000), 0.1),
                BUFFER(ST_POINT(-116.467, 32.589), 0.1)
            )
        ) AS geometry
    "

if [ -f data/pct-dem-trimmed.tif ]; then
    rm data/pct-dem-trimmed.tif
fi
gdalwarp \
    -cutline data/pct-buffered.shp \
    -cl pct-buffered \
    -crop_to_cutline \
    data/pct-dem.tif \
    data/pct-dem-trimmed.tif
gdalwarp \
    -cutline data/pct-terminus-holes-mask.shp \
    -cl pct-terminus-holes-mask \
    -crop_to_cutline \
    data/pct-dem-trimmed.tif \
    data/pct-dem-trimmed-holed.tif
gdal_edit.py \
    -a_nodata 0 \
    data/pct-dem-trimmed-holed.tif
# TO DO: Trim this very large bounding box down to just the area
# _without_ nodata
# TO DO: Find a way to slice off the bottom of the QGIS-generated
# STL polygon

# Suggested settings for DEMto3D:
# https://edutechwiki.unige.ch/en/3D_printing_of_digital_elevation_models_with_QGIS#Procedure_for_using_DEMto3D
# Note that Shapeways has a maximum size for metal printing of
# 89 × 89 × 100 mm; see, eg, https://www.shapeways.com/materials/bronze
echo "Now manually use the DEMto3D QGIS plugin to create an STL file"
