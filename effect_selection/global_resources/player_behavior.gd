extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MouseMode.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("idle")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var cursor_pos = get_viewport().get_mouse_position()
	if $"../Camera2D":
		cursor_pos = $"../Camera2D".get_global_mouse_position()
	global_position = cursor_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				var mirrored = not $Body.get_meta("mirrored")
				$Body.set_meta("mirrored", mirrored)
				var plant_mover = not $Body.get_meta("moves_plants")
				$Body.set_meta("moves_plants", plant_mover)
				for node in get_parent().get_children():
					if node.has_method("rescan_mirrored_objects"):
						node.rescan_mirrored_objects()
				print("Toggled mirrored")
				print("Toggled plant mover")
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var mirror_y_offset = $Body.get_meta("mirror_y_offset")
				mirror_y_offset += 10
				if mirror_y_offset > 50:
					mirror_y_offset = -20
				$Body.set_meta("mirror_y_offset", mirror_y_offset)
				print("Increased mirror_y_offset")
