if (global.ui_pending_open) {
    global.ui_pending_open = false;
    var _picked = get_open_filename("NES ROMs|*.nes|All files|*.*", "");
    if (_picked != "") {
        nes_start_rom(_picked);
        global.ui_open = false;
    }
}

if (keyboard_check_pressed(ord("O")) || (!rom_loaded && keyboard_check_pressed(vk_enter))) {
    global.ui_pending_open = true;
}

if (nes_ui_update()) {
    nes_last_time = get_timer();
    nes_time_accum = 0;
    exit;
}

if (!rom_loaded) exit;

if (keyboard_check_pressed(ord("M"))) {
    global.apu_muted = !global.apu_muted;
}

if (keyboard_check_pressed(ord("K"))) {
    global.apu_enabled = !global.apu_enabled;
    if (!global.apu_enabled) nes_apu_shutdown();
}

if (keyboard_check_pressed(ord("R"))) {
    nes_region_apply(!global.region_pal);
    nes_time_accum = 0;
    nes_last_time = get_timer();
    state_message = global.region_pal ? "PAL (50Hz)" : "NTSC (60Hz)";
    state_message_timer = 150;
}

if (keyboard_check_pressed(vk_f5)) {
    nes_state_save(global.ui_slot);
    state_message = "Saved state " + string(global.ui_slot);
    state_message_timer = 120;
}
if (keyboard_check_pressed(vk_f8)) {
    var _ok = nes_state_load(global.ui_slot);
    state_message = _ok ? ("Loaded state " + string(global.ui_slot)) : ("Slot " + string(global.ui_slot) + " is empty");
    state_message_timer = 120;
}
for (var _s = 0; _s <= 9; _s++) {
    if (keyboard_check_pressed(ord(string(_s)))) {
        global.ui_slot = _s;
        state_message = "Slot " + string(_s);
        state_message_timer = 90;
    }
}
if (state_message_timer > 0) state_message_timer -= 1;

var _pad = 0;
if (keyboard_check(ord("X"))) _pad |= 0x01;
if (keyboard_check(ord("Z"))) _pad |= 0x02;
if (keyboard_check(vk_shift)) _pad |= 0x04;
if (keyboard_check(vk_enter)) _pad |= 0x08;
if (keyboard_check(vk_up))    _pad |= 0x10;
if (keyboard_check(vk_down))  _pad |= 0x20;
if (keyboard_check(vk_left))  _pad |= 0x40;
if (keyboard_check(vk_right)) _pad |= 0x80;

if (gamepad_is_connected(0)) {
    if (gamepad_button_check(0, gp_face1)) _pad |= 0x01;
    if (gamepad_button_check(0, gp_face2)) _pad |= 0x02;
    if (gamepad_button_check(0, gp_select)) _pad |= 0x04;
    if (gamepad_button_check(0, gp_start))  _pad |= 0x08;
    if (gamepad_button_check(0, gp_padu) || gamepad_axis_value(0, gp_axislv) < -0.5) _pad |= 0x10;
    if (gamepad_button_check(0, gp_padd) || gamepad_axis_value(0, gp_axislv) > 0.5)  _pad |= 0x20;
    if (gamepad_button_check(0, gp_padl) || gamepad_axis_value(0, gp_axislh) < -0.5) _pad |= 0x40;
    if (gamepad_button_check(0, gp_padr) || gamepad_axis_value(0, gp_axislh) > 0.5)  _pad |= 0x80;
}

global.controller_state[0] = _pad;

var _now = get_timer();
var _elapsed = _now - nes_last_time;
nes_last_time = _now;

var _period = nes_speed_period_us();
if (_period > 0) {
    if (_elapsed > _period * 2) _elapsed = _period * 2;
    nes_time_accum += _elapsed;

    if (nes_time_accum < _period) {
        exit;
    }
    nes_time_accum -= _period;

    if (nes_time_accum > _period) nes_time_accum = _period;
}

global.ppu_frame_ready = false;
nes_cpu_run_frame();

nes_frames_emulated += 1;
if (_now - nes_fps_window >= 1000000) {
    nes_fps_emulated = nes_frames_emulated;
    nes_frames_emulated = 0;
    nes_fps_window = _now;
}

if (global.apu_enabled) nes_apu_flush_frame();

nes_cart_autosave_sram();
