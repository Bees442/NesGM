function nes_apu_shutdown() {
    if (variable_global_exists("apu_queue") && global.apu_queue >= 0) {
        audio_stop_sound(global.apu_queue);
        audio_free_play_queue(global.apu_queue);
        global.apu_queue = -1;
        global.apu_queue_playing = false;
        global.apu_queue_inst = -1;
        global.apu_queued_frames = 0;
    }
    if (variable_global_exists("apu_ring")) {
        for (var _i = 0; _i < NES_APU_RING_SIZE; _i++) {
            var _b = global.apu_ring[_i];
            if (_b >= 0 && buffer_exists(_b)) buffer_delete(_b);
            global.apu_ring[_i] = -1;
        }
        global.apu_ring_index = 0;
    }
}
