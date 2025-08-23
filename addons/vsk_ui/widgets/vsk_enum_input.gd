extends Control
class_name VSKEnumInput

signal item_selected(idx: int, text: String)

var _opt_btn: OptionButton
var _options: Array = []

# Exported array
@export var options: Array = []:
	set(v):
		_options = v.duplicate(true)
		_refresh_options()
	get():
		return _options

# Backing storage for selected index
var _selected_index: int = -1

# Exported selected index, with inline setter
@export var selected_index: int = -1:
	set(v):
		_selected_index = clamp(v, 0, _options.size() - 1)
		_opt_btn.select(_selected_index)
	get():
		return _selected_index

func _ready() -> void:
	_opt_btn = get_node("./PanelContainer/OptionButton")
	_opt_btn.connect("item_selected", Callable(self, "_on_item_selected"))
	# Initialize control from exported values
	_refresh_options()

func _refresh_options() -> void:
	if not _opt_btn:
		return
	_opt_btn.clear()
	for idx in range(_options.size()):
		_opt_btn.add_item(_options[idx], idx)
	# If nothing selected, pick first
	if _selected_index < 0 and _options.size() > 0:
		selected_index = 0

func _on_item_selected(idx: int) -> void:
	_selected_index = idx
	emit_signal("item_selected", idx, _options[idx])
