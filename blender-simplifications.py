import bpy
import bmesh
import os

input_stl_name = 'pct-dem-trimmed-stretched-model'
bpy.ops.import_mesh.stl(filepath=os.path.join('data', f'{input_stl_name}.stl'))

pct_mesh = bpy.data.meshes[-1]
pct_bmesh = bmesh.new()
pct_bmesh.from_mesh(pct_mesh)

origin_vertex = None
for vertex in pct_bmesh.verts:
    coordinates = vertex.co
    if coordinates[0] == 0 and \
            coordinates[1] == 0 and \
            coordinates[2] == 0:
        origin_vertex = vertex

max_z_coordinate = 0.0
for edge in origin_vertex.link_edges:
    max_z_coordinate = max(
        [v.co[2] for v in edge.verts] +
        [max_z_coordinate]
    )

epsilon = 0.001
z_plane_to_slice_at = max_z_coordinate + epsilon
pct_bmesh.clear()

# Select only the PCT mesh
bpy.ops.object.select_all(action="DESELECT")
# Need an object-type pointer instead of a mesh-type one
pct_object = bpy.context.scene.objects[-1]
pct_object.select_set(True)

# Remove null area, and re-extrude the trail manifold
# downwards
extrusion_amount = 1.0
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.bisect(
    plane_co=(0, 0, z_plane_to_slice_at),
    # Slice upwards on the Z axis only
    plane_no=(0, 0, 1),
    use_fill=True,
    clear_inner=True,
    clear_outer=False,
)
bpy.ops.mesh.extrude_manifold(
    TRANSFORM_OT_translate={
        "value": (0, 0, -extrusion_amount)
    }
)
# Move the mesh so that it rests on the zero Z plane
pct_object.location.z = pct_object.location.z - (max_z_coordinate - extrusion_amount) - epsilon

# Add the rings to attach jewelry chain
ring_z_coordinate = 0.5
major_radius = 1.5
minor_radius = 0.5
bpy.ops.mesh.primitive_torus_add(
    location=(38.0, 0, ring_z_coordinate),
    major_radius=major_radius,
    minor_radius=minor_radius
)
bpy.ops.mesh.primitive_torus_add(
    location=(17.2, 84.9, ring_z_coordinate),
    major_radius=major_radius,
    minor_radius=minor_radius
)

bpy.ops.object.mode_set(mode="OBJECT")
bm = bmesh.new()
bm.from_mesh(pct_object.data)
bmesh.ops.dissolve_limit(
    bm,
    use_dissolve_boundaries=True,
    angle_limit=0.01,
    verts=bm.verts,
    edges=bm.edges
)
bm.to_mesh(pct_mesh)
pct_mesh.update()
bm.clear()

bpy.ops.export_mesh.stl(
    filepath=os.path.join('data', f'{input_stl_name}-simp.stl'),
    check_existing=False,
    use_selection=True
)
