function nes_apu_reg_read(_addr) {
    if (_addr == 0x4015) {
        var _r = 0;
        if (global.apu_pulse_length[0] > 0) _r |= 0x01;
        if (global.apu_pulse_length[1] > 0) _r |= 0x02;
        if (global.apu_tri_length > 0) _r |= 0x04;
        if (global.apu_noise_length > 0) _r |= 0x08;
        return _r;
    }
    return 0;
}
