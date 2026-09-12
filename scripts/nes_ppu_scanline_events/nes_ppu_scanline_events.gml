/// @function nes_ppu_scanline_events(scanline, dot_start, dot_end)
/// @description Fires dot 1/256/257/280 effects falling within [dot_start, dot_end) of `scanline`.
function nes_ppu_scanline_events(_sl, _dot_start, _dot_end) {
    if (_sl <= 239) {
        if (_dot_start <= 1 && 1 < _dot_end) {
            if ((global.ppu_mask & 0x18) != 0) nes_mapper_scanline();

            nes_gpu_record_scanline(_sl);
        }
        if ((global.ppu_mask & 0x18) != 0) {
            if (_dot_start <= 256 && 256 < _dot_end) nes_ppu_increment_y();
            if (_dot_start <= 257 && 257 < _dot_end) nes_ppu_copy_horizontal();
        }
    } else if (_sl == 241) {
        if (_dot_start <= 1 && 1 < _dot_end) {
            global.ppu_status |= 0x80;
            global.ppu_frame_ready = true;
            if (global.ppu_ctrl & 0x80) global.ppu_nmi_line = true;
        }
    } else if (_sl == global.ppu_last_scanline) {
        if (_dot_start <= 1 && 1 < _dot_end) global.ppu_status &= 0x1F;
        if ((global.ppu_mask & 0x18) != 0) {
            if (_dot_start <= 256 && 256 < _dot_end) nes_ppu_increment_y();
            if (_dot_start <= 257 && 257 < _dot_end) nes_ppu_copy_horizontal();
            if (_dot_start <= 280 && 280 < _dot_end) nes_ppu_copy_vertical();
        }
    }
}
