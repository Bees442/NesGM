/// @function nes_gpu_upload_nametable()
/// @description Copies the 2KB of nametable RAM into its surface, one byte per texel.
function nes_gpu_upload_nametable() {
    var _src = global.ppu_nametable;
    var _dst = global.gpu_nt_buf;

    buffer_seek(_dst, buffer_seek_start, 0);
    for (var _i = 0; _i < 2048; _i++) {
        buffer_write(_dst, buffer_u32, 0xFF000000 | buffer_peek(_src, _i, buffer_u8));
    }

    buffer_set_surface(_dst, global.gpu_nt_surf, 0);
}
