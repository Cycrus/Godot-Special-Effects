extends Node2D

class_name PlantMovement

@export var random_movement: bool = false
@export var body_affected: bool = false
@export var wind_affected: bool = false
@export var wavelike_movement: bool = false
@export var wind_controller: WindController
@export var skewed_sprite: Sprite2D
@export var max_distance: float = 40.0
@export var max_body_skew: float = 20.0
@export var max_wind_skew: float = 15.0
@export var random_movement_value: float = 0.2

var affecting_bodies: Array = []
var skew_value: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wind_affected:
		_process_wind_effect()
	if body_affected:
		_process_affecting_bodies()
	if random_movement:
		_process_random_movement()
		
	_apply_skew()


func _set_skew_zero() -> void:
	skew_value = 0.0
	

func _get_body_distance_vector(body: Node2D) -> Vector2:
	var origin = global_position
	origin.y += skewed_sprite.get_rect().size.y / 2 # Constant offset from bottom of grass object
	return body.global_position - origin
	
	
func _compute_body_skew_ratio(body: Node2D) -> float:
	var body_distance_vector = _get_body_distance_vector(body)
	var body_distance = body_distance_vector.length()
	if body_distance > max_distance:
		body_distance = max_distance
	var body_y_side = sign(body_distance_vector.x)
	var body_skew_ratio = (1.0 - body_distance / max_distance) * body_y_side
	if body_skew_ratio > 1.0:
		body_skew_ratio = 1.0
	elif body_skew_ratio < -1.0:
		body_skew_ratio = -1.0
	return body_skew_ratio
	

func _process_affecting_bodies() -> void:
	var skew_ratio_sum: float = 0.0
	if affecting_bodies.size() > 0:
		for body in affecting_bodies:
			var body_skew_ratio = _compute_body_skew_ratio(body)
			skew_ratio_sum -= body_skew_ratio
		skew_value = skew_ratio_sum / affecting_bodies.size() * max_body_skew
		
		
func _process_wind_effect() -> void:
	var wind_strength: Vector2 = wind_controller.get_wind_strength(global_position)
	skew_value = wind_strength.length() * max_wind_skew * sign(wind_strength.x)
		
		
func _process_random_movement() -> void:
	skew_value += (randf() * 2 - 1) * random_movement_value # Positivation and scaling of random value
		
		
func _apply_skew() -> void:
	var skew_value_rad: float = deg_to_rad(skew_value)
	skewed_sprite.set_skew(skew_value_rad)
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_meta("moves_plants"):
		affecting_bodies.append(area)
	

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in affecting_bodies:
		affecting_bodies.erase(area)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("moves_plants"):
		affecting_bodies.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in affecting_bodies:
		affecting_bodies.erase(body)
