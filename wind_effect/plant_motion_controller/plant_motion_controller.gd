extends Node2D

class_name PlantMotionController

@export_category("General Motion Settings")
## If set to true, random movement noise is added to all other movement types. Can lead to more dynamic behavior. All movement types are listed descendingly by priority.
@export var random_movement: bool = false
## If set to true, bodies and areas equipped with a certain meta tag move the sprites away while going through.
@export var body_affected: bool = false
## If set to true, a wind controller can affect the grass. You need to assign the desired wind controller manually.
@export var wind_affected: bool = false
## If set to true, the plants will perform a dynamic wavelike movement while not affected by anything else.
@export var wavelike_movement: bool = false
## The sprite to skew with all movement types.
@export var skewed_sprite: Sprite2D

@export_category("Wind Motion Settings")
## The wind controller providing dynamics data for wind-controlled movement.
@export var wind_controller: WindController
## The max skew a wind controller can cause.
@export_range(-89, 89) var max_wind_skew: float = 35.0

@export_category("Body/Area Motion Settings")
## The meta tag to detect which areas or bodies can affect the skew of the sprite.
@export var body_move_meta_tag: String = "moves_plants"
## The max distance in pixels a body or area can affect the sprite from.
@export var max_distance: float = 70.0
## The max skew a body or area can cause while going through the sprite.
@export_range(-89, 89) var max_body_skew: float = 80.0

@export_category("Random Motion Settings")
## The noise value added to the movements if the random movement is active.
@export_range(0, 1) var random_movement_value: float = 0.2

@export_category("Wavelike Motion Settings")
## The max skew the default wavelike motion can cause.
@export_range(-89, 89) var max_wavelike_skew: float = 8.0
## The speed of the wavelike motion.
@export var wavelike_movement_speed: float = 1.2

var affecting_bodies: Array = []
var skew_value: float = 0.0
var wavelike_direction: float = 0.0
var timer: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelike_direction = sign(randf() - 0.5)
	
	
func _physics_process(delta: float) -> void:
	timer += delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var skew_values: Array = []
	if wind_affected:
		var wind_skew = _process_wind_effect()
		skew_values.append(wind_skew)
	if wavelike_movement:
		var wavelike_skew = _process_wavelike_movement()
		skew_values.append(wavelike_skew)
	if body_affected:
		var body_skew = _process_affecting_bodies()
		skew_values.append(body_skew)
		
	skew_value = 0.0
	for new_skew_value in skew_values:
		if new_skew_value != INF:
			skew_value += new_skew_value
	skew_value /= skew_values.size()
		
	if random_movement:
		_process_random_movement()
		
	_apply_skew()


func _set_skew_zero() -> void:
	skew_value = 0.0
	

func _process_wavelike_movement() -> float:
	var wavelike_skew = wavelike_direction * sin(timer * wavelike_movement_speed) * max_wavelike_skew
	return wavelike_skew
	

func _get_body_distance_vector(body: Node2D) -> Vector2:
	var origin = global_position
	origin.y += skewed_sprite.get_rect().size.y / 2
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
	

func _process_affecting_bodies() -> float:
	var skew_ratio_sum: float = 0.0
	if affecting_bodies.size() > 0:
		for body in affecting_bodies:
			var body_skew_ratio = _compute_body_skew_ratio(body)
			skew_ratio_sum -= body_skew_ratio
		var body_skew = skew_ratio_sum / affecting_bodies.size() * max_body_skew
		return body_skew
	return INF
		

func _process_wind_effect() -> float:
	var wind_strength: Vector2 = wind_controller.get_wind_strength(global_position)
	var wind_skew = wind_strength.length() * max_wind_skew * sign(wind_strength.x)
	return wind_skew
		
		
func _process_random_movement() -> void:
	skew_value += (randf() * 2 - 1) * random_movement_value # Positivation and scaling of random value

		
func _apply_skew() -> void:
	var skew_value_rad: float = deg_to_rad(skew_value)
	skewed_sprite.set_skew(skew_value_rad)
		
		
func add_affecting_body(body: Node2D) -> void:
	if body.has_meta(body_move_meta_tag):
		if body.get_meta(body_move_meta_tag):
			affecting_bodies.append(body)
		

func remove_affecting_body(body: Node2D) -> void:
	if body in affecting_bodies:
		affecting_bodies.erase(body)
