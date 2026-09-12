function nes_apu_pulse_write_sweep(_i, _value) {
    global.apu_pulse_sweep_enabled[_i] = (_value & 0x80) != 0;
    global.apu_pulse_sweep_period[_i] = (_value >> 4) & 0x07;
    global.apu_pulse_sweep_negate[_i] = (_value & 0x08) != 0;
    global.apu_pulse_sweep_shift[_i] = _value & 0x07;
    global.apu_pulse_sweep_reload[_i] = true;
}
