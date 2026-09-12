/// @function nes_chr_set_8k(bank8)
/// @description Points the whole pattern-table range at one 8KB CHR bank.
function nes_chr_set_8k(_bank8) {
    for (var _i = 0; _i < 8; _i++) nes_chr_set_1k(_i, _bank8 * 8 + _i);
}
