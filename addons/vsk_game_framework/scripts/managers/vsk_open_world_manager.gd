extends Node
class_name VskOpenWorldManager

const _splerger_const = preload("res://addons/splerger/split_splerger.gd")
var _world_db = null
var _current_scene = null
var _map_model = null # Meshinstance3d
var _player_camera = null
var last_camera_position =null
#var player_position

## The AssetManager class is designed to be a base class for fetching and
## caching assets from external sources, such as GLTF files.


  
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

	return "user://asset_cache"

func _update_camera_splits():
	var camera = _player_camera
  #_get_camera()
	if not camera:
		return
	
	var current_pos = camera.global_position
	last_camera_position = current_pos
    
func _process() -> void:
	_update_camera_splits()
    
# func _ready():
