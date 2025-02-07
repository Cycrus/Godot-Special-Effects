@tool
extends Node


@export_category("Downfall Controller")
## The particle material. Must be a particle process material to work correctly.
@export var particle_material: ParticleProcessMaterial:
	set(value):
		particle_material = value
		set_particle_material(particle_material)
		set_downfall_width(width)
		set_lifetime(lifetime)
		set_downfall_direction(direction)
		set_downfall_intensity(intensity)
		set_downfall_min_velocity(min_velocity)
		set_downfall_max_velocity(max_velocity)
		set_color(color)
		set_texture(texture)
		set_trail_size(trail_size)
		set_min_size(min_size)
		set_max_size(max_size)
		set_rotation_speed(rotation_speed)
		set_turbulences(turbulences)
		
## The width of the particle emitter.
@export var width: float = 500:
	set(value):
		width = value
		set_downfall_width(width)
		
## The lifetime of each downfall particle in seconds.
@export var lifetime: float = 5.0:
	set(value):
		lifetime = value
		set_lifetime(lifetime)

## The direction of the downfall movement in degree.
@export_range(-89.0, 89.0) var direction: float = 0.0: 
	set(value):
		direction = value
		set_downfall_direction(direction)
		
## The intensity of the downfall (the amount of particles).
@export_range(0.0, 1.0) var intensity: float = 0.1:
	set(value):
		intensity = value
		set_downfall_intensity(intensity)
		
## The minimum velocity of each particle in percent relative to the maximum velocity.
@export_range(0.0, 1.0) var min_velocity: float = 0.5:
	set(value):
		min_velocity = value
		set_downfall_min_velocity(min_velocity)
		set_downfall_max_velocity(max_velocity)

## The maximum velocity of each particle in percent relative to the maximum possible velocity.
@export_range(0.0, 1.0) var max_velocity: float = 0.1:
	set(value):
		max_velocity = value
		set_downfall_min_velocity(min_velocity)
		set_downfall_max_velocity(max_velocity)
		
## The minimum size of each particle in percent relative to the maximum size.
@export_range(0.0, 1.0) var min_size: float = 0.5:
	set(value):
		min_size = value
		set_min_size(min_size)
		set_max_size(max_size)
		
## The maximum size of each particle in percent relative to the maximum possible particle size.
@export_range(0.0, 1.0) var max_size: float = 0.1:
	set(value):
		max_size = value
		set_min_size(min_size)
		set_max_size(max_size)
		
## The color of each downfall particle.
@export var color: Color = Color(255, 255, 255, 0.7):
	set(value):
		color = value
		set_color(color)
		
## An optional texture each downfall particle can be assigned to.
@export var texture: Texture2D:
	set(value):
		texture = value
		set_texture(texture)
		
## The size of the trail each particle creates while moving. Can lead to more realistic rain, but is only valid if no texture is provided.
@export_range(0.0, 1.0) var trail_size: float = 0.0:
	set(value):
		trail_size = value
		set_trail_size(trail_size)
		
## The rotation speed of each downfall particle. Does not affect the particle trail.
@export_range(-1.0, 1.0) var rotation_speed: float = 0.0:
	set(value):
		rotation_speed = value
		set_rotation_speed(rotation_speed)
		
## The turbulences of the particles. More turbulences mean that the particles directions are more varied.
@export_range(0.0, 1.0) var turbulences: float = 0.0:
	set(value):
		turbulences = value
		set_turbulences(turbulences)
		
## Allows for more interesting flight patterns of the downfall particles. However, drastically slows the particles down.
@export var motion_noise: bool = false:
	set(value):
		motion_noise = value
		set_motion_noise(motion_noise)
		
		
var max_speed = 4000
var trail_max_lifetime = 0.3
var max_possible_size = 20.0
var max_rotation_speed = 80.0
var max_turbulences = 80.0


func set_downfall_width(width: float) -> void:
	if $Emitter:
		$Emitter.process_material.emission_shape = 3
		$Emitter.process_material.emission_box_extents.x = width
		
func set_particle_material(particle_material: ParticleProcessMaterial) -> void:
	if $Emitter:
		$Emitter.process_material = particle_material
		
func set_lifetime(lifetime: float) -> void:
	if $Emitter:
		$Emitter.lifetime = lifetime

func set_downfall_direction(direction: float) -> void:
	var direction_rad = deg_to_rad(direction)
	var x_component = sin(direction_rad)
	var y_component = cos(direction_rad)
	if $Emitter:
		$Emitter.process_material.direction.x = x_component
		$Emitter.process_material.direction.y = y_component
	
func set_downfall_intensity(intensity: float) -> void:
	if $Emitter:
		$Emitter.amount_ratio = intensity

func set_downfall_min_velocity(velocity: float) -> void:
	if $Emitter:
		$Emitter.process_material.initial_velocity[0] = max_speed * max_velocity * velocity

func set_downfall_max_velocity(velocity: float) -> void:
	if $Emitter:
		$Emitter.process_material.initial_velocity[1] = max_speed * velocity

func set_color(color: Color) -> void:
	if $Emitter:
		$Emitter.process_material.color = color
		
func set_texture(texture: Texture2D) -> void:
	if $Emitter:
		$Emitter.texture = texture
		
func set_trail_size(trail_size: float) -> void:
	if $Emitter:
		if trail_size < 0.035:
			$Emitter.trail_enabled = false
		else:
			$Emitter.trail_enabled = true
			$Emitter.trail_lifetime = trail_max_lifetime * trail_size
			
func set_min_size(snow_size: float) -> void:
	if $Emitter:
		$Emitter.process_material.scale[0] = max_size * max_possible_size * snow_size
			
func set_max_size(snow_size: float) -> void:
	if $Emitter:
		$Emitter.process_material.scale[1] = max_possible_size * snow_size

func set_rotation_speed(rotation_speed: float) -> void:
	if $Emitter:
		$Emitter.process_material.angular_velocity[0] = max_rotation_speed * rotation_speed
		$Emitter.process_material.angular_velocity[1] = max_rotation_speed * rotation_speed

func set_turbulences(turbulences: float) -> void:
	if $Emitter:
		$Emitter.process_material.spread = max_turbulences * turbulences
		
func set_motion_noise(motion_noise: bool) -> void:
	if $Emitter:
		$Emitter.process_material.turbulence_enabled = motion_noise
		$Emitter.process_material.turbulence_noise_speed = Vector3(0.2, 0.2, 0.0)
		$Emitter.process_material.turbulence_noise_scale = 4.0
