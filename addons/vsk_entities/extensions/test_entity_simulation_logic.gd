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
	test_spawning()


func _entity_ready() -> void:
	assert(get_node(rpc_table).session_master_spawn.connect(self.spawn_ball_master) == OK)
	assert(get_node(rpc_table).session_puppet_spawn.connect(self.spawn_ball_puppet) == OK)
