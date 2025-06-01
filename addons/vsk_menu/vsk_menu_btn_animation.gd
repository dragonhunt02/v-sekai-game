extends Node

#@export var button_nodepath: NodePath = NodePath()

@export var transition_time : float = 0.2 # seconds

var active_tween: Tween = null

func animate_click(button_node : Node):
	#print("Starting scale: ", get_parent().scale)
	#var button_node = get_node_or_null(button_nodepath)

	button_node.scale = Vector2(1.0, 1.0) # reset
	button_node.pivot_offset = button_node.size / 2

	if active_tween:
		active_tween.kill()
		active_tween = null

	active_tween = button_node.create_tween() \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(button_node,"scale", Vector2(0.9, 0.9), transition_time)
	active_tween.chain() \
	.tween_property(button_node,"scale", Vector2(1.0,1.0), transition_time)
	await active_tween.finished

	button_node.scale = Vector2(1.0, 1.0)
	button_node.release_focus()
