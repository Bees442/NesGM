/// @function nes_ui_hit(x, y, w, h)
/// @description Whether the pointer is inside a rectangle, in room coordinates.
function nes_ui_hit(_x, _y, _w, _h) {
    return global.ui_mx >= _x && global.ui_mx < _x + _w
        && global.ui_my >= _y && global.ui_my < _y + _h;
}
