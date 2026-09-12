nes_palette_init();
nes_ui_init();
nes_speed_apply();

nes_region_default();

gpu_set_texfilter(false);

audio_set_master_gain(0, 1);
show_debug_message("nes: audio_system_is_available=" + string(audio_system_is_available())
    + " master_gain=" + string(audio_get_master_gain(0))
    + " listeners=" + string(audio_get_listener_count()));

rom_loaded = false;
status_text = "";
nes_surface = -1;

global.gpu_ready = false;

nes_last_time = get_timer();
nes_time_accum = 0;
nes_frames_emulated = 0;
nes_fps_emulated = 0;
nes_fps_window = nes_last_time;

state_message = "";
state_message_timer = 0;

function nes_start_rom(_filename) {
    if (rom_loaded) nes_cart_save_sram();

    if (!nes_cart_load(_filename)) {
        status_text = "Failed to load: " + _filename;
        return;
    }
    nes_bus_init();
    nes_ppu_init();
    nes_apu_init();
    nes_gpu_init();
    nes_cpu_reset();

    nes_last_time = get_timer();
    nes_time_accum = 0;

    rom_loaded = true;
    status_text = "Running: " + _filename;
}
