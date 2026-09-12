/// @function nes_apu_generate_sample()
/// @description Mixes all channels into one DC-blocked output sample and writes it to global.apu_buffer.
function nes_apu_generate_sample() {
    var _rate = global.apu_sample_rate;

    var _enable = global.apu_enable;
    var _p_len = global.apu_pulse_length;
    var _p_per = global.apu_pulse_timer_period;
    var _p_phase = global.apu_pulse_phase;

    var _clock = global.cpu_clock_hz;

    var _p_out0 = 0;
    var _p_out1 = 0;

    for (var _i = 0; _i < 2; _i++) {
        var _period = _p_per[_i];
        if (_enable[_i] && _p_len[_i] > 0 && _period >= 8 && _period <= 0x7FF) {
            var _phase = _p_phase[_i] + (_clock / (16 * (_period + 1))) / _rate;
            _phase -= floor(_phase);
            _p_phase[_i] = _phase;
            if (global.apu_duty_table[global.apu_pulse_duty[_i] * 8 + floor(_phase * 8)] != 0) {
                var _vol = global.apu_pulse_const_vol[_i] ? global.apu_pulse_vol[_i] : global.apu_pulse_env_decay[_i];
                if (_i == 0) _p_out0 = _vol; else _p_out1 = _vol;
            }
        }
    }

    var _t_out = 0;
    var _tri_period = global.apu_tri_timer_period;
    if (_enable[2] && global.apu_tri_length > 0 && global.apu_tri_linear_value > 0 && _tri_period >= 2) {
        var _tphase = global.apu_tri_phase + (_clock / (32 * (_tri_period + 1))) / _rate;
        _tphase -= floor(_tphase);
        global.apu_tri_phase = _tphase;
        _t_out = global.apu_tri_table[floor(_tphase * 32)];
    }

    var _n_out = 0;
    if (_enable[3] && global.apu_noise_length > 0) {
        var _nperiod_cpu = global.apu_noise_period_table[global.apu_noise_period_index] * 2;
        var _accum = global.apu_noise_cycle_accum + global.apu_sample_period;
        var _shifts = floor(_accum / _nperiod_cpu);
        if (_shifts > 32) _shifts = 32;
        global.apu_noise_cycle_accum = _accum - _shifts * _nperiod_cpu;

        var _sr = global.apu_noise_shift;
        var _bitpos = global.apu_noise_mode ? 6 : 1;
        repeat (_shifts) {
            _sr = (_sr >> 1) | (((_sr & 1) ^ ((_sr >> _bitpos) & 1)) << 14);
        }
        global.apu_noise_shift = _sr;

        if ((_sr & 1) == 0) {
            _n_out = global.apu_noise_const_vol ? global.apu_noise_vol : global.apu_noise_env_decay;
        }
    }

    var _mixed = 0;
    if (!global.apu_muted) {
        var _pulse_sum = _p_out0 + _p_out1;
        var _pulse_mix = (_pulse_sum > 0) ? (95.88 / ((8128 / _pulse_sum) + 100)) : 0;
        var _tnd_sum = (_t_out / 8227) + (_n_out / 12241);
        var _tnd_mix = (_tnd_sum > 0) ? (159.79 / ((1 / _tnd_sum) + 100)) : 0;
        _mixed = _pulse_mix + _tnd_mix;
    }

    var _y = _mixed - global.apu_dc_prev_x + 0.995 * global.apu_dc_prev_y;
    global.apu_dc_prev_x = _mixed;
    global.apu_dc_prev_y = _y;

    var _sample = round(_y * 30000);
    if (_sample > 32767) _sample = 32767;
    if (_sample < -32768) _sample = -32768;

    buffer_write(global.apu_buffer, buffer_s16, _sample);
}
