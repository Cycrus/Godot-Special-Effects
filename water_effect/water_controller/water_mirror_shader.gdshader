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
uniform bool floating_image = false;

void vertex() {
	VERTEX *= 2.0;
}

void fragment() {
	vec2 tex_uv = UV * 2.0 - 0.5;
	float vert_distortion_factor = 2.0 - UV.y * 2.0 - 0.5;
	if(floating_image)
	{
		vert_distortion_factor = 1.0;
	}
	
	float depth = texture(noise1, tex_uv + scroll1 * TIME).r
		* texture(noise2, tex_uv + scroll2 * TIME).r;
	vec2 distorted_uv = tex_uv + distortion_strength * vec2(depth) * vert_distortion_factor;
	bool out_of_bounds = (distorted_uv.x > 1.0 || distorted_uv.y > 1.0 ||
						  distorted_uv.x < 0.0 || distorted_uv.y < 0.0);

	if(out_of_bounds)
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
	else
	{
		vec4 texture_col = texture(TEXTURE, distorted_uv);
		COLOR = texture_col * tone_color;
	}
	
	//COLOR = vec4(0.0, 0.0, 0.0, vert_distortion_factor);
}
