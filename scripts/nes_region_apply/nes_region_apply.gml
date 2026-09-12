/// @function nes_region_apply(is_pal)
/// @description Installs the timing constants (CPU clock, PPU ratio, scanlines, APU schedule) for a region.
function nes_region_apply(_pal) {
    global.region_pal = _pal;

    if (_pal) {
        global.cpu_clock_hz = 1662607;
        global.ppu_last_scanline = 311;
        global.nes_frame_period_us = 19997.2;

        global.ppu_dot_num = 16;
        global.ppu_dot_den = 5;

        global.apu_seq4 = [8313, 16627, 24939, 33253];
        global.apu_seq4_wrap = 33254;
        global.apu_seq5 = [8313, 16627, 24939, 33253, 41565];
        global.apu_seq5_wrap = 41566;

        global.apu_noise_period_table = [4, 7, 14, 30, 60, 88, 118, 148, 188, 236, 354, 472, 708, 944, 1890, 3778];
    } else {
        global.cpu_clock_hz = 1789773;
        global.ppu_last_scanline = 261;
        global.nes_frame_period_us = 16639.267;

        global.ppu_dot_num = 3;
        global.ppu_dot_den = 1;

        global.apu_seq4 = [7457, 14913, 22371, 29829];
        global.apu_seq4_wrap = 29830;
        global.apu_seq5 = [7457, 14913, 22371, 29829, 37281];
        global.apu_seq5_wrap = 37282;

        global.apu_noise_period_table = [4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068];
    }

    global.ppu_dot_carry = 0;

    if (variable_global_exists("apu_sample_rate")) {
        global.apu_sample_period = global.cpu_clock_hz / global.apu_sample_rate;
    }
}
