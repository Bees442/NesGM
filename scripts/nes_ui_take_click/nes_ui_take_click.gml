/// @function nes_ui_take_click(x, y, w, h)
/// @description Whether this rectangle was clicked, consuming the click so only one widget can act on a press.
function nes_ui_take_click(_x, _y, _w, _h) {
    if (!global.ui_click) return false;
    if (!nes_ui_hit(_x, _y, _w, _h)) return false;
    global.ui_click = false;
    return true;
}
