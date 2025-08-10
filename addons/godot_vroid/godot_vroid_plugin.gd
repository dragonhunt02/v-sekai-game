# godot_vroid_plugin.gd
# SPDX-License-Identifier: MIT

## The GodotVroid plugin provides an interface for interacting with instances
## of the Vroid Hub API from Godot.

@tool
extends EditorPlugin
class_name GodotVroidPlugin

func _init():
	print("Initialising GodotVroid plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying GodotVroid plugin")


func _get_plugin_name() -> String:
	return "GodotVroid"
