extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MouseMode.MOUSE_MODE_HIDDEN)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cursor_pos = get_viewport().get_mouse_position()
	global_position = cursor_pos
