tool
extends PanelContainer

signal setting_updated(path: String)

func _ready():
    if Engine.is_editor_hint():
        return
    _build_ui()

func _build_ui() -> void:
    var all_settings = ProjectSettings.get_setting_list()
    var by_section := {}
    # Group all settings by their first path element
    for info in all_settings:
        var section = info.name.get_slice("/", 0)
        by_section.setdefault(section, []).append(info)

    var vbox = $ScrollContainer/VBox
    for section in by_section.keys().sort():
        # Create a collapsible SectionContainer
        var sec = SectionContainer.new()
        sec.title = section.capitalize()
        vbox.add_child(sec)

        var inner = VBoxContainer.new()
        sec.add_child(inner)

        for info in by_section[section]:
            var h = HBoxContainer.new()
            inner.add_child(h)

            # Label
            var lbl = Label.new()
            lbl.text = info.name.substr(section.length() + 1)
            lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            h.add_child(lbl)

            # Control
            var ctrl = _create_control(info)
            if ctrl:
                h.add_child(ctrl)

func _create_control(info: Dictionary) -> Control:
    var path = info.name
    var cur_val = ProjectSettings.get_setting(path)

    match info.type:
        TYPE_BOOL:
            var cb = CheckBox.new()
            cb.pressed = cur_val
            cb.connect("toggled", self, "_on_bool_toggled", [path])
            return cb

        TYPE_INT, TYPE_FLOAT:
            # If hint is a range, build a Slider; else a SpinBox
            if info.hint == PROPERTY_HINT_RANGE:
                var parts = info.hint_string.split(",")
                var minv = parts[0].to_float()
                var maxv = parts[1].to_float()
                var step = parts.size() > 2 ? parts[2].to_float() : 1.0
                var slider = HSlider.new()
                slider.min_value = minv
                slider.max_value = maxv
                slider.step = step
                slider.value = cur_val
                slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                slider.connect("value_changed", self, "_on_number_changed", [path])
                return slider
            else:
                var sb = SpinBox.new()
                sb.allow_greater = true
                sb.allow_lesser = true
                sb.step = 1.0
                sb.value = cur_val
                sb.connect("value_changed", self, "_on_number_changed", [path])
                return sb

        TYPE_STRING:
            var le = LineEdit.new()
            le.text = cur_val
            le.connect("text_changed", self, "_on_text_changed", [path])
            return le

        TYPE_COLOR:
            var cpb = ColorPickerButton.new()
            cpb.color = cur_val
            cpb.connect("color_changed", self, "_on_color_changed", [path])
            return cpb

        _:
            # Handle enumerations via hint_string
            if info.hint == PROPERTY_HINT_ENUM:
                var opts = info.hint_string.split(",")
                var ob = OptionButton.new()
                for i in opts.size():
                    ob.add_item(opts[i].capitalize(), i)
                ob.selected = cur_val
                ob.connect("item_selected", self, "_on_enum_selected", [path, opts])
                return ob

    return null

# Signal handlers

func _on_bool_toggled(button_pressed: bool, path: String) -> void:
    ProjectSettings.set_setting(path, button_pressed)
    emit_signal("setting_updated", path)

func _on_number_changed(value: float, path: String) -> void:
    ProjectSettings.set_setting(path, value)
    emit_signal("setting_updated", path)

func _on_text_changed(text: String, path: String) -> void:
    ProjectSettings.set_setting(path, text)
    emit_signal("setting_updated", path)

func _on_color_changed(color: Color, path: String) -> void:
    ProjectSettings.set_setting(path, color)
    emit_signal("setting_updated", path)

func _on_enum_selected(idx: int, path: String, opts: Array) -> void:
    ProjectSettings.set_setting(path, idx)
    emit_signal("setting_updated", path)
