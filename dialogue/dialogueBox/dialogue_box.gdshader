shader_type canvas_item;

uniform sampler2D poop: repeat_enable,filter_nearest;
uniform sampler2D poop2: repeat_enable,filter_nearest;
uniform vec2 speed;
uniform vec2 speed2;
uniform vec2 scale = vec2(1.0);

uniform vec2 pixelateAmount = vec2(400,300);

void fragment() {
	
	vec2 gridUB = round(SCREEN_UV * float(pixelateAmount.x)) / float(pixelateAmount.y);
	
	vec4 tex = texture(TEXTURE,UV);
	vec4 bg = texture(poop,(gridUB*scale) + (vec2(TIME)*speed));
	vec4 bg2 = texture(poop2,(gridUB*scale) + (vec2(TIME)*speed2));

	COLOR = tex;
	
	bg.rg = mix(bg.rg,bg2.rg,0.5);
	bg.b = mix(bg.b,bg2.b,0.5);

	if (tex.g > 0.98 && tex.r < 0.01 ){
		COLOR = bg;
	}
}
