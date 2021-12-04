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
# Unfortunately, the nodata value isn't respected by DEMto3D,
# and is treated as zero height
gdalwarp \
    -cutline data/pct-buffered.shp \
    -cl pct-buffered \
    -crop_to_cutline \
    -dstnodata 0 \
    data/pct-dem.tif \
    data/pct-dem-trimmed.tif

# The DEMto3D QGIS plugin does not work properly with
# GeoTIFF elevations below sea level, so we'll standardize
# the min and max "elevations" of the GeoTiff
min_and_max=$(
    gdalinfo -mm data/pct-dem-trimmed.tif \
    | grep "Min/Max" \
    | grep -oEi '[0-9\.-]+'
)
min=$(echo "$min_and_max" | head -n 1)
max=$(echo "$min_and_max" | tail -n 1)
gdal_translate \
    -scale "$min" "$max" 100 1000 \
    data/pct-dem-trimmed.tif \
    data/pct-dem-trimmed-stretched.tif

echo "Now manually use the DEMto3D QGIS plugin to create an STL file. See \`README.md\` for details."
