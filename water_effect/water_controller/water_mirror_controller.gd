@tool
extends Node2D


@export var do_mirror: bool = false
@export var mirror_detection_shape: Shape2D:
	set(value):
		mirror_detection_shape = value
		_set_mirror_detection_shape(mirror_detection_shape)
@export var water_material: ShaderMaterial:
	set(value):
		water_material = value
		_set_water_material(water_material)
@export var show_mirror_detection_shape: bool = true:
	set(value):
		show_mirror_detection_shape = value
		_show_mirror_detection_shape(show_mirror_detection_shape)
@export var mirror_image_material: ShaderMaterial

var mirrored_objects: Dictionary = {}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if do_mirror:
		for body in mirrored_objects:
			var sprite = mirrored_objects[body]["sprite"]
			var y_offset = mirrored_objects[body]["y_offset"]
			sprite.global_position = body.global_position
			sprite.global_position.y += sprite.texture.get_height() * sprite.global_scale.y + y_offset
	else:
		if mirrored_objects.size() > 0:
			mirrored_objects.clear()


func _add_mirrored_object(body: Node2D) -> void:
	if do_mirror:
		var sprite: Sprite2D = null
		for node in body.get_parent().get_children():
			if node is Sprite2D:
				sprite = node
				break
		if sprite == null:
			return
		mirrored_objects[body] = {
			"sprite": sprite.duplicate(),
			"y_offset": 0.0
		}
		add_child(mirrored_objects[body]["sprite"])
		mirrored_objects[body]["sprite"].z_index = z_index + 1
		mirrored_objects[body]["sprite"].flip_v = true
		mirrored_objects[body]["sprite"].global_position = sprite.global_position
		mirrored_objects[body]["sprite"].scale = Vector2(sprite.global_scale.x / global_scale.x,
												   		 sprite.global_scale.y / global_scale.y)
		mirrored_objects[body]["sprite"].material = mirror_image_material.duplicate()
		mirrored_objects[body]["sprite"].material.shader = mirror_image_material.shader.duplicate()
		if body.get_parent().has_meta("mirror_offset"):
			mirrored_objects[body]["y_offset"] = body.get_parent().get_meta("mirror_offset")
			mirrored_objects[body]["sprite"].material.set("shader_parameter/floating_image", true)
		else:
			mirrored_objects[body]["sprite"].material.set("shader_parameter/floating_image", false)


func _remove_mirrored_object(body: Node2D) -> void:
	if do_mirror:
		if not mirrored_objects.has(body):
			return
		mirrored_objects[body]["sprite"].queue_free()
		mirrored_objects.erase(body)

func _set_mirror_detection_shape(mirror_detection_shape: Shape2D) -> void:
	if $MirrorArea/MirrorCollisionObject:
		$MirrorArea/MirrorCollisionObject.shape = mirror_detection_shape
	
func _set_water_material(water_material: ShaderMaterial) -> void:
	if $WaterSurface:
		$WaterSurface.material = water_material
		
func _show_mirror_detection_shape(show_mirror_detection_shape: bool) -> void:
	if $MirrorArea/MirrorCollisionObject:
		$MirrorArea/MirrorCollisionObject.visible = show_mirror_detection_shape

func _on_area_2d_area_entered(area: Area2D) -> void:
	_add_mirrored_object(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	_remove_mirrored_object(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_add_mirrored_object(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	_remove_mirrored_object(body)
