@tool
extends "res://addons/entity_manager/node_3d_simulation_logic.gd"

const interactable_prop_const = preload("res://addons/vsk_entities/vsk_interactable_prop.tscn")
const interactable_prop_const2 = preload("res://addons/vsk_entities/vsk_test_entity.tscn")
const interactable_prop_const3 = preload("res://vsk_default/scenes/prefabs/beachball.tscn")
# interactable_prop.tscn")

var spawned_balls: Array = []

@export var spawn_model: PackedScene  # (PackedScene) = null
@export var rpc_table: NodePath = NodePath()

var spawn_key_pressed_last_frame: bool = false
var background_loading_tasks: Dictionary = {}

func get_prop_list() -> Array:
	var return_dict: Dictionary = {"error": FAILED, "message": ""}
	var prop_list : Array = []

	var async_result : Dictionary = await GodotUro.godot_uro_api.get_props_async()
	if GodotUro.godot_uro_helper_const.requester_result_is_ok(async_result):
		if async_result.has("output"):
			if (async_result["output"].has("data") and async_result["output"]["data"].has("props")):
				return_dict["error"] = OK
				prop_list = async_result["output"]["data"]["props"]

	if return_dict["error"] == FAILED:
		push_error("Network request for /props failed")
		return []
	elif typeof(prop_list) != TYPE_ARRAY:
		push_error("Invalid type in return dictionaryfor /props")
		return []
	return prop_list

func get_random_prop_url() -> String:
	var prop_list : Array = await get_prop_list()
	var random_prop : Dictionary = prop_list[randi() % prop_list.size()]
	print(typeof(random_prop))
	var prop_url : String = ""
	if random_prop.has("user_content_data"):
		prop_url = GodotUro.get_base_url() + random_prop["user_content_data"]
	else:
		push_error("Error: 'user_content_data' key not found in return dictionary")
	return prop_url

func _background_loader_task_done(p_task_path: String, p_err: int, p_resource: Resource) -> void:
	if background_loading_tasks.has(p_task_path):
		var call_array: Array = background_loading_tasks[p_task_path].duplicate()
		background_loading_tasks[p_task_path] = []
		# Convert from standard Godot error enum to AssetManager enum
		var asset_err: int = VSKAssetManager.ASSET_OK
		if p_err != OK:
			asset_err = VSKAssetManager.ASSET_RESOURCE_LOAD_FAILED
		
		for callback in call_array:
			callback.call(p_resource)

func load_prop_url(prop_url : String, callback : Callable) -> bool:
	if (prop_url.strip_edges() == ""):
		return false
	if BackgroundLoader.task_done.connect(self._background_loader_task_done) != OK:
		push_error("Could not connect task_finished")
		return false
	background_loading_tasks[prop_url].push_back(callback)
	# TODO: use whitelist function
	BackgroundLoader.request_loading_task_bypass_whitelist(
				prop_url, "PackedScene"
			)
	return true


func spawn_ball_master(p_requester_id, _entity_callback_id: int) -> void:
	print("Spawn ball master")

	var requester_player_entity: RefCounted = VSKNetworkManager.get_player_instance_ref(p_requester_id)  # EntityRef
	#var requester_player_entity2 = VSKNetworkManager.get_player_instance_ref(NetworkManager.get_current_peer_id())
	
	var spawn_model=load("res://vsk_default/scenes/prefabs/beachball_orange.tscn")
	if requester_player_entity:
		var requester_transform = requester_player_entity.get_last_transform()
		requester_transform.origin.z += 8 + randi_range(1, 10)
		print(requester_player_entity.get_last_transform())
		print(str(spawn_model))
		if (
			(EntityManager.spawn_entity(
				interactable_prop_const,
				{"transform": requester_transform, "model_scene": spawn_model},
				"NetEntity",
				p_requester_id
			))
			== null
		):
			printerr("Could not spawn ball!")


func spawn_ball_puppet(_entity_callback_id: int) -> void:
	print("Spawn ball puppet")


func spawn_ball() -> void:
	get_node(rpc_table).nm_rpc_id(0, "spawn_ball", [0])


func spawn_prop_create(p_requester_id, _entity_callback_id: int, prop_scene) -> void:
	var requester_player_entity: RefCounted = VSKNetworkManager.get_player_instance_ref(p_requester_id)  # EntityRef
	#var requester_player_entity2 = VSKNetworkManager.get_player_instance_ref(NetworkManager.get_current_peer_id())
	
	var spawn_model = prop_scene
	#load(prop_scene_url)
	if requester_player_entity:
		var requester_transform = requester_player_entity.get_last_transform()
		requester_transform.origin.z += 8 + randi_range(1, 10)
		print(requester_player_entity.get_last_transform())
		print(str(spawn_model))
		if (
			(EntityManager.spawn_entity(
				interactable_prop_const,
				{"transform": requester_transform, "model_scene": spawn_model},
				"NetEntity",
				p_requester_id
			))
			== null
		):
			printerr("Could not spawn prop!")

func spawn_prop_master(p_requester_id, _entity_callback_id: int, prop_scene_url : String) -> void:
	print("Spawn prop master from ", prop_scene_url)
	var prop_spawner = func(prop_scene):
		spawn_prop_create(p_requester_id, _entity_callback_id, prop_scene)
	#var callback = Callable(self.instance(), prop_spawner)
	load_prop_url(prop_scene_url, prop_spawner) #callback)

func spawn_prop_puppet(_entity_callback_id: int, prop_scene_url : String) -> void:
	print("Spawn prop puppet from ", prop_scene_url)

func test_spawning() -> void:
	print("test spawning")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var current_seconds = int(Time.get_unix_time_from_system()) % 60
	if current_seconds % 4 == 0:
		print("The current seconds are double even!")
		self.spawn_ball()

	if InputManager.ingame_input_enabled():
		var spawn_key_pressed_this_frame: bool = Input.is_key_pressed(KEY_P)
		if !spawn_key_pressed_last_frame:
			if spawn_key_pressed_this_frame:
				spawn_ball()

		spawn_key_pressed_last_frame = spawn_key_pressed_this_frame


func _entity_physics_process(_delta: float):
	#var prop_scene_url = get_random_prop_url()
	#var prop_scene_url = "res://vsk_default/scenes/prefabs/beachball_orange.tscn")
	#var prop_spawner = func(prop_scene):
	#get_node(rpc_table).nm_rpc_id(0, "spawn_prop", [0, prop_scene_url])

	#var callback = Callable(self, prop_spawner)
	#load_prop_url("", callback)
	test_spawning()


func _entity_ready() -> void:
	assert(get_node(rpc_table).session_master_spawn.connect(self.spawn_ball_master) == OK)
	assert(get_node(rpc_table).session_puppet_spawn.connect(self.spawn_ball_puppet) == OK)

	#assert(get_node(rpc_table).session_master_spawn.connect(self.spawn_prop_master) == OK)
	#assert(get_node(rpc_table).session_puppet_spawn.connect(self.spawn_prop_puppet) == OK)
