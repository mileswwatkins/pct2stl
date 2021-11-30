#! /bin/sh

set -e

mkdir -p data

echo "Did you already manually download the GeoTIFF DEMs, to the \`data\` directory? See \`README.md\` for details."
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
        SELECT ST_BUFFER(geometry, 35000)
        FROM \"pct-unioned\"
    "

if [ -f data/pct-dem-trimmed.tif ]; then
    rm data/pct-dem-trimmed.tif
fi
# Unfortunately, the nodata value isn't respected by DEMto3D
gdalwarp \
    -cutline data/pct-buffered.shp \
    -cl pct-buffered \
    -crop_to_cutline \
    -dstnodata 0 \
    data/pct-dem.tif \
    data/pct-dem-trimmed.tif
# TO DO: Find a way to slice off the bottom of the QGIS-generated
# STL polygon

echo "Now manually use the DEMto3D QGIS plugin to create an STL file. See \`README.md\` for details."
