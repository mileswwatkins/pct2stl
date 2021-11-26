import bpy
import bmesh
import os
import sys

bpy.ops.import_mesh.stl(filepath=os.path.join('data', 'pct-dem-trimmed_model-6.stl'))
# The other (first) mesh is a cube that new Blender
# projects create by default
pct_mesh = bpy.data.meshes[-1]
pct_bmesh = bmesh.new()
pct_bmesh.from_mesh(pct_mesh)

bmesh.ops.dissolve_limit(pct_bmesh)

# Revert from a Blender mesh to a normal mesh
pct_bmesh.to_mesh(pct_mesh)
pct_bmesh.free()

# Select only the PCT mesh
bpy.ops.object.select_all(action="DESELECT")
# Need an object-type pointer instead of a mesh-type one
pct_object = bpy.context.scene.objects[-1]
pct_object.select_set(True)

for vertex in pct_object.data.vertices:
    coordinates = vertex.co
    if coordinates[0] == 0.0 and \
            coordinates[1] == 0.0 and \
            coordinates[2] == 0.0:
        print(vertex)

bpy.ops.export_mesh.stl(
    filepath=os.path.join('data', 'pct-dem-trimmed_model-6-simp.stl'),
    check_existing=False,
    use_selection=True
)

# Do not launch the Blender UI after this script completes
sys.exit(0)
