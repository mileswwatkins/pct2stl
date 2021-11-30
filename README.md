# PCT2STL

Create an STL file of the Pacific Crest Trail, for [printing as jewelry](https://www.shapeways.com/business/metal-3d-printing).

## Requirements

- [GDAL 3](https://gdal.org)
- [QGIS](https://www.qgis.org/en/site/forusers/download.html)
- [DEMto3D QGIS plugin](https://demto3d.com/en/)
- Blender

### Data

Before running, you must manually download the digital elevation models from [USGS EarthExplorer](https://earthexplorer.usgs.gov):

- Washington through Redding is in entity `GT30W140N90`
- The remainder of California is in entity `GT30W140N40`

Place both of these TIF files in the `data` directory.

## Run

1. Execute the `pct2stl.sh` shell script. This will generate intermediate data files in the `data` directory, most notably a `pct-dem-trimmed.tif` file.
1. Using the DEMto3D QGIS plugin, manually generate an STL file from the `pct-dem-trimmed.tif` file
     - Suggested settings for the plugin can be found [here](https://edutechwiki.unige.ch/en/3D_printing_of_digital_elevation_models_with_QGIS#Procedure_for_using_DEMto3D)
     - If using Shapeways for printing the final output in metal, note that they have [a maximum size of 89 x 89 x 100 mm](https://www.shapeways.com/materials/bronze)
1. Execute the `blender-simplifications.py` script using your Blender executable; eg, `blender --python blender-simplifications.py`
    - If `blender` isn't installed as a shell command, you'll instead need to call your Blender executable
1. Submit the final STL file to a 3D printer for printing in metal. At time of writing, this would cost about $20 at Shapeways.
