function nes_apu_pulse_write_timer_lo(_i, _value) {
    global.apu_pulse_timer_period[_i] = (global.apu_pulse_timer_period[_i] & 0x700) | _value;
}
