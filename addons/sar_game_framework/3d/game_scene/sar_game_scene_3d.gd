@tool
extends Node3D
class_name SarGameScene3D

var chunked: bool = true

## A meta class which should be placed on the root node of a scene
## to denote that it is a valid game scene for the game session
## managers.

func _ready() -> void:
	if not Engine.is_editor_hint():
		if chunked:
			setup_chunker(self)
		get_tree().call_group("game_session_managers", "notify_game_scene_changed")


## Start chunker
func setup_chunker(p_root_node: Node3D) -> void:
	pass
	# var chunk_splits_xz = 12
	# var chunk_splits_y = 4
	# var model3d = get_model3d()
	# VskOpenWorldManagerSingleton.start(model3d, chunk_splits_xz, chunk_splits_y)
