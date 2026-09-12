/// @function nes_gpu_set_chr_uniforms(shader, band)
/// @description Uploads a band's eight CHR bank offsets, which is how bank switching reaches the
/// shaders - the CHR texture itself holds the cartridge's whole pattern memory and never needs
/// re-uploading. Both shaders declare these uniforms identically, so this serves either.
function nes_gpu_set_chr_uniforms(_shader, _band) {
    var _chr = _band.chr;
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb0"), _chr[0]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb1"), _chr[1]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb2"), _chr[2]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb3"), _chr[3]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb4"), _chr[4]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb5"), _chr[5]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb6"), _chr[6]);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_cb7"), _chr[7]);
}
