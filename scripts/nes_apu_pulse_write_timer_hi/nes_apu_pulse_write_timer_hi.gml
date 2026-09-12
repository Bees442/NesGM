function nes_apu_pulse_write_timer_hi(_i, _value) {
    global.apu_pulse_timer_period[_i] = (global.apu_pulse_timer_period[_i] & 0x0FF) | ((_value & 0x07) << 8);
    if (global.apu_enable[_i]) global.apu_pulse_length[_i] = global.apu_length_table[(_value >> 3) & 0x1F];
    global.apu_pulse_env_start[_i] = true;
}
