shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : hint_color();

void fragment(){
	float value = texture(TEXTURE, UV).a * color.a;
	COLOR = vec4(color.rgb, value);
}