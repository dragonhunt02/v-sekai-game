@tool
extends Resource
class_name VSKSettingsInfo

#@export var categories: Dictionary[String, VSKSettingsInfoCategory] = {}

@export var settings: Array[VSKSettingsInfoSetting] = []

func _init() -> void:
	print("ok")

func get_category(p_category: String) -> Array:
	var result: Array = []
	for setting in settings:
		if setting.category == p_category:
			result.append(p_category)
	return result

func get_categories_dict() -> Dictionary:
	var result: Dictionary = {}
	var category: String = ""
	for setting in settings:
		category = setting.category
		if not result.get(category):
			result[category] = []
		result[category].append(setting)
	return result

func get_key(p_section: String, p_key: String, p_default = null) -> VSKSettingsInfoSetting:
	var result = p_default
	for setting in settings:
		if setting.category == p_section and setting.key == p_key:
			return setting
	return result

func to_array() -> Array:
	return settings.duplicate(true)

func _to_string() -> String:
	return str(self.settings)
