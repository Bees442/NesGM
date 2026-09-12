function nes_cpu_read(_addr) {
    _addr &= 0xFFFF;

    if (_addr < 0x2000) {
        return buffer_peek(global.ram, _addr & 0x07FF, buffer_u8);
    }
    if (_addr >= 0x8000) {
        return buffer_peek(global.prg_buf, global.prg_map[(_addr >> 13) & 3] | (_addr & 0x1FFF), buffer_u8);
    }
    if (_addr < 0x4000) {
        return nes_ppu_reg_read(_addr & 0x0007);
    }
    if (_addr == 0x4015) {
        return nes_apu_reg_read(_addr);
    }
    if (_addr == 0x4016) {
        return nes_controller_read(0);
    }
    if (_addr == 0x4017) {
        return nes_controller_read(1);
    }
    if (_addr < 0x4020) {
        return 0;
    }
    return nes_cart_cpu_read(_addr);
}
