# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# vsk_game_settings_manager.gd
# SPDX-License-Identifier: MIT

@tool
extends SarGameSettingsManager
class_name VSKGameSettingsManager

var _cfg_setting_info: VSKSettingsInfo = preload("res://addons/vsk_game_framework/data/vsk_default_settings_info.tres")

# Handle generic settings that have no specific manager
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	if not SarUtils.assert_ok(setting_updated.connect(_apply_generic_setting),
		"Could not connect signal 'setting_updated' to _apply_generic_setting"):
		return

func set_value(p_section: String, p_key: String, p_value: Variant, p_write_cfg: bool = true) -> Error:
	if _check_setting_type(p_section, p_key, p_value) != OK:
		push_error("Invalid setting value type")
		return FAILED
	return super.set_value(p_section, p_key, p_value, p_write_cfg)

func _check_setting_type(p_section: String, p_key: String, p_value: Variant, p_write_cfg: bool = true) -> Error:
	var setting: VSKSettingsInfoSetting = _cfg_setting_info.get_key(p_section, p_key)
	if not typeof(p_value) == setting.type:
		return FAILED
	return OK

func _apply_generic_setting(p_section: String, p_key: String, p_value) -> void:
	match p_section:
		"rendering":
			match p_key:
				"anti_aliasing/quality/msaa_2d":
					get_viewport().msaa_2d = p_value
				"anti_aliasing/quality/msaa_3d":
					get_viewport().msaa_3d = p_value
		"display":
			match p_key:
				"window/size/mode":
					DisplayServer.window_set_mode(p_value)
				"window/vsync/vsync_mode":
					DisplayServer.window_set_vsync_mode(p_value)
				"window/stretch/mode":
					var scale_mode = get_content_scale_mode_enum(p_value)
					get_viewport().window.set_content_scale_mode(scale_mode)
				"window/stretch/stretch":
					var scale_stretch = get_content_scale_stretch_enum(p_value)
					get_viewport().window.set_content_scale_stretch(scale_stretch)
		"physics":
			match p_key:
				"common/physics_interpolation":
					get_tree().set_physics_interpolation_enabled(p_value)



static func get_content_scale_mode_enum(p_cs_mode: String) -> int:
	match p_cs_mode:
		"canvas_items":
			return Window.ContentScaleMode.CONTENT_SCALE_MODE_CANVAS_ITEMS
		"viewport":
			return Window.ContentScaleMode.CONTENT_SCALE_MODE_VIEWPORT
		"disabled":
			return Window.ContentScaleMode.CONTENT_SCALE_MODE_DISABLED
	return Window.ContentScaleMode.CONTENT_SCALE_MODE_DISABLED
			
static func get_content_scale_stretch_enum(p_cs_stretch: String) -> int:
	match p_cs_stretch:
		"integer":
			return Window.ContentScaleStretch.CONTENT_SCALE_STRETCH_INTEGER
		"fractional":
			return Window.ContentScaleStretch.CONTENT_SCALE_STRETCH_FRACTIONAL
	return Window.ContentScaleStretch.CONTENT_SCALE_STRETCH_INTEGER
		

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
		
