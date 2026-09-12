function nes_apu_quarter_frame() {
    nes_apu_envelope_clock(0);
    nes_apu_envelope_clock(1);
    nes_apu_noise_envelope_clock();

    if (global.apu_tri_linear_reload) {
        global.apu_tri_linear_value = global.apu_tri_linear_period;
    } else if (global.apu_tri_linear_value > 0) {
        global.apu_tri_linear_value -= 1;
    }
    if (!global.apu_tri_halt) global.apu_tri_linear_reload = false;
}
