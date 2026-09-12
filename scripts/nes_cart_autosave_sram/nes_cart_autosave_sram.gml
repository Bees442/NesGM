function nes_cart_autosave_sram() {
    if (!global.sram_dirty) return;

    global.sram_autosave_timer -= 1;
    if (global.sram_autosave_timer > 0) return;

    global.sram_autosave_timer = 180;
    nes_cart_save_sram();
}
