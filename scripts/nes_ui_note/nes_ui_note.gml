/// @function nes_ui_note(text)
/// @description Shows a short confirmation along the bottom of the menu for a couple of seconds.
function nes_ui_note(_text) {
    global.ui_note = _text;
    global.ui_note_timer = 120;
}
