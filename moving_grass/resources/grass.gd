extends Node


@export_category("Plant Motion Controller")
@export var wind_controller: WindController:
	set(value):
		wind_controller = value
		$PlantMotionController.wind_controller = wind_controller


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
