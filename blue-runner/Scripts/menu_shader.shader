shader_type canvas_item;
render_mode unshaded;

uniform vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 replacing = vec4(1.0, 1.0, 1.0, 1.0);
uniform float offset : hint_range(-1.0, 1.0) = 0.0;

void fragment(){
	if(texture(TEXTURE, UV).rgba == replacing){
		float pos = abs(abs(UV.x - UV.y + offset) - 1.0) / 3.0 + 0.66;
		COLOR = vec4(pos, pos, pos, 1.0) * color;
	}
	else{
		discard;
	}
}