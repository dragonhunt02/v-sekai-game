# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# shard_service.gd
# SPDX-License-Identifier: MIT
@tool
#extends SarGameService

extends Node
#class_name VSKGameServiceShard
class_name VSKGameShardManager

var _active_shards: Dictionary = {}
var _public_server_shards: Dictionary = {}

var shard_heartbeat_timer: Timer = null
var shard_heartbeat_frequency: float = 10.0  # In seconds

func create_shard(p_shard_data: Dictionary) -> void:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await p_service.create_shard_async(_fetch_request, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shard = async_result["output"]["data"]["data"]
			var shard_id = async_result["output"]["data"]["data"]["id"]
			_active_shards[shard_id] = shard
			_public_server_shards[shard_id] = shard
		else:
			push_error(
				(
					"Create shard returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

func update_shard(p_id: String, p_shard_data: Dictionary) -> Dictionary:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await p_service.update_shard_async(_fetch_request, p_id: String, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shard = async_result["output"]["data"]["data"]
			var shard_id = async_result["output"]["data"]["data"]["id"]
			_active_shards[shard_id] = shard
			_public_server_shards[shard_id] = shard
			return shard
		else:
			push_error(
				(
					"Update shard returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

		return {}

func delete_shard(p_id: String, p_shard_data: Dictionary) -> void:
	var service: VSKGameServiceUro = _get_uro_service()
	if service:
		var current_account_address: String = service.get_current_account_address()
		if current_account_address.is_empty():
			return
		
		var address_dictionary: Dictionary = GodotUroHelper.get_username_and_domain_from_address(current_account_address)
		var _fetch_request = p_service.create_request(address_dictionary)
		var async_result: Dictionary = await p_service.create_shard_async(_fetch_request, p_id, p_shard_data)
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			_active_shards.erase(shard_id)
			_public_server_shards.erase(shard_id)
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
		var async_result: Dictionary = await p_service.get_shards_async(_fetch_request)
		_fetch_request = null
		
		if GodotUroHelper.requester_result_is_ok(async_result):
			var shards_list = async_result["output"]["data"]["data"]["shards"]
			_public_server_shards = shards_list
		else:
			push_error(
				(
					"Get shards returned with error %s"
					% GodotUroHelper.get_full_requester_error_string(async_result)
				)
			)

func get_public_server_shards() -> Dictionary:
	return _public_server_shards

func _get_uro_service() -> VSKGameServiceUro:
	var service_manager: VSKGameServiceManager = get_tree().get_first_node_in_group("game_service_managers")
	if service_manager:
		var game_service: VSKGameServiceUro = service_manager.get_service("Uro")
		return game_service
		
	return null

func shard_heartbeat(p_id: String) -> void:
	var shard = await update_shard_async(p_id, {})

func shard_update_current_users(p_id: String, p_current_users: int) -> Dictionary:
	var shard = await update_shard(
		p_id, {"current_users": p_current_users}
	)
	if not shard.empty():
		_active_shards[shard_id] = shard
		_public_server_shards[shard_id] = shard
	return shard

func _process(_delta: float):
	if not Engine.is_editor_hint():
		pass

func setup() -> void:
	pass  # Nothing to setup
