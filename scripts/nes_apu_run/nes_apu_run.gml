function nes_apu_run(_cycles) {
    global.apu_cycle_carry += _cycles;
    var _apu_cycles = global.apu_cycle_carry div 2;
    global.apu_cycle_carry -= _apu_cycles * 2;

    var _old = global.apu_frame_cycle;
    var _new = _old + _apu_cycles;

    if (!global.apu_frame_5step) {
        var _s4 = global.apu_seq4;
        if (_old < _s4[0] && _new >= _s4[0]) nes_apu_quarter_frame();
        if (_old < _s4[1] && _new >= _s4[1]) { nes_apu_quarter_frame(); nes_apu_half_frame(); }
        if (_old < _s4[2] && _new >= _s4[2]) nes_apu_quarter_frame();
        if (_old < _s4[3] && _new >= _s4[3]) { nes_apu_quarter_frame(); nes_apu_half_frame(); }
        if (_new >= global.apu_seq4_wrap) _new -= global.apu_seq4_wrap;
    } else {
        var _s5 = global.apu_seq5;
        if (_old < _s5[0] && _new >= _s5[0]) nes_apu_quarter_frame();
        if (_old < _s5[1] && _new >= _s5[1]) { nes_apu_quarter_frame(); nes_apu_half_frame(); }
        if (_old < _s5[2] && _new >= _s5[2]) nes_apu_quarter_frame();
        if (_old < _s5[3] && _new >= _s5[3]) nes_apu_quarter_frame();
        if (_old < _s5[4] && _new >= _s5[4]) { nes_apu_quarter_frame(); nes_apu_half_frame(); }
        if (_new >= global.apu_seq5_wrap) _new -= global.apu_seq5_wrap;
    }
    global.apu_frame_cycle = _new;

    global.apu_sample_accum += _cycles;
    while (global.apu_sample_accum >= global.apu_sample_period) {
        global.apu_sample_accum -= global.apu_sample_period;
        nes_apu_generate_sample();
    }
}
