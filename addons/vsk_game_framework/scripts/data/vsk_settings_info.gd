@tool
extends Resource
class_name VSKSettingsInfo

#@export var categories: Dictionary[String, VSKSettingsInfoCategory] = {}

@export var settings: Array[VSKSettingsInfoSetting] = []

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
		result[category] = setting
	return result

# Assuming keys are unique
func get_key(p_key, p_default = null) -> Dictionary:
	var result: Dictionary = p_default
	for setting in settings:
		if setting.key == p_key:
			return setting
	return result

