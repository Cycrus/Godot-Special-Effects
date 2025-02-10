extends Node2D

func _on_downfall_pressed() -> void:
	get_tree().change_scene_to_file("res://downfall_effect/downfall_scene.tscn")


func _on_fog_pressed() -> void:
	get_tree().change_scene_to_file("res://fog_effect/fog_scene.tscn")


func _on_glow_pressed() -> void:
	get_tree().change_scene_to_file("res://glow_effect/glow_scene.tscn")


func _on_pixellation_pressed() -> void:
	get_tree().change_scene_to_file("res://pixelation_effect/pixelation_shader_scene.tscn")


func _on_texture_splatting_pressed() -> void:
	get_tree().change_scene_to_file("res://texture_splatting_effect/texture_splatting_scene.tscn")


func _on_water_pressed() -> void:
	get_tree().change_scene_to_file("res://water_effect/water_shading_scene.tscn")


func _on_wind_pressed() -> void:
	get_tree().change_scene_to_file("res://wind_effect/wind_scene.tscn")


func _on_footprints_pressed() -> void:
	get_tree().change_scene_to_file("res://footsteps_effect/footsteps_scene.tscn")
