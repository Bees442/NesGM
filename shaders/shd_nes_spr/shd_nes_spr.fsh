varying vec2 v_uv;
varying vec4 v_col;

uniform sampler2D u_pal;

uniform float u_chr_h;

uniform float u_cb0;
uniform float u_cb1;
uniform float u_cb2;
uniform float u_cb3;
uniform float u_cb4;
uniform float u_cb5;
uniform float u_cb6;
uniform float u_cb7;

float chrByte(float addr) {
    float bank = floor(addr / 1024.0);
    float off = u_cb0;
    if (bank > 6.5)      off = u_cb7;
    else if (bank > 5.5) off = u_cb6;
    else if (bank > 4.5) off = u_cb5;
    else if (bank > 3.5) off = u_cb4;
    else if (bank > 2.5) off = u_cb3;
    else if (bank > 1.5) off = u_cb2;
    else if (bank > 0.5) off = u_cb1;

    float phys = off + mod(addr, 1024.0);
    float ty = floor(phys / 256.0);
    float tx = phys - ty * 256.0;
    return floor(texture2D(gm_BaseTexture, vec2((tx + 0.5) / 256.0, (ty + 0.5) / u_chr_h)).r * 255.0 + 0.5);
}

void main() {
    float col = floor(v_uv.x);
    float addr = floor(v_uv.y);

    float lo = chrByte(addr);
    float hi = chrByte(addr + 8.0);

    float bitWeight = pow(2.0, 7.0 - col);
    float value = mod(floor(lo / bitWeight), 2.0) + 2.0 * mod(floor(hi / bitWeight), 2.0);

    if (value < 0.5) discard;

    float palSel = floor(v_col.r * 255.0 + 0.5);
    float index = 16.0 + palSel * 4.0 + value;
    gl_FragColor = vec4(texture2D(u_pal, vec2((index + 0.5) / 32.0, 0.5)).rgb, 1.0);
}
