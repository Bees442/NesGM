function nes_apu_pulse_write_ctrl(_i, _value) {
    global.apu_pulse_duty[_i] = (_value >> 6) & 0x03;
    global.apu_pulse_halt[_i] = (_value & 0x20) != 0;
    global.apu_pulse_const_vol[_i] = (_value & 0x10) != 0;
    global.apu_pulse_vol[_i] = _value & 0x0F;
}
