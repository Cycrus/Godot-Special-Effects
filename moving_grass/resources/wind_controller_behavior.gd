extends Node


@export var wind_direction: Vector2 = Vector2(1.0, 0.0)
@export var wind_starting_plane: Vector2 = Vector2(0, 0)
@export var wind_travel_distance: float = 1000.0
@export var wind_spawn_interval: float = 4.0
@export var wind_width: float = 80.0
@export var wind_speed: float = 2

var wave_timer: float = 0.0
var wind_origin: Vector2
var wind_end: Vector2
var wind_wave_list: Array = []

func _ready() -> void:
	wind_direction = wind_direction.normalized()
	wind_origin = wind_starting_plane.project(wind_direction)
	wind_end = wind_origin + wind_direction * wind_travel_distance


func _process(delta: float) -> void:
	print(get_wind_strength(Vector2(400, 0)))
	
func _physics_process(delta: float) -> void:
	wave_timer += delta
	_move_and_remove_wind_waves()
	_add_new_wind_wave()
	
func _is_wave_alive(wave: Vector2, epsilon: float = 10.0) -> bool:
	var wave_start_distance = (wave - wind_origin).length()
	var wave_end_distance = (wave - wind_end).length()
	return wave_start_distance + wave_end_distance < wind_travel_distance + epsilon
		
func _move_and_remove_wind_waves() -> void:
	for wind_wave_idx in range(wind_wave_list.size(), 0, -1):
		wind_wave_idx -= 1
		var wind_wave = wind_wave_list[wind_wave_idx]
		wind_wave_list[wind_wave_idx] += wind_direction * wind_speed
		if not _is_wave_alive(wind_wave_list[wind_wave_idx]):
			wind_wave_list.remove_at(wind_wave_idx)
			
func _add_new_wind_wave() -> void:
	if wave_timer >= wind_spawn_interval:
		wind_wave_list.append(Vector2(wind_origin))
		wave_timer = 0.0

func get_wind_strength(probing_position: Vector2) -> Vector2:
	var proj_position = probing_position.project(wind_direction)
	var closest_wind_wave: Vector2
	var closest_wind_wave_distance: float = INF
	for wind_wave in wind_wave_list:
		var wind_wave_distance = (proj_position - closest_wind_wave).dot(wind_direction)
		if wind_wave_distance < closest_wind_wave_distance:
			closest_wind_wave_distance = wind_wave_distance
			closest_wind_wave = wind_wave
	if closest_wind_wave_distance > wind_width:
		return Vector2(0.0, 0.0)
		
	var k = PI / wind_width
	var wind_strength = sin(k * closest_wind_wave_distance)
	return wind_strength * wind_direction
