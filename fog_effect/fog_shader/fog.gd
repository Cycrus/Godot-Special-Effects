@tool
extends Node


@export var shader_material: ShaderMaterial:
	set(value):
		shader_material = value
		set_shader_material(shader_material)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_shader_material(shader_material: ShaderMaterial) -> void:
	$Sprite2D.material = shader_material
