/* A shader allowing a uniformly dimensioned plane to act as a fog overlay.
 * @param fog_color The color the fog is colored in.
 * @param fog_density The overall thickness of the fog.
 * @param noise The noise function the fog is drawn as.
 * @param scroll The scroll direction of the fog.
 * @param intensity_change_speed The speed with which the intensity of the fog changes.
 * @param intensity_change_min The minimum value the fog intensity can change to over time.
 * @param clear_radius The clear radius around the center of the screen. Used to simulate fog clearance around a character.
 * @param clear_softness The softness of the edge of the clear radius.
 * @param pixel_number The number of pixels on x and y the fog should be rendered as.
 */

shader_type canvas_item;

uniform vec4 fog_color: source_color;
uniform float fog_density: hint_range(0.0, 3.0, 0.1);
uniform sampler2D noise: repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform float intensity_change_speed: hint_range(0.0, 5.0, 0.1);
uniform float intensity_change_min: hint_range(0.0, 1.0, 0.1);
uniform float clear_radius: hint_range(0.0, 1.0, 0.1);
uniform float clear_softness: hint_range(0.1, 1.0, 0.1);
uniform float pixel_number = 0;


float remap_value(float x, float source_min, float source_max, float target_min, float target_max)
{
	return (x - source_min) / (source_max - source_min) * (target_max - target_min) + target_min;
}


float circle_sdf(vec2 origin, float radius, float screen_aspect_ratio, vec2 screen_uv)
{
	vec2 frag_pos = screen_uv - origin;
    frag_pos.x *= screen_aspect_ratio;
	float origin_distance = length(frag_pos);

	if(radius <= 0.0)
	{
		return 1.0;
	}

	float clamped_value = origin_distance / (radius);
	return clamp(clamped_value, 0.0, 1.0);
}


vec2 pixelate_uv(vec2 uv)
{
	vec2 output_uv = uv;
	if(pixel_number > 0.0)
	{
		output_uv = floor(uv * pixel_number) / pixel_number;
	}
	return output_uv;
}


void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 screen_size = vec2(1.0 / SCREEN_PIXEL_SIZE.x, 1.0 / SCREEN_PIXEL_SIZE.y);
    float aspect_ratio = screen_size.x / screen_size.y;

	vec2 uv_texture = pixelate_uv(UV);
	float fog_cutout_value = circle_sdf(center, clear_radius, aspect_ratio, SCREEN_UV);

	vec4 noise_color = texture(noise, uv_texture + TIME * scroll);
	float intensity_change = sin(TIME * intensity_change_speed);
	intensity_change = remap_value(intensity_change, -1.0, 1.0, intensity_change_min, 1.0);
	noise_color.a = noise_color.r * fog_density * intensity_change;
	float edge_softness = 0.2; // Adjust this for sharper or softer edges
	float fog_cutout = 1.0 - smoothstep(clear_radius + clear_softness, clear_radius - clear_softness, fog_cutout_value);
	noise_color.a *= fog_cutout;
	COLOR = noise_color * fog_color;
}
