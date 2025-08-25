extends Control

@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var step: float = 1.0
@export var value: float = 50.0

@onready var _slider: HSlider = $HBoxContainer/HSlider #/MarginContainer/HSlider
@onready var _input: LineEdit = $HBoxContainer/TextInput/HBoxContainer/LineEdit

func _ready():
	# Configure slider
	_slider.min_value = min_value
	_slider.max_value = max_value
	_slider.step = step
	_slider.value = value

	# Set initial text
	_input.text = str(value)

	# Connect signals
	_slider.value_changed.connect(_on_slider_value_changed)
	_input.text_submitted.connect(_on_text_submitted)

func _on_slider_value_changed(new_value: float):
	value = new_value
	_input.text = str(value)

func _on_text_submitted(new_text: String):
	var num = new_text.to_float()
	num = clamp(num, min_value, max_value)
	value = num
	_slider.value = value
	_input.text = str(value)
