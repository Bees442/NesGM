/// @function nes_ppu_nt_offset(addr)
/// @description Maps a $2000-$2FFF nametable address to its physical offset (0-2047) in the console's 2KB VRAM.
function nes_ppu_nt_offset(_addr) {
    var _rel = _addr & 0x0FFF;
    return (nes_ppu_nt_bank((_rel >> 10) & 3) << 10) | (_rel & 0x03FF);
}
