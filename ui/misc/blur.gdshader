shader_type canvas_item;

uniform float blur = 0.0;
uniform float opacity = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	COLOR.rgb = mix(textureLod(screen_texture, SCREEN_UV, blur).rgb, COLOR.rgb, opacity);
}
