/* Shader to create a texture splatting effect. Select 3 textures of uniform sizes (with uniform width/height),
 * and one splatmap. Draw on the splatmap with red, green and blue and the selected textures are blended onto
 * the shaded material. The system also acknowledges alpha values.
 * @param splatmap 					   The map which controls the distribution of the different textures.
 * @param texture1, texture2, texture3 The 3 textures to blend into each other.bool
 * @param scale 					   The scale of the textures. Controls how often each texture is repeated.
 * @param texture_size				   The dimension of the texture to place on the surface. Used for nearest neighbor
 * 									   interpolation. If set to 0 it usest linear interpolation.
 */

shader_type canvas_item;

uniform sampler2D splatmap;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform float scale;
uniform float texture_size;

void fragment() {
	vec4 splat = texture(splatmap, UV);

	vec2 texture_pos = UV * vec2(scale);
	// Distributes the UV range of 0.0 - 1.0 to individual smaller pathes.
	texture_pos.x = mod(texture_pos.x, 1);
	texture_pos.y = mod(texture_pos.y, 1);

	// Avoids linear interpolation and replaces it with nearest neighbor interpolation.
	// Needs correct texture size given as a uniform parameter.
	if(texture_size > 0.0)
	{
		texture_pos.x = floor(texture_pos.x * texture_size) / texture_size;
		texture_pos.y = floor(texture_pos.y * texture_size) / texture_size;
	}

    vec4 tex1 = texture(texture1, texture_pos);
    vec4 tex2 = texture(texture2, texture_pos);
    vec4 tex3 = texture(texture3, texture_pos);

    COLOR = (splat.r * tex1 + splat.g * tex2 + splat.b * tex3) * splat.a;
}
