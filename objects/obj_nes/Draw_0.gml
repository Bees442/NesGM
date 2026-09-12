draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (!rom_loaded) {
    var _cx = room_width * 0.5;
    var _card_w = min(room_width - 32, 560);
    var _card_h = min(room_height - 32, 390);
    var _card_x = floor(_cx - _card_w * 0.5);
    var _card_y = floor((room_height - _card_h) * 0.5);
    var _inner_x = _card_x + 28;
    var _inner_r = _card_x + _card_w - 28;

    draw_set_colour(0x17131D);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_colour(0x2C2236);
    draw_rectangle(_card_x - 5, _card_y - 5, _card_x + _card_w + 5, _card_y + _card_h + 5, false);
    draw_roundrect_colour_ext(_card_x, _card_y, _card_x + _card_w, _card_y + _card_h,
        10, 10, 0x2A2131, 0x2A2131, false);
    draw_roundrect_colour_ext(_card_x, _card_y, _card_x + _card_w, _card_y + _card_h,
        10, 10, 0x8A657E, 0x8A657E, true);

    draw_set_halign(fa_center);
    draw_set_colour(c_white);
    draw_text_transformed(_cx, _card_y + 52, "NesGM", 2.5, 2.5, 0);
    draw_set_colour(0xC2AEC7);

    draw_set_colour(0x5B465D);
    draw_line(_inner_x, _card_y + 174, _inner_r, _card_y + 174);
    draw_set_colour(0xC2AEC7);

    var _button_w = min(250, _card_w - 56);
    if (nes_ui_button(_cx - _button_w * 0.5, _card_y + 194, _button_w, 38, "Choose ROM")) {
        global.ui_pending_open = true;
    }

    draw_set_halign(fa_center);
    draw_set_colour(0x9C89A4);
    draw_text(_cx, _card_y + 244, "or press Enter / O to browse for a .nes file");

    draw_set_colour(0x443648);
    draw_line(_inner_x, _card_y + 273, _inner_r, _card_y + 273);
    draw_set_colour(0xC2AEC7);
    draw_text(_cx, _card_y + 290, "Controls");
    draw_set_colour(0x9C89A4);
    draw_text(_cx, _card_y + 312, "Arrows  Move     Z  B     X  A");
    draw_text(_cx, _card_y + 332, "Shift  Select     Enter  Start");

    if (status_text != "" && string_pos("Failed", status_text) > 0) {
        draw_set_colour(0xE1848D);
        draw_text(_cx, _card_y + _card_h - 28, status_text);
    } else {
        draw_set_colour(0x78667D);
        draw_text(_cx, _card_y + _card_h - 28, "Esc opens settings");
    }
    draw_set_halign(fa_left);
    draw_set_colour(c_white);

    nes_ui_draw();
    exit;
}

if (!surface_exists(nes_surface)) {
    nes_surface = surface_create(256, 240);
}

nes_gpu_render_frame(nes_surface);

var _scale = min(room_width / 256, room_height / 240);
if (_scale >= 1) _scale = floor(_scale);

var _draw_w = 256 * _scale;
var _draw_h = 240 * _scale;
var _draw_x = floor((room_width - _draw_w) / 2);
var _draw_y = floor((room_height - _draw_h) / 2);
nes_ui_draw_screen(nes_surface, _draw_x, _draw_y, _draw_w, _draw_h);

if (!global.ui_open) {
    draw_set_colour(0xC2AEC7);
    draw_text(10, 10, "FPS " + string(nes_fps_emulated));

    if (state_message_timer > 0) {
        draw_set_color(c_yellow);
        draw_text(8, 26, state_message);
    }
    draw_set_color(c_white);
}

nes_ui_draw();
