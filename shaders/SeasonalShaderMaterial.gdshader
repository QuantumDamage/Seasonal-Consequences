shader_type canvas_item;

uniform int season : hint_range(0, 3); // 0: wiosna, 1: lato, 2: jesień, 3: zima

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Modyfikacje kolorów dla każdej pory roku
    if (season == 0) { // Wiosna
        // Możesz zostawić oryginalny kolor
    } else if (season == 1) { // Lato
        tex_color.r *= 0.8; // Zmniejsz czerwony dla ciemniejszej zieleni
        tex_color.g *= 1.2; // Zwiększ zielony
    } else if (season == 2) { // Jesień
        tex_color.r *= 1.2; // Zwiększ czerwony
        tex_color.g *= 0.8; // Zmniejsz zielony
    } else { // Zima
        tex_color.rgb = mix(tex_color.rgb, vec3(0.9), 0.5); // Rozjaśnij i dodaj bieli
    }
    
    COLOR = tex_color;
}