function nes_apu_noise_envelope_clock() {
    if (global.apu_noise_env_start) {
        global.apu_noise_env_start = false;
        global.apu_noise_env_decay = 15;
        global.apu_noise_env_divider = global.apu_noise_vol;
    } else if (global.apu_noise_env_divider == 0) {
        global.apu_noise_env_divider = global.apu_noise_vol;
        if (global.apu_noise_env_decay > 0) {
            global.apu_noise_env_decay -= 1;
        } else if (global.apu_noise_halt) {
            global.apu_noise_env_decay = 15;
        }
    } else {
        global.apu_noise_env_divider -= 1;
    }
}
