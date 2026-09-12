/// @function nes_ppu_vram_read(addr)
/// @description Reads a byte from the PPU's $0000-$3FFF space: pattern tables, mirrored nametables or palette RAM.
function nes_ppu_vram_read(_addr) {
    _addr &= 0x3FFF;
    if (_addr < 0x2000) {
        return nes_cart_ppu_read(_addr);
    }
    if (_addr < 0x3F00) {
        return buffer_peek(global.ppu_nametable, nes_ppu_nt_offset(_addr), buffer_u8);
    }
    var _p = _addr & 0x1F;
    if (_p == 0x10 || _p == 0x14 || _p == 0x18 || _p == 0x1C) _p -= 0x10;
    return buffer_peek(global.ppu_palette, _p, buffer_u8);
}
