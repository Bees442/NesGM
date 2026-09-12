function nes_apu_reg_write(_addr, _value) {
    global.apu_reg_write_count += 1;

    switch (_addr) {
        case 0x4000: nes_apu_pulse_write_ctrl(0, _value); break;
        case 0x4001: nes_apu_pulse_write_sweep(0, _value); break;
        case 0x4002: nes_apu_pulse_write_timer_lo(0, _value); break;
        case 0x4003: nes_apu_pulse_write_timer_hi(0, _value); break;

        case 0x4004: nes_apu_pulse_write_ctrl(1, _value); break;
        case 0x4005: nes_apu_pulse_write_sweep(1, _value); break;
        case 0x4006: nes_apu_pulse_write_timer_lo(1, _value); break;
        case 0x4007: nes_apu_pulse_write_timer_hi(1, _value); break;

        case 0x4008:
            global.apu_tri_halt = (_value & 0x80) != 0;
            global.apu_tri_linear_period = _value & 0x7F;
            break;
        case 0x400A:
            global.apu_tri_timer_period = (global.apu_tri_timer_period & 0x700) | _value;
            break;
        case 0x400B:
            global.apu_tri_timer_period = (global.apu_tri_timer_period & 0x0FF) | ((_value & 0x07) << 8);
            if (global.apu_enable[2]) global.apu_tri_length = global.apu_length_table[(_value >> 3) & 0x1F];
            global.apu_tri_linear_reload = true;
            break;

        case 0x400C:
            global.apu_noise_halt = (_value & 0x20) != 0;
            global.apu_noise_const_vol = (_value & 0x10) != 0;
            global.apu_noise_vol = _value & 0x0F;
            break;
        case 0x400E:
            global.apu_noise_mode = (_value & 0x80) != 0;
            global.apu_noise_period_index = _value & 0x0F;
            break;
        case 0x400F:
            if (global.apu_enable[3]) global.apu_noise_length = global.apu_length_table[(_value >> 3) & 0x1F];
            global.apu_noise_env_start = true;
            break;

        case 0x4010:
        case 0x4011:
        case 0x4012:
        case 0x4013:
            break;

        case 0x4015: {
            global.apu_enable[0] = (_value & 0x01) != 0;
            global.apu_enable[1] = (_value & 0x02) != 0;
            global.apu_enable[2] = (_value & 0x04) != 0;
            global.apu_enable[3] = (_value & 0x08) != 0;
            if (!global.apu_enable[0]) global.apu_pulse_length[0] = 0;
            if (!global.apu_enable[1]) global.apu_pulse_length[1] = 0;
            if (!global.apu_enable[2]) global.apu_tri_length = 0;
            if (!global.apu_enable[3]) global.apu_noise_length = 0;
            break;
        }

        case 0x4017:
            global.apu_frame_5step = (_value & 0x80) != 0;
            global.apu_frame_irq_inhibit = (_value & 0x40) != 0;
            global.apu_frame_cycle = 0;
            if (global.apu_frame_5step) {
                nes_apu_quarter_frame();
                nes_apu_half_frame();
            }
            break;
    }
}
