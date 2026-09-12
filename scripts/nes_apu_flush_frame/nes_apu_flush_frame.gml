function nes_apu_flush_frame() {
    if (global.apu_batch_cycles > 0) {
        var _pending = global.apu_batch_cycles;
        global.apu_batch_cycles = 0;
        nes_apu_run(_pending);
    }

    var _bytes = buffer_tell(global.apu_buffer);
    if (_bytes < 2) return;

    if (global.apu_queue < 0) {
        global.apu_queue = audio_create_play_queue(buffer_s16, global.apu_sample_rate, audio_mono);
        global.apu_queue_playing = false;
        global.apu_queued_frames = 0;
    }

    var _buf = nes_apu_take_buffer(_bytes);
    buffer_copy(global.apu_buffer, 0, _bytes, _buf, 0);
    audio_queue_sound(global.apu_queue, _buf, 0, _bytes);
    global.apu_queued_frames += 1;

    var _peak = 0;
    var _n = min(_bytes div 2, 256);
    for (var _i = 0; _i < _n; _i++) {
        _peak = max(_peak, abs(buffer_peek(_buf, _i * 2, buffer_s16)));
    }
    global.apu_last_peak = _peak;

    var _running = global.apu_queue_playing
        && global.apu_queue_inst >= 0
        && audio_is_playing(global.apu_queue_inst);

    if (!_running && global.apu_queued_frames >= NES_APU_PREBUFFER_FRAMES) {
        var _inst = audio_play_sound(global.apu_queue, 1, false);
        global.apu_queue_playing = true;
        global.apu_queue_inst = _inst;

        audio_sound_gain(_inst, 1, 0);
        if (audio_get_master_gain(0) <= 0) audio_set_master_gain(0, 1);

        global.apu_restart_count += 1;
        if (global.apu_restart_count <= 3) {
            show_debug_message("nes_apu: queue " + ((global.apu_restart_count == 1) ? "started" : "restarted after running dry")
                + " (inst=" + string(_inst)
                + ", rate=" + string(global.apu_sample_rate)
                + ", bytes/frame=" + string(_bytes) + ")");
        }
    }

    buffer_seek(global.apu_buffer, buffer_seek_start, 0);
}
