function nes_apu_sweep_clock(_i) {
    var _period = global.apu_pulse_timer_period[_i];
    var _shift = global.apu_pulse_sweep_shift[_i];
    var _change = _period >> _shift;
    var _target;
    if (global.apu_pulse_sweep_negate[_i]) {
        _target = _period - _change - (_i == 0 ? 1 : 0);
        if (_target < 0) _target = 0;
    } else {
        _target = _period + _change;
    }

    if (global.apu_pulse_sweep_divider[_i] == 0 && global.apu_pulse_sweep_enabled[_i] && _shift > 0 && _period >= 8 && _target <= 0x7FF) {
        global.apu_pulse_timer_period[_i] = _target;
    }
    if (global.apu_pulse_sweep_divider[_i] == 0 || global.apu_pulse_sweep_reload[_i]) {
        global.apu_pulse_sweep_divider[_i] = global.apu_pulse_sweep_period[_i];
        global.apu_pulse_sweep_reload[_i] = false;
    } else {
        global.apu_pulse_sweep_divider[_i] -= 1;
    }
}
