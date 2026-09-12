/// @function nes_ppu_nt_bank(nt_index)
/// @description Which physical 1KB nametable a logical one (0-3) resolves to under the current mirroring mode.
function nes_ppu_nt_bank(_nt_index) {
    switch (global.mirror_mode) {
        case NES_MIRROR_VERTICAL:    return _nt_index & 1;
        case NES_MIRROR_SINGLE_LOW:  return 0;
        case NES_MIRROR_SINGLE_HIGH: return 1;
        default:                     return (_nt_index >> 1) & 1;
    }
}
