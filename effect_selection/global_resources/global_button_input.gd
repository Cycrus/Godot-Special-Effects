extends Node2D

var key_delay: float = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and key_delay == 0.0:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://effect_selection/effect_selection.tscn")
			key_delay = 3.0
			
func _physics_process(delta: float) -> void:
	if key_delay > 0.0:
		key_delay -= delta
	elif key_delay < 0.0:
		key_delay = 0.0
