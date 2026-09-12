/// @function nes_ppu_init()
/// @description Allocates OAM/nametable/palette RAM and resets all PPU register/timing state.
function nes_ppu_init() {
    var _old = ["ppu_oam", "ppu_nametable", "ppu_palette"];
    for (var _i = 0; _i < array_length(_old); _i++) {
        var _n = _old[_i];
        if (variable_global_exists(_n)) {
            var _b = variable_global_get(_n);
            if (is_real(_b) && _b >= 0 && buffer_exists(_b)) buffer_delete(_b);
        }
    }

    global.ppu_ctrl = 0;
    global.ppu_mask = 0;
    global.ppu_status = 0;
    global.ppu_oamaddr = 0;
    global.ppu_v = 0;
    global.ppu_t = 0;
    global.ppu_x = 0;
    global.ppu_w = false;
    global.ppu_data_buffer = 0;

    global.ppu_oam = buffer_create(256, buffer_fixed, 1);
    global.ppu_nametable = buffer_create(2048, buffer_fixed, 1);
    global.ppu_palette = buffer_create(32, buffer_fixed, 1);

    global.ppu_scanline = global.ppu_last_scanline;
    global.ppu_dot = 0;
    global.ppu_frame_odd = false;
    global.ppu_nmi_line = false;
    global.ppu_frame_ready = false;

    global.ppu_palette_dirty = true;
    nes_ppu_build_decode_table();
}
