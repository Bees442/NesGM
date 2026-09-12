function nes_bus_oam_dma(_page) {
    var _base = _page << 8;
    for (var _i = 0; _i < 256; _i++) {
        nes_ppu_oam_dma_byte(nes_cpu_read(_base + _i));
    }
    global.dma_extra_cycles += 513;
}
