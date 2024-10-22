extends ColorRect

var ox: float = -0.5
var oy: float = 0.0

var zoom: float = 0.2
var max_depth: int = 250

var palette_red: float = 2.0
var palette_green: float = 1.5
var palette_blue: float = 1.0

var bound: float = 2.0

func update_shader():
	self.material.set_shader_parameter("ox", ox)
	self.material.set_shader_parameter("oy", oy)
	
	self.material.set_shader_parameter("zoom", zoom)
	self.material.set_shader_parameter("max_depth", max_depth)
	
	self.material.set_shader_parameter("palette_red", palette_red)
	self.material.set_shader_parameter("palette_green", palette_green)
	self.material.set_shader_parameter("palette_blue", palette_blue)
	
	self.material.set_shader_parameter("bound", bound)
	
	dirty = true


func _ready():
	get_tree().get_root().size_changed.connect(_on_window_resize)
	update_shader()


var dirty: bool = false
var delta_modifier: float = 0.3
var click_zoom: bool = false
func _process(_delta):
	
	if Input.is_action_just_pressed("canvas_zoom_in"):
		zoom *= 1.25
		dirty = true
	elif Input.is_action_just_pressed("canvas_zoom_out"):
		zoom /= 1.25
		dirty = true
	
	if Input.is_action_just_pressed("canvas_toggle_click_zoom"):
		click_zoom = !click_zoom
		
	if click_zoom:
		if click_held:
			if not invert_click:
				zoom *= click_zoom_multiplier + _delta * delta_modifier
			else:
				zoom /= click_zoom_multiplier + _delta * delta_modifier
			dirty = true
			
	if Input.is_action_just_pressed("canvas_depth_increase"):
		max_depth += 50
		dirty = true
	elif Input.is_action_just_pressed("canvas_depth_decrease"):
		if max_depth > 50:
			max_depth -= 50
			dirty = true
			
	var canvas_pan_keyboard_speed = 500 if \
	Input.is_action_pressed("canvas_pan_speed_up") else 250
	
	if not Input.is_action_pressed("canvas_pan_jump"):
		if Input.is_action_pressed("canvas_pan_left"):
			move_towards_x_y(Vector2(-1, 0), 
				canvas_pan_keyboard_speed * move_velocity * _delta, true)
			dirty = true
		if Input.is_action_pressed("canvas_pan_right"):
			move_towards_x_y(Vector2(1, 0), 
				canvas_pan_keyboard_speed * move_velocity * _delta, true)
			dirty = true
		if Input.is_action_pressed("canvas_pan_up"):
			move_towards_x_y(Vector2(0, -1), 
				canvas_pan_keyboard_speed * move_velocity * _delta, true)
			dirty = true
		if Input.is_action_pressed("canvas_pan_down"):
			move_towards_x_y(Vector2(0, 1), 
				canvas_pan_keyboard_speed * move_velocity * _delta, true)
			dirty = true
	else:
		if Input.is_action_just_pressed("canvas_pan_left"):
			move_towards_x_y(Vector2(-1, 0), 
				canvas_pan_keyboard_speed * jump_velocity, true)
			dirty = true
		if Input.is_action_just_pressed("canvas_pan_right"):
			move_towards_x_y(Vector2(1, 0), 
				canvas_pan_keyboard_speed * jump_velocity, true)
			dirty = true
		if Input.is_action_just_pressed("canvas_pan_up"):
			move_towards_x_y(Vector2(0, -1), 
				canvas_pan_keyboard_speed * jump_velocity, true)
			dirty = true
		if Input.is_action_just_pressed("canvas_pan_down"):
			move_towards_x_y(Vector2(0, 1), 
				canvas_pan_keyboard_speed * jump_velocity, true)
			dirty = true
		
	
	if dirty:
		update_shader()
		dirty = false


var click_held: bool = false
var invert_click: bool = false
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				click_held = true
				invert_click = false
				dirty = true
			else:
				click_held = false
		elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				click_held = true
				invert_click = true
				dirty = true
			else:
				click_held = false
		else:
			if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
				zoom *= 1.05
				if click_held:
					move_towards_x_y(get_viewport().get_size() / 2, zoom_velocity)
				else:
					move_towards_x_y(get_viewport().get_mouse_position(), zoom_velocity)
				dirty = true
			elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				zoom /= 1.05
				var sizef = Vector2(get_viewport().size.x, get_viewport().size.y)
				if click_held:
					move_towards_x_y(get_viewport().get_size() / 2, zoom_velocity)
				else:
					move_towards_x_y(sizef - get_viewport().get_mouse_position(), zoom_velocity)
				dirty = true
	elif event is InputEventMouseMotion:
		if click_held || Input.is_action_pressed("canvas_pan"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			move_towards_x_y(event.relative, move_velocity, true)
			dirty = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


var zoom_velocity: float = 0.25
var move_velocity: float = 0.5
var jump_velocity: float = 0.75
var click_zoom_multiplier: float = 1.0
func move_towards_x_y(xy: Vector2, velocity: float, relative: bool = false):
	if not relative:
		var scaled_x = ox + (xy.x / get_viewport().size.x - 0.5) / zoom * velocity
		var scaled_y = oy + (xy.y / get_viewport().size.y - 0.5) / zoom * velocity
		ox = (ox + scaled_x) / 2
		oy = (oy + scaled_y) / 2
	else:
		var scaled_x = xy.x / (get_viewport().size.x / 2)
		var scaled_y = xy.y / (get_viewport().size.y / 2)
		ox += scaled_x * velocity / zoom
		oy += scaled_y * velocity / zoom


func set_shader_resolution():
	self.material.set_shader_parameter("y_ratio", 
		(float) (get_viewport().size.y) / get_viewport().size.x)
	update_shader()


func _on_window_resize():
	set_shader_resolution()
