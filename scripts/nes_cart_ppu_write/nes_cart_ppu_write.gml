function nes_cart_ppu_write(_addr, _value) {
    if (global.cart.chr_is_ram) {
        buffer_poke(global.chr_buf, global.chr_map[(_addr >> 10) & 7] | (_addr & 0x3FF), buffer_u8, _value & 0xFF);
    }
}
