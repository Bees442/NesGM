/// @function nes_ui_section(x, y, title)
/// @description Draws a section heading and returns the y to carry on laying out from.
function nes_ui_section(_x, _y, _title) {
    draw_set_colour(0xD35D79);
    draw_text(_x, _y, string_upper(_title));
    return _y + 20;
}
