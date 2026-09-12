varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_amount;
uniform float u_darken;
uniform float u_tint;

void main() {
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;

    float lum = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));

    vec3 mono = vec3(lum) * mix(vec3(1.0), vec3(1.06, 1.0, 0.92), u_tint);

    col.rgb = mix(col.rgb, mono, u_amount) * mix(1.0, u_darken, u_amount);

    gl_FragColor = col;
}
