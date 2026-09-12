#macro NES_UI_WIDTH 380
#macro NES_UI_ROW_H 24
#macro NES_UI_PAD 12

/// @function nes_ui_init()
/// @description Sets up the menu's state. Called once at startup.
function nes_ui_init() {
    global.ui_open = false;
    global.ui_mx = 0;
    global.ui_my = 0;
    global.ui_click = false;
    global.ui_pending_open = false;
    global.ui_slot = 0;

    // 0 = follow the region, -1 = no limiter, anything else is a target frame rate.
    global.ui_fps_list = [0, 30, 50, 60, 120, 240, -1];
    global.ui_fps_labels = ["Auto", "30", "50", "60", "120", "240", "Unlimited"];
    global.ui_fps_mode = 0;
    global.ui_speed_fast = false;

    global.ui_mono = 0;

    global.ui_note = "";
    global.ui_note_timer = 0;
}
