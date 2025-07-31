extends Node3D
class_name VSKChunkStreamer

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

func split_cell(mesh_inst, surface_id, gx, gy, gz, parent: Node3D):
    preload("res://split_splerger.gd")._split_mesh(
      mdt, mesh_inst, surface_id,
      gx, gy, gz, si,
      parent,
      faces_assigned,
      world_verts
    )

var requested = {}                      # Set of Vector3i
var pending   = []                      # Array of Vector3i

func process_update(delta):
    var player_pos = player.global_transform.origin
    var player_cell = _get_cell(player_pos)
    if cell != last_cell:

    _enqueue_neighbors(player_cell)
    last_cell = cell

    # Process one cell per frame (tweak for perf)
    #if pending.size() > 0:
   #     var cell = pending.pop_front()
     #   split_cell(original_mesh, surface_id, cell.x, cell.y, cell.z, self)

func _enqueue_neighbors(center: Vector3i):
    for dz in -1 to 1:
      for dy in -1 to 1:
        for dx in -1 to 1:
          var c = Vector3i(center.x+dx, center.y+dy, center.z+dz)
          if not requested.has(c):
            requested.insert(c)
            pending.push_back(c)

# Returns a Vector3i of integer cell indices for a world position
func _get_cell(pos: Vector3) -> Vector3i:
    return Vector3i(
        floor(pos.x / grid_size),
        floor(pos.y / grid_size_y),
        floor(pos.z / grid_size)
    )
