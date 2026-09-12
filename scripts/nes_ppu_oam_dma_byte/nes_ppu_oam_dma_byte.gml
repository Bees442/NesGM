/// @function nes_ppu_oam_dma_byte(value)
/// @description Writes one byte via OAM DMA (see nes_bus_oam_dma) at the current OAMADDR.
function nes_ppu_oam_dma_byte(_value) {
    buffer_poke(global.ppu_oam, global.ppu_oamaddr, buffer_u8, _value);
    global.ppu_oamaddr = (global.ppu_oamaddr + 1) & 0xFF;
}
