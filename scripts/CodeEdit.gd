extends CodeEdit


func update_font_size():
	var new_font_size = (get_viewport().size.x + get_viewport().size.y) / 2
	new_font_size *= 0.031
	add_theme_font_size_override("font_size", new_font_size)


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_window_resize)
	update_font_size()


func _on_window_resize():
	update_font_size()
