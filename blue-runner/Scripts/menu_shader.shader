shader_type canvas_item;
render_mode unshaded;

uniform vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 replacing = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 secondary_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 secondary_replacing = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool offset_enabled = true;
uniform float offset : hint_range(-1.0, 1.0) = 0.0;
uniform bool only_replaced = false;

void fragment(){
	if(texture(TEXTURE, UV).rgba == replacing && offset_enabled){
		float pos = abs(abs(UV.x - UV.y + offset) - 1.0) / 3.0 + 0.66;
		COLOR = vec4(pos, pos, pos, 1.0) * color;
	}
	else if(texture(TEXTURE, UV).rgba == replacing){
		COLOR = color;
	}
	else if(texture(TEXTURE, UV).rgba == secondary_replacing){
		COLOR = secondary_color;
	}
	else if(only_replaced){
		discard;
	}
	else{
		COLOR = texture(TEXTURE, UV).rgba;
	}
}