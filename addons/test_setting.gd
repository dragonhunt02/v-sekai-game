@tool
extends Control
class_name VSKUIViewSettingsBrowser2

const _content_item_scene_const: PackedScene = preload("./../widgets/vsk_big_button.tscn")
const _button_scn: PackedScene = preload("./../widgets/vsk_check_box.tscn")
const _enum_scn: PackedScene = preload("./../widgets/vsk_enum_input.tscn")
const _slider_scn: PackedScene = preload("./../widgets/vsk_slider_text_input.tscn")
const _widget_scn: PackedScene = preload("./../widgets/vsk_setting_container.tscn")

const _settings_info: VSKSettingsInfo = preload("res://addons/vsk_game_framework/data/vsk_default_settings_info.tres")

func _build_settings():
	#var error: 
	var initial_setting: Variant = null
	var settings: Dictionary = _settings_info.get_categories_dict()
	for category: String in settings:
		for setting: VSKSettingsInfoSetting in settings:
			initial_setting = VSKGameSettingsManagerSingleton.get_value(setting.category, setting.key)
			#if typeof(initial_setting) != setting.type:
			if setting.hint == PROPERTY_HINT_ENUM:
				_add_enum_widget(setting, initial_setting)
			elif setting.hint == PROPERTY_HINT_RANGE:
				match setting.type:
					TYPE_INT:
						add_content_item2()
					TYPE_FLOAT:
						add_content_item2()
					_:
						SarUtils.assert_true(false, "UI display is not supported for range of type %s" % type_string(setting.type))
			else:
				match setting.type:
					TYPE_INT:
						add_content_item2()
					TYPE_FLOAT:
						add_content_item2()
					TYPE_BOOL:
						add_content_item2()
					TYPE_STRING:
						add_content_item2()
					_:
						SarUtils.assert_true(false, "UI display is not supported for type %s" % type_string(setting.type))

			pass


func _update_content_size0() -> void:
	if content_item_container and content_scroll_container:
		for child in content_item_container.get_children():
			child.custom_minimum_size = Vector2(
				0.0,
				float(content_scroll_container.size.y) / float(content_item_container.columns) * 1.5
			)

func _update_content_size() -> void:
	if content_item_container and content_scroll_container:
		var child_count := content_item_container.get_child_count()
		var columns: int = max(content_item_container.columns, 1)
		var rows := int(ceil(float(child_count) / float(columns)))
		
		var available_height := content_scroll_container.size.y
		var row_height := available_height / float(rows)
		
		for child in content_item_container.get_children():
			child.custom_minimum_size = Vector2(0.0, row_height)


func _content_item_container_resized():
	pass
	#_update_content_size()
	
func _notification(p_what: int) -> void:
	add_content_item2()
	match p_what:
		NOTIFICATION_RESIZED:
			_update_content_size()
					

func _ready() -> void:
	if content_item_container:
		if not SarUtils.assert_ok(content_item_container.resized.connect(_content_item_container_resized),
			"Could not connect signal 'content_item_container.resized' to '_content_item_container_resized'"):
			return

###

@export var show_search: bool = false:
	set(p_show_search):
		show_search = p_show_search
		if not is_node_ready():
			await ready
		
		if content_search_container:
			if show_search:
				content_search_container.show()
			else:
				content_search_container.hide()
			
@export var content_item_container: GridContainer = null
@export var content_scroll_container: ScrollContainer = null
@export var content_load_indicator: Control = null
@export var content_search_container: Control = null:
	set(p_content_search_container):
		content_search_container = p_content_search_container
		if content_search_container:
			if show_search:
				content_search_container.show()
			else:
				content_search_container.hide()

@export var content_label: Label = null:
	set(p_label):
		content_label = p_label
		if content_label:
			content_label.text = content_text

@export var content_text: String = "":
	set(p_text):
		content_text = p_text
		
		if not is_node_ready():
			await ready
		
		if content_label:
			content_label.text = p_text

# Review locale
func _set_enum_setting(p_idx: int, p_option: String, p_setting: VSKSettingsInfoSetting):
	match p_setting.type:
		TYPE_INT:
			VSKGameSettingsManagerSingleton.set_value(p_setting.category, p_setting.key, p_idx)
		TYPE_STRING:
			VSKGameSettingsManagerSingleton.set_value(p_setting.category, p_setting.key, p_option)
		#_:
		#	SarUtils.assert_true(false, "UI display is not supported for key %s: enum type %s" % [p_setting.key, type_string(p_setting.type)])

