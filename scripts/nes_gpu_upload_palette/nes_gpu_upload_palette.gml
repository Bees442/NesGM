/// @function nes_gpu_upload_palette()
/// @description Resolves the 32 palette entries to RGB and uploads them as a 32x1 surface.
function nes_gpu_upload_palette() {
    var _pal = global.ppu_palette;
    var _r = global.nes_pal_r;
    var _g = global.nes_pal_g;
    var _b = global.nes_pal_b;
    var _gray_mask = (global.ppu_mask & 0x01) ? 0x30 : 0x3F;
    var _dst = global.gpu_pal_buf;

    buffer_seek(_dst, buffer_seek_start, 0);
    for (var _i = 0; _i < 32; _i++) {
        var _src = ((_i & 0x13) == 0x10) ? (_i - 0x10) : _i;
        var _ci = buffer_peek(_pal, _src, buffer_u8) & _gray_mask;
        buffer_write(_dst, buffer_u32, (255 << 24) | (_b[_ci] << 16) | (_g[_ci] << 8) | _r[_ci]);
    }

    buffer_set_surface(_dst, global.gpu_pal_surf, 0);
}
