extends Panel

var panel_container

# Called when the node enters the scene tree for the first time.
func _ready():
	panel_container = get_node("PanelContainer")
	get_tree().get_root().size_changed.connect(_on_window_resize)

func _on_window_resize():
	self.size = get_viewport().size
	panel_container.size = get_viewport().size
