/// @function nes_ppu_copy_vertical()
/// @description Copies fine Y, the vertical nametable bit and coarse Y from t into v (dots 280-304 of pre-render).
function nes_ppu_copy_vertical() {
    global.ppu_v = (global.ppu_v & 0x841F) | (global.ppu_t & 0x7BE0);
}
