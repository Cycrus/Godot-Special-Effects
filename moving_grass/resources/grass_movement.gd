extends Node2D

@export var max_distance: float = 40.0
@export var max_body_skew: float = 20.0
@export var max_wind_skew: float = 15.0
@export var wind_direction: float = -1
@export var wind_waiting_phases: int = 3
@export var wind_phase_speed: float = 0.024
@export var wind_progression_speed: float = 250

var affecting_bodies: Array = []
var skew_value: float = 0.0
var curr_wind_phase: int = 0
var in_wind_phase: bool = false
var counter: float = 0.0
var wind_blown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var wind_phase_init: int = 0
	wind_phase_init = int((global_position.x - global_position.y) / (wind_progression_speed * PI))
	curr_wind_phase = curr_wind_phase + wind_phase_init
	if wind_waiting_phases > 0:
		curr_wind_phase %= wind_waiting_phases


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_wind_effect()
	process_affecting_bodies()
	process_random_movement()
	apply_skew()
	counter += wind_phase_speed


func get_body_distance_vector(body: Node2D) -> Vector2:
	var origin = global_position
	origin.y += $Sprite2D.get_rect().size.y / 2 - 5 # Constant offset from bottom of grass object
	return body.global_position - origin
	
	
func compute_body_skew_ratio(body: Node2D) -> float:
	var body_distance_vector = get_body_distance_vector(body)
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
	
func set_skew_zero() -> void:
	skew_value = 0.0
	
func process_wind_effect() -> void:
	var x_pos = global_position.x / wind_progression_speed
	var y_pos = global_position.y / wind_progression_speed * wind_direction # Times wind_direction to always make the wind come from top
	var wind_wave = sin(counter + (x_pos * -wind_direction) +
								  (y_pos * -wind_direction))
	
	if wind_wave >= -0.2:
		if not in_wind_phase:
				curr_wind_phase += 1
		if curr_wind_phase >= wind_waiting_phases:
			wind_wave = wind_wave + 1.0 / 2.0 # Positivation of sin wave
			skew_value = wind_wave * max_wind_skew * wind_direction
			wind_blown = true
		in_wind_phase = true
	else:
		in_wind_phase = false
		if wind_blown:
			curr_wind_phase = 0
		wind_blown = false
	

func process_affecting_bodies() -> void:
	var skew_ratio_sum: float = 0.0
	if affecting_bodies.size() > 0:
		for body in affecting_bodies:
			var body_skew_ratio = compute_body_skew_ratio(body)
			skew_ratio_sum -= body_skew_ratio
		skew_value = skew_ratio_sum / affecting_bodies.size() * max_body_skew
		
		
func process_random_movement() -> void:
	skew_value += (randf() * 2 - 1) * 0.1 # Positivation and scaling of random value
		
		
func apply_skew() -> void:
	var skew_value_rad: float = deg_to_rad(skew_value)
	$Sprite2D.set_skew(skew_value_rad)
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_meta("moves_plants"):
		affecting_bodies.append(area)
	

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in affecting_bodies:
		affecting_bodies.erase(area)
