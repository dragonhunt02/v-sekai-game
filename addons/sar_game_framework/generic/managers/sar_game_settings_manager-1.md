@tool
extends Node
class_name SarGameSettingsManager

# This class is provides a standardized base for interacting with what should be
# user-configurable project settings.

signal setting_updated(p_setting: String)

var _config: ConfigFile = null

func _ready():
	if Engine.is_editor_hint():
		return

	_config = ConfigFile.new()
	
	if not SarUtils.assert_ok(_load_stored_cfg(),
		"Could not load config files"):
		return

func _load_stored_cfg() -> Error:
	var default_cfg: ConfigFile = null
	var custom_cfg: ConfigFile = null

	if not FileAccess.file_exists("res://project.godot"):
		return FAILED

	default_cfg = ConfigFile.new()
	if not SarUtils.assert_ok(default_cfg.load("res://project.godot"),
		"Could not load default config"):
		return FAILED
		
	var override_path: String = ProjectSettings.get("application/config/project_settings_override", "")
	if (not override_path.is_empty()) and FileAccess.file_exists(override_path):
		custom_cfg = ConfigFile.new()
		if not SarUtils.assert_ok(custom_cfg.load(override_path),
			"Could not load custom config"):
			return FAILED

	if default_cfg and custom_cfg:
		var interpolated_cfg: ConfigFile = _interpolate_config(default_cfg, custom_cfg)
		_config = interpolated_cfg
		default_cfg = null # modified by function
	elif default_cfg:
		_config = default_cfg
	else:
		return FAILED

	return OK

# Modifies p_default_cfg
func _interpolate_config(p_default_cfg: ConfigFile, p_custom_cfg: ConfigFile) -> ConfigFile:
	var new_cfg: ConfigFile = p_default_cfg
	for section in p_custom_cfg.get_sections():
		for key in p_custom_cfg.get_section_keys(section):
			var value = p_custom_cfg.get_value(section, key)
			new_cfg.set_value(section, key, value)
			print("%s/%s = %s" % [section, key, value])
	return new_cfg

func get_value(p_section: String, p_key: String, p_default: Variant = null):
	return _config.get_value(p_section, p_key, p_default)
func set_value(p_section: String, p_key: String, p_value: Variant, p_write_cfg: bool = true):
	return _config.set_value(p_section, p_key, p_value)

func _setting_updated(p_setting) -> void:
	setting_updated.emit(p_setting)

func set_msaa_2d(p_msaa: Viewport.MSAA) -> void:
	get_viewport().msaa_2d = p_msaa

func set_msaa_3d(p_msaa: Viewport.MSAA) -> void:
	get_viewport().msaa_3d = p_msaa
	
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
			
func _write_project_setting(
	p_default_cfg: ConfigFile,
	p_custom_cfg: ConfigFile,
	p_section: String,
	p_key: String,
	p_skip_if_default_matches) -> void:
	
	if ProjectSettings.get_setting(p_section + "/" + p_key, "") != p_default_cfg.get_value(p_section, p_key) or not p_skip_if_default_matches:
		p_custom_cfg.set_value(p_section, p_key, ProjectSettings.get_setting(p_section + "/" + p_key, ""))
	else:
		if p_custom_cfg.has_section_key(p_section, p_key):
			p_custom_cfg.erase_section_key(p_section, p_key)
			
func _write_custom_config(p_default_cfg: ConfigFile, p_custom_cfg: ConfigFile) -> void:
	# Rendering
	p_custom_cfg.set_value("rendering", "anti_aliasing/quality/msaa_2d", get_viewport().msaa_2d)
	p_custom_cfg.set_value("rendering", "anti_aliasing/quality/msaa_3d", get_viewport().msaa_3d)
	
	# Display
	p_custom_cfg.set_value("display", "window/size/mode", DisplayServer.window_get_mode())
	p_custom_cfg.set_value("display", "window/vsync/vsync_mode", DisplayServer.window_get_vsync_mode())
	
	p_custom_cfg.set_value("display", "window/stretch/mode", get_content_scale_mode_string(get_window().content_scale_mode))
	p_custom_cfg.set_value("display", "window/stretch/stretch", get_content_scale_stretch_string(get_window().content_scale_stretch))
	
	# Physics
	_write_project_setting(p_default_cfg, p_custom_cfg, "common", "physics_interpolation", true)

func _save_settings() -> void:
	if not Engine.is_editor_hint():
		var default_cfg: ConfigFile = ConfigFile.new()
		
		if FileAccess.file_exists("res://project.godot"):
			var _err_for_default_cfg: Error = default_cfg.load("res://project.godot")
		
			var override_path: String = ProjectSettings.get("application/config/project_settings_override")
			if not override_path.is_empty():
				var custom_cfg: ConfigFile = ConfigFile.new()
				
				if FileAccess.file_exists(override_path):
					var _err_for_custom_cfg: Error = custom_cfg.load(override_path)
				
				if default_cfg and custom_cfg:
					_write_custom_config(default_cfg, custom_cfg)
				
					custom_cfg.save(override_path)

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		add_to_group("game_settings_managers")

func _exit_tree() -> void:
	_save_settings()
