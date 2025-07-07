# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# vsk_game_session_manager.gd
# SPDX-License-Identifier: MIT

@tool
extends SarGameSessionManager
class_name VSKGameSessionManager

var _active_shard_id: String = ""
var _network_info: VSKNetworkInfo = preload("res://addons/vsk_game_framework/data/vsk_default_network_info.tres")

var _DEFAULT_HOST_ARGS: Dictionary = _network_info.host_params

func _create_server_shard() -> void:
	print("Creating public server shard...")
	_current_players = 1
	var shard_data: Dictionary = {
		"map": _active_map_path,
		"name": _server_name,
		"port": _port,
		"dedicated": _is_dedicated,
		"current_users": _current_players,
		"max_players": _max_players
	}
	
	var shard: Dictionary = await VSKGameShardManagerSingleton.create_shard(shard_data)
	if not shard.is_empty():
		_active_shard_id = shard["id"]

func notify_game_scene_changed() -> void:
	super.notify_game_scene_changed()
	if not Engine.is_editor_hint():
		var current_scene: Node = get_tree().current_scene
		if current_scene is SarGameScene3D:
			if (multiplayer.is_server() and _is_public):
				_create_server_shard()

## Attempts to join a multiplayer server shard.
## p_shard_id is the shard id of server you are attempting to join.
func join_server_shard(p_shard_id: String) -> Error:
	var result: Error = FAILED

	# Assuming shards are refreshed already
	var shard_data: Dictionary = VSKGameShardManagerSingleton.get_public_server_shard_from_id(p_shard_id)
	if shard_data.is_empty():
		push_error("Failed to join shard id '%s'. Shard not found." % p_shard_id)
		return result

	result = join_server(shard_data["address"], shard_data["port"])
	if (result == OK):
		_server_name = shard_data["name"]
		# TODO: Update other properties
	else:
		push_error("Failed to join shard id '%s'. Could not connect." % p_shard_id)
	return result

func _create_authentication_node() -> SarGameSessionAuthentication:
	return VSKGameSessionAuthentication.new()

func is_avatar_path_allowed_for_avatar_sync(_sync: VSKGameEntityComponentAvatarSync, _path: String):
	return true
