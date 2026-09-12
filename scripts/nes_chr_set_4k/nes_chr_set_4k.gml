/// @function nes_chr_set_4k(slot4, bank4)
/// @description Points a 4KB PPU CHR window (slot4: 0 = $0000, 1 = $1000) at a 4KB bank.
function nes_chr_set_4k(_slot4, _bank4) {
    for (var _i = 0; _i < 4; _i++) nes_chr_set_1k(_slot4 * 4 + _i, _bank4 * 4 + _i);
}
