shader_type canvas_item;



void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if(color.a > 0.01)
	{
		float alpha = smoothstep(0.0, 0.05, color.a);
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}

