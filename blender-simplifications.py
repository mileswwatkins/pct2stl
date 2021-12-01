import bpy
import bmesh
import os

input_stl_name = 'pct-dem-trimmed_model-6'
bpy.ops.import_mesh.stl(filepath=os.path.join('data', f'{input_stl_name}.stl'))

pct_mesh = bpy.data.meshes[-1]
pct_bmesh = bmesh.new()
pct_bmesh.from_mesh(pct_mesh)

origin_vertex = None
for vertex in pct_bmesh.verts:
    coordinates = vertex.co
    if coordinates[0] == 0.0 and \
            coordinates[1] == 0.0 and \
            coordinates[2] == 0.0:
        origin_vertex = vertex

max_z_coordinate = 0.0
for edge in origin_vertex.link_edges:
    max_z_coordinate = max([v.co[2] for v in edge.verts] + [max_z_coordinate])

epsilon = 0.01
z_plane_to_slice_at = max_z_coordinate + epsilon

# Select only the PCT mesh
bpy.ops.object.select_all(action="DESELECT")
# Need an object-type pointer instead of a mesh-type one
pct_object = bpy.context.scene.objects[-1]
pct_object.select_set(True)

# Toggle edit mode
bpy.ops.object.editmode_toggle()

# Remove null values with bisect
bpy.ops.mesh.bisect(
	plane_co=(0.0,0.0,z_plane_to_slice_at),
	plane_no=(0.0,0.0,1.0),
	use_fill=True,
	clear_inner=True,
	clear_outer=False,
)

bpy.ops.export_mesh.stl(
    filepath=os.path.join('data', f'{input_stl_name}-simp.stl'),
    check_existing=False,
    use_selection=True
)
