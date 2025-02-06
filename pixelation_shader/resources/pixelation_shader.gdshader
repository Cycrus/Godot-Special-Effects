shader_type canvas_item;

uniform float pixel_number_x;

void fragment() {
	vec2 uv_texture = UV;
	if(pixel_number_x > 0.0)
	{
		float pixel_number_y = floor(pixel_number_x * (TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y));
		uv_texture.x = floor(uv_texture.x * pixel_number_x) / pixel_number_x;
		uv_texture.y = floor(uv_texture.y * pixel_number_y) / pixel_number_y;
	}
	COLOR = texture(TEXTURE, uv_texture);
}
