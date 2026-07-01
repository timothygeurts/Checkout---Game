shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float pixel_size : hint_range(1.0, 12.0) = 4.0;
uniform int kleur_niveaus : hint_range(2, 32) = 16;

void fragment() {
	vec2 scherm_grootte = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 blok = pixel_size / scherm_grootte;
	vec2 uv_pixel = floor(UV / blok) * blok + blok * 0.5;

	vec4 kleur = texture(screen_tex, uv_pixel);

	float niveaus = float(kleur_niveaus);
	kleur.rgb = floor(kleur.rgb * niveaus) / niveaus;

	COLOR = kleur;
}
