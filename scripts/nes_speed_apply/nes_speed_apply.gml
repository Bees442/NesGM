/// @function nes_speed_apply()
/// @description Applies the chosen frame-rate limit: sets the game speed and, above 60fps or
/// with the limiter off, drops vsync so the loop is not pinned to the monitor.
function nes_speed_apply() {
    var _fps = global.ui_fps_list[global.ui_fps_mode];

    // vsync holds the whole game loop at the refresh rate, so no game speed above it means
    // anything until vsync is off. Only ever toggled on a real change - display_reset throws
    // every surface away, which the GPU renderer then has to rebuild.
    var _fast = (_fps < 0 || _fps > 60);
    if (_fast != global.ui_speed_fast) {
        global.ui_speed_fast = _fast;
        display_reset(0, !_fast);
    }

    game_set_speed(_fast ? 1000 : 60, gamespeed_fps);
}

/// @function nes_speed_period_us()
/// @description Microseconds one emulated frame should take, or 0 when the limiter is off.
/// Read fresh each frame so "Auto" follows a region switch without needing to be reapplied.
function nes_speed_period_us() {
    var _fps = global.ui_fps_list[global.ui_fps_mode];
    if (_fps == 0) return global.nes_frame_period_us;
    if (_fps < 0) return 0;
    return 1000000 / _fps;
}
