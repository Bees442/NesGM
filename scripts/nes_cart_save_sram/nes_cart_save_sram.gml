function nes_cart_save_sram() {
    if (!variable_global_exists("cart") || is_undefined(global.cart)) return;
    if (!global.cart.battery) return;
    if (!global.sram_dirty) return;

    var _path = nes_cart_sram_path();
    buffer_save(global.cart.prg_ram, _path);
    global.sram_dirty = false;
    show_debug_message("nes_cart: wrote save RAM to " + _path);
}
