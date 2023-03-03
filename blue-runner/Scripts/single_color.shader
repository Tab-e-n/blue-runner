shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : hint_color;
uniform bool active = false;

uniform float blend : hint_range(0.0, 1.0) = 1.0;

void fragment(){
	if(active){
		vec4 value = texture(TEXTURE, UV).rgba;
		COLOR = vec4(color.rgb * vec3(blend, blend, blend) + value.rgb * vec3(1.0 - blend, 1.0 - blend, 1.0 - blend), value.a * color.a);
	}
	else{
		COLOR = vec4(texture(TEXTURE, UV).rgba);
	}
}