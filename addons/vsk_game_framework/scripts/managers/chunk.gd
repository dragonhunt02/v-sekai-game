class_name VSKChunkStreamer
extends Node3D

var si                # _SplitInfo
var mdt: MeshDataTool
var world_verts       # PackedVector3Array
var faces_assigned    # PoolBoolArray

func prepare(mesh_inst: MeshInstance3D, surface_id, grid_size, grid_size_y):
    # init split info
    si = preload("res://split_splerger.gd")._init_split_info(
      mesh_inst, surface_id, grid_size, grid_size_y
    )

    #. build MeshDataTool + world_verts + faces_assigned
    mdt = MeshDataTool.new()
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in mesh_inst.mesh.get_surface_count():
        st.append_from(mesh_inst.mesh, i, Transform3D())
    st.generate_normals()
    if mdt.get_vertex_uv(0) != Vector2():
        st.generate_tangents()
    mdt.create_from_surface(st.commit(), surface_id)

    var nVerts = mdt.get_vertex_count()
    world_verts = PackedVector3Array()
    world_verts.resize(nVerts)
    var xform = mesh_inst.global_transform
    for i in range(nVerts):
        world_verts[i] = xform * mdt.get_vertex(i)

    # Mark no face assigned yet
    faces_assigned = PoolBoolArray()
    faces_assigned.resize(mdt.get_face_count())
