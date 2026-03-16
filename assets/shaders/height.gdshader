shader_type spatial;

uniform float min_height = 0.0;
uniform float max_height = 20.0;

uniform vec3 low_color : source_color = vec3(0.2, 0.6, 0.2);   // grass
uniform vec3 mid_color : source_color = vec3(0.5, 0.4, 0.2);   // dirt
uniform vec3 high_color : source_color = vec3(0.8, 0.8, 0.8);  // rock

void fragment() {
    float h = VERTEX.y; // vertex height

    float t = clamp((h - min_height) / (max_height - min_height), 0.0, 1.0);
	t = floor(t * 4.0) / 4.0; // quantize to 4 layers
    // blend low -> mid -> high
    vec3 color;
    if (t < 0.5) {
        float f = t * 2.0;
        color = mix(low_color, mid_color, f);
    } else {
        float f = (t - 0.5) * 2.0;
        color = mix(mid_color, high_color, f);
    }

    ALBEDO = color;
}
