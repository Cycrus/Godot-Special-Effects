extends Node2D


@export_category("Plant Motion Controller")
@export var wind_controller: WindController:
	set(value):
		wind_controller = value
		$PlantMotionController.wind_controller = wind_controller


var pollen_chance = 2


func _emit_pollen() -> void:
	var chance_for_pollen = randi_range(0, 100) < pollen_chance
	if not chance_for_pollen:
		return
		
	var wind = wind_controller.get_wind_strength(global_position)
	var wind_strong_enough = wind.length() > 0.8
	if not wind_strong_enough:
		return
		
	$Pollen.emitting = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_emit_pollen()


func _on_area_2d_area_entered(area: Area2D) -> void:
	$PlantMotionController.add_affecting_body(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	$PlantMotionController.remove_affecting_body(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	$PlantMotionController.add_affecting_body(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	$PlantMotionController.remove_affecting_body(body)
