function nes_cart_load_sram() {
    if (!global.cart.battery) return;

    var _path = nes_cart_sram_path();
    if (!file_exists(_path)) return;

    var _buf = buffer_load(_path);
    if (_buf < 0) return;

    var _size = min(buffer_get_size(_buf), 8192);
    buffer_copy(_buf, 0, _size, global.cart.prg_ram, 0);
    buffer_delete(_buf);
    show_debug_message("nes_cart: loaded save RAM from " + _path);
}
