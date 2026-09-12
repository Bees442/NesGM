/// @function nes_ui_update()
/// @description Captures pointer state for the menu's widgets and handles open/close. Returns whether the menu is up.
function nes_ui_update() {
    if (keyboard_check_pressed(vk_escape)) {
        global.ui_open = !global.ui_open;
    }

    global.ui_mx = mouse_x;
    global.ui_my = mouse_y;
    global.ui_click = mouse_check_button_pressed(mb_left);

    if (global.ui_note_timer > 0) global.ui_note_timer -= 1;

    var _target = global.ui_open ? 1 : 0;
    global.ui_mono += clamp(_target - global.ui_mono, -0.2, 0.2);

    return global.ui_open;
}
