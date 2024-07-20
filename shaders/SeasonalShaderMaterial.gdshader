shader_type canvas_item;
uniform int season : hint_range(0, 3); // 0: wiosna, 1: lato, 2: jesień, 3: zima
vec3 adjust_color(vec3 color, vec3 add, vec3 multiply) {
    return (color * multiply) + add;
}
void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 original = tex_color.rgb;
    vec3 modified;
    
    if (season == 0) { // Wiosna
        modified = original;
    } else if (season == 1) { // Lato
        modified = adjust_color(original, vec3(0.0, 0.1, 0.0), vec3(1.0, 1.2, 0.9));
    } else if (season == 2) { // Jesień
        modified = adjust_color(original, vec3(0.2, 0.0, -0.1), vec3(1.2, 0.8, 0.7));
    } else { // Zima
        modified = adjust_color(original, vec3(0.1, 0.1, 0.2), vec3(0.8, 0.8, 1.1));
    }
    
    // Dostosowanie kolorów specyficznych dla tilemapy
    if (original == vec3(0.2549, 0.8039, 0.4510)) { // #41CD73 - trawa
        if (season == 2) { // Jesień
            modified = mix(modified, vec3(0.8, 0.4, 0.1), 0.5); // Bardziej brązowa
        } else if (season == 3) { // Zima
            modified = mix(modified, vec3(0.85, 0.9, 0.95), 0.8); // Bardziej biała, oszroniona
        }
    } else if (original == vec3(0.0588, 0.6471, 0.4118)) { // #0FA569 - chwast
        if (season == 2) { // Jesień
            modified = mix(modified, vec3(0.7, 0.3, 0.1), 0.6); // Bardziej pomarańczowa
        } else if (season == 3) { // Zima
            modified = mix(modified, vec3(0.75, 0.8, 0.85), 0.9); // Bardziej biało-szara, zamarznięta
        }
    } else if (original == vec3(1.0, 0.6667, 0.1961)) { // #FFAA32 - płatki kwiatu
        if (season == 2) { // Jesień
            modified = mix(modified, vec3(0.8, 0.2, 0.1), 0.5); // Bardziej czerwona
        } else if (season == 3) { // Zima
            modified = mix(modified, vec3(0.85, 0.87, 0.9), 0.95); // Biało-szara, zamarznięta
        }
    } else if (original == vec3(1.0, 1.0, 1.0)) { // #FFFFFF - środek kwiatu
        if (season == 3) { // Zima
            modified = mix(modified, vec3(0.8, 0.82, 0.85), 0.7); // Lekko szary, zamarznięty
        }
    } else if (original == vec3(0.2549, 0.8431, 0.8431)) { // #41D7D7 - woda
        if (season == 2) { // Jesień
            modified = mix(modified, vec3(0.2, 0.4, 0.6), 0.3); // Ciemniejsza
        } else if (season == 3) { // Zima
            modified = mix(modified, vec3(0.8, 0.9, 1.0), 0.7); // Jaśniejsza, bardziej zamarznięta
        }
    } else if (original == vec3(0.1373, 0.4902, 0.0784)) { // #237D14 - ciemniejszy kawałek drzewa
        if (season == 2) { // Jesień
            modified = mix(modified, vec3(0.4, 0.2, 0.1), 0.5); // Bardziej brązowa
        } else if (season == 3) { // Zima
            modified = mix(modified, vec3(0.4, 0.42, 0.45), 0.6); // Ciemniejsza, szarawa z odrobiną bieli
        }
    }
    
    COLOR = vec4(modified, tex_color.a);
}