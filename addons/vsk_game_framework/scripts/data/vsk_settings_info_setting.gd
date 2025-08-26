@tool
extends Resource
class_name VSKSettingsInfoSetting

@export var display_name: String
@export var category: String
@export var key: String
@export var type: Variant.Type
@export var hint: PropertyHint
@export var hint_string: String

# Internal use only, can be null. Use for registered class enums like 'Viewport.MSAA'.
@export var godot_enum: String:
	set(value):
		#print("values is %s" % value);
		if value and not value.is_empty():
			hint_string = ",".join(_enum_list_from_string(value))
			hint = PROPERTY_HINT_ENUM
			type = TYPE_INT
			godot_enum = value
		

func _ready() -> void:
	print("heyy")
	print(display_name)
	if godot_enum:
		print("yay")

func _enum_list_from_string(enum_str: String) -> Array:
	var result: Array = []
	# 1. Split "Viewport.MSAA" → ["Viewport","MSAA"]
	var parts = enum_str.split(".")
	if parts.size() != 2:
		push_error("Invalid enum format: %s" % enum_str)
		return result

	var classname = parts[0]
	var const_name = parts[1]

	# 2. Check existence
	if not ClassDB.class_has_enum(classname, const_name):
		push_error("No constant %s.%s" % [classname, const_name])
		return result

	# 3. Fetch the integer value
	#print(ClassDB.class_get_enum_list(parts[0]))
	result = ClassDB.class_get_enum_constants(parts[0], parts[1])
	return result

func to_dict() -> Dictionary:
	return {
		"display_name": display_name,
		"category": category,
		"key": key,
		# Cast enums to ints so they serialize cleanly
		"type": int(type),
		"hint": int(hint),
		"hint_string": hint_string
	}

# Override built-in hook
func _to_string() -> String:
	return str(self.to_dict())
