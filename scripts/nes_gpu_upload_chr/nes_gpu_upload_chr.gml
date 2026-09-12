/// @function nes_gpu_upload_chr()
/// @description Copies the cartridge's whole CHR memory into the CHR surface, one byte per texel in the red channel.
function nes_gpu_upload_chr() {
    if (!global.gpu_ready) return;

    var _src = global.chr_buf;
    var _n = global.cart.chr_size;
    var _dst = global.gpu_chr_buf;

    buffer_seek(_dst, buffer_seek_start, 0);
    for (var _i = 0; _i < _n; _i++) {
        buffer_write(_dst, buffer_u32, 0xFF000000 | buffer_peek(_src, _i, buffer_u8));
    }

    buffer_set_surface(_dst, global.gpu_chr_surf, 0);
}
