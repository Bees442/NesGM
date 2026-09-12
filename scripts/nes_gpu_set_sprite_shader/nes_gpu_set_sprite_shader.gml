/// @function nes_gpu_set_sprite_shader()
/// @description Selects the sprite shader and binds what it samples besides the CHR texture,
/// which arrives as the primitive's own texture. Per-band CHR bank offsets are set separately
/// by nes_gpu_set_chr_uniforms.
function nes_gpu_set_sprite_shader() {
    shader_set(shd_nes_spr);
    texture_set_stage(shader_get_sampler_index(shd_nes_spr, "u_pal"), surface_get_texture(global.gpu_pal_surf));
    shader_set_uniform_f(shader_get_uniform(shd_nes_spr, "u_chr_h"), global.gpu_chr_h);
}
