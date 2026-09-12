function nes_apu_init() {
    global.apu_duty_table = [
        0,1,0,0,0,0,0,0,
        0,1,1,0,0,0,0,0,
        0,1,1,1,1,0,0,0,
        1,0,0,1,1,1,1,1
    ];
    global.apu_tri_table = [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
    global.apu_length_table = [10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30];

    global.apu_pulse_duty = [0, 0];
    global.apu_pulse_halt = [false, false];
    global.apu_pulse_const_vol = [false, false];
    global.apu_pulse_vol = [0, 0];
    global.apu_pulse_env_start = [false, false];
    global.apu_pulse_env_decay = [0, 0];
    global.apu_pulse_env_divider = [0, 0];
    global.apu_pulse_sweep_enabled = [false, false];
    global.apu_pulse_sweep_period = [0, 0];
    global.apu_pulse_sweep_negate = [false, false];
    global.apu_pulse_sweep_shift = [0, 0];
    global.apu_pulse_sweep_reload = [false, false];
    global.apu_pulse_sweep_divider = [0, 0];
    global.apu_pulse_timer_period = [0, 0];
    global.apu_pulse_length = [0, 0];
    global.apu_pulse_phase = [0, 0];

    global.apu_tri_halt = false;
    global.apu_tri_linear_period = 0;
    global.apu_tri_linear_value = 0;
    global.apu_tri_linear_reload = false;
    global.apu_tri_timer_period = 0;
    global.apu_tri_length = 0;
    global.apu_tri_phase = 0;

    global.apu_noise_halt = false;
    global.apu_noise_const_vol = false;
    global.apu_noise_vol = 0;
    global.apu_noise_env_start = false;
    global.apu_noise_env_decay = 0;
    global.apu_noise_env_divider = 0;
    global.apu_noise_mode = false;
    global.apu_noise_period_index = 0;
    global.apu_noise_length = 0;
    global.apu_noise_shift = 1;
    global.apu_noise_cycle_accum = 0;

    global.apu_enable = [false, false, false, false];

    global.apu_frame_cycle = 0;
    global.apu_cycle_carry = 0;
    global.apu_frame_5step = false;
    global.apu_frame_irq_inhibit = true;
    global.apu_reg_write_count = 0;
    global.apu_tone_phase = 0;

    global.apu_dc_prev_x = 0;
    global.apu_dc_prev_y = 0;

    global.apu_enabled = true;

    global.apu_muted = false;
    global.apu_sample_rate = NES_APU_SAMPLE_RATE;
    global.apu_sample_period = global.cpu_clock_hz / global.apu_sample_rate;
    global.apu_sample_accum = 0;
    global.apu_batch_cycles = 0;

    if (variable_global_exists("apu_buffer") && buffer_exists(global.apu_buffer)) {
        buffer_delete(global.apu_buffer);
    }
    global.apu_buffer = buffer_create(8192, buffer_grow, 1);
    buffer_seek(global.apu_buffer, buffer_seek_start, 0);

    if (!variable_global_exists("apu_ring")) {
        global.apu_ring = array_create(NES_APU_RING_SIZE, -1);
        global.apu_ring_index = 0;
    }
    if (!variable_global_exists("apu_queue")) {
        global.apu_queue = -1;
        global.apu_queue_playing = false;
        global.apu_queue_inst = -1;
        global.apu_queued_frames = 0;
    }
    global.apu_last_peak = 0;
    global.apu_restart_count = 0;

    nes_apu_shutdown();
}
