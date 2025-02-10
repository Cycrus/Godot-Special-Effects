extends Node2D


## While true, the controller spawns footprints while moving around.
@export var spawn_footprints: bool = true
## The texture of the footprints to spawn.
@export var footstep_texture: Texture2D
## The delay in seconds between every two footprints.
@export var footstep_delay: float = 0.4
## The distance offset between two footsteps in pixels.
@export var footstep_offset_horizontal: float = 20.0
## The of the footprints relative to the motion vector.
@export_range(-90.0, 90.0) var footstep_angle: float = 20.0
## The maximum lifetime of each footprint until it starts fading away. If 0, they always stay.
@export var footstep_max_lifetime: float = 1.0
## The amount how much the footprints fade away each second after their lifetime was reached.
@export_range(0.0, 1.0) var footstep_fading_factor: float = 0.5


class Footstep:
	var sprite: Sprite2D = null
	var lifetime: float = 0.0


var parent_position_tracker: Array[Vector2] = []
var footstep_list: Array[Footstep] = []
var footstep_timer: float = 0.0
var curr_foot: int = 0
var no_movement_counter: int = 0
var no_movement_threshold: int = 20
var footprint_rotation: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_position_tracker.append(global_position)
	parent_position_tracker.append(global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_push_new_position(global_position)
	_compute_footprint_rotation()
	
	_fade_footsteps(delta)
	
	if not _parent_has_moved():
		footstep_timer = 0.0
		return
		
	if _new_footstep_ready():
		_spawn_footstep()
		footstep_timer = 0.0
		
	footstep_timer += delta


func _compute_footprint_rotation() -> void:
	if parent_position_tracker[0] != parent_position_tracker[1]:
		footprint_rotation = parent_position_tracker[0].angle_to_point(parent_position_tracker[1]) - PI / 2


func _fade_footsteps(delta: float) -> void:
	if footstep_max_lifetime == 0:
		return
		
	for footstep_idx in range(footstep_list.size() - 1, -1, -1):
		var footstep = footstep_list[footstep_idx]
		footstep.lifetime += delta
		if footstep.lifetime >= footstep_max_lifetime:
			footstep.sprite.modulate.a -= footstep_fading_factor * delta
		if footstep.sprite.modulate.a <= 0.0:
			footstep.sprite.queue_free()
			footstep_list.remove_at(footstep_idx)


func _new_footstep_ready() -> bool:
	return spawn_footprints and footstep_timer >= footstep_delay


func _spawn_footstep() -> void:
	var new_footstep: Sprite2D = Sprite2D.new()
	new_footstep.texture = footstep_texture
	new_footstep.global_position = parent_position_tracker[1]
	new_footstep.global_rotation = footprint_rotation
	if curr_foot % 2 == 0:
		new_footstep.translate(Vector2(footstep_offset_horizontal / 2, 0.0))
		new_footstep.rotate(deg_to_rad(footstep_angle))
	else:
		new_footstep.translate(Vector2(-footstep_offset_horizontal / 2, 0.0))
		new_footstep.rotate(deg_to_rad(-footstep_angle))
	new_footstep.z_index = z_index - 1
	var new_footstep_container: Footstep = Footstep.new()
	new_footstep_container.sprite = new_footstep
	$FootstepContainer.add_child(new_footstep)
	footstep_list.append(new_footstep_container)
	curr_foot += 1


func _push_new_position(new_position: Vector2) -> void:
	parent_position_tracker[1] = parent_position_tracker[0]
	parent_position_tracker[0] = new_position


func _parent_has_moved() -> bool:
	var movement_detected: bool = parent_position_tracker[0] != parent_position_tracker[1]
	if movement_detected:
		no_movement_counter = 0
	else:
		no_movement_counter += 1
	var body_stands_still: bool = no_movement_counter >= no_movement_threshold
	return not body_stands_still
