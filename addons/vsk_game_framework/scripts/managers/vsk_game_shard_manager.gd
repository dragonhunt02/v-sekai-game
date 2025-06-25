# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# shard_service.gd
# SPDX-License-Identifier: MIT
@tool
#extends SarGameService

extends Node
#class_name VSKGameServiceShard
class_name VSKGameShardManager

signal public_shards_updated
signal shard_created
signal shard_updated
signal shard_deleted

# Owned shards
var _active_shards: Dictionary = {}
var _active_heartbeat_timers: Dictionary = {}

# Not locally synced with '_active_shards'
var _public_server_shards: Dictionary = {}

var shard_heartbeat_frequency: float = null # In seconds

func create_shard(p_shard_data: Dictionary) -> void:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await service.create_shard_async(_fetch_request, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shard = async_result["output"]["data"]["data"]
			var shard_id = async_result["output"]["data"]["data"]["id"]
			_active_shards[shard_id] = shard
			shard_created.emit(shard_id, shard)
		else:
			push_error(
				(
					"Create shard returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

func update_shard(p_id: String, p_shard_data: Dictionary) -> void: #Dictionary:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await service.update_shard_async(_fetch_request, p_id: String, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shard = async_result["output"]["data"]["data"]
			var shard_id = async_result["output"]["data"]["data"]["id"]
			_active_shards[shard_id] = shard
			shard_updated.emit(shard_id, shard)
			#return shard
		else:
			push_error(
				(
					"Update shard returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

		return

func delete_shard(p_id: String, p_shard_data: Dictionary) -> void:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await service.create_shard_async(_fetch_request, p_id, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			_active_shards.erase(shard_id)
			shard_deleted.emit(shard_id)
		else:
			push_error(
				(
					"Delete shard returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

func refresh_shards_list() -> void:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await service.get_shards_async(_fetch_request)
		_fetch_request = null
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shards_list = async_result["output"]["data"]["data"]["shards"]
			_public_server_shards = shards_list
			public_shards_updated.emit()
		else:
			push_error(
				(
					"Get shards returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

func start_timer_update(p_shard_id: String) -> Error:
	var timer: Timer = _active_heartbeat_timers.get(p_shard_id, null)
	if not timer:
		var callback: Callable = Callable(self, "_shard_heartbeat").bind(p_shard_id)
		var timer: Timer = Timer.new()
		timer.wait_time = shard_heartbeat_frequency
		timer.one_shot = false
		timer.autostart = true
		timer.timeout.connect(callback)
		add_child(timer)

		_active_heartbeat_timers[p_shard_id] = timer
		return OK
	else:
		push_error("Timer already exist for shard: %s" % p_shard_id)
		return ERR_INVALID_PARAMETER

func stop_timer_update(p_shard_id: String) -> Error:
	var timer: Timer = _active_heartbeat_timers.get(p_shard_id, null)
	if timer:
		timer.stop()
		remove_child(timer)
		timer.queue_free()
		_active_heartbeat_timers.erase(p_shard_id)
		return OK
	else:
		push_error("Timer does not exist for shard: %s" % p_shard_id)
		return ERR_INVALID_PARAMETER

func get_public_server_shards() -> Dictionary:
	return _public_server_shards

func get_active_shards() -> Dictionary:
	return _active_shards

# Update current player count
func update_shard_current_users(p_id: String, p_current_users: int) -> void: #Dictionary:
	var shard = await update_shard(
		p_id, {"current_users": p_current_users}
	)
	return
	#if not shard.empty():
	#	_active_shards[shard_id] = shard
	#	_public_server_shards[shard_id] = shard
	#return shard

func _shard_heartbeat(p_id: String) -> void:
	var shard = await update_shard_async(p_id, {})
	return

func _get_uro_service() -> VSKGameServiceUro:
	var service_manager: VSKGameServiceManager = get_tree().get_first_node_in_group("game_service_managers")
	if service_manager:
		var game_service: VSKGameServiceUro = service_manager.get_service("Uro")
		return game_service
		
	return null

#func _on_shard_created(p_shard_id: String, p_shard: Dictionary) -> void:

#func _on_shard_updated(p_shard_id: String, p_shard: Dictionary) -> void:


func _process(_delta: float):
	if not Engine.is_editor_hint():
		pass

func _ready():
	if Engine.is_editor_hint():
		return

	if ProjectSettings.has_setting("game/session/shard_heartbeat_frequency"):
		shard_heartbeat_frequency = ProjectSettings.get_setting("game/session/shard_heartbeat_frequency")

func setup() -> void:
	pass  # Nothing to setup
