@tool
extends Control
class_name VSKUIViewSettingsBrowser

const _content_item_scene_const: PackedScene = preload("./../widgets/vsk_big_button.tscn")
const _button_scn: PackedScene = preload("./../widgets/vsk_check_box.tscn")
const _enum_scn: PackedScene = preload("./../widgets/vsk_enum_input.tscn")
const _widget_scn: PackedScene = preload("./../widgets/vsk_setting_container.tscn")

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

func add_content_item2():
	var widget = add_setting("Cooler", _enum_scn)
	#if widget.is_class("VSKEnumInput"):
	widget.options= ["abcdef", "ghi"]
	
func add_setting(p_name: String, p_widget: PackedScene):
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
