@tool
extends Node2D


@export_category("Water Settings")
## Selects the shading material of the water surface.
@export var water_material: ShaderMaterial:
	set(value):
		water_material = value
		_set_water_material(water_material)
@export_category("Mirror Image Settings")
## If set the surface is able to mirror objects vertically.
@export var do_mirror: bool = false
## The detection shape of the mirror. All marked areas and bodys colliding with this shape are allowed to be mirrored.
@export var mirror_detection_shape: Shape2D:
	set(value):
		mirror_detection_shape = value
		_set_mirror_detection_shape(mirror_detection_shape)
## If set to true, the mirror detection shape is drawn in the editor. Useful to set the shape correctly.
@export var show_mirror_detection_shape: bool = true:
	set(value):
		show_mirror_detection_shape = value
		_show_mirror_detection_shape(show_mirror_detection_shape)
## The meta tag (boolean set to true) all areas and bodies need to have to be mirrored by this surface.
@export var mirrorable_meta_tag: String = "mirrored"
## The meta tag (string) an area or body can have to enable a y offset on their mirrored image. Allows for a floating/flying impression.
@export var mirror_y_offset_meta_tag: String = "mirror_y_offset"
## The shader material of the mirrored image. Allows for natural distortion effects in the mirrored image.
@export var mirror_image_material: ShaderMaterial


var mirrored_objects: Dictionary = {}
var perform_rescan: bool = false


func _remove_unnecessary_body(body: Node2D) -> bool:
	if not body.has_meta(mirrorable_meta_tag) or \
	   not body.get_meta(mirrorable_meta_tag):
		_remove_mirrored_object(body)
		return true
	return false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if do_mirror:
		for body in mirrored_objects:
			var removed_body = _remove_unnecessary_body(body)
			if not removed_body:
				_update_mirror_image(body)
	else:
		if mirrored_objects.size() > 0:
			mirrored_objects.clear()


func _crop_current_animation_frame(original_sprite: Sprite2D, image_texture: Image) -> ImageTexture:
	var texture_size: Vector2 = image_texture.get_size()
	var frame_size: Vector2 = Vector2(texture_size.x / original_sprite.hframes,
									  texture_size.y / original_sprite.vframes)
	var curr_frame_pos : Vector2 = Vector2(frame_size.x * original_sprite.frame_coords.x, frame_size.y * original_sprite.frame_coords.y)
	var frame_rect: Rect2i = Rect2i(curr_frame_pos, frame_size)
	var cropped_image: Image = image_texture.get_region(frame_rect)
	var cropped_texture: ImageTexture = ImageTexture.create_from_image(cropped_image)
	return cropped_texture


func _update_mirror_image(body: Node2D) -> void:
	var sprite = mirrored_objects[body]["sprite"]
	var original_sprite = mirrored_objects[body]["original_sprite"]
	var image_texture = mirrored_objects[body]["texture_image"]
	var y_offset = 0.0
	
	var cropped_animation_frame: ImageTexture = _crop_current_animation_frame(original_sprite, image_texture)
	sprite.texture = cropped_animation_frame
	
	if body.has_meta(mirror_y_offset_meta_tag):
		y_offset = body.get_meta(mirror_y_offset_meta_tag)
		sprite.material.set("shader_parameter/floating_image", true)
	else:
		sprite.material.set("shader_parameter/floating_image", false)
	
	sprite.global_position = original_sprite.global_position
	sprite.global_position.y += sprite.texture.get_height() * sprite.global_scale.y + y_offset
	sprite.skew = original_sprite.skew * -1
	sprite.scale = Vector2(original_sprite.global_scale.x / global_scale.x,
						   original_sprite.global_scale.y / global_scale.y)


func _extract_texture_image(sprite: Sprite2D) -> Image:
	var texture_image: Image = sprite.texture.get_image()
	return texture_image
	

func _prepare_mirrored_sprite(mirrored_sprite_dict: Dictionary) -> void:
	mirrored_sprite_dict["sprite"].z_index = z_index + 1
	mirrored_sprite_dict["sprite"].flip_v = true
	mirrored_sprite_dict["sprite"].hframes = 1
	mirrored_sprite_dict["sprite"].vframes = 1
	mirrored_sprite_dict["sprite"].frame = 0
	mirrored_sprite_dict["sprite"].frame_coords = Vector2(0, 0)
	mirrored_sprite_dict["sprite"].material = mirror_image_material.duplicate()
	mirrored_sprite_dict["sprite"].material.shader = mirror_image_material.shader.duplicate()


func _add_mirrored_object(body: Node2D) -> void:
	if not do_mirror:
		return
	if not body.has_meta(mirrorable_meta_tag) or \
	   not body.get_meta(mirrorable_meta_tag):
		return
	if mirrored_objects.has(body):
		return
		
	var sprite: Sprite2D = null
	for node in body.get_parent().get_children():
		if node is Sprite2D:
			sprite = node
			break
	if sprite == null:
		return
		
	var full_texture_image = _extract_texture_image(sprite)
	mirrored_objects[body] = {
		"sprite": sprite.duplicate(),
		"original_sprite": sprite,
		"texture_image": full_texture_image
	}
	_prepare_mirrored_sprite(mirrored_objects[body])
	_update_mirror_image(body)
	add_child(mirrored_objects[body]["sprite"])


func _remove_mirrored_object(body: Node2D) -> void:
	if not mirrored_objects.has(body):
		return
	if perform_rescan:
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


func rescan_mirrored_objects():
	perform_rescan = true
	$MirrorArea/MirrorCollisionObject.disabled = true
	await get_tree().process_frame
	$MirrorArea/MirrorCollisionObject.disabled = false
	perform_rescan = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	_add_mirrored_object(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	_remove_mirrored_object(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_add_mirrored_object(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	_remove_mirrored_object(body)
