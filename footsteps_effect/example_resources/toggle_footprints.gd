extends Node


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var spawn_footprints = $Player/FootstepController.spawn_footprints
				$Player/FootstepController.spawn_footprints = not spawn_footprints
				print("Toggled Footprints")
