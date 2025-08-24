shader_type canvas_item;

uniform sampler2D gradient: repeat_enable, filter_nearest;
uniform float speed_scale = 1;

uniform float flow_speed = 1;
uniform float stretch = 1.0;

uniform vec2 pixelateAmount = vec2(400,300);

void fragment() {
	vec2 gridUB = round(SCREEN_UV * float(pixelateAmount.x)) / float(pixelateAmount.y);
	
	vec4 color = texture(TEXTURE, (UV + vec2((-TIME*flow_speed),sin(TIME) * 0.01)) + vec2(0.0,sin(TIME+UV.x * stretch) * 0.1));
	float x = color.r - TIME * speed_scale;
	COLOR = vec4(texture(gradient, vec2(x, 0)).rgb, color.a);
}