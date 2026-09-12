function nes_cart_ppu_read(_addr) {
    return buffer_peek(global.chr_buf, global.chr_map[(_addr >> 10) & 7] | (_addr & 0x3FF), buffer_u8);
}