func _add_enum_widget(p_setting: VSKSettingsInfoSetting, p_initial_value: Variant = null):
	var widget = add_setting(p_setting.display_name, _slider_scn)
	var setting_enum: Array = p_setting.hint_as_enum()
	widget.options = setting_enum
	#move up
	match p_setting.type:
		TYPE_INT:
			widget.selected_index = p_initial_value
		TYPE_STRING:
			for option_name: String in setting_enum:
			for idx in range(setting_enum.size()):
				if p_initial_value == setting_enum[idx]:
					widget.selected_index = idx
		_:
			SarUtils.assert_true(false, "UI display is not supported for key %s: enum type %s" % [p_setting.key, type_string(setting.type)])
			return
	if not SarUtils.assert_ok( widget.item_selected.connect( _set_enum_setting.bind(setting) ) ):
		return

func _add_slider_widget(p_setting: VSKSettingsInfoSetting, p_initial_value: Variant = null):
	var widget = add_setting(p_setting.display_name, _slider_scn)
	var setting_dict: Dictionary = p_setting.hint_as_float_range()
	widget.options = settings_enum
	#move up
	match p_setting.type:
		TYPE_INT:
			widget.selected_index = p_initial_value
		TYPE_STRING:
			for option_name: String in settings_enum:
			for idx in range(settings_enum.size()):
				if p_initial_value == settings_enum[idx]:
					widget.selected_index = idx
		_:
			SarUtils.assert_true(false, "UI display is not supported for key %s: enum type %s" % [p_setting.key, type_string(setting.type)])
	#widget.item_selected.connect((_set_setting)


#func add_setting_item(p_

func add_content_item2():
	var widget = add_setting("Cooler", _slider_scn)
	#if widget.is_class("VSKEnumInput"):
	#widget.options= ["abcdef", "ghi"]
	
func add_setting(p_name: String, p_widget: PackedScene, p_initial_value: Variant = null):
	#var margin_container := _widget_scn.instantiate()
	var margin_container := _widget_scn.instantiate()
	var widget := p_widget.instantiate()
	var widget_container := margin_container.get_node("HBoxContainer/WidgetContainer")
	widget_container.add_child(widget)
	# 5. Finally, add it to your container
	if content_item_container:
		# Ensure the parent container also expands
		content_item_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		content_item_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		content_item_container.add_theme_constant_override("h_separation", 80)
		content_item_container.add_theme_constant_override("v_separation", 20)
		#content_item_container.set_columns(3)


		margin_container.name = "content_%s" % content_item_container.get_child_count()
		margin_container.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		margin_container.mouse_filter = Control.MOUSE_FILTER_PASS

		content_item_container.add_child(margin_container)
		print("added")
		return widget
	return null


"""
func add_content_item(p_text: String, p_url: String) -> VSKButton:
	var instance: VSKButton = null
	if content_item_container:
		instance = _content_item_scene_const.instantiate()
		if instance:
			instance.name = "content_%s" % str(content_item_container.get_child_count())
			instance.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			instance.text = p_text
			instance.url = p_url
			
			content_item_container.add_child(instance)
			instance.set_h_size_flags(SIZE_EXPAND_FILL)
			instance.mouse_filter = Control.MOUSE_FILTER_PASS
			
			# Wire up focus neighbours.
			var child_count: int = content_item_container.get_child_count()
			if child_count > 1:
				var child_index = child_count -1
				# Horizontal neighbors
				if child_index % content_item_container.columns:
					if child_index - 1 >= 0:
						var left_sibling: Control = content_item_container.get_child(child_index - 1)
						instance.focus_neighbor_left = instance.get_path_to(left_sibling)
						
						left_sibling.focus_neighbor_right = left_sibling.get_path_to(instance)
				# Vertical neighbors
				if child_index - content_item_container.columns >= 0:
					var top_sibling: Control = content_item_container.get_child(child_index - content_item_container.columns)
					instance.focus_neighbor_top = instance.get_path_to(top_sibling)
					
					top_sibling.focus_neighbor_bottom = top_sibling.get_path_to(instance)
	
	return instance
	
"""

func clear_content() -> void:
	if content_item_container:
		for child in content_item_container.get_children():
			child.queue_free()
			content_item_container.remove_child(child)
