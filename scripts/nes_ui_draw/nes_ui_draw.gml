/// @function nes_ui_draw()
/// @description Draws the menu and handles everything on it. Call from the Draw event, after the game picture.
function nes_ui_draw() {
    if (!global.ui_open) return;

    var _w = NES_UI_WIDTH;
    var _h = 450;
    var _pad = NES_UI_PAD;
    var _rw = _w - _pad * 2;
    var _rh = NES_UI_ROW_H;

    var _x = floor((room_width - _w) / 2);
    var _y = floor((room_height - _h) / 2);

    draw_set_alpha(0.62 * global.ui_mono);
    draw_rectangle_colour(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);

    draw_roundrect_colour_ext(_x - 4, _y - 4, _x + _w + 4, _y + _h + 4, 10, 10, 0x17131D, 0x17131D, false);
    draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 8, 8, 0x2A2131, 0x2A2131, false);
    draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 8, 8, 0x8A657E, 0x8A657E, true);

    var _cx = _x + _pad;
    var _cy = _y + _pad;
    var _loaded = (variable_global_exists("cart") && !is_undefined(global.cart));

    draw_set_colour(0xD35D79);
    draw_text(_cx, _cy, "PAUSED");
    draw_set_colour(c_white);
    draw_text_transformed(_cx, _cy + 9, "NesGM", 1.15, 1.15, 0);
    if (nes_ui_button(_x + _w - _pad - 28, _cy, 28, 24, "X")) global.ui_open = false;
    var _footer_y = _y + _h - 24;
    draw_set_colour(0x5B465D);
    _cy += 29;
    draw_line(_cx, _cy, _cx + _rw, _cy);
    _cy += 6;

    _cy = nes_ui_section(_cx, _cy, "Cartridge");

    if (nes_ui_button(_cx, _cy, _rw, 28, _loaded ? "Open another ROM..." : "Open ROM...")) {
        global.ui_pending_open = true;
    }
    _cy += 32;

    if (_loaded) {
        draw_set_colour(0xD8CBE0);
        draw_text(_cx + 2, _cy, filename_name(global.cart.filename));
        _cy += 16;
        draw_set_colour(0x9C89A4);
        draw_text(_cx + 2, _cy, nes_mapper_name(global.cart.mapper)
            + "   PRG " + string(global.cart.prg_size div 1024) + "K"
            + "   CHR " + string(global.cart.chr_size div 1024) + "K"
            + (global.cart.chr_is_ram ? " RAM" : "")
            + (global.cart.battery ? "   battery" : ""));
    } else {
        draw_set_colour(0x9C89A4);
        draw_text(_cx + 2, _cy, "No cartridge loaded");
    }
    _cy += 22;

    _cy = nes_ui_section(_cx, _cy, "System");

    if (nes_ui_row_choice(_cx, _cy, _rw, "Region", global.region_pal ? "PAL 50Hz" : "NTSC 60Hz") != 0) {
        nes_region_apply(!global.region_pal);
        nes_ui_note(global.region_pal ? "Switched to PAL" : "Switched to NTSC");
    }
    _cy += _rh;

    var _fps_step = nes_ui_row_choice(_cx, _cy, _rw, "Frame rate", global.ui_fps_labels[global.ui_fps_mode]);
    if (_fps_step != 0) {
        var _fps_n = array_length(global.ui_fps_list);
        global.ui_fps_mode = (global.ui_fps_mode + _fps_step + _fps_n) mod _fps_n;
        nes_speed_apply();
        nes_ui_note(global.ui_fps_list[global.ui_fps_mode] < 0
            ? "Limiter off - runs as fast as it can"
            : "Frame rate: " + global.ui_fps_labels[global.ui_fps_mode]);
    }
    _cy += _rh + 3;

    if (nes_ui_button(_cx, _cy, _rw, 24, "Reset console", _loaded)) {
        nes_reset();
        nes_ui_note("Console reset");
    }
    _cy += 30;

    _cy = nes_ui_section(_cx, _cy, "Video");

    if (nes_ui_row_toggle(_cx, _cy, _rw, "Fullscreen", window_get_fullscreen())) {
        window_set_fullscreen(!window_get_fullscreen());
    }
    _cy += _rh + 3;

    _cy = nes_ui_section(_cx, _cy, "Audio");

    if (nes_ui_row_toggle(_cx, _cy, _rw, "Sound", global.apu_enabled)) {
        global.apu_enabled = !global.apu_enabled;
        if (!global.apu_enabled) nes_apu_shutdown();
    }
    _cy += _rh;

    if (nes_ui_row_toggle(_cx, _cy, _rw, "Mute", global.apu_muted)) {
        global.apu_muted = !global.apu_muted;
    }
    _cy += _rh + 2;

    _cy = nes_ui_section(_cx, _cy, "Save state");

    var _step = nes_ui_row_choice(_cx, _cy, _rw, "Slot", string(global.ui_slot));
    if (_step != 0) global.ui_slot = (global.ui_slot + _step + 10) mod 10;
    _cy += _rh;

    var _bw = (_rw - 8) / 2;
    if (nes_ui_button(_cx, _cy, _bw, 24, "Save", _loaded)) {
        nes_state_save(global.ui_slot);
        nes_ui_note("Saved to slot " + string(global.ui_slot));
    }
    if (nes_ui_button(_cx + _bw + 8, _cy, _bw, 24, "Load", _loaded)) {
        nes_ui_note(nes_state_load(global.ui_slot)
            ? "Loaded slot " + string(global.ui_slot)
            : "Slot " + string(global.ui_slot) + " is empty");
    }
    draw_set_colour(0x5B465D);
    draw_line(_cx, _footer_y - 6, _cx + _rw, _footer_y - 6);

    _cy = _footer_y;
    if (global.ui_note_timer > 0) {
        draw_set_colour(0xE7C5D9);
        draw_text(_cx + 2, _footer_y, global.ui_note);
    } else {
        draw_set_colour(0x7A736A);
        draw_text(_cx + 2, _cy, "Esc closes  ·  paused while this is open");
    }

    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
