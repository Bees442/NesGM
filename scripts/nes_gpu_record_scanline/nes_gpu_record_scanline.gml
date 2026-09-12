/// @function nes_gpu_record_scanline(scanline)
/// @description Records a scanline's state for the GPU renderer instead
/// of producing pixels it records the state this line will be drawn with, which is all the
/// shader needs later.
///
/// Per-line state (the loopy v register, fine X, the mask bits) goes into the state surface's
/// buffer. State that changes rarely - CHR bank mapping, mirroring, pattern-table select - is
/// compared against the band in progress, and a mismatch starts a new band; the frame is then
/// drawn as one quad per band with those values as uniforms.
function nes_gpu_record_scanline(_sl) {
    if (_sl == 0) {
        // Top of the visible region: snapshot the memory the whole frame draws from, and start
        // banding over. OAM is snapshotted here too, so a mid-frame DMA can't retro-actively
        // move sprites that were already drawn.
        if (!nes_gpu_ensure_surfaces()) return;
        nes_gpu_upload_nametable();
        nes_gpu_upload_palette();
        if (global.cart.chr_is_ram) nes_gpu_upload_chr();
        buffer_copy(global.ppu_oam, 0, 256, global.gpu_oam, 0);
        global.gpu_band_count = 0;
    }

    var _mask = global.ppu_mask;
    var _v = global.ppu_v & 0x7FFF;
    var _flags = ((_mask & 0x08) ? 1 : 0) | ((_mask & 0x02) ? 2 : 0);

    buffer_poke(global.gpu_state_buf, _sl * 4 + 0, buffer_u8, _v & 0xFF);
    buffer_poke(global.gpu_state_buf, _sl * 4 + 1, buffer_u8, (_v >> 8) & 0x7F);
    buffer_poke(global.gpu_state_buf, _sl * 4 + 2, buffer_u8, global.ppu_x & 7);
    buffer_poke(global.gpu_state_buf, _sl * 4 + 3, buffer_u8, _flags);

    // Does this line still belong to the band in progress?
    var _chr = global.chr_map;
    var _ctrl = global.ppu_ctrl;
    var _bg_pt = (_ctrl & 0x10) ? 0x1000 : 0x0000;
    var _spr_pt = (_ctrl & 0x08) ? 0x1000 : 0x0000;
    var _spr_h = (_ctrl & 0x20) ? 16 : 8;
    var _spr_left = (_mask & 0x04) != 0;
    var _mirror = global.mirror_mode;

    var _same = false;
    if (global.gpu_band_count > 0) {
        var _b = global.gpu_bands[global.gpu_band_count - 1];
        _same = (_b.bg_pt == _bg_pt && _b.mirror == _mirror
            && _b.spr_pt == _spr_pt && _b.spr_h == _spr_h && _b.spr_left == _spr_left);
        if (_same) {
            var _bc = _b.chr;
            for (var _i = 0; _i < 8; _i++) {
                if (_bc[_i] != _chr[_i]) { _same = false; break; }
            }
        }
    }

    if (_same) {
        global.gpu_bands[global.gpu_band_count - 1].y1 = _sl + 1;
    } else {
        // Scanline bounds are named y0/y1 rather than start/end because `end` is a GML keyword
        // (the old block syntax) and can't be a struct member name.
        var _band = {
            y0: _sl,
            y1: _sl + 1,
            bg_pt: _bg_pt,
            spr_pt: _spr_pt,
            spr_h: _spr_h,
            spr_left: _spr_left,
            mirror: _mirror,
            chr: [_chr[0], _chr[1], _chr[2], _chr[3], _chr[4], _chr[5], _chr[6], _chr[7]],
            ntb: [nes_ppu_nt_bank(0) * 1024, nes_ppu_nt_bank(1) * 1024,
                  nes_ppu_nt_bank(2) * 1024, nes_ppu_nt_bank(3) * 1024],
        };
        global.gpu_bands[global.gpu_band_count] = _band;
        global.gpu_band_count += 1;
    }

    // Sprite 0 hit still has to be produced on the CPU, because the game polls it while the
    // frame is being drawn.
    nes_ppu_sprite0_check(_sl);
}
