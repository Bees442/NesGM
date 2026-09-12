function nes_cart_cpu_write(_addr, _value) {
    if (_addr >= 0x8000) {
        nes_mapper_write(_addr, _value);
        return;
    }
    if (_addr >= 0x6000) {
        buffer_poke(global.prg_ram_buf, _addr - 0x6000, buffer_u8, _value & 0xFF);
        global.sram_dirty = true;
    }
}
