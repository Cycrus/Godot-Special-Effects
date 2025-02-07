extends Node

class_name WindController

@export_category("General Wind Settings")
## If set, the wind is blowing continuously. Otherwise it is sent out in pulsed waves.
@export var continuous_wind: bool = false
## The direction the wind is blowing. Is later normalized, so any vector.
@export var wind_direction: Vector2 = Vector2(1.0, 0.0)

@export_category("Continuous Wind Settings")
## Selects the continuous wind strength (only valid when in continuous wind mode).
@export_range(0, 1) var wind_strength: float
## Sets a noise parameter for the wind strength to make it more interesting (only valid when in continuous wind mode).
@export_range(0, 1) var wind_strength_noise: float

@export_category("Wavelike Wind Settings")
## The starting point of any wind wave. Is not a dot but a 1d plane (or line) where the wind is spawned from.
@export var wind_starting_plane: Vector2 = Vector2(0, 0)
## The distance a wind wave is allowed to travel from the starting point.
@export var wind_travel_distance: float = 1000.0
## The spawning interval in seconds of the wind waves.
@export var wind_spawn_interval: float = 3.0
## The width of the wind waves spawned in pixels.
@export var wind_width: float = 80.0
## The speed the wind waves are travelling with in pixels every second.
@export var wind_speed: float = 70


var wave_timer: float = 0.0
var wind_origin: Vector2
var wind_end: Vector2
var wind_wave_list: Array = []


func _ready() -> void:
	wind_direction = wind_direction.normalized()
	wind_origin = wind_starting_plane.project(wind_direction)
	wind_end = wind_origin + wind_direction * wind_travel_distance


func _process(delta: float) -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	wave_timer += delta
	
	if not continuous_wind:
		_move_and_remove_wind_waves(delta)
		_add_new_wind_wave()
	
	
func _is_wave_alive(wave: Vector2, epsilon: float = 10.0) -> bool:
	var wave_start_distance = (wave - wind_origin).length()
	var wave_end_distance = (wave - wind_end).length()
	return wave_start_distance + wave_end_distance < wind_travel_distance + epsilon
		
		
func _move_and_remove_wind_waves(delta: float) -> void:
	for wind_wave_idx in range(wind_wave_list.size(), 0, -1):
		wind_wave_idx -= 1
		var wind_wave = wind_wave_list[wind_wave_idx]
		wind_wave_list[wind_wave_idx] += wind_direction * wind_speed * delta
		if not _is_wave_alive(wind_wave_list[wind_wave_idx]):
			wind_wave_list.remove_at(wind_wave_idx)
			
			
func _add_new_wind_wave() -> void:
	if wave_timer >= wind_spawn_interval:
		wind_wave_list.append(Vector2(wind_origin))
		wave_timer = 0.0
		
		
func get_wind_strength(probing_position: Vector2) -> Vector2:
	if continuous_wind:
		return _get_continuous_wind_strength(probing_position)
	else:
		return _get_wavelike_wind_strength(probing_position)


func _get_continuous_wind_strength(probing_position: Vector2) -> Vector2:
	var curr_wind_strength = wind_strength
	curr_wind_strength += (randf() * 2 - 1) * wind_strength_noise
	if curr_wind_strength > 1.0:
		curr_wind_strength = 1.0
	elif curr_wind_strength < 0.0:
		curr_wind_strength = 0.0
	return curr_wind_strength * wind_direction


func _get_wavelike_wind_strength(probing_position: Vector2) -> Vector2:
	var proj_position = probing_position.project(wind_direction)
	var closest_wind_wave_distance: float = INF
	for wind_wave in wind_wave_list:
		var wind_wave_distance = (proj_position - wind_wave).length()
		if wind_wave_distance < closest_wind_wave_distance:
			closest_wind_wave_distance = wind_wave_distance
		elif wind_wave_distance > closest_wind_wave_distance:
			break
	if closest_wind_wave_distance > wind_width / 2:
		return Vector2(0, 0)
		
	# Cosine Bell Curve to control wind strength around wind wave peaks
	var wind_strength = 0.5 * (1.0 + cos(PI * closest_wind_wave_distance / (wind_width / 2)))
	return wind_strength * wind_direction
