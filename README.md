# PCT2STL

Create an STL file of the Pacific Crest Trail, for [printing as jewelry](https://www.shapeways.com/business/metal-3d-printing).

## Requirements

### Software

- [GDAL 3](https://gdal.org)
- [QGIS](https://www.qgis.org/en/site/)
- [DEMto3D QGIS plugin](https://demto3d.com/en/)
- [Blender](https://www.blender.org)

### Data

Before running, you must manually download the digital elevation models from [USGS EarthExplorer](https://earthexplorer.usgs.gov):

- Southern and Central California are in entity `GT30W140N40`
- Oregon, Washington, and the remainder of California are in entity `GT30W140N90`

Place both of these downloaded TIF files into the `data` directory.

## Run

1. Execute the `pct2stl.sh` script. This will output intermediate data files to the `data` directory, most notably a `pct-dem-trimmed-stretched.tif` file.
1. Using the DEMto3D QGIS plugin, manually generate an STL file from the `pct-dem-trimmed-stretched.tif` file
    - This step needs to be performed manually because the DEMto3D plugin doesn't provide command-line bindings that could be called with [`qgis_process`](https://docs.qgis.org/latest/en/docs/user_manual/processing/standalone.html)
    - Suggested settings for the plugin can be found [here](https://edutechwiki.unige.ch/en/3D_printing_of_digital_elevation_models_with_QGIS#Procedure_for_using_DEMto3D)
    - If using Shapeways for printing the final output in metal, note that they have [a maximum size of 89 x 89 x 100 mm, and a detail resolution of 0.35 mm](https://www.shapeways.com/materials/brass)
1. Execute the `blender-simplifications.py` script using your Blender executable; eg, `blender --background --python blender-simplifications.py`
    - If `blender` isn't installed as a shell command, you'll instead need to point to your Blender executable
1. Submit the final STL file to a 3D metal printing service. At time of writing, this would cost about $20 at Shapeways.
