extends Node
class_name VSKOpenWorldManager

const _splerger_const = preload("res://addons/splerger/split_splerger.gd")
var _world_db = null
var _current_scene = null
var _map_model = null # Meshinstance3d
var _player_camera = null
var last_camera_position =null

var grid_size: float = 2.0
var grid_size_y: float = 2.0
var split_radius: int = 3      # how many cells out to split

#var player_position


var player: Node3D = $"../Player"
var mesh_inst: MeshInstance3D = $"../Map"
var surface_id = 0

var streamer = VSKChunkStreamer.new()

func _ready():
    add_child(streamer)

func start(scene, model) -> String: # SarGameScene3d
#splerger_const.traverse_root_and_split(cube, 1.0, 1.0)
	_current_scene = scene
	_map_model = model
	_world_db = OpenWorldDatabase.new()
	_current_scene.add_child(world_db)
  #_player_camera = $Camera3D
	#world_db.camera = $Camera3D
	# Optionally tweak thresholds at runtime
	#world_db.size_thresholds = [1.0, 5.0, 20.0]

        streamer.prepare(mesh_inst, surface_id, grid_size, grid_size_y)

	return "user://asset_cache"

func _update_camera_splits():
	var camera = _player_camera
  #_get_camera()
	if not camera:
		return
	
	var current_pos = camera.global_position
	
	last_camera_position = current_pos



func _process(delta) -> void:
    #streamer._process(delta)
	_update_camera_splits()
    
# func _ready():
