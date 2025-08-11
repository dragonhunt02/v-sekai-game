# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# godot_uro.gd
# SPDX-License-Identifier: MIT

@tool
extends GodotRequestService
class_name GodotUro

var godot_uro_api: GodotUroAPI = null

func _load_api() -> void:
	if godot_uro_api == null:
		godot_uro_api = GodotUroAPI.new(self)
