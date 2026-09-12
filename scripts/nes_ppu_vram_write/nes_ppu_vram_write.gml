/// @function nes_ppu_vram_write(addr, value)
/// @description Writes a byte through the PPU's address space (see nes_ppu_vram_read).
function nes_ppu_vram_write(_addr, _value) {
    _addr &= 0x3FFF;
    _value &= 0xFF;
    if (_addr < 0x2000) {
        nes_cart_ppu_write(_addr, _value);
        return;
    }
    if (_addr < 0x3F00) {
        buffer_poke(global.ppu_nametable, nes_ppu_nt_offset(_addr), buffer_u8, _value);
        return;
    }
    var _p = _addr & 0x1F;
    if (_p == 0x10 || _p == 0x14 || _p == 0x18 || _p == 0x1C) _p -= 0x10;
    buffer_poke(global.ppu_palette, _p, buffer_u8, _value);
    global.ppu_palette_dirty = true;
}
