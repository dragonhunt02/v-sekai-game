# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# vsk_game_settings_manager.gd
# SPDX-License-Identifier: MIT

@tool
extends SarGameSettingsManager
class_name VSKGameSettingsManager

# Handle generic settings that have no specific manager
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	if not SarUtils.assert_ok(setting_updated.connect("_apply_generic_setting"),
		"Could not connect signal 'setting_updated' to _apply_generic_setting"):
		return

func _apply_generic_setting(p_section: String, p_key: String, p_value) -> void:
	match p_section:
		"rendering":
			match p_key:
				"anti_aliasing/quality/msaa_2d":
					get_viewport().msaa_2d = p_value
				"anti_aliasing/quality/msaa_3d":
					get_viewport().msaa_3d = p_value
			match p_key:
				"window/size/mode":
					DisplayServer.window_set_mode(p_value)
				"window/vsync/vsync_mode":
					DisplayServer.window_set_vsync_mode(p_value)
				"window/stretch/mode":
					get_viewport().window.set_content_scale_mode(p_value)
				"window/stretch/stretch":
					get_viewport().window.set_content_scale_stretch(p_value)
		"physics":
			match p_key:
				"common/physics_interpolation":
					get_tree().physics_interpolation = p_value


static func get_content_scale_mode_string(p_cs_mode: Window.ContentScaleMode) -> String:
	match p_cs_mode:
		Window.ContentScaleMode.CONTENT_SCALE_MODE_CANVAS_ITEMS:
			return "canvas_items"
		Window.ContentScaleMode.CONTENT_SCALE_MODE_VIEWPORT:
			return "viewport"
		_:
			return "disabled"
			
static func get_content_scale_stretch_string(p_cs_stretch: Window.ContentScaleStretch) -> String:
	match p_cs_stretch:
		Window.ContentScaleStretch.CONTENT_SCALE_STRETCH_INTEGER:
			return "integer"
		_:
			return "fractional"
		
