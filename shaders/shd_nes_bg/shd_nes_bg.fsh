varying vec2 v_uv;

uniform sampler2D u_nt;
uniform sampler2D u_state;
uniform sampler2D u_pal;

uniform float u_chr_h;
uniform float u_bg_pt;

uniform float u_cb0;
uniform float u_cb1;
uniform float u_cb2;
uniform float u_cb3;
uniform float u_cb4;
uniform float u_cb5;
uniform float u_cb6;
uniform float u_cb7;

uniform float u_ntb0;
uniform float u_ntb1;
uniform float u_ntb2;
uniform float u_ntb3;

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

float ntByte(float addr) {
    float ty = floor(addr / 256.0);
    float tx = addr - ty * 256.0;
    return floor(texture2D(u_nt, vec2((tx + 0.5) / 256.0, (ty + 0.5) / 8.0)).r * 255.0 + 0.5);
}

vec3 palColour(float index) {
    return texture2D(u_pal, vec2((index + 0.5) / 32.0, 0.5)).rgb;
}

void main() {
    float px = floor(v_uv.x * 256.0);
    float sl = floor(v_uv.y * 240.0);

    vec4 st = texture2D(u_state, vec2((sl + 0.5) / 256.0, 0.5));
    float vreg  = floor(st.r * 255.0 + 0.5) + floor(st.g * 255.0 + 0.5) * 256.0;
    float finex = floor(st.b * 255.0 + 0.5);
    float flags = floor(st.a * 255.0 + 0.5);

    float bgOn   = mod(flags, 2.0);
    float bgLeft = mod(floor(flags / 2.0), 2.0);

    if (bgOn < 0.5 || (px < 8.0 && bgLeft < 0.5)) discard;

    float coarseX = mod(vreg, 32.0);
    float coarseY = mod(floor(vreg / 32.0), 32.0);
    float ntSel   = mod(floor(vreg / 1024.0), 4.0);
    float fineY   = mod(floor(vreg / 4096.0), 8.0);

    float xx = px + finex;
    float cx = coarseX + floor(xx / 8.0);
    float pixelInTile = mod(xx, 8.0);
    float ntx = mod(ntSel, 2.0);
    float nty = floor(ntSel / 2.0);
    if (cx > 31.5) {
        cx -= 32.0;
        ntx = 1.0 - ntx;
    }

    float ntIndex = nty * 2.0 + ntx;
    float ntBase = u_ntb0;
    if (ntIndex > 2.5)      ntBase = u_ntb3;
    else if (ntIndex > 1.5) ntBase = u_ntb2;
    else if (ntIndex > 0.5) ntBase = u_ntb1;

    float tile = ntByte(ntBase + coarseY * 32.0 + cx);

    float attr = ntByte(ntBase + 960.0 + floor(coarseY / 4.0) * 8.0 + floor(cx / 4.0));
    float shift = 0.0;
    if (mod(coarseY, 4.0) > 1.5) shift += 4.0;
    if (mod(cx, 4.0) > 1.5) shift += 2.0;
    float palSel = mod(floor(attr / pow(2.0, shift)), 4.0);

    float chrAddr = u_bg_pt + tile * 16.0 + fineY;
    float lo = chrByte(chrAddr);
    float hi = chrByte(chrAddr + 8.0);

    float bitWeight = pow(2.0, 7.0 - pixelInTile);
    float value = mod(floor(lo / bitWeight), 2.0) + 2.0 * mod(floor(hi / bitWeight), 2.0);

    if (value < 0.5) discard;

    gl_FragColor = vec4(palColour(palSel * 4.0 + value), 1.0);
}
