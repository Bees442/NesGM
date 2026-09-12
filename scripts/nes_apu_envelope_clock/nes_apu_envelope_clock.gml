function nes_apu_envelope_clock(_i) {
    if (global.apu_pulse_env_start[_i]) {
        global.apu_pulse_env_start[_i] = false;
        global.apu_pulse_env_decay[_i] = 15;
        global.apu_pulse_env_divider[_i] = global.apu_pulse_vol[_i];
    } else if (global.apu_pulse_env_divider[_i] == 0) {
        global.apu_pulse_env_divider[_i] = global.apu_pulse_vol[_i];
        if (global.apu_pulse_env_decay[_i] > 0) {
            global.apu_pulse_env_decay[_i] -= 1;
        } else if (global.apu_pulse_halt[_i]) {
            global.apu_pulse_env_decay[_i] = 15;
        }
    } else {
        global.apu_pulse_env_divider[_i] -= 1;
    }
}
