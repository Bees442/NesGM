/// @function nes_ppu_copy_horizontal()
/// @description Copies the horizontal nametable bit and coarse X from t into v (dot 257).
function nes_ppu_copy_horizontal() {
    global.ppu_v = (global.ppu_v & 0xFBE0) | (global.ppu_t & 0x041F);
}
