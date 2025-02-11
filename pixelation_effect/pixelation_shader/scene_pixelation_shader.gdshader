shader_type canvas_item;

uniform float pixel_number_x;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;


void fragment() {
	vec2 uv_screen = SCREEN_UV;
	if(pixel_number_x > 0.0)
	{
		float pixel_number_y = floor(pixel_number_x * (TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y));
		uv_screen.x = floor(uv_screen.x * pixel_number_x) / pixel_number_x;
		uv_screen.y = floor(uv_screen.y * pixel_number_y) / pixel_number_y;
	}
	COLOR = texture(SCREEN_TEXTURE, uv_screen);
}
