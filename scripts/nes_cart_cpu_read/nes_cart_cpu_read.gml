function nes_cart_cpu_read(_addr) {
    if (_addr >= 0x8000) {
        return buffer_peek(global.prg_buf, global.prg_map[(_addr >> 13) & 3] | (_addr & 0x1FFF), buffer_u8);
    }
    if (_addr >= 0x6000) {
        return buffer_peek(global.prg_ram_buf, _addr - 0x6000, buffer_u8);
    }
    return 0;
}
