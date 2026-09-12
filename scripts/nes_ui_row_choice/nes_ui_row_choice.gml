/// @function nes_ui_row_choice(x, y, w, label, value_text)
/// @description Draws a labelled row with < > arrows; returns -1 or +1 when an arrow is clicked, 0 otherwise.
function nes_ui_row_choice(_x, _y, _w, _label, _value) {
    var _h = NES_UI_ROW_H;
    if (nes_ui_hit(_x, _y, _w, _h)) {
        draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 4, 4, 0x382D40, 0x382D40, false);
    }

    draw_set_valign(fa_middle);
    draw_set_colour(0xD8CBE0);
    draw_text(_x + 8, _y + _h / 2, _label);

    var _aw = 20;
    var _right = _x + _w - 8;
    var _lx = _right - 130;
    var _rx = _right - _aw;

    var _step = 0;
    if (nes_ui_button(_lx, _y + 3, _aw, _h - 6, "<")) _step = -1;
    if (nes_ui_button(_rx, _y + 3, _aw, _h - 6, ">")) _step = 1;

    draw_set_halign(fa_center);
    // The arrow buttons restore top alignment, so set middle alignment again
    // before drawing the value. Otherwise its baseline sits too low and clips.
    draw_set_valign(fa_middle);
    draw_set_colour(c_white);
    draw_text((_lx + _aw + _rx) / 2, _y + _h / 2, _value);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return _step;
}
