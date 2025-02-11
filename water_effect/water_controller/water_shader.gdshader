/* Creates a water effect.
 * @param noise1 The first water distortion effect.
 * @param noise2 A second (mostly contrary) distortion effect for more realism.
 * @param scroll1 The scroll vector (direction & speed) of noise1 over time.
 * @param scroll2 The scroll vector of noise2 over time.
 * @param distortion_strength The strength of distortion on the underlying objects behind the water.
 * @param tone_color The color of the water.
 * @param top_color The color of the highlights.
 * @param light_start, light_end The range of the highlights on the noise texture. Controls how much highlight is visible.
 * @param pixel_number An additional parameter to set the number of pixels the shader should display itself.
 *                     Allows for a pixelated look of the water. Set to 0 to deactivate.
 */

shader_type canvas_item;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);
uniform float distortion_strength: hint_range(-1, 1) = 0.2;
uniform vec4 tone_color: source_color;
uniform vec4 top_color: source_color;
uniform float light_start: hint_range(0.0, 1.0) = 0.275;
uniform float light_end: hint_range(0.0, 1.0) = 0.4;
uniform float pixel_number = 0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest;

void fragment() {
	vec2 tex_uv = UV;
	if(pixel_number > 0.0)
	{
		tex_uv = floor(UV * pixel_number) / pixel_number;
	}
	float depth = texture(noise1, tex_uv + scroll1 * TIME).r
		* texture(noise2, tex_uv + scroll2 * TIME).r;
	vec4 screen_col = texture(SCREEN_TEXTURE,
		SCREEN_UV + distortion_strength * vec2(depth));
	vec4 top_light = smoothstep(light_start, light_end, depth) * top_color;

	// Read screen texture
	vec4 current_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);

	COLOR = screen_col * tone_color + top_light * top_light.a;
	COLOR.a = 1.0;
}
