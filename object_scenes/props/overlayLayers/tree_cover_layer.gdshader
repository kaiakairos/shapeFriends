shader_type canvas_item;

uniform sampler2D s:  hint_screen_texture;
uniform float balls;
uniform float dick;
uniform float scale;

void fragment() {
	vec2 speed = vec2(sin(TIME) * 0.001,cos(TIME) * 0.001) + vec2(TIME*0.0008,TIME*-0.0004);
	vec2 uv = UV + vec2(sin(TIME+UV.y * balls) * dick,0.0);
	vec4 tex = texture(TEXTURE,(uv*scale)+speed);
	vec4 screen = texture(s,SCREEN_UV);
	
	COLOR = tex * screen;
	COLOR.a = tex.a;
}

