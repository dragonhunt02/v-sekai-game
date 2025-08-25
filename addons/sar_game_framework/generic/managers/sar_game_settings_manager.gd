@tool
extends Node
class_name SarGameSettingsManager

# This class is provides a standardized base for interacting with what should be
# user-configurable project settings.

signal setting_updated(p_setting: String)

const WRITE_DEBOUNCE_MS = 5000

var _override_path: String = ""
var _default_cfg: ConfigFile = null
var _custom_cfg: ConfigFile = null

var _cfg_mutex : Mutex = null
var _write_request_timeout = null

func _ready():
	if Engine.is_editor_hint():
		return
	_cfg_mutex = Mutex.new()
	_override_path = ProjectSettings.get("application/config/project_settings_override", "")

	if not SarUtils.assert_ok(_load_stored_cfg(),
		"Could not load config files"):
		return

func _load_stored_cfg() -> Error:
	_default_cfg = ConfigFile.new()
	_custom_cfg = ConfigFile.new()

	if not SarUtils.assert_true(FileAccess.file_exists("res://project.godot"),
		"Could not find res://project.godot"):
		return FAILED

	if not SarUtils.assert_ok(default_cfg.load("res://project.godot"),
		"Could not load default config"):
		return FAILED
		
	if (not _override_path.is_empty()) and FileAccess.file_exists(override_path):
		if not SarUtils.assert_ok(custom_cfg.load(override_path),
			"Could not load custom config"):
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

# Thread-safe
func get_value(p_section: String, p_key: String, p_default: Variant = null):
	_cfg_mutex.lock()
	var value = _get_unsafe_value(p_section, p_key, p_default)
	_cfg_mutex.unlock()
	return value

# Thread-safe
func set_value(p_section: String, p_key: String, p_value: Variant, p_write_cfg: bool = true) -> void:
	_cfg_mutex.lock()
	var current_value = _get_unsafe_value(p_section, p_key, null)
	if current_value != p_value:
		if not p_value == null:
			_custom_cfg.set_value(p_section, p_key, p_value)
		else:
			_reset_value(p_section, p_key)
		if p_write_cfg:
			_queue_write_settings()
		_setting_updated([p_section, p_key, p_value])
	_cfg_mutex.unlock()

func _get_unsafe_value(p_section: String, p_key: String, p_default: Variant = null):
	var value: Variant = _custom_cfg.get_value(p_section, p_key, null)
	if value == null:
		value = _default_cfg.get_value(p_section, p_key, null)
		if value == null:
			value = p_default
	return value

# Restore to default
func _reset_value(p_section: String, p_key: String):
	if _custom_cfg.has_section_key(p_section, p_key):
		_custom_cfg.erase_section_key(p_section, p_key)

func _queue_write_settings():
	_write_request_timeout = Time.get_ticks_msec() + WRITE_DEBOUNCE_MS

func _process():
	if Engine.is_editor_hint():
		return
	if _cfg_mutex.try_lock():
		if _write_request_timeout and (Time.get_ticks_msec() > _write_request_timeout):
			# Could slow down game if file is big
			self.call_deferred("_write_settings")
			_write_request_timeout = null
		_cfg_mutex.unlock()
	else:
		return

func _write_settings():
	if not override_path.is_empty():
		push_error("Could not write config, override path is not set")
		return
	if FileAccess.file_exists(override_path):
		push_warning("Overwriting config at %s" % override_path)

	if not SarUtils.assert_ok(custom_cfg.save(override_path),
		"Could not save config file"):
		return

func _setting_updated(p_setting) -> void:
	setting_updated.emit(p_setting)

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		add_to_group("game_settings_managers")

func _exit_tree() -> void:
	# Ensure threads released lock
	if _cfg_mutex.try_lock():
		_write_settings()
		_cfg_mutex.unlock()
	else:
		return




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
