if (rom_loaded) nes_cart_save_sram();

nes_apu_shutdown();
nes_gpu_free();

if (surface_exists(nes_surface)) surface_free(nes_surface);
