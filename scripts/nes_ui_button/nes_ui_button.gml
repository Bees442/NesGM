/// @function nes_ui_button(x, y, w, h, label, [enabled])
/// @description Draws a button and returns whether it was clicked this frame. A disabled button never reports a click.
function nes_ui_button(_x, _y, _w, _h, _label, _enabled = true) {
    var _hover = _enabled && nes_ui_hit(_x, _y, _w, _h);

    var _fill = _enabled ? (_hover ? 0x72506E : 0x443244) : 0x302834;
    draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 5, 5, _fill, _fill, false);
    draw_roundrect_colour_ext(_x, _y, _x + _w, _y + _h, 5, 5,
        _hover ? 0xE7C5D9 : 0x8A657E, _hover ? 0xE7C5D9 : 0x8A657E, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_enabled ? c_white : 0x756C78);
    draw_text(_x + _w / 2, _y + _h / 2, _label);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return _enabled && nes_ui_take_click(_x, _y, _w, _h);
}
