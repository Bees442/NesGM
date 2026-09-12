function nes_cpu_write(_addr, _value) {
    _addr &= 0xFFFF;
    _value &= 0xFF;

    if (_addr < 0x2000) {
        buffer_poke(global.ram, _addr & 0x07FF, buffer_u8, _value);
        return;
    }
    if (_addr < 0x4000) {
        nes_ppu_reg_write(_addr & 0x0007, _value);
        return;
    }
    if (_addr <= 0x4013) {
        nes_apu_reg_write(_addr, _value);
        return;
    }
    if (_addr == 0x4014) {
        nes_bus_oam_dma(_value);
        return;
    }
    if (_addr == 0x4015) {
        nes_apu_reg_write(_addr, _value);
        return;
    }
    if (_addr == 0x4016) {
        nes_controller_write(_value);
        return;
    }
    if (_addr == 0x4017) {
        nes_apu_reg_write(_addr, _value);
        return;
    }
    if (_addr < 0x4020) {
        return;
    }
    nes_cart_cpu_write(_addr, _value);
}
