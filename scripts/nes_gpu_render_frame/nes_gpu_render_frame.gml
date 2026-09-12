/// @function nes_gpu_render_frame(target)
/// @description Draws the frame into `target` (a 256x240 surface) from the state
/// nes_gpu_record_scanline collected while the frame was emulated.
///
/// Layers go down in the order the NES composites them, with both shaders discarding their
/// transparent pixels so each pass shows what is underneath:
///   1. the backdrop colour over the whole surface;
///   2. sprites marked as being behind the background;
///   3. the background itself;
///   4. sprites in front of the background.
///
/// Each pass is issued once per band - a run of scanlines sharing CHR bank mapping, mirroring
/// and the pattern-table selects - since those arrive as uniforms. Everything that changes every
/// line (scroll, fine X, mask bits) is read by the shader from the per-scanline state surface.
function nes_gpu_render_frame(_target) {
    if (!global.gpu_ready || global.gpu_band_count <= 0) return;
    if (!nes_gpu_ensure_surfaces()) return;

    buffer_set_surface(global.gpu_state_buf, global.gpu_state_surf, 0);

    var _chr_tex = surface_get_texture(global.gpu_chr_surf);
    var _n = global.gpu_band_count;

    surface_set_target(_target);

    // 1. Backdrop. Palette entry 0 shows anywhere nothing else is drawn.
    var _bd = buffer_peek(global.gpu_pal_buf, 0, buffer_u32);
    draw_clear(make_colour_rgb(_bd & 0xFF, (_bd >> 8) & 0xFF, (_bd >> 16) & 0xFF));

    // 2. Sprites behind the background.
    nes_gpu_set_sprite_shader();
    for (var _i = 0; _i < _n; _i++) {
        var _b = global.gpu_bands[_i];
        nes_gpu_set_chr_uniforms(shd_nes_spr, _b);
        nes_gpu_draw_sprites(_b, 1);
    }
    shader_reset();

    // 3. Background.
    var _sh = shd_nes_bg;
    shader_set(_sh);
    texture_set_stage(shader_get_sampler_index(_sh, "u_nt"), surface_get_texture(global.gpu_nt_surf));
    texture_set_stage(shader_get_sampler_index(_sh, "u_state"), surface_get_texture(global.gpu_state_surf));
    texture_set_stage(shader_get_sampler_index(_sh, "u_pal"), surface_get_texture(global.gpu_pal_surf));
    shader_set_uniform_f(shader_get_uniform(_sh, "u_chr_h"), global.gpu_chr_h);

    var _u_bg_pt = shader_get_uniform(_sh, "u_bg_pt");
    var _u_ntb = [
        shader_get_uniform(_sh, "u_ntb0"), shader_get_uniform(_sh, "u_ntb1"),
        shader_get_uniform(_sh, "u_ntb2"), shader_get_uniform(_sh, "u_ntb3"),
    ];

    for (var _i = 0; _i < _n; _i++) {
        var _b = global.gpu_bands[_i];
        nes_gpu_set_chr_uniforms(_sh, _b);
        shader_set_uniform_f(_u_bg_pt, _b.bg_pt);
        for (var _k = 0; _k < 4; _k++) shader_set_uniform_f(_u_ntb[_k], _b.ntb[_k]);

        // v spans the full 240 lines rather than the band, so the shader can turn it straight
        // into a scanline index.
        var _v0 = _b.y0 / 240;
        var _v1 = _b.y1 / 240;

        draw_primitive_begin_texture(pr_trianglestrip, _chr_tex);
        draw_vertex_texture(0,   _b.y0, 0, _v0);
        draw_vertex_texture(256, _b.y0, 1, _v0);
        draw_vertex_texture(0,   _b.y1, 0, _v1);
        draw_vertex_texture(256, _b.y1, 1, _v1);
        draw_primitive_end();
    }
    shader_reset();

    // 4. Sprites in front of the background.
    nes_gpu_set_sprite_shader();
    for (var _i = 0; _i < _n; _i++) {
        var _b = global.gpu_bands[_i];
        nes_gpu_set_chr_uniforms(shd_nes_spr, _b);
        nes_gpu_draw_sprites(_b, 0);
    }
    shader_reset();

    surface_reset_target();
}
