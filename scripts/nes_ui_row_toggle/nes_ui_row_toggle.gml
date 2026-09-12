/// @function nes_ui_row_toggle(x, y, w, label, is_on)
/// @description Draws a labelled on/off row and returns whether it was clicked. The caller owns the state.
function nes_ui_row_toggle(_x, _y, _w, _label, _on) {
    var _h = NES_UI_ROW_H;
    var _hover = nes_ui_hit(_x, _y, _w, _h);
    if (_hover) draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 4, 4, 0x382D40, 0x382D40, false);

    draw_set_valign(fa_middle);
    draw_set_colour(0xD8CBE0);
    draw_text(_x + 8, _y + _h / 2, _label);

    var _pw = 46;
    var _px = _x + _w - _pw - 8;
    var _py = _y + 5;
    var _ph = _h - 10;
    var _col = _on ? 0xA15B8C : 0x4A414F;
    draw_roundrect_colour_ext(_px, _py, _px + _pw, _py + _ph, 4, 4, _col, _col, false);

    draw_set_halign(fa_center);
    draw_set_colour(_on ? c_white : 0xAAA0AF);
    draw_text(_px + _pw / 2, _y + _h / 2, _on ? "ON" : "OFF");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return nes_ui_take_click(_x, _y, _w, _h);
}
